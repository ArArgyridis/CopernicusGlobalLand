PGDMP         6                z           jrcstats_export    14.5    14.5 �    �           0    0    ENCODING    ENCODING     #   SET client_encoding = 'SQL_ASCII';
                      false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            �           1262    348903    jrcstats_export    DATABASE     _   CREATE DATABASE jrcstats_export WITH TEMPLATE = template0 ENCODING = 'SQL_ASCII' LOCALE = 'C';
    DROP DATABASE jrcstats_export;
                postgres    false            �           0    0    SCHEMA pg_catalog    ACL     -   GRANT ALL ON SCHEMA pg_catalog TO statsuser;
                   postgres    false    4            �           0    0    SCHEMA public    ACL     )   GRANT ALL ON SCHEMA public TO statsuser;
                   postgres    false    5                        2615    348904    tmp    SCHEMA        CREATE SCHEMA tmp;
    DROP SCHEMA tmp;
             	   statsuser    false                        3079    348905    postgis 	   EXTENSION     ;   CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;
    DROP EXTENSION postgis;
                   false            �           0    0    EXTENSION postgis    COMMENT     ^   COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';
                        false    2                        3079    349936    postgis_raster 	   EXTENSION     B   CREATE EXTENSION IF NOT EXISTS postgis_raster WITH SCHEMA public;
    DROP EXTENSION postgis_raster;
                   false    2            �           0    0    EXTENSION postgis_raster    COMMENT     M   COMMENT ON EXTENSION postgis_raster IS 'PostGIS raster types and functions';
                        false    3            �           0    0    TABLE pg_aggregate    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_aggregate TO statsuser;
       
   pg_catalog          postgres    false    24            �           0    0    TABLE pg_am    ACL     2   GRANT ALL ON TABLE pg_catalog.pg_am TO statsuser;
       
   pg_catalog          postgres    false    25            �           0    0    TABLE pg_amop    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_amop TO statsuser;
       
   pg_catalog          postgres    false    26            �           0    0    TABLE pg_amproc    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_amproc TO statsuser;
       
   pg_catalog          postgres    false    27            �           0    0    TABLE pg_attrdef    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_attrdef TO statsuser;
       
   pg_catalog          postgres    false    28            �           0    0    TABLE pg_attribute    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_attribute TO statsuser;
       
   pg_catalog          postgres    false    13            �           0    0    TABLE pg_auth_members    ACL     <   GRANT ALL ON TABLE pg_catalog.pg_auth_members TO statsuser;
       
   pg_catalog          postgres    false    17            �           0    0    TABLE pg_authid    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_authid TO statsuser;
       
   pg_catalog          postgres    false    16            �           0    0 %   TABLE pg_available_extension_versions    ACL     L   GRANT ALL ON TABLE pg_catalog.pg_available_extension_versions TO statsuser;
       
   pg_catalog          postgres    false    89            �           0    0    TABLE pg_available_extensions    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_available_extensions TO statsuser;
       
   pg_catalog          postgres    false    88            �           0    0     TABLE pg_backend_memory_contexts    ACL     G   GRANT ALL ON TABLE pg_catalog.pg_backend_memory_contexts TO statsuser;
       
   pg_catalog          postgres    false    100            �           0    0    TABLE pg_cast    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_cast TO statsuser;
       
   pg_catalog          postgres    false    29            �           0    0    TABLE pg_class    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_class TO statsuser;
       
   pg_catalog          postgres    false    15            �           0    0    TABLE pg_collation    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_collation TO statsuser;
       
   pg_catalog          postgres    false    54            �           0    0    TABLE pg_config    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_config TO statsuser;
       
   pg_catalog          postgres    false    98            �           0    0    TABLE pg_constraint    ACL     :   GRANT ALL ON TABLE pg_catalog.pg_constraint TO statsuser;
       
   pg_catalog          postgres    false    30            �           0    0    TABLE pg_conversion    ACL     :   GRANT ALL ON TABLE pg_catalog.pg_conversion TO statsuser;
       
   pg_catalog          postgres    false    31            �           0    0    TABLE pg_cursors    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_cursors TO statsuser;
       
   pg_catalog          postgres    false    87            �           0    0    TABLE pg_database    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_database TO statsuser;
       
   pg_catalog          postgres    false    18            �           0    0    TABLE pg_db_role_setting    ACL     ?   GRANT ALL ON TABLE pg_catalog.pg_db_role_setting TO statsuser;
       
   pg_catalog          postgres    false    45            �           0    0    TABLE pg_default_acl    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_default_acl TO statsuser;
       
   pg_catalog          postgres    false    9            �           0    0    TABLE pg_depend    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_depend TO statsuser;
       
   pg_catalog          postgres    false    32            �           0    0    TABLE pg_description    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_description TO statsuser;
       
   pg_catalog          postgres    false    33                        0    0    TABLE pg_enum    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_enum TO statsuser;
       
   pg_catalog          postgres    false    56                       0    0    TABLE pg_event_trigger    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_event_trigger TO statsuser;
       
   pg_catalog          postgres    false    55                       0    0    TABLE pg_extension    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_extension TO statsuser;
       
   pg_catalog          postgres    false    47                       0    0    TABLE pg_file_settings    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_file_settings TO statsuser;
       
   pg_catalog          postgres    false    94                       0    0    TABLE pg_foreign_data_wrapper    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_foreign_data_wrapper TO statsuser;
       
   pg_catalog          postgres    false    22                       0    0    TABLE pg_foreign_server    ACL     >   GRANT ALL ON TABLE pg_catalog.pg_foreign_server TO statsuser;
       
   pg_catalog          postgres    false    19                       0    0    TABLE pg_foreign_table    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_foreign_table TO statsuser;
       
   pg_catalog          postgres    false    48                       0    0    TABLE pg_group    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_group TO statsuser;
       
   pg_catalog          postgres    false    73                       0    0    TABLE pg_hba_file_rules    ACL     >   GRANT ALL ON TABLE pg_catalog.pg_hba_file_rules TO statsuser;
       
   pg_catalog          postgres    false    95            	           0    0    TABLE pg_index    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_index TO statsuser;
       
   pg_catalog          postgres    false    34            
           0    0    TABLE pg_indexes    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_indexes TO statsuser;
       
   pg_catalog          postgres    false    80                       0    0    TABLE pg_inherits    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_inherits TO statsuser;
       
   pg_catalog          postgres    false    35                       0    0    TABLE pg_init_privs    ACL     :   GRANT ALL ON TABLE pg_catalog.pg_init_privs TO statsuser;
       
   pg_catalog          postgres    false    52                       0    0    TABLE pg_language    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_language TO statsuser;
       
   pg_catalog          postgres    false    36                       0    0    TABLE pg_largeobject    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_largeobject TO statsuser;
       
   pg_catalog          postgres    false    37                       0    0    TABLE pg_largeobject_metadata    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_largeobject_metadata TO statsuser;
       
   pg_catalog          postgres    false    46                       0    0    TABLE pg_locks    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_locks TO statsuser;
       
   pg_catalog          postgres    false    86                       0    0    TABLE pg_matviews    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_matviews TO statsuser;
       
   pg_catalog          postgres    false    79                       0    0    TABLE pg_namespace    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_namespace TO statsuser;
       
   pg_catalog          postgres    false    38                       0    0    TABLE pg_opclass    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_opclass TO statsuser;
       
   pg_catalog          postgres    false    39                       0    0    TABLE pg_operator    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_operator TO statsuser;
       
   pg_catalog          postgres    false    40                       0    0    TABLE pg_opfamily    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_opfamily TO statsuser;
       
   pg_catalog          postgres    false    44                       0    0    TABLE pg_partitioned_table    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_partitioned_table TO statsuser;
       
   pg_catalog          postgres    false    50                       0    0    TABLE pg_policies    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_policies TO statsuser;
       
   pg_catalog          postgres    false    75                       0    0    TABLE pg_policy    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_policy TO statsuser;
       
   pg_catalog          postgres    false    49                       0    0    TABLE pg_prepared_statements    ACL     C   GRANT ALL ON TABLE pg_catalog.pg_prepared_statements TO statsuser;
       
   pg_catalog          postgres    false    91                       0    0    TABLE pg_prepared_xacts    ACL     >   GRANT ALL ON TABLE pg_catalog.pg_prepared_xacts TO statsuser;
       
   pg_catalog          postgres    false    90                       0    0    TABLE pg_proc    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_proc TO statsuser;
       
   pg_catalog          postgres    false    14                       0    0    TABLE pg_publication    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_publication TO statsuser;
       
   pg_catalog          postgres    false    69                       0    0    TABLE pg_publication_rel    ACL     ?   GRANT ALL ON TABLE pg_catalog.pg_publication_rel TO statsuser;
       
   pg_catalog          postgres    false    70                       0    0    TABLE pg_publication_tables    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_publication_tables TO statsuser;
       
   pg_catalog          postgres    false    85                       0    0    TABLE pg_range    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_range TO statsuser;
       
   pg_catalog          postgres    false    57                        0    0    TABLE pg_replication_origin    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_replication_origin TO statsuser;
       
   pg_catalog          postgres    false    66            !           0    0 "   TABLE pg_replication_origin_status    ACL     I   GRANT ALL ON TABLE pg_catalog.pg_replication_origin_status TO statsuser;
       
   pg_catalog          postgres    false    142            "           0    0    TABLE pg_replication_slots    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_replication_slots TO statsuser;
       
   pg_catalog          postgres    false    126            #           0    0    TABLE pg_rewrite    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_rewrite TO statsuser;
       
   pg_catalog          postgres    false    41            $           0    0    TABLE pg_roles    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_roles TO statsuser;
       
   pg_catalog          postgres    false    71            %           0    0    TABLE pg_rules    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_rules TO statsuser;
       
   pg_catalog          postgres    false    76            &           0    0    TABLE pg_seclabel    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_seclabel TO statsuser;
       
   pg_catalog          postgres    false    60            '           0    0    TABLE pg_seclabels    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_seclabels TO statsuser;
       
   pg_catalog          postgres    false    92            (           0    0    TABLE pg_sequence    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_sequence TO statsuser;
       
   pg_catalog          postgres    false    21            )           0    0    TABLE pg_sequences    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_sequences TO statsuser;
       
   pg_catalog          postgres    false    81            *           0    0    TABLE pg_settings    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_settings TO statsuser;
       
   pg_catalog          postgres    false    93            +           0    0    TABLE pg_shadow    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_shadow TO statsuser;
       
   pg_catalog          postgres    false    72            ,           0    0    TABLE pg_shdepend    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_shdepend TO statsuser;
       
   pg_catalog          postgres    false    11            -           0    0    TABLE pg_shdescription    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_shdescription TO statsuser;
       
   pg_catalog          postgres    false    23            .           0    0    TABLE pg_shmem_allocations    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_shmem_allocations TO statsuser;
       
   pg_catalog          postgres    false    99            /           0    0    TABLE pg_shseclabel    ACL     :   GRANT ALL ON TABLE pg_catalog.pg_shseclabel TO statsuser;
       
   pg_catalog          postgres    false    59            0           0    0    TABLE pg_stat_activity    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_stat_activity TO statsuser;
       
   pg_catalog          postgres    false    119            1           0    0    TABLE pg_stat_all_indexes    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_stat_all_indexes TO statsuser;
       
   pg_catalog          postgres    false    110            2           0    0    TABLE pg_stat_all_tables    ACL     ?   GRANT ALL ON TABLE pg_catalog.pg_stat_all_tables TO statsuser;
       
   pg_catalog          postgres    false    101            3           0    0    TABLE pg_stat_archiver    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_stat_archiver TO statsuser;
       
   pg_catalog          postgres    false    132            4           0    0    TABLE pg_stat_bgwriter    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_stat_bgwriter TO statsuser;
       
   pg_catalog          postgres    false    133            5           0    0    TABLE pg_stat_database    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_stat_database TO statsuser;
       
   pg_catalog          postgres    false    128            6           0    0     TABLE pg_stat_database_conflicts    ACL     G   GRANT ALL ON TABLE pg_catalog.pg_stat_database_conflicts TO statsuser;
       
   pg_catalog          postgres    false    129            7           0    0    TABLE pg_stat_gssapi    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_stat_gssapi TO statsuser;
       
   pg_catalog          postgres    false    125            8           0    0    TABLE pg_stat_progress_analyze    ACL     E   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_analyze TO statsuser;
       
   pg_catalog          postgres    false    135            9           0    0 !   TABLE pg_stat_progress_basebackup    ACL     H   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_basebackup TO statsuser;
       
   pg_catalog          postgres    false    139            :           0    0    TABLE pg_stat_progress_cluster    ACL     E   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_cluster TO statsuser;
       
   pg_catalog          postgres    false    137            ;           0    0    TABLE pg_stat_progress_copy    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_copy TO statsuser;
       
   pg_catalog          postgres    false    140            <           0    0 #   TABLE pg_stat_progress_create_index    ACL     J   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_create_index TO statsuser;
       
   pg_catalog          postgres    false    138            =           0    0    TABLE pg_stat_progress_vacuum    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_vacuum TO statsuser;
       
   pg_catalog          postgres    false    136            >           0    0    TABLE pg_stat_replication    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_stat_replication TO statsuser;
       
   pg_catalog          postgres    false    120            ?           0    0    TABLE pg_stat_replication_slots    ACL     F   GRANT ALL ON TABLE pg_catalog.pg_stat_replication_slots TO statsuser;
       
   pg_catalog          postgres    false    127            @           0    0    TABLE pg_stat_slru    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_stat_slru TO statsuser;
       
   pg_catalog          postgres    false    121            A           0    0    TABLE pg_stat_ssl    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_stat_ssl TO statsuser;
       
   pg_catalog          postgres    false    124            B           0    0    TABLE pg_stat_subscription    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_stat_subscription TO statsuser;
       
   pg_catalog          postgres    false    123            C           0    0    TABLE pg_stat_sys_indexes    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_stat_sys_indexes TO statsuser;
       
   pg_catalog          postgres    false    111            D           0    0    TABLE pg_stat_sys_tables    ACL     ?   GRANT ALL ON TABLE pg_catalog.pg_stat_sys_tables TO statsuser;
       
   pg_catalog          postgres    false    103            E           0    0    TABLE pg_stat_user_functions    ACL     C   GRANT ALL ON TABLE pg_catalog.pg_stat_user_functions TO statsuser;
       
   pg_catalog          postgres    false    130            F           0    0    TABLE pg_stat_user_indexes    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_stat_user_indexes TO statsuser;
       
   pg_catalog          postgres    false    112            G           0    0    TABLE pg_stat_user_tables    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_stat_user_tables TO statsuser;
       
   pg_catalog          postgres    false    105            H           0    0    TABLE pg_stat_wal    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_stat_wal TO statsuser;
       
   pg_catalog          postgres    false    134            I           0    0    TABLE pg_stat_wal_receiver    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_stat_wal_receiver TO statsuser;
       
   pg_catalog          postgres    false    122            J           0    0    TABLE pg_stat_xact_all_tables    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_stat_xact_all_tables TO statsuser;
       
   pg_catalog          postgres    false    102            K           0    0    TABLE pg_stat_xact_sys_tables    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_stat_xact_sys_tables TO statsuser;
       
   pg_catalog          postgres    false    104            L           0    0 !   TABLE pg_stat_xact_user_functions    ACL     H   GRANT ALL ON TABLE pg_catalog.pg_stat_xact_user_functions TO statsuser;
       
   pg_catalog          postgres    false    131            M           0    0    TABLE pg_stat_xact_user_tables    ACL     E   GRANT ALL ON TABLE pg_catalog.pg_stat_xact_user_tables TO statsuser;
       
   pg_catalog          postgres    false    106            N           0    0    TABLE pg_statio_all_indexes    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_statio_all_indexes TO statsuser;
       
   pg_catalog          postgres    false    113            O           0    0    TABLE pg_statio_all_sequences    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_statio_all_sequences TO statsuser;
       
   pg_catalog          postgres    false    116            P           0    0    TABLE pg_statio_all_tables    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_statio_all_tables TO statsuser;
       
   pg_catalog          postgres    false    107            Q           0    0    TABLE pg_statio_sys_indexes    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_statio_sys_indexes TO statsuser;
       
   pg_catalog          postgres    false    114            R           0    0    TABLE pg_statio_sys_sequences    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_statio_sys_sequences TO statsuser;
       
   pg_catalog          postgres    false    117            S           0    0    TABLE pg_statio_sys_tables    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_statio_sys_tables TO statsuser;
       
   pg_catalog          postgres    false    108            T           0    0    TABLE pg_statio_user_indexes    ACL     C   GRANT ALL ON TABLE pg_catalog.pg_statio_user_indexes TO statsuser;
       
   pg_catalog          postgres    false    115            U           0    0    TABLE pg_statio_user_sequences    ACL     E   GRANT ALL ON TABLE pg_catalog.pg_statio_user_sequences TO statsuser;
       
   pg_catalog          postgres    false    118            V           0    0    TABLE pg_statio_user_tables    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_statio_user_tables TO statsuser;
       
   pg_catalog          postgres    false    109            W           0    0    TABLE pg_statistic    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_statistic TO statsuser;
       
   pg_catalog          postgres    false    42            X           0    0    TABLE pg_statistic_ext    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_statistic_ext TO statsuser;
       
   pg_catalog          postgres    false    51            Y           0    0    TABLE pg_statistic_ext_data    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_statistic_ext_data TO statsuser;
       
   pg_catalog          postgres    false    53            Z           0    0    TABLE pg_stats    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_stats TO statsuser;
       
   pg_catalog          postgres    false    82            [           0    0    TABLE pg_stats_ext    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_stats_ext TO statsuser;
       
   pg_catalog          postgres    false    83            \           0    0    TABLE pg_stats_ext_exprs    ACL     ?   GRANT ALL ON TABLE pg_catalog.pg_stats_ext_exprs TO statsuser;
       
   pg_catalog          postgres    false    84            ]           0    0    TABLE pg_subscription    ACL     <   GRANT ALL ON TABLE pg_catalog.pg_subscription TO statsuser;
       
   pg_catalog          postgres    false    67            ^           0    0    TABLE pg_subscription_rel    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_subscription_rel TO statsuser;
       
   pg_catalog          postgres    false    68            _           0    0    TABLE pg_tables    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_tables TO statsuser;
       
   pg_catalog          postgres    false    78            `           0    0    TABLE pg_tablespace    ACL     :   GRANT ALL ON TABLE pg_catalog.pg_tablespace TO statsuser;
       
   pg_catalog          postgres    false    10            a           0    0    TABLE pg_timezone_abbrevs    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_timezone_abbrevs TO statsuser;
       
   pg_catalog          postgres    false    96            b           0    0    TABLE pg_timezone_names    ACL     >   GRANT ALL ON TABLE pg_catalog.pg_timezone_names TO statsuser;
       
   pg_catalog          postgres    false    97            c           0    0    TABLE pg_transform    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_transform TO statsuser;
       
   pg_catalog          postgres    false    58            d           0    0    TABLE pg_trigger    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_trigger TO statsuser;
       
   pg_catalog          postgres    false    43            e           0    0    TABLE pg_ts_config    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_ts_config TO statsuser;
       
   pg_catalog          postgres    false    63            f           0    0    TABLE pg_ts_config_map    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_ts_config_map TO statsuser;
       
   pg_catalog          postgres    false    64            g           0    0    TABLE pg_ts_dict    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_ts_dict TO statsuser;
       
   pg_catalog          postgres    false    61            h           0    0    TABLE pg_ts_parser    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_ts_parser TO statsuser;
       
   pg_catalog          postgres    false    62            i           0    0    TABLE pg_ts_template    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_ts_template TO statsuser;
       
   pg_catalog          postgres    false    65            j           0    0    TABLE pg_type    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_type TO statsuser;
       
   pg_catalog          postgres    false    12            k           0    0    TABLE pg_user    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_user TO statsuser;
       
   pg_catalog          postgres    false    74            l           0    0    TABLE pg_user_mapping    ACL     <   GRANT ALL ON TABLE pg_catalog.pg_user_mapping TO statsuser;
       
   pg_catalog          postgres    false    20            m           0    0    TABLE pg_user_mappings    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_user_mappings TO statsuser;
       
   pg_catalog          postgres    false    141            n           0    0    TABLE pg_views    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_views TO statsuser;
       
   pg_catalog          postgres    false    77            �            1259    350493    category    TABLE     }   CREATE TABLE public.category (
    id bigint NOT NULL,
    title text NOT NULL,
    active boolean DEFAULT false NOT NULL
);
    DROP TABLE public.category;
       public         heap 	   statsuser    false            �            1259    350499    category_id_seq    SEQUENCE     �   ALTER TABLE public.category ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.category_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   statsuser    false    227            o           0    0    TABLE geography_columns    ACL     :   GRANT ALL ON TABLE public.geography_columns TO statsuser;
          public          postgres    false    215            p           0    0    TABLE geometry_columns    ACL     9   GRANT ALL ON TABLE public.geometry_columns TO statsuser;
          public          postgres    false    216            �            1259    350500    output_product    TABLE     �   CREATE TABLE public.output_product (
    id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    rel_file_path text,
    type text
);
 "   DROP TABLE public.output_product;
       public         heap    postgres    false            q           0    0    TABLE output_product    ACL     7   GRANT ALL ON TABLE public.output_product TO statsuser;
          public          postgres    false    229            �            1259    350505    output_product_id_seq    SEQUENCE     ~   CREATE SEQUENCE public.output_product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE public.output_product_id_seq;
       public       	   statsuser    false            �            1259    350506 
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
       public         heap 	   statsuser    false            �            1259    350512    poly_stats_id_seq    SEQUENCE     z   CREATE SEQUENCE public.poly_stats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.poly_stats_id_seq;
       public       	   statsuser    false    231            r           0    0    poly_stats_id_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE public.poly_stats_id_seq OWNED BY public.poly_stats.id;
          public       	   statsuser    false    232            �            1259    350513    product    TABLE     �   CREATE TABLE public.product (
    id bigint NOT NULL,
    name text[] NOT NULL,
    type text DEFAULT 'raw'::text NOT NULL,
    category_id bigint
);
    DROP TABLE public.product;
       public         heap 	   statsuser    false            �            1259    350519    product_file    TABLE     �   CREATE TABLE public.product_file (
    id bigint NOT NULL,
    product_description_id bigint,
    rel_file_path text,
    date timestamp without time zone,
    date_created timestamp without time zone DEFAULT (now() AT TIME ZONE 'UTC'::text)
);
     DROP TABLE public.product_file;
       public         heap 	   statsuser    false            �            1259    350525    product_file_description    TABLE       CREATE TABLE public.product_file_description (
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
    product_id bigint,
    file_name_creation_pattern text
);
 ,   DROP TABLE public.product_file_description;
       public         heap 	   statsuser    false            �            1259    350530    product_file_id_seq    SEQUENCE     |   CREATE SEQUENCE public.product_file_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.product_file_id_seq;
       public       	   statsuser    false    234            s           0    0    product_file_id_seq    SEQUENCE OWNED BY     K   ALTER SEQUENCE public.product_file_id_seq OWNED BY public.product_file.id;
          public       	   statsuser    false    236            �            1259    350531    product_id_seq    SEQUENCE     w   CREATE SEQUENCE public.product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public.product_id_seq;
       public       	   statsuser    false    235            t           0    0    product_id_seq    SEQUENCE OWNED BY     R   ALTER SEQUENCE public.product_id_seq OWNED BY public.product_file_description.id;
          public       	   statsuser    false    237            �            1259    350532    product_id_seq1    SEQUENCE     x   CREATE SEQUENCE public.product_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.product_id_seq1;
       public       	   statsuser    false    233            u           0    0    product_id_seq1    SEQUENCE OWNED BY     B   ALTER SEQUENCE public.product_id_seq1 OWNED BY public.product.id;
          public       	   statsuser    false    238            v           0    0    TABLE raster_columns    ACL     7   GRANT ALL ON TABLE public.raster_columns TO statsuser;
          public          postgres    false    225            w           0    0    TABLE raster_overviews    ACL     9   GRANT ALL ON TABLE public.raster_overviews TO statsuser;
          public          postgres    false    226            x           0    0    TABLE spatial_ref_sys    ACL     8   GRANT ALL ON TABLE public.spatial_ref_sys TO statsuser;
          public          postgres    false    213            �            1259    350533    stratification    TABLE     m   CREATE TABLE public.stratification (
    id bigint NOT NULL,
    description text,
    tilelayer_url text
);
 "   DROP TABLE public.stratification;
       public         heap 	   statsuser    false            �            1259    350538    stratification_geom    TABLE     �   CREATE TABLE public.stratification_geom (
    id bigint NOT NULL,
    stratification_id bigint NOT NULL,
    geom public.geometry(MultiPolygon,4326),
    geom3857 public.geometry(MultiPolygon,3857),
    metadata jsonb,
    description text
);
 '   DROP TABLE public.stratification_geom;
       public         heap 	   statsuser    false    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2            �            1259    350543    stratification_geom_id_seq    SEQUENCE     �   CREATE SEQUENCE public.stratification_geom_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE public.stratification_geom_id_seq;
       public       	   statsuser    false    240            y           0    0    stratification_geom_id_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE public.stratification_geom_id_seq OWNED BY public.stratification_geom.id;
          public       	   statsuser    false    241            �            1259    350544    stratification_id_seq    SEQUENCE     ~   CREATE SEQUENCE public.stratification_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE public.stratification_id_seq;
       public       	   statsuser    false    239            z           0    0    stratification_id_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE public.stratification_id_seq OWNED BY public.stratification.id;
          public       	   statsuser    false    242            7           2604    350545    poly_stats id    DEFAULT     n   ALTER TABLE ONLY public.poly_stats ALTER COLUMN id SET DEFAULT nextval('public.poly_stats_id_seq'::regclass);
 <   ALTER TABLE public.poly_stats ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    232    231            9           2604    350546 
   product id    DEFAULT     i   ALTER TABLE ONLY public.product ALTER COLUMN id SET DEFAULT nextval('public.product_id_seq1'::regclass);
 9   ALTER TABLE public.product ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    238    233            ;           2604    350547    product_file id    DEFAULT     r   ALTER TABLE ONLY public.product_file ALTER COLUMN id SET DEFAULT nextval('public.product_file_id_seq'::regclass);
 >   ALTER TABLE public.product_file ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    236    234            <           2604    350548    product_file_description id    DEFAULT     y   ALTER TABLE ONLY public.product_file_description ALTER COLUMN id SET DEFAULT nextval('public.product_id_seq'::regclass);
 J   ALTER TABLE public.product_file_description ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    237    235            =           2604    350549    stratification id    DEFAULT     v   ALTER TABLE ONLY public.stratification ALTER COLUMN id SET DEFAULT nextval('public.stratification_id_seq'::regclass);
 @   ALTER TABLE public.stratification ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    242    239            >           2604    350550    stratification_geom id    DEFAULT     �   ALTER TABLE ONLY public.stratification_geom ALTER COLUMN id SET DEFAULT nextval('public.stratification_geom_id_seq'::regclass);
 E   ALTER TABLE public.stratification_geom ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    241    240            �          0    350493    category 
   TABLE DATA           5   COPY public.category (id, title, active) FROM stdin;
    public       	   statsuser    false    227   A�       �          0    350500    output_product 
   TABLE DATA           R   COPY public.output_product (id, product_file_id, rel_file_path, type) FROM stdin;
    public          postgres    false    229   ��       �          0    350506 
   poly_stats 
   TABLE DATA           �   COPY public.poly_stats (id, poly_id, product_file_id, noval_area_ha, sparse_area_ha, mid_area_ha, dense_area_ha, date_created, noval_color, sparseval_color, midval_color, highval_color, histogram) FROM stdin;
    public       	   statsuser    false    231   ��       �          0    350513    product 
   TABLE DATA           >   COPY public.product (id, name, type, category_id) FROM stdin;
    public       	   statsuser    false    233   ��       �          0    350519    product_file 
   TABLE DATA           e   COPY public.product_file (id, product_description_id, rel_file_path, date, date_created) FROM stdin;
    public       	   statsuser    false    234   ~�       �          0    350525    product_file_description 
   TABLE DATA             COPY public.product_file_description (id, pattern, types, create_date, variable, style, description, low_value, mid_value, high_value, noval_colors, sparseval_colors, midval_colors, highval_colors, min_prod_value, max_prod_value, product_id, file_name_creation_pattern) FROM stdin;
    public       	   statsuser    false    235   ��       3          0    349215    spatial_ref_sys 
   TABLE DATA           X   COPY public.spatial_ref_sys (srid, auth_name, auth_srid, srtext, proj4text) FROM stdin;
    public          postgres    false    213   E�       �          0    350533    stratification 
   TABLE DATA           H   COPY public.stratification (id, description, tilelayer_url) FROM stdin;
    public       	   statsuser    false    239   b�       �          0    350538    stratification_geom 
   TABLE DATA           k   COPY public.stratification_geom (id, stratification_id, geom, geom3857, metadata, description) FROM stdin;
    public       	   statsuser    false    240   �       {           0    0    category_id_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public.category_id_seq', 6, true);
          public       	   statsuser    false    228            |           0    0    output_product_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.output_product_id_seq', 1, false);
          public       	   statsuser    false    230            }           0    0    poly_stats_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.poly_stats_id_seq', 1, false);
          public       	   statsuser    false    232            ~           0    0    product_file_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.product_file_id_seq', 1, false);
          public       	   statsuser    false    236                       0    0    product_id_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public.product_id_seq', 14, true);
          public       	   statsuser    false    237            �           0    0    product_id_seq1    SEQUENCE SET     =   SELECT pg_catalog.setval('public.product_id_seq1', 4, true);
          public       	   statsuser    false    238            �           0    0    stratification_geom_id_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public.stratification_geom_id_seq', 1, false);
          public       	   statsuser    false    241            �           0    0    stratification_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.stratification_id_seq', 1, false);
          public       	   statsuser    false    242                        2606    409677    category newtable_pk 
   CONSTRAINT     R   ALTER TABLE ONLY public.category
    ADD CONSTRAINT newtable_pk PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.category DROP CONSTRAINT newtable_pk;
       public         	   statsuser    false    227            "           2606    409679     output_product output_product_pk 
   CONSTRAINT     ^   ALTER TABLE ONLY public.output_product
    ADD CONSTRAINT output_product_pk PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.output_product DROP CONSTRAINT output_product_pk;
       public            postgres    false    229            $           2606    409681    poly_stats poly_stats_pk 
   CONSTRAINT     V   ALTER TABLE ONLY public.poly_stats
    ADD CONSTRAINT poly_stats_pk PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.poly_stats DROP CONSTRAINT poly_stats_pk;
       public         	   statsuser    false    231            &           2606    409683    poly_stats poly_stats_un 
   CONSTRAINT     g   ALTER TABLE ONLY public.poly_stats
    ADD CONSTRAINT poly_stats_un UNIQUE (poly_id, product_file_id);
 B   ALTER TABLE ONLY public.poly_stats DROP CONSTRAINT poly_stats_un;
       public         	   statsuser    false    231    231            *           2606    409685    product_file product_file_pk 
   CONSTRAINT     Z   ALTER TABLE ONLY public.product_file
    ADD CONSTRAINT product_file_pk PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.product_file DROP CONSTRAINT product_file_pk;
       public         	   statsuser    false    234            ,           2606    409687    product_file product_file_un 
   CONSTRAINT     x   ALTER TABLE ONLY public.product_file
    ADD CONSTRAINT product_file_un UNIQUE (product_description_id, rel_file_path);
 F   ALTER TABLE ONLY public.product_file DROP CONSTRAINT product_file_un;
       public         	   statsuser    false    234    234            .           2606    409689 #   product_file_description product_pk 
   CONSTRAINT     a   ALTER TABLE ONLY public.product_file_description
    ADD CONSTRAINT product_pk PRIMARY KEY (id);
 M   ALTER TABLE ONLY public.product_file_description DROP CONSTRAINT product_pk;
       public         	   statsuser    false    235            (           2606    409691    product product_pk1 
   CONSTRAINT     Q   ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_pk1 PRIMARY KEY (id);
 =   ALTER TABLE ONLY public.product DROP CONSTRAINT product_pk1;
       public         	   statsuser    false    233            0           2606    409693     stratification stratification_pk 
   CONSTRAINT     ^   ALTER TABLE ONLY public.stratification
    ADD CONSTRAINT stratification_pk PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.stratification DROP CONSTRAINT stratification_pk;
       public         	   statsuser    false    239            6           2606    409695 '   stratification_geom stratification_pkey 
   CONSTRAINT     e   ALTER TABLE ONLY public.stratification_geom
    ADD CONSTRAINT stratification_pkey PRIMARY KEY (id);
 Q   ALTER TABLE ONLY public.stratification_geom DROP CONSTRAINT stratification_pkey;
       public         	   statsuser    false    240            2           2606    409697     stratification stratification_un 
   CONSTRAINT     b   ALTER TABLE ONLY public.stratification
    ADD CONSTRAINT stratification_un UNIQUE (description);
 J   ALTER TABLE ONLY public.stratification DROP CONSTRAINT stratification_un;
       public         	   statsuser    false    239            3           1259    409698    sidx_stratification_geom    INDEX     W   CREATE INDEX sidx_stratification_geom ON public.stratification_geom USING gist (geom);
 ,   DROP INDEX public.sidx_stratification_geom;
       public         	   statsuser    false    240    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2            4           1259    409699    sidx_stratification_geom3857    INDEX     _   CREATE INDEX sidx_stratification_geom3857 ON public.stratification_geom USING gist (geom3857);
 0   DROP INDEX public.sidx_stratification_geom3857;
       public         	   statsuser    false    240    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2            7           2606    409700     output_product output_product_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.output_product
    ADD CONSTRAINT output_product_fk FOREIGN KEY (id) REFERENCES public.product_file(id) ON UPDATE CASCADE ON DELETE CASCADE;
 J   ALTER TABLE ONLY public.output_product DROP CONSTRAINT output_product_fk;
       public          postgres    false    229    4906    234            8           2606    409705 %   poly_stats poly_stats_product_file_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats
    ADD CONSTRAINT poly_stats_product_file_fk FOREIGN KEY (product_file_id) REFERENCES public.product_file(id) ON UPDATE CASCADE ON DELETE CASCADE;
 O   ALTER TABLE ONLY public.poly_stats DROP CONSTRAINT poly_stats_product_file_fk;
       public       	   statsuser    false    4906    234    231            9           2606    409710 ,   poly_stats poly_stats_stratification_geom_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats
    ADD CONSTRAINT poly_stats_stratification_geom_fk FOREIGN KEY (poly_id) REFERENCES public.stratification_geom(id) ON UPDATE CASCADE ON DELETE CASCADE;
 V   ALTER TABLE ONLY public.poly_stats DROP CONSTRAINT poly_stats_stratification_geom_fk;
       public       	   statsuser    false    4918    231    240            ;           2606    409715    product_file product_file_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.product_file
    ADD CONSTRAINT product_file_fk FOREIGN KEY (product_description_id) REFERENCES public.product_file_description(id) ON UPDATE CASCADE ON DELETE CASCADE;
 F   ALTER TABLE ONLY public.product_file DROP CONSTRAINT product_file_fk;
       public       	   statsuser    false    234    4910    235            :           2606    409720    product product_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_fk FOREIGN KEY (category_id) REFERENCES public.category(id) ON UPDATE CASCADE ON DELETE CASCADE;
 <   ALTER TABLE ONLY public.product DROP CONSTRAINT product_fk;
       public       	   statsuser    false    4896    227    233            <           2606    409725 *   stratification_geom stratification_geom_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.stratification_geom
    ADD CONSTRAINT stratification_geom_fk FOREIGN KEY (stratification_id) REFERENCES public.stratification(id) ON DELETE CASCADE;
 T   ALTER TABLE ONLY public.stratification_geom DROP CONSTRAINT stratification_geom_fk;
       public       	   statsuser    false    4912    240    239            �   Z   x�3�t�K-J��L�2�O,I-�L8��*�2R�R�\SN�������b όӽ(�4/E�)�85(`����Z�X����Y����� owq      �      x������ � �      �      x������ � �      �   �   x�3�v��H,��s	�460�3�w��OJ�����r�b��E�圆\�(��CC���aJL8��f����KI-�u��-H,�,��s���M̩tI-IM.�/��L� u�wsp�����9�0�b���� �d=�      �      x������ � �      �      x��ooܸ��_O>���M�c=�#�A��l��(���7q��)J��;�'�u�|��;�a�Y�[�v���H�g����#��������P�8x�����^�>��_�n~Q�˯�z�:�;>]=\��c����C�q��o�q���œ?������t~q|v��C���e:�φ��7�;>�v�����O��Z]���E�L���E~�nuv��|z����j�����/�����]:}s|��4��.N��J{�����oޞl��|�S��7��b�ܧb�B�Z����'�H���o>�O=��6��������bu�uq]������wPf����:���7oc-�}|�������6n���_����)��z������c��ƋU��������7�JU��O��4��J'�_�O�2ץ�;���%�(p]�����>]ڼ��W��/.���׸:GM�^�������w�U~��w~�'�������S�oNW�˿��������Nn�'�K'���u�����w�xRt#EEjl\o"WJ�H)�J}�ĕ�7R���J�)S�z�Z�R�F�)�zm�o{{#�)��5_�W�m�Z����&�.�޻:�ŮW'�N��vZO�n��uWN����]>^�EY�p�L�����厲W�u>��s�����.��C�>������=\�\��� 5�����e�m����b&�h(c�bMTz}�`��H����Bʔ��M�|EW�j}Vq��5�va�����(��q��^�GoN.��ev_�:ʗ	�_Ln�	߽���o��;����_?=<:�y �G�������4�����m���o����s��னƿ��|�ql�DMnD�?W��/����P�?_�#����6^��a�ԭs�yR���I�:G�'u�a�ԭs�yR�F��W��H��J��p�&Z�;ݿ�C��w������m�J��{�z*͞���4|�w˧����m�J�{�~*͟������� U��� U���tZ�Š�W�ؠ[�8@��m�e�(t@k�n�b��VbF�o5Uq�B8�t`�(W�Ϳ�/P� o;ݱŊ: ؤ��Ժ8@�B��-V����:�Ŋ��Ĭ�b0�At�3�#�8@��6��$�.�� m+���w�0���`�ht��Ȱ{]���i��5tq�F��5�^����ƳŊL�l0vd������FS`�� �Ѱ� �p��<vd�����`�+0��Q�ְ{S`\%,��jq���w��k�� �,���8�6(˞��� �h���.�XU���lq�E��,����C��g�pl+�޲� [`�!$��5lq�E��Xv�a����f� [`�]���k��mS�9˞���-:��Ѳ���8�E�o�]P[��J,��.�-h�C״�^�-hm%F-��h�!P[���m��8�u��n�Fo�Z_�ٖ==h��P��-��8�5��k��t��*�в��\�.�l;�� W9����8���icq�����8��{�t� �r@�8�\q���+��\q�C�^;�|q�o*1��C�/�T���� _��UαG'_�u%�={@���Tb3�/�� o+�γ_��J��l;�� �*���0�Wb#u�/��Ƴ�P*��v
��r��<{@	��r�`<�N�8 T�g(�8 T���S(����8 TB`�)��C�%��C�v
 �j�=���w$V{ ���(��.{P��XS� Q�bk �5��
쁅@cM兤�X� k*7��X��B౦�Cj�t
����\d0� "k*O$ٞ� YS�"��dA1��qL]仢B�T��{d��i�~�|W .�j%e#{�!�H��ql"����g9��!4Fj��t7c ��q�3{�!�H������!:Fv��\�7�cR�+F���Ǥ*W䡂o2�K(*W���=��I����o2�ȤjW�^��BծH�d �IUc�8ΑW��:�nƋW M�U:~8��'�q�T���\�Dy���;w@ʄLytY�o2�ʤ+�0v`Ը�]a���=
�eB�<�,ǟT Z&]��ܣ�{c�˄tyl�܌UY���/��O�H��*�<�n�8��*��g9�� 2SE���Θ� f&��)d9�g4���G;c~���5�v4��Y�K�p���r|�n&S��u�O* 8礲߳��	�s�QE�g:R�!Og�Dv&��C�r|�x&$�C?63n@=���r|�|&��CH㌻m�τ�y�)�� ��@.�yRaq)*�b�i�s�Єz0Y�?0�&�ЃJ=���&$����l� E��>O����`4!����l�{p4!����;	�4!��<߳��	�t��?�%�҄T��Y�?0�&�ҽK��H�Z\�����z�� M��y5	�4!��u�|�A��	�tOY�?0�&$�}� jBFݥ������
��ݐ��#`jBN��I9�gT��.f9�gU��.$r��`5!��\j��n] Wtm��� �	�ug�߳��	�u��߳ �	�u���'�ؚ�[w�0�W!�kBr�,��,�kBv���� �ׄ�:�Y��Y�ׄ�:vCnz|9p���_DC��	v�Y��Y�؄;W-�`lB���g��&$�Q��Ί e���m�� f��;G\�<;t��P# ڄD;�A�W� mB��0c1�&����	[\�\;���;$ ۄd;4�8G���+|������m����[�`��m�n�lxC��]��S�m�l��>��*`�
ٶ׽�#�ސm{������m�Է���
ضB����Α��oȶ]������m;?'SF�Vȶ���9�
�p�'��yl[!�v�7���
ضB�ݎ�8G\�l��d�;.�m+d�m��9r�
dۭ�:��
l[!�n�.�|(`�
�vk�;H�m�l����w�(��lێ���Q�5ٶ�S�9r�9\a���d�p{4�m�;�� �p�4�m�vz��ٶ5����R�IٶU���)�&�l�6]3G\�l�q�o�S�Uٶ������m+d�&�l��ٶq�3�qضB�mL����
ضB�mTs��ȶM=Ϩ���m�?����m�.�s��ȶu�vFF �m�l[�h�ۊ�m�l[ۨg��Vȶ�����Z�Vȶui��ٶJ��oW���mՇ���]�Vȶ�ǆ9r�
d�ʅ��g_�Vȶ�?O@�Vȶs#�s��ȶ��'�8l[!ۦ<?�A�Vȶ��������Q���f��Ir��՚En��?����
?�S~�M�%�RoR*o��#+?菏�E֡���Jh��VJh��V~)%��ӥ$��%&��Z�ELB+%�r۽��UbZ�ULB+%�r���VJh�1	����-�_Z)��[�$�RB+��Ih��Vn��J	��"&��Z�ELB+%�r���VJh�1	����)rZ)����$�RB+��Ih径VN���J	��$'��Z9INB+%�r���VJh�$9	����IrZ)����$�RB+'�Ih��VN���J	��"'���Z9INB+%�r���VJh�$9	����IrZ)����$�RB+'�Ih��VN���J	��$'��Z�Yh�:�n�<��򿗺i�J��o�jW����ta�����я/x����Wώ�r��i��%�����'_?=<:ԛ$˿�=�������+����k�z��&d�^��}1�j��q��֍>O �u�Gh�+tJu7v���峾G�o>�M��u��}��ӗ�һ/֕��W�:������r��]y�W��>XW���TzS	\��U	\���/�$pu�����$pUW��I��n{.�%*1	\�*&����ELW%pu���J���/	\���-b�*��[�$pUW��I��n��U	\�"&����ELW%pu���J��9	\���Ir�*��S�$pu_W'�I��N���U	\�$'���:INW%pu���J��$9	\���Ir�*����$pUW'�I��N����}	\�$'���:INW%pu���J��$ �   9	\���Ir�*����$pUW'�I��N���U	\�,p���`[��˧���y���?���..OW?��qON.�Os����e�㦼�Z�Y#WkyZ�M��ޚ~9;�����+��� �)�W/�l}��Ժ�w��޳�=x��� 6p]8      3      x������ � �      �      x������ � �      �      x������ � �     