PGDMP     )    2        	        z            jrcstats_test    13.6    13.6 F    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            �           1262    503534    jrcstats_test    DATABASE     b   CREATE DATABASE jrcstats_test WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'en_US.UTF-8';
    DROP DATABASE jrcstats_test;
                postgres    false            �           0    0    DATABASE jrcstats_test    ACL     2   GRANT ALL ON DATABASE jrcstats_test TO statsuser;
                   postgres    false    4533            �           0    0    jrcstats_test    DATABASE PROPERTIES     O   ALTER DATABASE jrcstats_test SET search_path TO '$user', 'public', 'topology';
                     postgres    false                        2615    503535    tmp    SCHEMA        CREATE SCHEMA tmp;
    DROP SCHEMA tmp;
             	   statsuser    false                        3079    503536    postgis 	   EXTENSION     ;   CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;
    DROP EXTENSION postgis;
                   false            �           0    0    EXTENSION postgis    COMMENT     ^   COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';
                        false    2                        3079    514963    postgis_raster 	   EXTENSION     B   CREATE EXTENSION IF NOT EXISTS postgis_raster WITH SCHEMA public;
    DROP EXTENSION postgis_raster;
                   false    2            �           0    0    EXTENSION postgis_raster    COMMENT     M   COMMENT ON EXTENSION postgis_raster IS 'PostGIS raster types and functions';
                        false    3            �            1259    1312820    output_product    TABLE     �   CREATE TABLE public.output_product (
    id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    rel_file_path text,
    type text
);
 "   DROP TABLE public.output_product;
       public         heap    postgres    false            �            1259    1312818    output_product_id_seq    SEQUENCE     ~   CREATE SEQUENCE public.output_product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE public.output_product_id_seq;
       public          postgres    false    229            �           0    0    output_product_id_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE public.output_product_id_seq OWNED BY public.output_product.id;
          public          postgres    false    228            �            1259    504568 
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
       public         heap 	   statsuser    false            �            1259    504575    poly_stats_id_seq    SEQUENCE     z   CREATE SEQUENCE public.poly_stats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.poly_stats_id_seq;
       public       	   statsuser    false    208            �           0    0    poly_stats_id_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE public.poly_stats_id_seq OWNED BY public.poly_stats.id;
          public       	   statsuser    false    209            �            1259    1312839    product    TABLE     P   CREATE TABLE public.product (
    id bigint NOT NULL,
    name text NOT NULL
);
    DROP TABLE public.product;
       public         heap    postgres    false            �            1259    504583    product_file    TABLE     �   CREATE TABLE public.product_file (
    id bigint NOT NULL,
    product_description_id bigint,
    rel_file_path text,
    date timestamp without time zone,
    date_created timestamp without time zone
);
     DROP TABLE public.product_file;
       public         heap 	   statsuser    false            �            1259    504577    product_file_description    TABLE     �  CREATE TABLE public.product_file_description (
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
       public         heap 	   statsuser    false            �            1259    504589    product_file_id_seq    SEQUENCE     |   CREATE SEQUENCE public.product_file_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.product_file_id_seq;
       public       	   statsuser    false    211            �           0    0    product_file_id_seq    SEQUENCE OWNED BY     K   ALTER SEQUENCE public.product_file_id_seq OWNED BY public.product_file.id;
          public       	   statsuser    false    212            �            1259    504591    product_id_seq    SEQUENCE     w   CREATE SEQUENCE public.product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public.product_id_seq;
       public       	   statsuser    false    210            �           0    0    product_id_seq    SEQUENCE OWNED BY     R   ALTER SEQUENCE public.product_id_seq OWNED BY public.product_file_description.id;
          public       	   statsuser    false    213            �            1259    1312837    product_id_seq1    SEQUENCE     x   CREATE SEQUENCE public.product_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.product_id_seq1;
       public          postgres    false    231            �           0    0    product_id_seq1    SEQUENCE OWNED BY     B   ALTER SEQUENCE public.product_id_seq1 OWNED BY public.product.id;
          public          postgres    false    230            �            1259    504593    stratification    TABLE     m   CREATE TABLE public.stratification (
    id bigint NOT NULL,
    description text,
    tilelayer_url text
);
 "   DROP TABLE public.stratification;
       public         heap 	   statsuser    false            �            1259    504599    stratification_geom    TABLE     �   CREATE TABLE public.stratification_geom (
    id bigint NOT NULL,
    stratification_id bigint NOT NULL,
    geom public.geometry(MultiPolygon,4326),
    geom3857 public.geometry(MultiPolygon,3857),
    metadata jsonb
);
 '   DROP TABLE public.stratification_geom;
       public         heap 	   statsuser    false    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2            �            1259    504605    stratification_geom_id_seq    SEQUENCE     �   CREATE SEQUENCE public.stratification_geom_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE public.stratification_geom_id_seq;
       public       	   statsuser    false    215            �           0    0    stratification_geom_id_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE public.stratification_geom_id_seq OWNED BY public.stratification_geom.id;
          public       	   statsuser    false    216            �            1259    504607    stratification_id_seq    SEQUENCE     ~   CREATE SEQUENCE public.stratification_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE public.stratification_id_seq;
       public       	   statsuser    false    214            �           0    0    stratification_id_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE public.stratification_id_seq OWNED BY public.stratification.id;
          public       	   statsuser    false    217            �           2604    1312823    output_product id    DEFAULT     v   ALTER TABLE ONLY public.output_product ALTER COLUMN id SET DEFAULT nextval('public.output_product_id_seq'::regclass);
 @   ALTER TABLE public.output_product ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    229    228    229            �           2604    504609    poly_stats id    DEFAULT     n   ALTER TABLE ONLY public.poly_stats ALTER COLUMN id SET DEFAULT nextval('public.poly_stats_id_seq'::regclass);
 <   ALTER TABLE public.poly_stats ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    209    208            �           2604    1312842 
   product id    DEFAULT     i   ALTER TABLE ONLY public.product ALTER COLUMN id SET DEFAULT nextval('public.product_id_seq1'::regclass);
 9   ALTER TABLE public.product ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    230    231    231            �           2604    504611    product_file id    DEFAULT     r   ALTER TABLE ONLY public.product_file ALTER COLUMN id SET DEFAULT nextval('public.product_file_id_seq'::regclass);
 >   ALTER TABLE public.product_file ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    212    211            �           2604    504610    product_file_description id    DEFAULT     y   ALTER TABLE ONLY public.product_file_description ALTER COLUMN id SET DEFAULT nextval('public.product_id_seq'::regclass);
 J   ALTER TABLE public.product_file_description ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    213    210            �           2604    504612    stratification id    DEFAULT     v   ALTER TABLE ONLY public.stratification ALTER COLUMN id SET DEFAULT nextval('public.stratification_id_seq'::regclass);
 @   ALTER TABLE public.stratification ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    217    214            �           2604    504613    stratification_geom id    DEFAULT     �   ALTER TABLE ONLY public.stratification_geom ALTER COLUMN id SET DEFAULT nextval('public.stratification_geom_id_seq'::regclass);
 E   ALTER TABLE public.stratification_geom ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    216    215            �          0    1312820    output_product 
   TABLE DATA           R   COPY public.output_product (id, product_file_id, rel_file_path, type) FROM stdin;
    public          postgres    false    229   Jk       �          0    504568 
   poly_stats 
   TABLE DATA           �   COPY public.poly_stats (id, poly_id, product_file_id, noval_area_ha, sparse_area_ha, mid_area_ha, dense_area_ha, date_created, noval_color, sparseval_color, midval_color, highval_color, histogram) FROM stdin;
    public       	   statsuser    false    208   gk       �          0    1312839    product 
   TABLE DATA           +   COPY public.product (id, name) FROM stdin;
    public          postgres    false    231   �k       �          0    504583    product_file 
   TABLE DATA           e   COPY public.product_file (id, product_description_id, rel_file_path, date, date_created) FROM stdin;
    public       	   statsuser    false    211   �k       �          0    504577    product_file_description 
   TABLE DATA           �   COPY public.product_file_description (id, pattern, types, create_date, variable, style, description, low_value, mid_value, high_value, noval_colors, sparseval_colors, midval_colors, highval_colors, min_prod_value, max_prod_value, product_id) FROM stdin;
    public       	   statsuser    false    210   �k       �          0    503846    spatial_ref_sys 
   TABLE DATA           X   COPY public.spatial_ref_sys (srid, auth_name, auth_srid, srtext, proj4text) FROM stdin;
    public          postgres    false    204   �{       �          0    504593    stratification 
   TABLE DATA           H   COPY public.stratification (id, description, tilelayer_url) FROM stdin;
    public       	   statsuser    false    214   �{       �          0    504599    stratification_geom 
   TABLE DATA           ^   COPY public.stratification_geom (id, stratification_id, geom, geom3857, metadata) FROM stdin;
    public       	   statsuser    false    215   �{       �           0    0    output_product_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.output_product_id_seq', 1, false);
          public          postgres    false    228            �           0    0    poly_stats_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.poly_stats_id_seq', 1, false);
          public       	   statsuser    false    209            �           0    0    product_file_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.product_file_id_seq', 1, false);
          public       	   statsuser    false    212            �           0    0    product_id_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public.product_id_seq', 11, true);
          public       	   statsuser    false    213            �           0    0    product_id_seq1    SEQUENCE SET     =   SELECT pg_catalog.setval('public.product_id_seq1', 3, true);
          public          postgres    false    230            �           0    0    stratification_geom_id_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public.stratification_geom_id_seq', 1, false);
          public       	   statsuser    false    216            �           0    0    stratification_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.stratification_id_seq', 1, false);
          public       	   statsuser    false    217                       2606    1312828     output_product output_product_pk 
   CONSTRAINT     ^   ALTER TABLE ONLY public.output_product
    ADD CONSTRAINT output_product_pk PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.output_product DROP CONSTRAINT output_product_pk;
       public            postgres    false    229                       2606    504615    poly_stats poly_stats_pk 
   CONSTRAINT     V   ALTER TABLE ONLY public.poly_stats
    ADD CONSTRAINT poly_stats_pk PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.poly_stats DROP CONSTRAINT poly_stats_pk;
       public         	   statsuser    false    208                       2606    504617    poly_stats poly_stats_un 
   CONSTRAINT     g   ALTER TABLE ONLY public.poly_stats
    ADD CONSTRAINT poly_stats_un UNIQUE (poly_id, product_file_id);
 B   ALTER TABLE ONLY public.poly_stats DROP CONSTRAINT poly_stats_un;
       public         	   statsuser    false    208    208                       2606    504619    product_file product_file_pk 
   CONSTRAINT     Z   ALTER TABLE ONLY public.product_file
    ADD CONSTRAINT product_file_pk PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.product_file DROP CONSTRAINT product_file_pk;
       public         	   statsuser    false    211            	           2606    504621    product_file product_file_un 
   CONSTRAINT     x   ALTER TABLE ONLY public.product_file
    ADD CONSTRAINT product_file_un UNIQUE (product_description_id, rel_file_path);
 F   ALTER TABLE ONLY public.product_file DROP CONSTRAINT product_file_un;
       public         	   statsuser    false    211    211                       2606    504623 #   product_file_description product_pk 
   CONSTRAINT     a   ALTER TABLE ONLY public.product_file_description
    ADD CONSTRAINT product_pk PRIMARY KEY (id);
 M   ALTER TABLE ONLY public.product_file_description DROP CONSTRAINT product_pk;
       public         	   statsuser    false    210                       2606    504625     stratification stratification_pk 
   CONSTRAINT     ^   ALTER TABLE ONLY public.stratification
    ADD CONSTRAINT stratification_pk PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.stratification DROP CONSTRAINT stratification_pk;
       public         	   statsuser    false    214                       2606    504627 '   stratification_geom stratification_pkey 
   CONSTRAINT     e   ALTER TABLE ONLY public.stratification_geom
    ADD CONSTRAINT stratification_pkey PRIMARY KEY (id);
 Q   ALTER TABLE ONLY public.stratification_geom DROP CONSTRAINT stratification_pkey;
       public         	   statsuser    false    215                       2606    504629     stratification stratification_un 
   CONSTRAINT     b   ALTER TABLE ONLY public.stratification
    ADD CONSTRAINT stratification_un UNIQUE (description);
 J   ALTER TABLE ONLY public.stratification DROP CONSTRAINT stratification_un;
       public         	   statsuser    false    214                       1259    504630    sidx_stratification_geom    INDEX     W   CREATE INDEX sidx_stratification_geom ON public.stratification_geom USING gist (geom);
 ,   DROP INDEX public.sidx_stratification_geom;
       public         	   statsuser    false    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    215                       1259    504631    sidx_stratification_geom3857    INDEX     _   CREATE INDEX sidx_stratification_geom3857 ON public.stratification_geom USING gist (geom3857);
 0   DROP INDEX public.sidx_stratification_geom3857;
       public         	   statsuser    false    215    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2                       2606    1312829     output_product output_product_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.output_product
    ADD CONSTRAINT output_product_fk FOREIGN KEY (id) REFERENCES public.product_file(id) ON UPDATE CASCADE ON DELETE CASCADE;
 J   ALTER TABLE ONLY public.output_product DROP CONSTRAINT output_product_fk;
       public          postgres    false    4359    229    211                       2606    504632 %   poly_stats poly_stats_product_file_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats
    ADD CONSTRAINT poly_stats_product_file_fk FOREIGN KEY (product_file_id) REFERENCES public.product_file(id) ON UPDATE CASCADE ON DELETE CASCADE;
 O   ALTER TABLE ONLY public.poly_stats DROP CONSTRAINT poly_stats_product_file_fk;
       public       	   statsuser    false    4359    211    208                       2606    504637 ,   poly_stats poly_stats_stratification_geom_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats
    ADD CONSTRAINT poly_stats_stratification_geom_fk FOREIGN KEY (poly_id) REFERENCES public.stratification_geom(id) ON UPDATE CASCADE ON DELETE CASCADE;
 V   ALTER TABLE ONLY public.poly_stats DROP CONSTRAINT poly_stats_stratification_geom_fk;
       public       	   statsuser    false    208    215    4369                       2606    504642    product_file product_file_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.product_file
    ADD CONSTRAINT product_file_fk FOREIGN KEY (product_description_id) REFERENCES public.product_file_description(id) ON UPDATE CASCADE ON DELETE CASCADE;
 F   ALTER TABLE ONLY public.product_file DROP CONSTRAINT product_file_fk;
       public       	   statsuser    false    4357    211    210                       2606    1312974 *   stratification_geom stratification_geom_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.stratification_geom
    ADD CONSTRAINT stratification_geom_fk FOREIGN KEY (stratification_id) REFERENCES public.stratification(id) ON DELETE CASCADE;
 T   ALTER TABLE ONLY public.stratification_geom DROP CONSTRAINT stratification_geom_fk;
       public       	   statsuser    false    4363    214    215            �      x������ � �      �      x������ � �      �   ?   x�3�t��H,��s	�460�3�w��OJ��2�I�98��ar����CC�aR1z\\\ �	      �      x������ � �      �   �  x��]s�6����_ѥ���Z2>�eM�'���$Y����$�DU���I�.��E�dᅝ�yػ7S'�8I7���� d?�K�˟Ϯ^����_�R/�����ξ�j�o���/���_�}���o���>V�t|>���|}w�|u�N�?zG����;��~��}�6�=x����V��˫Ӌ�C:V��|>\���?����wG���?�8�t��,����|�(_���������W'���ׯ�߻��o�_���?�^��������ޤo��~y��_v��������{6�������{��X���*_n�����ʎ�o_�.����������2�����&7ݼ���k��އ�{_�٦l���1��?�W������VD�T���_���_��(��ܼ��M�ڇW�պ��W�������p�m��%��糧�,����h�����Loo��d��M�^����F������Ovq����~�Gz��\�]\�-�^��O����t�&_����a�o�חoW��&��O�oOˉ|��|���a����dc�ч�xQtE�F��(�o���2�F��(�o���r�Fu�QݾQ�6��n�¾Q�6*�}��ӝ�?������z����<Փ��>멞���yO�ħ��|��>�}�S=�iﳟ��O{��T��	Е �7��� k{c�a0��&l4�V	�H�s�8vX%@#�Ӧc�U�k¬��J�F��&��*�7a�$vX%@#���g�U4]6���`���)3��*	H�1�V	0�	sfb����w�*vX%� C�,��*�5a��_�U0ve�`�U0z��Q�T����Q�T0�βG[	��	6��*��O�=�J��M�h�C��X `"?Y�d���t ��l%��&�Lv�J�&:�5l%��&,:��a+�l�{԰� L.���U	p
âr�W	pH@�cA��tf{r� ���{r� ��{rp우��� W	pH@�ٱGW	pH@JʱGW	p�	3�=j�J�C��{��*�j¼c_�t��	Rr�!��tH����=u���4a�cA]%�C�^u�Q��t�	��=jt�!Pׄ�zW	�|f:6�]%�M��ؗ]%��MXױA�� ��0߱��� OMX��l�J�o�S���W|C@�{6��[F�����[�g�+�%`��y�����l|%�7ڳ�:_	�H@�g*A5aֳ��P	Ԅu�M@�݄yϞ�B% �&,��*�6a1�q
�����>�'�P	]66N�|6��@�&l
l�B% 4�*�'�X	�#6N�F�J�Ć��6N�F�J�Ć���l�b% 6�!�EQ% 6�1�q����0�ȞPb% 6�Cd�A����=��B%�2�#(R �TK�ٓ
)�b�� SdCE
ĘjH�:�'R��T�B6�)�c����ǲ'R��T�C��u
�L5Dd��)Pd�a"��f�H2�P�SbO2��M�4�>�hT15q��T�-�6�-�
���Kܔؓ�0Fc<M�J|*P�3.qԳ'Bi�ָę~�3 @z�g{��C(���8׳�Bu������c�S��S�c�e��C�����)���2醊i����D&�RQnx�q@�n��=2ɤ��b������.G���*�&�C{� :��'Oi��a���ˉ��A):�ɗ8>d ��4Fa�{��h��"����#
�eB�<�ǿ� �L�1keD�� �	��J܂�����/o�O�L���<N~�<���<�8>d ����i�\��f&��9�8>� �	Ms�[p}���5�n��Ϭ�G��yW��̂n&�<u7�Ŀ� �Lh��.q|fA9:�L�N|fA:Z�\..���L��\��̂x&4��0�7���	��ؗ8>� �	����n�3�CΑ?1��&4У�K>�p�(*P1���s�Єz�%�?1��&�У���'Mh�G�=��1M袇ry��܎@F����F>���	}�0�����@H��1�%M複���])Mh��P��#hiB/=����S��hC�����4��l��O� �	��`��k=M�*q��5��T�|=D��	u��	�*�R�c��O���	=u?d��̂�&4�}*q|fAU��>f���d5���}V|�J�. }W��#kBcݻrc�g�5���M��3Қ�Z�z�|�O��	�u�Ƒ���&4�i*q|fA]��4���yMh��P��̂�&�ש˩Ǐ*�`�8&�C4
��a�P��̂�&����"��#�M豓Â8ل&;���"Pل.;����C �lB�����c?Z�jB��h�8��sJ��iG?.x�@jZ����;�@������mB��0-�ån@E�C�?b��mkt�a�n��9X�n;��_��m?$�éܶF����jp��v0CX���m<�an[���y���/kp�ݶ�$����i��G�5�m�nۇa�c�ܶF��ݠ���"P���O�kp�ݶ�A����5��n�%q@��n�㯸���mw���趻���eܶF��u}�/���5����V�hp��vG}�nѸ0ݶ�z�_y�qi4�mW.�����h�_,������]�-����]כ%q@�mg{�_�q�4�m�{�CӸLݶS�ZT�۶c��K�4.�F�m�4�jp�ݶ�e*[T�۶>��?ς��趭M���R���趭NqIP�n۪�kF5�m�n�����Y5�m�n���[T��619��]n[��6>Y��bn[��6.�q�5�mc�毠��5�m�-�*�m������m�!N���ܶF�]��趵�;���mk{~�����m��0-�*�m��h��,�m�n�r�&n[�ۦ!�?���9�Ik޼~�3�n7`��K;���l{�����������\=J����Q�?^��r]R���?�;xw���K;{wU����]m
^�/��*�	����ֺ�b��*�ͫ�zc��|������#��U������ݙ-n3�y;S%�L7%:ں3�f�JI!m������G{+;�BI���{S�<=�;����?=|R~�GO�m:*��+n�e���6_u��_��.��ˣw���M��;������YJ���YJ��QRf9?J�,YaRf)e�;¤�R�,w���-_&e�;ä�R�,w�I���Y��2K)��q�%e�Rf�#L�,��rG��YJ��0)��2�aRf)e�;¤�R�,w�I���Y��2K)��'e�Rf9+N�,��rN��Y�H��8)��2�YqRf)e����R�,g�I���YΊ�2K)��'e�Rf9+N�,��rV��YJ��8)��2�9qRfy"e����R�,g�I���YΊ�2K)��'e�Rf9+N�,��rV��YJ��8)��2�YqRf)e��Y~w��l��i��������闋������/y}:������e�_��IO�v{c�_���M�y�@߉m�!����χ������_�}��R�?�i�|�μ��i�T����_�������t�����Q=~��e��ģ�z�������'?���������� o�i�I��ۿ�����-T�B�-T�B?�����Q��
��Pi�&m����0i�&m���#L�B�-tG���J[��/i���a�*m�;¤-T�Bw�I[������Pi�&m���#L�B�-tG���J[�8i���Yq�*m�s�-�D�Bg�I[���Ί��Pi�'m��:+N�B�-tV���J[�8i���Yq�*m���-T�Bg�I[���Ή���i�'m��:+N�B�-tV���J[�8i���Yq�*m���-T�Bg�I[���Ί��Pi��-��m������'?>:z���o���H~����U��N������ң����֋�;w��/p�E�      �      x������ � �      �      x������ � �      �      x������ � �     