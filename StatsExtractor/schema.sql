PGDMP                         z            jrcstats_test    13.6    13.6 �    )           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            *           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            +           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            ,           1262    1330396    jrcstats_test    DATABASE     b   CREATE DATABASE jrcstats_test WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'en_US.UTF-8';
    DROP DATABASE jrcstats_test;
                postgres    false            -           0    0    SCHEMA pg_catalog    ACL     -   GRANT ALL ON SCHEMA pg_catalog TO statsuser;
                   postgres    false    4            .           0    0    SCHEMA public    ACL     )   GRANT ALL ON SCHEMA public TO statsuser;
                   postgres    false    5                        2615    1330397    tmp    SCHEMA        CREATE SCHEMA tmp;
    DROP SCHEMA tmp;
             	   statsuser    false                        3079    1330398    postgis 	   EXTENSION     ;   CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;
    DROP EXTENSION postgis;
                   false            /           0    0    EXTENSION postgis    COMMENT     ^   COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';
                        false    2                        3079    1331430    postgis_raster 	   EXTENSION     B   CREATE EXTENSION IF NOT EXISTS postgis_raster WITH SCHEMA public;
    DROP EXTENSION postgis_raster;
                   false    2            0           0    0    EXTENSION postgis_raster    COMMENT     M   COMMENT ON EXTENSION postgis_raster IS 'PostGIS raster types and functions';
                        false    3            1           0    0    TABLE pg_aggregate    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_aggregate TO statsuser;
       
   pg_catalog          postgres    false    24            2           0    0    TABLE pg_am    ACL     2   GRANT ALL ON TABLE pg_catalog.pg_am TO statsuser;
       
   pg_catalog          postgres    false    25            3           0    0    TABLE pg_amop    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_amop TO statsuser;
       
   pg_catalog          postgres    false    26            4           0    0    TABLE pg_amproc    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_amproc TO statsuser;
       
   pg_catalog          postgres    false    27            5           0    0    TABLE pg_attrdef    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_attrdef TO statsuser;
       
   pg_catalog          postgres    false    28            6           0    0    TABLE pg_attribute    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_attribute TO statsuser;
       
   pg_catalog          postgres    false    13            7           0    0    TABLE pg_auth_members    ACL     <   GRANT ALL ON TABLE pg_catalog.pg_auth_members TO statsuser;
       
   pg_catalog          postgres    false    17            8           0    0    TABLE pg_authid    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_authid TO statsuser;
       
   pg_catalog          postgres    false    16            9           0    0 %   TABLE pg_available_extension_versions    ACL     L   GRANT ALL ON TABLE pg_catalog.pg_available_extension_versions TO statsuser;
       
   pg_catalog          postgres    false    88            :           0    0    TABLE pg_available_extensions    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_available_extensions TO statsuser;
       
   pg_catalog          postgres    false    87            ;           0    0    TABLE pg_cast    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_cast TO statsuser;
       
   pg_catalog          postgres    false    29            <           0    0    TABLE pg_class    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_class TO statsuser;
       
   pg_catalog          postgres    false    15            =           0    0    TABLE pg_collation    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_collation TO statsuser;
       
   pg_catalog          postgres    false    54            >           0    0    TABLE pg_config    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_config TO statsuser;
       
   pg_catalog          postgres    false    97            ?           0    0    TABLE pg_constraint    ACL     :   GRANT ALL ON TABLE pg_catalog.pg_constraint TO statsuser;
       
   pg_catalog          postgres    false    30            @           0    0    TABLE pg_conversion    ACL     :   GRANT ALL ON TABLE pg_catalog.pg_conversion TO statsuser;
       
   pg_catalog          postgres    false    31            A           0    0    TABLE pg_cursors    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_cursors TO statsuser;
       
   pg_catalog          postgres    false    86            B           0    0    TABLE pg_database    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_database TO statsuser;
       
   pg_catalog          postgres    false    18            C           0    0    TABLE pg_db_role_setting    ACL     ?   GRANT ALL ON TABLE pg_catalog.pg_db_role_setting TO statsuser;
       
   pg_catalog          postgres    false    45            D           0    0    TABLE pg_default_acl    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_default_acl TO statsuser;
       
   pg_catalog          postgres    false    9            E           0    0    TABLE pg_depend    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_depend TO statsuser;
       
   pg_catalog          postgres    false    32            F           0    0    TABLE pg_description    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_description TO statsuser;
       
   pg_catalog          postgres    false    33            G           0    0    TABLE pg_enum    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_enum TO statsuser;
       
   pg_catalog          postgres    false    56            H           0    0    TABLE pg_event_trigger    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_event_trigger TO statsuser;
       
   pg_catalog          postgres    false    55            I           0    0    TABLE pg_extension    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_extension TO statsuser;
       
   pg_catalog          postgres    false    47            J           0    0    TABLE pg_file_settings    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_file_settings TO statsuser;
       
   pg_catalog          postgres    false    93            K           0    0    TABLE pg_foreign_data_wrapper    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_foreign_data_wrapper TO statsuser;
       
   pg_catalog          postgres    false    22            L           0    0    TABLE pg_foreign_server    ACL     >   GRANT ALL ON TABLE pg_catalog.pg_foreign_server TO statsuser;
       
   pg_catalog          postgres    false    19            M           0    0    TABLE pg_foreign_table    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_foreign_table TO statsuser;
       
   pg_catalog          postgres    false    48            N           0    0    TABLE pg_group    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_group TO statsuser;
       
   pg_catalog          postgres    false    73            O           0    0    TABLE pg_hba_file_rules    ACL     >   GRANT ALL ON TABLE pg_catalog.pg_hba_file_rules TO statsuser;
       
   pg_catalog          postgres    false    94            P           0    0    TABLE pg_index    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_index TO statsuser;
       
   pg_catalog          postgres    false    34            Q           0    0    TABLE pg_indexes    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_indexes TO statsuser;
       
   pg_catalog          postgres    false    80            R           0    0    TABLE pg_inherits    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_inherits TO statsuser;
       
   pg_catalog          postgres    false    35            S           0    0    TABLE pg_init_privs    ACL     :   GRANT ALL ON TABLE pg_catalog.pg_init_privs TO statsuser;
       
   pg_catalog          postgres    false    52            T           0    0    TABLE pg_language    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_language TO statsuser;
       
   pg_catalog          postgres    false    36            U           0    0    TABLE pg_largeobject    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_largeobject TO statsuser;
       
   pg_catalog          postgres    false    37            V           0    0    TABLE pg_largeobject_metadata    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_largeobject_metadata TO statsuser;
       
   pg_catalog          postgres    false    46            W           0    0    TABLE pg_locks    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_locks TO statsuser;
       
   pg_catalog          postgres    false    85            X           0    0    TABLE pg_matviews    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_matviews TO statsuser;
       
   pg_catalog          postgres    false    79            Y           0    0    TABLE pg_namespace    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_namespace TO statsuser;
       
   pg_catalog          postgres    false    38            Z           0    0    TABLE pg_opclass    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_opclass TO statsuser;
       
   pg_catalog          postgres    false    39            [           0    0    TABLE pg_operator    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_operator TO statsuser;
       
   pg_catalog          postgres    false    40            \           0    0    TABLE pg_opfamily    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_opfamily TO statsuser;
       
   pg_catalog          postgres    false    44            ]           0    0    TABLE pg_partitioned_table    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_partitioned_table TO statsuser;
       
   pg_catalog          postgres    false    50            ^           0    0    TABLE pg_policies    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_policies TO statsuser;
       
   pg_catalog          postgres    false    75            _           0    0    TABLE pg_policy    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_policy TO statsuser;
       
   pg_catalog          postgres    false    49            `           0    0    TABLE pg_prepared_statements    ACL     C   GRANT ALL ON TABLE pg_catalog.pg_prepared_statements TO statsuser;
       
   pg_catalog          postgres    false    90            a           0    0    TABLE pg_prepared_xacts    ACL     >   GRANT ALL ON TABLE pg_catalog.pg_prepared_xacts TO statsuser;
       
   pg_catalog          postgres    false    89            b           0    0    TABLE pg_proc    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_proc TO statsuser;
       
   pg_catalog          postgres    false    14            c           0    0    TABLE pg_publication    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_publication TO statsuser;
       
   pg_catalog          postgres    false    69            d           0    0    TABLE pg_publication_rel    ACL     ?   GRANT ALL ON TABLE pg_catalog.pg_publication_rel TO statsuser;
       
   pg_catalog          postgres    false    70            e           0    0    TABLE pg_publication_tables    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_publication_tables TO statsuser;
       
   pg_catalog          postgres    false    84            f           0    0    TABLE pg_range    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_range TO statsuser;
       
   pg_catalog          postgres    false    57            g           0    0    TABLE pg_replication_origin    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_replication_origin TO statsuser;
       
   pg_catalog          postgres    false    66            h           0    0 "   TABLE pg_replication_origin_status    ACL     I   GRANT ALL ON TABLE pg_catalog.pg_replication_origin_status TO statsuser;
       
   pg_catalog          postgres    false    137            i           0    0    TABLE pg_replication_slots    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_replication_slots TO statsuser;
       
   pg_catalog          postgres    false    124            j           0    0    TABLE pg_rewrite    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_rewrite TO statsuser;
       
   pg_catalog          postgres    false    41            k           0    0    TABLE pg_roles    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_roles TO statsuser;
       
   pg_catalog          postgres    false    71            l           0    0    TABLE pg_rules    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_rules TO statsuser;
       
   pg_catalog          postgres    false    76            m           0    0    TABLE pg_seclabel    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_seclabel TO statsuser;
       
   pg_catalog          postgres    false    60            n           0    0    TABLE pg_seclabels    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_seclabels TO statsuser;
       
   pg_catalog          postgres    false    91            o           0    0    TABLE pg_sequence    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_sequence TO statsuser;
       
   pg_catalog          postgres    false    21            p           0    0    TABLE pg_sequences    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_sequences TO statsuser;
       
   pg_catalog          postgres    false    81            q           0    0    TABLE pg_settings    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_settings TO statsuser;
       
   pg_catalog          postgres    false    92            r           0    0    TABLE pg_shadow    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_shadow TO statsuser;
       
   pg_catalog          postgres    false    72            s           0    0    TABLE pg_shdepend    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_shdepend TO statsuser;
       
   pg_catalog          postgres    false    11            t           0    0    TABLE pg_shdescription    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_shdescription TO statsuser;
       
   pg_catalog          postgres    false    23            u           0    0    TABLE pg_shmem_allocations    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_shmem_allocations TO statsuser;
       
   pg_catalog          postgres    false    98            v           0    0    TABLE pg_shseclabel    ACL     :   GRANT ALL ON TABLE pg_catalog.pg_shseclabel TO statsuser;
       
   pg_catalog          postgres    false    59            w           0    0    TABLE pg_stat_activity    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_stat_activity TO statsuser;
       
   pg_catalog          postgres    false    117            x           0    0    TABLE pg_stat_all_indexes    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_stat_all_indexes TO statsuser;
       
   pg_catalog          postgres    false    108            y           0    0    TABLE pg_stat_all_tables    ACL     ?   GRANT ALL ON TABLE pg_catalog.pg_stat_all_tables TO statsuser;
       
   pg_catalog          postgres    false    99            z           0    0    TABLE pg_stat_archiver    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_stat_archiver TO statsuser;
       
   pg_catalog          postgres    false    129            {           0    0    TABLE pg_stat_bgwriter    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_stat_bgwriter TO statsuser;
       
   pg_catalog          postgres    false    130            |           0    0    TABLE pg_stat_database    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_stat_database TO statsuser;
       
   pg_catalog          postgres    false    125            }           0    0     TABLE pg_stat_database_conflicts    ACL     G   GRANT ALL ON TABLE pg_catalog.pg_stat_database_conflicts TO statsuser;
       
   pg_catalog          postgres    false    126            ~           0    0    TABLE pg_stat_gssapi    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_stat_gssapi TO statsuser;
       
   pg_catalog          postgres    false    123                       0    0    TABLE pg_stat_progress_analyze    ACL     E   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_analyze TO statsuser;
       
   pg_catalog          postgres    false    131            �           0    0 !   TABLE pg_stat_progress_basebackup    ACL     H   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_basebackup TO statsuser;
       
   pg_catalog          postgres    false    135            �           0    0    TABLE pg_stat_progress_cluster    ACL     E   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_cluster TO statsuser;
       
   pg_catalog          postgres    false    133            �           0    0 #   TABLE pg_stat_progress_create_index    ACL     J   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_create_index TO statsuser;
       
   pg_catalog          postgres    false    134            �           0    0    TABLE pg_stat_progress_vacuum    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_vacuum TO statsuser;
       
   pg_catalog          postgres    false    132            �           0    0    TABLE pg_stat_replication    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_stat_replication TO statsuser;
       
   pg_catalog          postgres    false    118            �           0    0    TABLE pg_stat_slru    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_stat_slru TO statsuser;
       
   pg_catalog          postgres    false    119            �           0    0    TABLE pg_stat_ssl    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_stat_ssl TO statsuser;
       
   pg_catalog          postgres    false    122            �           0    0    TABLE pg_stat_subscription    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_stat_subscription TO statsuser;
       
   pg_catalog          postgres    false    121            �           0    0    TABLE pg_stat_sys_indexes    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_stat_sys_indexes TO statsuser;
       
   pg_catalog          postgres    false    109            �           0    0    TABLE pg_stat_sys_tables    ACL     ?   GRANT ALL ON TABLE pg_catalog.pg_stat_sys_tables TO statsuser;
       
   pg_catalog          postgres    false    101            �           0    0    TABLE pg_stat_user_functions    ACL     C   GRANT ALL ON TABLE pg_catalog.pg_stat_user_functions TO statsuser;
       
   pg_catalog          postgres    false    127            �           0    0    TABLE pg_stat_user_indexes    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_stat_user_indexes TO statsuser;
       
   pg_catalog          postgres    false    110            �           0    0    TABLE pg_stat_user_tables    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_stat_user_tables TO statsuser;
       
   pg_catalog          postgres    false    103            �           0    0    TABLE pg_stat_wal_receiver    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_stat_wal_receiver TO statsuser;
       
   pg_catalog          postgres    false    120            �           0    0    TABLE pg_stat_xact_all_tables    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_stat_xact_all_tables TO statsuser;
       
   pg_catalog          postgres    false    100            �           0    0    TABLE pg_stat_xact_sys_tables    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_stat_xact_sys_tables TO statsuser;
       
   pg_catalog          postgres    false    102            �           0    0 !   TABLE pg_stat_xact_user_functions    ACL     H   GRANT ALL ON TABLE pg_catalog.pg_stat_xact_user_functions TO statsuser;
       
   pg_catalog          postgres    false    128            �           0    0    TABLE pg_stat_xact_user_tables    ACL     E   GRANT ALL ON TABLE pg_catalog.pg_stat_xact_user_tables TO statsuser;
       
   pg_catalog          postgres    false    104            �           0    0    TABLE pg_statio_all_indexes    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_statio_all_indexes TO statsuser;
       
   pg_catalog          postgres    false    111            �           0    0    TABLE pg_statio_all_sequences    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_statio_all_sequences TO statsuser;
       
   pg_catalog          postgres    false    114            �           0    0    TABLE pg_statio_all_tables    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_statio_all_tables TO statsuser;
       
   pg_catalog          postgres    false    105            �           0    0    TABLE pg_statio_sys_indexes    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_statio_sys_indexes TO statsuser;
       
   pg_catalog          postgres    false    112            �           0    0    TABLE pg_statio_sys_sequences    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_statio_sys_sequences TO statsuser;
       
   pg_catalog          postgres    false    115            �           0    0    TABLE pg_statio_sys_tables    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_statio_sys_tables TO statsuser;
       
   pg_catalog          postgres    false    106            �           0    0    TABLE pg_statio_user_indexes    ACL     C   GRANT ALL ON TABLE pg_catalog.pg_statio_user_indexes TO statsuser;
       
   pg_catalog          postgres    false    113            �           0    0    TABLE pg_statio_user_sequences    ACL     E   GRANT ALL ON TABLE pg_catalog.pg_statio_user_sequences TO statsuser;
       
   pg_catalog          postgres    false    116            �           0    0    TABLE pg_statio_user_tables    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_statio_user_tables TO statsuser;
       
   pg_catalog          postgres    false    107            �           0    0    TABLE pg_statistic    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_statistic TO statsuser;
       
   pg_catalog          postgres    false    42            �           0    0    TABLE pg_statistic_ext    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_statistic_ext TO statsuser;
       
   pg_catalog          postgres    false    51            �           0    0    TABLE pg_statistic_ext_data    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_statistic_ext_data TO statsuser;
       
   pg_catalog          postgres    false    53            �           0    0    TABLE pg_stats    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_stats TO statsuser;
       
   pg_catalog          postgres    false    82            �           0    0    TABLE pg_stats_ext    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_stats_ext TO statsuser;
       
   pg_catalog          postgres    false    83            �           0    0    TABLE pg_subscription    ACL     <   GRANT ALL ON TABLE pg_catalog.pg_subscription TO statsuser;
       
   pg_catalog          postgres    false    67            �           0    0    TABLE pg_subscription_rel    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_subscription_rel TO statsuser;
       
   pg_catalog          postgres    false    68            �           0    0    TABLE pg_tables    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_tables TO statsuser;
       
   pg_catalog          postgres    false    78            �           0    0    TABLE pg_tablespace    ACL     :   GRANT ALL ON TABLE pg_catalog.pg_tablespace TO statsuser;
       
   pg_catalog          postgres    false    10            �           0    0    TABLE pg_timezone_abbrevs    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_timezone_abbrevs TO statsuser;
       
   pg_catalog          postgres    false    95            �           0    0    TABLE pg_timezone_names    ACL     >   GRANT ALL ON TABLE pg_catalog.pg_timezone_names TO statsuser;
       
   pg_catalog          postgres    false    96            �           0    0    TABLE pg_transform    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_transform TO statsuser;
       
   pg_catalog          postgres    false    58            �           0    0    TABLE pg_trigger    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_trigger TO statsuser;
       
   pg_catalog          postgres    false    43            �           0    0    TABLE pg_ts_config    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_ts_config TO statsuser;
       
   pg_catalog          postgres    false    63            �           0    0    TABLE pg_ts_config_map    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_ts_config_map TO statsuser;
       
   pg_catalog          postgres    false    64            �           0    0    TABLE pg_ts_dict    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_ts_dict TO statsuser;
       
   pg_catalog          postgres    false    61            �           0    0    TABLE pg_ts_parser    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_ts_parser TO statsuser;
       
   pg_catalog          postgres    false    62            �           0    0    TABLE pg_ts_template    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_ts_template TO statsuser;
       
   pg_catalog          postgres    false    65            �           0    0    TABLE pg_type    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_type TO statsuser;
       
   pg_catalog          postgres    false    12            �           0    0    TABLE pg_user    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_user TO statsuser;
       
   pg_catalog          postgres    false    74            �           0    0    TABLE pg_user_mapping    ACL     <   GRANT ALL ON TABLE pg_catalog.pg_user_mapping TO statsuser;
       
   pg_catalog          postgres    false    20            �           0    0    TABLE pg_user_mappings    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_user_mappings TO statsuser;
       
   pg_catalog          postgres    false    136            �           0    0    TABLE pg_views    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_views TO statsuser;
       
   pg_catalog          postgres    false    77            �           0    0    TABLE geography_columns    ACL     :   GRANT ALL ON TABLE public.geography_columns TO statsuser;
          public          postgres    false    206            �           0    0    TABLE geometry_columns    ACL     9   GRANT ALL ON TABLE public.geometry_columns TO statsuser;
          public          postgres    false    207            �            1259    1331987    output_product    TABLE     �   CREATE TABLE public.output_product (
    id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    rel_file_path text,
    type text
);
 "   DROP TABLE public.output_product;
       public         heap    postgres    false            �           0    0    TABLE output_product    ACL     7   GRANT ALL ON TABLE public.output_product TO statsuser;
          public          postgres    false    218            �            1259    1331993    output_product_id_seq    SEQUENCE     ~   CREATE SEQUENCE public.output_product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE public.output_product_id_seq;
       public          postgres    false    218            �           0    0    output_product_id_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE public.output_product_id_seq OWNED BY public.output_product.id;
          public          postgres    false    219            �           0    0    SEQUENCE output_product_id_seq    ACL     A   GRANT ALL ON SEQUENCE public.output_product_id_seq TO statsuser;
          public          postgres    false    219            �            1259    1331995 
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
       public         heap 	   statsuser    false            �            1259    1332002    poly_stats_id_seq    SEQUENCE     z   CREATE SEQUENCE public.poly_stats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.poly_stats_id_seq;
       public       	   statsuser    false    220            �           0    0    poly_stats_id_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE public.poly_stats_id_seq OWNED BY public.poly_stats.id;
          public       	   statsuser    false    221            �            1259    1332004    product    TABLE     P   CREATE TABLE public.product (
    id bigint NOT NULL,
    name text NOT NULL
);
    DROP TABLE public.product;
       public         heap    postgres    false            �           0    0    TABLE product    ACL     0   GRANT ALL ON TABLE public.product TO statsuser;
          public          postgres    false    222            �            1259    1332010    product_file    TABLE     �   CREATE TABLE public.product_file (
    id bigint NOT NULL,
    product_description_id bigint,
    rel_file_path text,
    date timestamp without time zone,
    date_created timestamp without time zone
);
     DROP TABLE public.product_file;
       public         heap 	   statsuser    false            �            1259    1332016    product_file_description    TABLE     �  CREATE TABLE public.product_file_description (
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
       public         heap 	   statsuser    false            �            1259    1332022    product_file_id_seq    SEQUENCE     |   CREATE SEQUENCE public.product_file_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.product_file_id_seq;
       public       	   statsuser    false    223            �           0    0    product_file_id_seq    SEQUENCE OWNED BY     K   ALTER SEQUENCE public.product_file_id_seq OWNED BY public.product_file.id;
          public       	   statsuser    false    225            �            1259    1332024    product_id_seq    SEQUENCE     w   CREATE SEQUENCE public.product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public.product_id_seq;
       public       	   statsuser    false    224            �           0    0    product_id_seq    SEQUENCE OWNED BY     R   ALTER SEQUENCE public.product_id_seq OWNED BY public.product_file_description.id;
          public       	   statsuser    false    226            �            1259    1332026    product_id_seq1    SEQUENCE     x   CREATE SEQUENCE public.product_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.product_id_seq1;
       public          postgres    false    222            �           0    0    product_id_seq1    SEQUENCE OWNED BY     B   ALTER SEQUENCE public.product_id_seq1 OWNED BY public.product.id;
          public          postgres    false    227            �           0    0    SEQUENCE product_id_seq1    ACL     ;   GRANT ALL ON SEQUENCE public.product_id_seq1 TO statsuser;
          public          postgres    false    227            �           0    0    TABLE raster_columns    ACL     7   GRANT ALL ON TABLE public.raster_columns TO statsuser;
          public          postgres    false    216            �           0    0    TABLE raster_overviews    ACL     9   GRANT ALL ON TABLE public.raster_overviews TO statsuser;
          public          postgres    false    217            �           0    0    TABLE spatial_ref_sys    ACL     8   GRANT ALL ON TABLE public.spatial_ref_sys TO statsuser;
          public          postgres    false    204            �            1259    1332028    stratification    TABLE     m   CREATE TABLE public.stratification (
    id bigint NOT NULL,
    description text,
    tilelayer_url text
);
 "   DROP TABLE public.stratification;
       public         heap 	   statsuser    false            �            1259    1332034    stratification_geom    TABLE     �   CREATE TABLE public.stratification_geom (
    id bigint NOT NULL,
    stratification_id bigint NOT NULL,
    geom public.geometry(MultiPolygon,4326),
    geom3857 public.geometry(MultiPolygon,3857),
    metadata jsonb
);
 '   DROP TABLE public.stratification_geom;
       public         heap 	   statsuser    false    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2            �            1259    1332040    stratification_geom_id_seq    SEQUENCE     �   CREATE SEQUENCE public.stratification_geom_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE public.stratification_geom_id_seq;
       public       	   statsuser    false    229            �           0    0    stratification_geom_id_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE public.stratification_geom_id_seq OWNED BY public.stratification_geom.id;
          public       	   statsuser    false    230            �            1259    1332042    stratification_id_seq    SEQUENCE     ~   CREATE SEQUENCE public.stratification_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE public.stratification_id_seq;
       public       	   statsuser    false    228            �           0    0    stratification_id_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE public.stratification_id_seq OWNED BY public.stratification.id;
          public       	   statsuser    false    231            �           2604    1332044    output_product id    DEFAULT     v   ALTER TABLE ONLY public.output_product ALTER COLUMN id SET DEFAULT nextval('public.output_product_id_seq'::regclass);
 @   ALTER TABLE public.output_product ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    219    218            �           2604    1332045    poly_stats id    DEFAULT     n   ALTER TABLE ONLY public.poly_stats ALTER COLUMN id SET DEFAULT nextval('public.poly_stats_id_seq'::regclass);
 <   ALTER TABLE public.poly_stats ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    221    220            �           2604    1332046 
   product id    DEFAULT     i   ALTER TABLE ONLY public.product ALTER COLUMN id SET DEFAULT nextval('public.product_id_seq1'::regclass);
 9   ALTER TABLE public.product ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    227    222            �           2604    1332047    product_file id    DEFAULT     r   ALTER TABLE ONLY public.product_file ALTER COLUMN id SET DEFAULT nextval('public.product_file_id_seq'::regclass);
 >   ALTER TABLE public.product_file ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    225    223            �           2604    1332048    product_file_description id    DEFAULT     y   ALTER TABLE ONLY public.product_file_description ALTER COLUMN id SET DEFAULT nextval('public.product_id_seq'::regclass);
 J   ALTER TABLE public.product_file_description ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    226    224            �           2604    1332049    stratification id    DEFAULT     v   ALTER TABLE ONLY public.stratification ALTER COLUMN id SET DEFAULT nextval('public.stratification_id_seq'::regclass);
 @   ALTER TABLE public.stratification ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    231    228            �           2604    1332050    stratification_geom id    DEFAULT     �   ALTER TABLE ONLY public.stratification_geom ALTER COLUMN id SET DEFAULT nextval('public.stratification_geom_id_seq'::regclass);
 E   ALTER TABLE public.stratification_geom ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    230    229                      0    1331987    output_product 
   TABLE DATA           R   COPY public.output_product (id, product_file_id, rel_file_path, type) FROM stdin;
    public          postgres    false    218   ��                 0    1331995 
   poly_stats 
   TABLE DATA           �   COPY public.poly_stats (id, poly_id, product_file_id, noval_area_ha, sparse_area_ha, mid_area_ha, dense_area_ha, date_created, noval_color, sparseval_color, midval_color, highval_color, histogram) FROM stdin;
    public       	   statsuser    false    220   �                 0    1332004    product 
   TABLE DATA           +   COPY public.product (id, name) FROM stdin;
    public          postgres    false    222   !�                 0    1332010    product_file 
   TABLE DATA           e   COPY public.product_file (id, product_description_id, rel_file_path, date, date_created) FROM stdin;
    public       	   statsuser    false    223   p�                 0    1332016    product_file_description 
   TABLE DATA           �   COPY public.product_file_description (id, pattern, types, create_date, variable, style, description, low_value, mid_value, high_value, noval_colors, sparseval_colors, midval_colors, highval_colors, min_prod_value, max_prod_value, product_id) FROM stdin;
    public       	   statsuser    false    224   ��       �          0    1330708    spatial_ref_sys 
   TABLE DATA           X   COPY public.spatial_ref_sys (srid, auth_name, auth_srid, srtext, proj4text) FROM stdin;
    public          postgres    false    204   I�       #          0    1332028    stratification 
   TABLE DATA           H   COPY public.stratification (id, description, tilelayer_url) FROM stdin;
    public       	   statsuser    false    228   f�       $          0    1332034    stratification_geom 
   TABLE DATA           ^   COPY public.stratification_geom (id, stratification_id, geom, geom3857, metadata) FROM stdin;
    public       	   statsuser    false    229   ��       �           0    0    output_product_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.output_product_id_seq', 1, false);
          public          postgres    false    219            �           0    0    poly_stats_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.poly_stats_id_seq', 1, false);
          public       	   statsuser    false    221            �           0    0    product_file_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.product_file_id_seq', 1, false);
          public       	   statsuser    false    225            �           0    0    product_id_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public.product_id_seq', 11, true);
          public       	   statsuser    false    226            �           0    0    product_id_seq1    SEQUENCE SET     =   SELECT pg_catalog.setval('public.product_id_seq1', 3, true);
          public          postgres    false    227            �           0    0    stratification_geom_id_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public.stratification_geom_id_seq', 1, false);
          public       	   statsuser    false    230            �           0    0    stratification_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.stratification_id_seq', 1, false);
          public       	   statsuser    false    231            u           2606    1332055     output_product output_product_pk 
   CONSTRAINT     ^   ALTER TABLE ONLY public.output_product
    ADD CONSTRAINT output_product_pk PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.output_product DROP CONSTRAINT output_product_pk;
       public            postgres    false    218            w           2606    1332057    poly_stats poly_stats_pk 
   CONSTRAINT     V   ALTER TABLE ONLY public.poly_stats
    ADD CONSTRAINT poly_stats_pk PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.poly_stats DROP CONSTRAINT poly_stats_pk;
       public         	   statsuser    false    220            y           2606    1332059    poly_stats poly_stats_un 
   CONSTRAINT     g   ALTER TABLE ONLY public.poly_stats
    ADD CONSTRAINT poly_stats_un UNIQUE (poly_id, product_file_id);
 B   ALTER TABLE ONLY public.poly_stats DROP CONSTRAINT poly_stats_un;
       public         	   statsuser    false    220    220            }           2606    1332061    product_file product_file_pk 
   CONSTRAINT     Z   ALTER TABLE ONLY public.product_file
    ADD CONSTRAINT product_file_pk PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.product_file DROP CONSTRAINT product_file_pk;
       public         	   statsuser    false    223                       2606    1332063    product_file product_file_un 
   CONSTRAINT     x   ALTER TABLE ONLY public.product_file
    ADD CONSTRAINT product_file_un UNIQUE (product_description_id, rel_file_path);
 F   ALTER TABLE ONLY public.product_file DROP CONSTRAINT product_file_un;
       public         	   statsuser    false    223    223            �           2606    1332065 #   product_file_description product_pk 
   CONSTRAINT     a   ALTER TABLE ONLY public.product_file_description
    ADD CONSTRAINT product_pk PRIMARY KEY (id);
 M   ALTER TABLE ONLY public.product_file_description DROP CONSTRAINT product_pk;
       public         	   statsuser    false    224            {           2606    1332110    product product_pk1 
   CONSTRAINT     Q   ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_pk1 PRIMARY KEY (id);
 =   ALTER TABLE ONLY public.product DROP CONSTRAINT product_pk1;
       public            postgres    false    222            �           2606    1332067     stratification stratification_pk 
   CONSTRAINT     ^   ALTER TABLE ONLY public.stratification
    ADD CONSTRAINT stratification_pk PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.stratification DROP CONSTRAINT stratification_pk;
       public         	   statsuser    false    228            �           2606    1332069 '   stratification_geom stratification_pkey 
   CONSTRAINT     e   ALTER TABLE ONLY public.stratification_geom
    ADD CONSTRAINT stratification_pkey PRIMARY KEY (id);
 Q   ALTER TABLE ONLY public.stratification_geom DROP CONSTRAINT stratification_pkey;
       public         	   statsuser    false    229            �           2606    1332071     stratification stratification_un 
   CONSTRAINT     b   ALTER TABLE ONLY public.stratification
    ADD CONSTRAINT stratification_un UNIQUE (description);
 J   ALTER TABLE ONLY public.stratification DROP CONSTRAINT stratification_un;
       public         	   statsuser    false    228            �           1259    1332072    sidx_stratification_geom    INDEX     W   CREATE INDEX sidx_stratification_geom ON public.stratification_geom USING gist (geom);
 ,   DROP INDEX public.sidx_stratification_geom;
       public         	   statsuser    false    229    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2            �           1259    1332073    sidx_stratification_geom3857    INDEX     _   CREATE INDEX sidx_stratification_geom3857 ON public.stratification_geom USING gist (geom3857);
 0   DROP INDEX public.sidx_stratification_geom3857;
       public         	   statsuser    false    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    229            �           2606    1332074     output_product output_product_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.output_product
    ADD CONSTRAINT output_product_fk FOREIGN KEY (id) REFERENCES public.product_file(id) ON UPDATE CASCADE ON DELETE CASCADE;
 J   ALTER TABLE ONLY public.output_product DROP CONSTRAINT output_product_fk;
       public          postgres    false    223    4477    218            �           2606    1332079 %   poly_stats poly_stats_product_file_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats
    ADD CONSTRAINT poly_stats_product_file_fk FOREIGN KEY (product_file_id) REFERENCES public.product_file(id) ON UPDATE CASCADE ON DELETE CASCADE;
 O   ALTER TABLE ONLY public.poly_stats DROP CONSTRAINT poly_stats_product_file_fk;
       public       	   statsuser    false    220    223    4477            �           2606    1332084 ,   poly_stats poly_stats_stratification_geom_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats
    ADD CONSTRAINT poly_stats_stratification_geom_fk FOREIGN KEY (poly_id) REFERENCES public.stratification_geom(id) ON UPDATE CASCADE ON DELETE CASCADE;
 V   ALTER TABLE ONLY public.poly_stats DROP CONSTRAINT poly_stats_stratification_geom_fk;
       public       	   statsuser    false    220    4489    229            �           2606    1332111 4   product_file_description product_file_description_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.product_file_description
    ADD CONSTRAINT product_file_description_fk FOREIGN KEY (product_id) REFERENCES public.product(id) ON UPDATE CASCADE ON DELETE CASCADE;
 ^   ALTER TABLE ONLY public.product_file_description DROP CONSTRAINT product_file_description_fk;
       public       	   statsuser    false    222    4475    224            �           2606    1332089    product_file product_file_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.product_file
    ADD CONSTRAINT product_file_fk FOREIGN KEY (product_description_id) REFERENCES public.product_file_description(id) ON UPDATE CASCADE ON DELETE CASCADE;
 F   ALTER TABLE ONLY public.product_file DROP CONSTRAINT product_file_fk;
       public       	   statsuser    false    4481    224    223            �           2606    1332094 *   stratification_geom stratification_geom_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.stratification_geom
    ADD CONSTRAINT stratification_geom_fk FOREIGN KEY (stratification_id) REFERENCES public.stratification(id) ON DELETE CASCADE;
 T   ALTER TABLE ONLY public.stratification_geom DROP CONSTRAINT stratification_geom_fk;
       public       	   statsuser    false    228    229    4483                  x������ � �            x������ � �         ?   x�3�t��H,��s	�460�3�w��OJ��2�I�98��ar����CC�aR1z\\\ �	            x������ � �         �  x��]sG���ů��܌g�ȓ��/cl��2�n�	"�*+BH���f��f7B�&��N�\M���V�TOfU?�/�_�]=���ӿ����ٳ�}���o�����?��/�>���7}�T�c:>�xz�����?�:x�����[�{�ּ�[vrW���~�}��˳�/������䐎��*������ÿ?��(~��g���ߜ��az�/�������rU�����������;w~����W������y^߹:��M��K>�e�7�x1�ܬ<�a�/�vnV�;,o`�����|�}��ʎ�n�.����������2�����&�]?���+��·�;_�٦l���6��?��������VD�T�����n�l׫lws�����cMW��޼�/�N�u��i����t~���<���m����2�����7y|��r��m������Ovq���x��^��wsqvq���j�.ߩ��_���|u����öߞ�/߬��:��O�oNˁ|��|���a���������;�(���}��M��7��D�}��M��7��D�}����n�(���
7Qaߨx�>D��N��p��}�S=�i�c��AO{�T{����z���G>�C��>������O�𧽏� ���J�ޛ ]	�H���1�0�u6��h$�9e;�����iӱ�*�5a�xvX%@#�y�a� 훰h;�����zӳ�*	�.��}BP	0H@��a� ��Θ��݄93����	�;o;�`���K��a� 㚰��O�*	�2p��*	=Y��a*	��X��a*	�|g٣��XՄ�a� L�'��l%��&l��!�V,0��,{�p�L:�eA�`]V&;vX%��	�e��`}{԰� L6�=j�J�&Fǿ��8�aQ9����8$��ڱ� W	p�	��=�J�C|�=�J�CB��=9� vM���C��8$ ��أ��8$ %�أ���Є�5\%�!}r�=jt��N5aޱO\�J@�)9��U:$`LC���J@g��ܱ����!c�:���U:ׄQ�5:��k�t���t�	3��Ѕ&�u�Ӄ���&��ؠ�J�WM���l�J��&,vl6}%�7��c��+�!��=� _	�-���X	�-ٳ	� �0y����І�Ay6����S��x$ Ƴ	����0��S]�j�:�& T�n¼g�N�L{B	��`���8�J@pMX�J���	�P	�	{B	 B66N�F�J�Ć���X	���	%VbC�h�X	���	%VbC��E6N�������8�J@lSdO(��!�q� �Z�ȞPH�kȑ)�b��`��I�h1�p�)��"bL5$d�)Pc�a!����1��P�cٓ)�c��!wi�:A�"�O�	�(2�0�Cb3A
$�j��)�'BQ��x�r��T4����r�̏*�O�w˧u1��7%�dC(��OӤ�
T��K��	�P�5.q�_p P�޸�ٞ=��c4�%���i�P�;.q��C�tC�z����tCE�*��i����bJ=��L��bz>d �I�T�^~P�[*rχD2�f���%q@�n��˫[�f�
��奍=��L蓧��T��P�Fy��@�	���K2��d�0�=b4xkRad��2�Y�L��T�Z&Ә�2��Gc�˄vyR%n�]Y@E�7�'&�L�a'�`��L�cJ2���X�4u�Q@3z�K�Y̈́�9��-8��L�s7��g��-wx��+q|fA7�mL�T�p&4�Y�8>���	�s�I'>� �	��XN\D�v&��c.q|fA<��q�ԂPPτ�y�K�Y�τ�y�yZp����?�!�ȟA@���%�T8��]^�9
HhB=�ǟACz�Q�����&4�#�����&t�C9��nG �	m�P.g#�Y�ф>zs��I �	�����̂�&t�Cʁ��.��&��C(q���4��|���ĩ�[�����]�Cj��M���'F�ӄvz0��5��&���8�����P*[�"PԄ���ل��h�����'F�Ԅ����|fAT��>�8>���	]u3y�����V�>+�y%�K���+q���5���]���3ʚ�Y����iMh�{=f��'�ք޺W�ȿ�@\��4�8>���	�uǁ���&��i(q|fA_��ԏ����h�S�&�M�S(q|fAbZ���"��#�M豓Â8ل&;����"Pل.;����C �lB�����c?Z�jB��h�8��sJ��iG?.��@jZ����	;�@������mB��0-�ån@E�C��b��mkt�a�n��9X�n;��_��m?$�ͩܶF���7�jp��v0CX���m<�an[���y���/kp�ݶ�$����i��[�5�m�nۇa�m�ܶF��ݠ���"P���w�kp�ݶ�A�����5��n�%q@��n�㯸���mw���趻���eܶF��u}�/���5����V�hp��vG}�nѸ0ݶ�z�_y�qi4�mWN�����h�,������]�-����]כ%q@�mg{�_�q�4�m�{�CӸLݶS�ZT�۶c��K�4.�F�m�4�jp�ݶ�e*[T�۶>��?ς��趭M���R���趭NqIP�n۪�kF5�m�n�����Y5�m�n���[T��619��]n[��6>Y��bn[��6.�q�5�mc�毠��5�m�-�*�m������m�!N���ܶF�]��趵�;���mk{~�����m��0-�*�m��h��,�m�n�r�&n[�ۦ!�߉��9�Nk�|��g
ݮ7������{�d�[w���ݻ�ŀ�m���AZ����R���@���������Cuxw���۫2 �?����jS�}ؔGTy�L�<쮷��K�W!n��7���ʗmm�ܒ_%o�J��ǻ��ٲ�6���3U�tS���;#m6��Ҷ��n_BW��`oeG]()�?|o��tK_X~w�����O��ѓMG�}ŭ�,��u�U����/uY��<zk�=��X�u�.��K�2K)��2K)��4J�,�GI�%+L�,��rG��YJ��k>��k¤�rg��YJ��0)��2�aRf)e�;.���R�,w�I���Y��2K)��&e�Rf�#L�,��rG��YJ��0)��2�aRf)e�s��R�,g�I���YΉ�2�)��'e�Rf9+N�,��rV��YJ��8)��2�YqRf)e����R�,g�I���YΊ�2K)��'e�Rf9'N�,O��rV��YJ��8)��2�YqRf)e����R�,g�I���YΊ�2K)��'e�Rf9+N�,���2��.Ӷ�mu1���W�}W?�|���zs��9�O�tv�fu�l�K^=J�i�no���������2�[Dm�!����ק����K������[����R���g?|��2�*�>y����x���xqO�r�ӣ�r���f�?4r^�n_�Rw��������S8��S8?����Q���
�Ni��&�����B�S�0i��&����#L8��sG�4pJ��/i���a��)�;¤�S8w�I�4p��Ni��&����#L8��sG�4pJ�8i���Yq��)�s⤁�D8g�I�4pΊ�Ni��'���9+N8��sV�4pJ�8i���Yq��)��⤁S8g�I�4pΉ��i��'���9+N8��sV�4pJ�8i���Yq��)��⤁S8g�I�4pΊ�Ni������m������G?>8z���o�����lN�ᗫͭ���߇K_U-���eŏz,�l�F���8���~�����ώoݺ����H�      �      x������ � �      #      x������ � �      $      x������ � �     