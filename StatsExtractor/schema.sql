PGDMP         :    
            z            jrcstats_test    13.6    13.6 E    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            �           1262    1323341    jrcstats_test    DATABASE     b   CREATE DATABASE jrcstats_test WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'en_US.UTF-8';
    DROP DATABASE jrcstats_test;
                postgres    false            �           0    0    DATABASE jrcstats_test    ACL     2   GRANT ALL ON DATABASE jrcstats_test TO statsuser;
                   postgres    false    4533                        2615    1323342    tmp    SCHEMA        CREATE SCHEMA tmp;
    DROP SCHEMA tmp;
             	   statsuser    false                        3079    1323343    postgis 	   EXTENSION     ;   CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;
    DROP EXTENSION postgis;
                   false            �           0    0    EXTENSION postgis    COMMENT     ^   COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';
                        false    2                        3079    1324375    postgis_raster 	   EXTENSION     B   CREATE EXTENSION IF NOT EXISTS postgis_raster WITH SCHEMA public;
    DROP EXTENSION postgis_raster;
                   false    2            �           0    0    EXTENSION postgis_raster    COMMENT     M   COMMENT ON EXTENSION postgis_raster IS 'PostGIS raster types and functions';
                        false    3            �            1259    1324932    output_product    TABLE     �   CREATE TABLE public.output_product (
    id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    rel_file_path text,
    type text
);
 "   DROP TABLE public.output_product;
       public         heap    postgres    false            �            1259    1324938    output_product_id_seq    SEQUENCE     ~   CREATE SEQUENCE public.output_product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE public.output_product_id_seq;
       public          postgres    false    218            �           0    0    output_product_id_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE public.output_product_id_seq OWNED BY public.output_product.id;
          public          postgres    false    219            �            1259    1324940 
   poly_stats    TABLE     �  CREATE TABLE public.poly_stats (
    id bigint NOT NULL,
    poly_id bigint,
    product_file_id bigint NOT NULL,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now()),
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb
);
    DROP TABLE public.poly_stats;
       public         heap 	   statsuser    false            �            1259    1324947    poly_stats_id_seq    SEQUENCE     z   CREATE SEQUENCE public.poly_stats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.poly_stats_id_seq;
       public       	   statsuser    false    220            �           0    0    poly_stats_id_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE public.poly_stats_id_seq OWNED BY public.poly_stats.id;
          public       	   statsuser    false    221            �            1259    1324949    product    TABLE     P   CREATE TABLE public.product (
    id bigint NOT NULL,
    name text NOT NULL
);
    DROP TABLE public.product;
       public         heap    postgres    false            �            1259    1324955    product_file    TABLE     �   CREATE TABLE public.product_file (
    id bigint NOT NULL,
    product_description_id bigint,
    rel_file_path text,
    date timestamp without time zone,
    date_created timestamp without time zone
);
     DROP TABLE public.product_file;
       public         heap 	   statsuser    false            �            1259    1324961    product_file_description    TABLE     �  CREATE TABLE public.product_file_description (
    id bigint NOT NULL,
    pattern text NOT NULL,
    types text NOT NULL,
    create_date text NOT NULL,
    variable text,
    style text,
    description text,
    low_value double precision,
    mid_value double precision,
    high_value double precision,
    noval_colors jsonb,
    sparseval_colors jsonb,
    midval_colors jsonb,
    highval_colors jsonb,
    min_prod_value smallint,
    max_prod_value smallint,
    product_id bigint
);
 ,   DROP TABLE public.product_file_description;
       public         heap 	   statsuser    false            �            1259    1324967    product_file_id_seq    SEQUENCE     |   CREATE SEQUENCE public.product_file_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.product_file_id_seq;
       public       	   statsuser    false    223            �           0    0    product_file_id_seq    SEQUENCE OWNED BY     K   ALTER SEQUENCE public.product_file_id_seq OWNED BY public.product_file.id;
          public       	   statsuser    false    225            �            1259    1324969    product_id_seq    SEQUENCE     w   CREATE SEQUENCE public.product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public.product_id_seq;
       public       	   statsuser    false    224            �           0    0    product_id_seq    SEQUENCE OWNED BY     R   ALTER SEQUENCE public.product_id_seq OWNED BY public.product_file_description.id;
          public       	   statsuser    false    226            �            1259    1324971    product_id_seq1    SEQUENCE     x   CREATE SEQUENCE public.product_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.product_id_seq1;
       public          postgres    false    222            �           0    0    product_id_seq1    SEQUENCE OWNED BY     B   ALTER SEQUENCE public.product_id_seq1 OWNED BY public.product.id;
          public          postgres    false    227            �            1259    1324973    stratification    TABLE     m   CREATE TABLE public.stratification (
    id bigint NOT NULL,
    description text,
    tilelayer_url text
);
 "   DROP TABLE public.stratification;
       public         heap 	   statsuser    false            �            1259    1324979    stratification_geom    TABLE     �   CREATE TABLE public.stratification_geom (
    id bigint NOT NULL,
    stratification_id bigint NOT NULL,
    geom public.geometry(MultiPolygon,4326),
    geom3857 public.geometry(MultiPolygon,3857),
    metadata jsonb
);
 '   DROP TABLE public.stratification_geom;
       public         heap 	   statsuser    false    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2            �            1259    1324985    stratification_geom_id_seq    SEQUENCE     �   CREATE SEQUENCE public.stratification_geom_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE public.stratification_geom_id_seq;
       public       	   statsuser    false    229            �           0    0    stratification_geom_id_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE public.stratification_geom_id_seq OWNED BY public.stratification_geom.id;
          public       	   statsuser    false    230            �            1259    1324987    stratification_id_seq    SEQUENCE     ~   CREATE SEQUENCE public.stratification_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE public.stratification_id_seq;
       public       	   statsuser    false    228            �           0    0    stratification_id_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE public.stratification_id_seq OWNED BY public.stratification.id;
          public       	   statsuser    false    231            �           2604    1325044    output_product id    DEFAULT     v   ALTER TABLE ONLY public.output_product ALTER COLUMN id SET DEFAULT nextval('public.output_product_id_seq'::regclass);
 @   ALTER TABLE public.output_product ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    219    218            �           2604    1325045    poly_stats id    DEFAULT     n   ALTER TABLE ONLY public.poly_stats ALTER COLUMN id SET DEFAULT nextval('public.poly_stats_id_seq'::regclass);
 <   ALTER TABLE public.poly_stats ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    221    220            �           2604    1325046 
   product id    DEFAULT     i   ALTER TABLE ONLY public.product ALTER COLUMN id SET DEFAULT nextval('public.product_id_seq1'::regclass);
 9   ALTER TABLE public.product ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    227    222            �           2604    1325047    product_file id    DEFAULT     r   ALTER TABLE ONLY public.product_file ALTER COLUMN id SET DEFAULT nextval('public.product_file_id_seq'::regclass);
 >   ALTER TABLE public.product_file ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    225    223            �           2604    1325048    product_file_description id    DEFAULT     y   ALTER TABLE ONLY public.product_file_description ALTER COLUMN id SET DEFAULT nextval('public.product_id_seq'::regclass);
 J   ALTER TABLE public.product_file_description ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    226    224            �           2604    1325049    stratification id    DEFAULT     v   ALTER TABLE ONLY public.stratification ALTER COLUMN id SET DEFAULT nextval('public.stratification_id_seq'::regclass);
 @   ALTER TABLE public.stratification ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    231    228            �           2604    1325050    stratification_geom id    DEFAULT     �   ALTER TABLE ONLY public.stratification_geom ALTER COLUMN id SET DEFAULT nextval('public.stratification_geom_id_seq'::regclass);
 E   ALTER TABLE public.stratification_geom ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    230    229            �          0    1324932    output_product 
   TABLE DATA           R   COPY public.output_product (id, product_file_id, rel_file_path, type) FROM stdin;
    public          postgres    false    218   �j       �          0    1324940 
   poly_stats 
   TABLE DATA           �   COPY public.poly_stats (id, poly_id, product_file_id, noval_area_ha, sparse_area_ha, mid_area_ha, dense_area_ha, date_created, noval_color, sparseval_color, midval_color, highval_color, histogram) FROM stdin;
    public       	   statsuser    false    220   �j       �          0    1324949    product 
   TABLE DATA           +   COPY public.product (id, name) FROM stdin;
    public          postgres    false    222   �j       �          0    1324955    product_file 
   TABLE DATA           e   COPY public.product_file (id, product_description_id, rel_file_path, date, date_created) FROM stdin;
    public       	   statsuser    false    223   k       �          0    1324961    product_file_description 
   TABLE DATA           �   COPY public.product_file_description (id, pattern, types, create_date, variable, style, description, low_value, mid_value, high_value, noval_colors, sparseval_colors, midval_colors, highval_colors, min_prod_value, max_prod_value, product_id) FROM stdin;
    public       	   statsuser    false    224   4k       �          0    1323653    spatial_ref_sys 
   TABLE DATA           X   COPY public.spatial_ref_sys (srid, auth_name, auth_srid, srtext, proj4text) FROM stdin;
    public       	   statsuser    false    204   �z       �          0    1324973    stratification 
   TABLE DATA           H   COPY public.stratification (id, description, tilelayer_url) FROM stdin;
    public       	   statsuser    false    228   {       �          0    1324979    stratification_geom 
   TABLE DATA           ^   COPY public.stratification_geom (id, stratification_id, geom, geom3857, metadata) FROM stdin;
    public       	   statsuser    false    229   *{       �           0    0    output_product_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.output_product_id_seq', 1, false);
          public          postgres    false    219            �           0    0    poly_stats_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.poly_stats_id_seq', 1, false);
          public       	   statsuser    false    221            �           0    0    product_file_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.product_file_id_seq', 1, false);
          public       	   statsuser    false    225            �           0    0    product_id_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public.product_id_seq', 11, true);
          public       	   statsuser    false    226            �           0    0    product_id_seq1    SEQUENCE SET     =   SELECT pg_catalog.setval('public.product_id_seq1', 3, true);
          public          postgres    false    227            �           0    0    stratification_geom_id_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public.stratification_geom_id_seq', 1, false);
          public       	   statsuser    false    230            �           0    0    stratification_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.stratification_id_seq', 1, false);
          public       	   statsuser    false    231                       2606    1325000     output_product output_product_pk 
   CONSTRAINT     ^   ALTER TABLE ONLY public.output_product
    ADD CONSTRAINT output_product_pk PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.output_product DROP CONSTRAINT output_product_pk;
       public            postgres    false    218                       2606    1325002    poly_stats poly_stats_pk 
   CONSTRAINT     V   ALTER TABLE ONLY public.poly_stats
    ADD CONSTRAINT poly_stats_pk PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.poly_stats DROP CONSTRAINT poly_stats_pk;
       public         	   statsuser    false    220                       2606    1325004    poly_stats poly_stats_un 
   CONSTRAINT     g   ALTER TABLE ONLY public.poly_stats
    ADD CONSTRAINT poly_stats_un UNIQUE (poly_id, product_file_id);
 B   ALTER TABLE ONLY public.poly_stats DROP CONSTRAINT poly_stats_un;
       public         	   statsuser    false    220    220                       2606    1325006    product_file product_file_pk 
   CONSTRAINT     Z   ALTER TABLE ONLY public.product_file
    ADD CONSTRAINT product_file_pk PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.product_file DROP CONSTRAINT product_file_pk;
       public         	   statsuser    false    223            	           2606    1325008    product_file product_file_un 
   CONSTRAINT     x   ALTER TABLE ONLY public.product_file
    ADD CONSTRAINT product_file_un UNIQUE (product_description_id, rel_file_path);
 F   ALTER TABLE ONLY public.product_file DROP CONSTRAINT product_file_un;
       public         	   statsuser    false    223    223                       2606    1325010 #   product_file_description product_pk 
   CONSTRAINT     a   ALTER TABLE ONLY public.product_file_description
    ADD CONSTRAINT product_pk PRIMARY KEY (id);
 M   ALTER TABLE ONLY public.product_file_description DROP CONSTRAINT product_pk;
       public         	   statsuser    false    224                       2606    1325012     stratification stratification_pk 
   CONSTRAINT     ^   ALTER TABLE ONLY public.stratification
    ADD CONSTRAINT stratification_pk PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.stratification DROP CONSTRAINT stratification_pk;
       public         	   statsuser    false    228                       2606    1325014 '   stratification_geom stratification_pkey 
   CONSTRAINT     e   ALTER TABLE ONLY public.stratification_geom
    ADD CONSTRAINT stratification_pkey PRIMARY KEY (id);
 Q   ALTER TABLE ONLY public.stratification_geom DROP CONSTRAINT stratification_pkey;
       public         	   statsuser    false    229                       2606    1325016     stratification stratification_un 
   CONSTRAINT     b   ALTER TABLE ONLY public.stratification
    ADD CONSTRAINT stratification_un UNIQUE (description);
 J   ALTER TABLE ONLY public.stratification DROP CONSTRAINT stratification_un;
       public         	   statsuser    false    228                       1259    1325017    sidx_stratification_geom    INDEX     W   CREATE INDEX sidx_stratification_geom ON public.stratification_geom USING gist (geom);
 ,   DROP INDEX public.sidx_stratification_geom;
       public         	   statsuser    false    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    229                       1259    1325018    sidx_stratification_geom3857    INDEX     _   CREATE INDEX sidx_stratification_geom3857 ON public.stratification_geom USING gist (geom3857);
 0   DROP INDEX public.sidx_stratification_geom3857;
       public         	   statsuser    false    229    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2                       2606    1325019     output_product output_product_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.output_product
    ADD CONSTRAINT output_product_fk FOREIGN KEY (id) REFERENCES public.product_file(id) ON UPDATE CASCADE ON DELETE CASCADE;
 J   ALTER TABLE ONLY public.output_product DROP CONSTRAINT output_product_fk;
       public          postgres    false    223    4359    218                       2606    1325024 %   poly_stats poly_stats_product_file_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats
    ADD CONSTRAINT poly_stats_product_file_fk FOREIGN KEY (product_file_id) REFERENCES public.product_file(id) ON UPDATE CASCADE ON DELETE CASCADE;
 O   ALTER TABLE ONLY public.poly_stats DROP CONSTRAINT poly_stats_product_file_fk;
       public       	   statsuser    false    4359    220    223                       2606    1325029 ,   poly_stats poly_stats_stratification_geom_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats
    ADD CONSTRAINT poly_stats_stratification_geom_fk FOREIGN KEY (poly_id) REFERENCES public.stratification_geom(id) ON UPDATE CASCADE ON DELETE CASCADE;
 V   ALTER TABLE ONLY public.poly_stats DROP CONSTRAINT poly_stats_stratification_geom_fk;
       public       	   statsuser    false    4371    220    229                       2606    1325034    product_file product_file_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.product_file
    ADD CONSTRAINT product_file_fk FOREIGN KEY (product_description_id) REFERENCES public.product_file_description(id) ON UPDATE CASCADE ON DELETE CASCADE;
 F   ALTER TABLE ONLY public.product_file DROP CONSTRAINT product_file_fk;
       public       	   statsuser    false    4363    223    224                       2606    1325039 *   stratification_geom stratification_geom_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.stratification_geom
    ADD CONSTRAINT stratification_geom_fk FOREIGN KEY (stratification_id) REFERENCES public.stratification(id) ON DELETE CASCADE;
 T   ALTER TABLE ONLY public.stratification_geom DROP CONSTRAINT stratification_geom_fk;
       public       	   statsuser    false    229    4365    228            �      x������ � �      �      x������ � �      �   C   x�3�t��H,��s	�460�3�w��OJ��2�I�98��ar����CC�aR�T71F��� 2�3i      �      x������ � �      �   �  x��]sG���ů��܌g�ȓ��/cl��2�n�	"�*+BH���f��f7B�&��N�\M���V�TOfU?�/�_�]=���ӿ����ٳ�}���o�����?��/�>���7}�T�c:>�xz�����?�:x�����[�{�ּ�[vrW���~�}��˳�/������䐎��*������ÿ?��(~��g���ߜ��az�/�������rU�����������;w~����W������y^߹:��M��K>�e�7�x1�ܬ<�a�/�vnV�;,o`�����|�}��ʎ�n�.����������2�����&�]?���+��·�;_�٦l���6��?��������VD�T�����n�l׫lws�����cMW��޼�/�N�u��i����t~���<���m����2�����7y|��r��m������Ovq���x��^��wsqvq���j�.ߩ��_���|u����öߞ�/߬��:��O�oNˁ|��|���a���������;�(���}��M��7��D�}��M��7��D�}����n�(���
7Qaߨx�>D��N��p��}�S=�i�c��AO{�T{����z���G>�C��>������O�𧽏� ���J�ޛ ]	�H���1�0�u6��h$�9e;�����iӱ�*�5a�xvX%@#�y�a� 훰h;�����zӳ�*	�.��}BP	0H@��a� ��Θ��݄93����	�;o;�`���K��a� 㚰��O�*	�2p��*	=Y��a*	��X��a*	�|g٣��XՄ�a� L�'��l%��&l��!�V,0��,{�p�L:�eA�`]V&;vX%��	�e��`}{԰� L6�=j�J�&Fǿ��8�aQ9����8$��ڱ� W	p�	��=�J�C|�=�J�CB��=9� vM���C��8$ ��أ��8$ %�أ���Є�5\%�!}r�=jt��N5aޱO\�J@�)9��U:$`LC���J@g��ܱ����!c�:���U:ׄQ�5:��k�t���t�	3��Ѕ&�u�Ӄ���&��ؠ�J�WM���l�J��&,vl6}%�7��c��+�!��=� _	�-���X	�-ٳ	� �0y����І�Ay6����S��x$ Ƴ	����0��S]�j�:�& T�n¼g�N�L{B	��`���8�J@pMX�J���	�P	�	{B	 B66N�F�J�Ć���X	���	%VbC�h�X	���	%VbC��E6N�������8�J@lSdO(��!�q� �Z�ȞPH�kȑ)�b��`��I�h1�p�)��"bL5$d�)Pc�a!����1��P�cٓ)�c��!wi�:A�"�O�	�(2�0�Cb3A
$�j��)�'BQ��x�r��T4����r�̏*�O�w˧u1��7%�dC(��OӤ�
T��K��	�P�5.q�_p P�޸�ٞ=��c4�%���i�P�;.q��C�tC�z����tCE�*��i����bJ=��L��bz>d �I�T�^~P�[*rχD2�f���%q@�n��˫[�f�
��奍=��L蓧��T��P�Fy��@�	���K2��d�0�=b4xkRad��2�Y�L��T�Z&Ә�2��Gc�˄vyR%n�]Y@E�7�'&�L�a'�`��L�cJ2���X�4u�Q@3z�K�Y̈́�9��-8��L�s7��g��-wx��+q|fA7�mL�T�p&4�Y�8>���	�s�I'>� �	��XN\D�v&��c.q|fA<��q�ԂPPτ�y�K�Y�τ�y�yZp����?�!�ȟA@���%�T8��]^�9
HhB=�ǟACz�Q�����&4�#�����&t�C9��nG �	m�P.g#�Y�ф>zs��I �	�����̂�&t�Cʁ��.��&��C(q���4��|���ĩ�[�����]�Cj��M���'F�ӄvz0��5��&���8�����P*[�"PԄ���ل��h�����'F�Ԅ����|fAT��>�8>���	]u3y�����V�>+�y%�K���+q���5���]���3ʚ�Y����iMh�{=f��'�ք޺W�ȿ�@\��4�8>���	�uǁ���&��i(q|fA_��ԏ����h�S�&�M�S(q|fAbZ���"��#�M豓Â8ل&;����"Pل.;����C �lB�����c?Z�jB��h�8��sJ��iG?.��@jZ����	;�@������mB��0-�ån@E�C��b��mkt�a�n��9X�n;��_��m?$�ͩܶF���7�jp��v0CX���m<�an[���y���/kp�ݶ�$����i��[�5�m�nۇa�m�ܶF��ݠ���"P���w�kp�ݶ�A�����5��n�%q@��n�㯸���mw���趻���eܶF��u}�/���5����V�hp��vG}�nѸ0ݶ�z�_y�qi4�mWN�����h�,������]�-����]כ%q@�mg{�_�q�4�m�{�CӸLݶS�ZT�۶c��K�4.�F�m�4�jp�ݶ�e*[T�۶>��?ς��趭M���R���趭NqIP�n۪�kF5�m�n�����Y5�m�n���[T��619��]n[��6>Y��bn[��6.�q�5�mc�毠��5�m�-�*�m������m�!N���ܶF�]��趵�;���mk{~�����m��0-�*�m��h��,�m�n�r�&n[�ۦ!�߉��9�Nk�|��g
ݮ7������{�d�[w���ݻ�ŀ�m���AZ����R���@���������Cuxw���۫2 �?����jS�}ؔGTy�L�<쮷��K�W!n��7���ʗmm�ܒ_%o�J��ǻ��ٲ�6���3U�tS���;#m6��Ҷ��n_BW��`oeG]()�?|o��tK_X~w�����O��ѓMG�}ŭ�,��u�U����/uY��<zk�=��X�u�.��K�2K)��2K)��4J�,�GI�%+L�,��rG��YJ��k>��k¤�rg��YJ��0)��2�aRf)e�;.���R�,w�I���Y��2K)��&e�Rf�#L�,��rG��YJ��0)��2�aRf)e�s��R�,g�I���YΉ�2�)��'e�Rf9+N�,��rV��YJ��8)��2�YqRf)e����R�,g�I���YΊ�2K)��'e�Rf9'N�,O��rV��YJ��8)��2�YqRf)e����R�,g�I���YΊ�2K)��'e�Rf9+N�,���2��.Ӷ�mu1���W�}W?�|���zs��9�O�tv�fu�l�K^=J�i�no���������2�[Dm�!����ק����K������[����R���g?|��2�*�>y����x���xqO�r�ӣ�r���f�?4r^�n_�Rw��������S8��S8?����Q���
�Ni��&�����B�S�0i��&����#L8��sG�4pJ��/i���a��)�;¤�S8w�I�4p��Ni��&����#L8��sG�4pJ�8i���Yq��)�s⤁�D8g�I�4pΊ�Ni��'���9+N8��sV�4pJ�8i���Yq��)��⤁S8g�I�4pΉ��i��'���9+N8��sV�4pJ�8i���Yq��)��⤁S8g�I�4pΊ�Ni������m������G?>8z���o�����lN�ᗫͭ���߇K_U-���eŏz,�l�F���8���~�����ώoݺ����H�      �      x������ � �      �      x������ � �      �      x������ � �     