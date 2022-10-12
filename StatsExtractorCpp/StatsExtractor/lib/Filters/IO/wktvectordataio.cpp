#include "wktvectordataio.hxx"


using namespace otb;

//public
void WKTVectorDataIO::AppendData(std::string wkt, size_t id) {
    this->wktGeoms.emplace_back(std::pair<std::string, size_t>(wkt,id));
}

void WKTVectorDataIO::AppendData(std::vector<std::pair<std::string, std::size_t>>& wktVector) {
    this->wktGeoms.insert(this->wktGeoms.end(), wktVector.begin(), wktVector.end());
}

bool WKTVectorDataIO::CanReadFile(const char*) const {
    return true;
}

LabelSetPtr WKTVectorDataIO::GetLabels() {
    return this->validPolyIds;
}

OGREnvelope WKTVectorDataIO::GetOutEnevelope() {
    return this->outEnvelope;
}


void WKTVectorDataIO::Read(itk::DataObject* datag) {
    VectorDataPointerType data = dynamic_cast<VectorDataType*>(datag);
    // Destroy previous opened data source

    if (!data) {
        itkExceptionMacro(<< "Failed to dynamic cast to otb::VectorData (this should never happen)");
    }

    otbMsgDebugMacro(<< "Driver to read: OGR");

    // Retrieving root node
    DataTreePointerType tree = data->GetDataTree();
    DataNodePointerType root = tree->GetRoot()->Get();

    OGRSpatialReferencePtr oSRS = std::make_unique<OGRSpatialReference>();
    oSRS->importFromEPSG(epsg);

    std::string projectionRef;
    if (oSRS != nullptr) {
        char* projectionRefChar;
        oSRS->exportToWkt(&projectionRefChar);
        projectionRef = projectionRefChar;
        CPLFree(projectionRefChar);
        itk::MetaDataDictionary& dict = data->GetMetaDataDictionary();
        itk::EncapsulateMetaData<std::string>(dict, MetaDataKey::ProjectionRefKey, projectionRef);
    }
    else {
        otbMsgDevMacro(<< "Can't retrieve the OGRSpatialReference from the shapefile");
    }

    std::string projectionRefWkt = data->GetProjectionRef();

    bool projectionInformationAvailable = !projectionRefWkt.empty();

    if (projectionInformationAvailable) {
        otbMsgDevMacro(<< "Projection information : " << projectionRefWkt);
    }
    else {
        otbMsgDevMacro(<< "Projection information unavailable: assuming WGS84");
    }

    GDALDriver *ogrdrv= GetGDALDriverManager()->GetDriverByName("MEMORY");

    GDALDatasetPtr dataset  = GDALDatasetPtr (ogrdrv->Create( "tmp.shp", 0, 0, 0, GDT_Unknown, nullptr ), GDALClose);

    OGRLayer *layer ;
    layer = dataset->CreateLayer("tmpLayer", oSRS.get(), this->geomType);

    OGRGeometryPtr geom = OGRGeometryPtr(new OGRPoint(), OGRGeometryFactory::destroyGeometry);
    if (this->geomType == wkbMultiPolygon)
        geom = OGRGeometryPtr(new OGRMultiPolygon(), OGRGeometryFactory::destroyGeometry);
    else if (this->geomType == wkbPolygon)
        geom = OGRGeometryPtr(new OGRPolygon(), OGRGeometryFactory::destroyGeometry);

    OGRFieldDefn oField(idField.c_str(), OFTInteger64);
    layer->CreateField(&oField);

    for (std::pair<std::string, size_t>& wktGeom: wktGeoms) {
        OGRFeaturePtr outFt(OGRFeature::CreateFeature(layer->GetLayerDefn()), OGRFeature::DestroyFeature);

        std::unique_ptr<const char*> k = std::make_unique<const char*>(const_cast<char*>(wktGeom.first.c_str()));

        outFt->SetField(idField.c_str(), static_cast<int>(wktGeom.second));
        geom->importFromWkt(k.get());
        //std::cout <<geom->exportToJson() <<"\n";

        OGREnvelope envlp;
        geom->getEnvelope(&envlp);

        //skipping geometries if empty or outside maximum envelope
        if (geom->IsEmpty()) {
                std::cout << "Polygon with id: " << wktGeom.second <<" is empty. Skipping\n";
                continue;
        }

        if ((!maxEnvelope.Intersects(envlp))) {
            std::cout << "Polygon with id: " << wktGeom.second <<" falls outside of specified bounds. Skipping\n";
            continue;
        }


        outFt->SetGeometry(geom.get());

        if (layer->CreateFeature(outFt.get()) != OGRERR_NONE) {
            std::cout << "Unable to Create Feature!!!\n";
            continue;
        }

        validPolyIds->emplace_back(wktGeom.second);
        outEnvelope.Merge(envlp);
    }

    if (layer->GetFeatureCount() > 0) {
        //cropping outEnvelope with maxEnvelope to ensure that the resulting region is within bounds
        outEnvelope.Intersect(maxEnvelope);

        DataNodePointerType document = DataNodeType::New();
        document->SetNodeType(DOCUMENT);
        document->SetNodeId(layer->GetLayerDefn()->GetName());
        tree->Add(document, root);

        /// This is not good but we do not have the choice if we want to
        /// get a hook on the internal structure
        InternalTreeNodeType* documentPtr = const_cast<InternalTreeNodeType*>(tree->GetNode(document));

        OGRIOHelper::Pointer OGRConversion = OGRIOHelper::New();
        OGRConversion->ConvertOGRLayerToDataTreeNode(layer, documentPtr);
        data->SetProjectionRef(projectionRef);

        point2d originPnt;
        originPnt[0] = outEnvelope.MinX;
        originPnt[1] = outEnvelope.MaxY;

        data->SetOrigin(originPnt);
        layer = nullptr;
    }
    wktGeoms.clear();
};

void WKTVectorDataIO::SetGeometryMetaData(int epsg, OGRwkbGeometryType type, std::string idField) {
    this->epsg = epsg;
    this->geomType = type;
    this->idField = idField;
}


//protected
WKTVectorDataIO::WKTVectorDataIO():epsg(4326), idField("id"), geomType(wkbPolygon){
    outEnvelope.MinX = outEnvelope.MinY = maxEnvelope.MaxX = maxEnvelope.MaxY = DBL_MAX;
    outEnvelope.MaxX = outEnvelope.MaxY = maxEnvelope.MinX = maxEnvelope.MinY = -DBL_MAX;

    maxEnvelopePoly = envelopeToGeometry(maxEnvelope);

    validPolyIds = std::make_shared<LabelSet>();

};
