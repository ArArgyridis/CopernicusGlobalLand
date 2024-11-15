<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" version="1.0.0" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc" xmlns:sld="http://www.opengis.net/sld">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>NDVI300V2_LTCAD_2020-07-01_2020-07-11</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="values">
              <sld:ColorMapEntry quantity="0" label="0" color="#d7191c"/>
              <sld:ColorMapEntry quantity="1" label="1" color="#f07c4a"/>
              <sld:ColorMapEntry quantity="2" label="2" color="#fec981"/>
              <sld:ColorMapEntry quantity="3" label="3" color="#ffffc0"/>
              <sld:ColorMapEntry quantity="4" label="4" color="#c4e687"/>
              <sld:ColorMapEntry quantity="5" label="5" color="#77c35c"/>
              <sld:ColorMapEntry quantity="6" label="6" color="#1a9641"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>
