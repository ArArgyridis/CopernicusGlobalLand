PGDMP                     
    z            jrcstats_export    14.5    14.5 �    �           0    0    ENCODING    ENCODING     #   SET client_encoding = 'SQL_ASCII';
                      false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            �           1262    588565    jrcstats_export    DATABASE     _   CREATE DATABASE jrcstats_export WITH TEMPLATE = template0 ENCODING = 'SQL_ASCII' LOCALE = 'C';
    DROP DATABASE jrcstats_export;
                postgres    false            �           0    0    SCHEMA pg_catalog    ACL     -   GRANT ALL ON SCHEMA pg_catalog TO statsuser;
                   postgres    false    3            �           0    0    SCHEMA public    ACL     )   GRANT ALL ON SCHEMA public TO statsuser;
                   postgres    false    4                        2615    588566    tmp    SCHEMA        CREATE SCHEMA tmp;
    DROP SCHEMA tmp;
             	   statsuser    false                        3079    588567    postgis 	   EXTENSION     ;   CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;
    DROP EXTENSION postgis;
                   false            �           0    0    EXTENSION postgis    COMMENT     ^   COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';
                        false    2            �           1255    589610    clms_updatepolygonstats()    FUNCTION       CREATE FUNCTION public.clms_updatepolygonstats() RETURNS smallint
    LANGUAGE plpgsql COST 1000
    AS $$
declare ret smallint;
begin
	
	WITH merged_data AS (
	SELECT poly_id, product_file_id, SUM(mean) mean, SUM(sd) sd, min(min_val) min_val, max(max_val) max_val, SUM(total_pixels) total_pixels, SUM(valid_pixels) valid_pixels,
	SUM(noval_area_ha) noval_area_ha, SUM(sparse_area_ha) sparse_area_ha, SUM(mid_area_ha) mid_area_ha, SUM(dense_area_ha) dense_area_ha
	FROM tmp.poly_stats_per_region pspr
	GROUP BY poly_id, product_file_id
),raw_hist_data AS(
	SELECT x.poly_id, x.product_file_id, x.idx, SUM((x.cnt)::integer) hist_val
	FROM (
    	SELECT pspr.id, pspr.poly_id, pspr.product_file_id, t.* 
    	FROM TMP.poly_stats_per_region pspr, jsonb_array_elements(histogram->'y') with ordinality as t(cnt, idx)
	) as x
	GROUP BY x.poly_id, x.product_file_id, x.idx
),hist_x_data AS(
	SELECT histogram->'x' x
	FROM TMP.poly_stats_per_region pspr LIMIT 1
),hist_y_data AS(
	SELECT poly_id, product_file_id, ARRAY_TO_JSON(ARRAY_AGG(hist_val order by idx)) y
	FROM raw_hist_data
	GROUP BY poly_id, product_file_id
),histogram AS(
	SELECT poly_id, product_file_id, json_build_object('x', hist_x_data.x, 'y', hist_y_data.y) histogram 
	FROM hist_x_data
	JOIN hist_y_data ON true
)
insert into poly_stats (poly_id, product_file_id, mean, sd, min_val, max_val, total_pixels,valid_pixels,noval_area_ha,
sparse_area_ha,mid_area_ha,dense_area_ha,histogram)
SELECT 
md.poly_id, md.product_file_id
, CASE WHEN valid_pixels = 0 THEN null ELSE mean/valid_pixels END mean
, CASE WHEN valid_pixels = 0 OR sd/valid_pixels < power(mean/valid_pixels,2) THEN null ELSE sqrt(sd/valid_pixels - power(mean/valid_pixels,2))  END sd
,min_val, max_val, total_pixels, valid_pixels, noval_area_ha, sparse_area_ha, mid_area_ha, dense_area_ha
,hst.histogram
FROM merged_data md 
JOIN histogram hst ON md.product_file_id = hst.product_file_id AND md.poly_id = hst.poly_id
--ORDER BY md.product_file_id, md.poly_id
ON CONFLICT (poly_id, product_file_id) DO NOTHING;
RETURN 0;

end;$$;
 0   DROP FUNCTION public.clms_updatepolygonstats();
       public       	   statsuser    false            �           0    0    TABLE pg_aggregate    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_aggregate TO statsuser;
       
   pg_catalog          postgres    false    23            �           0    0    TABLE pg_am    ACL     2   GRANT ALL ON TABLE pg_catalog.pg_am TO statsuser;
       
   pg_catalog          postgres    false    24            �           0    0    TABLE pg_amop    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_amop TO statsuser;
       
   pg_catalog          postgres    false    25            �           0    0    TABLE pg_amproc    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_amproc TO statsuser;
       
   pg_catalog          postgres    false    26            �           0    0    TABLE pg_attrdef    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_attrdef TO statsuser;
       
   pg_catalog          postgres    false    27            �           0    0    TABLE pg_attribute    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_attribute TO statsuser;
       
   pg_catalog          postgres    false    12            �           0    0    TABLE pg_auth_members    ACL     <   GRANT ALL ON TABLE pg_catalog.pg_auth_members TO statsuser;
       
   pg_catalog          postgres    false    16            �           0    0    TABLE pg_authid    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_authid TO statsuser;
       
   pg_catalog          postgres    false    15            �           0    0 %   TABLE pg_available_extension_versions    ACL     L   GRANT ALL ON TABLE pg_catalog.pg_available_extension_versions TO statsuser;
       
   pg_catalog          postgres    false    88            �           0    0    TABLE pg_available_extensions    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_available_extensions TO statsuser;
       
   pg_catalog          postgres    false    87            �           0    0     TABLE pg_backend_memory_contexts    ACL     G   GRANT ALL ON TABLE pg_catalog.pg_backend_memory_contexts TO statsuser;
       
   pg_catalog          postgres    false    99            �           0    0    TABLE pg_cast    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_cast TO statsuser;
       
   pg_catalog          postgres    false    28            �           0    0    TABLE pg_class    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_class TO statsuser;
       
   pg_catalog          postgres    false    14            �           0    0    TABLE pg_collation    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_collation TO statsuser;
       
   pg_catalog          postgres    false    53            �           0    0    TABLE pg_config    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_config TO statsuser;
       
   pg_catalog          postgres    false    97            �           0    0    TABLE pg_constraint    ACL     :   GRANT ALL ON TABLE pg_catalog.pg_constraint TO statsuser;
       
   pg_catalog          postgres    false    29            �           0    0    TABLE pg_conversion    ACL     :   GRANT ALL ON TABLE pg_catalog.pg_conversion TO statsuser;
       
   pg_catalog          postgres    false    30            �           0    0    TABLE pg_cursors    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_cursors TO statsuser;
       
   pg_catalog          postgres    false    86            �           0    0    TABLE pg_database    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_database TO statsuser;
       
   pg_catalog          postgres    false    17            �           0    0    TABLE pg_db_role_setting    ACL     ?   GRANT ALL ON TABLE pg_catalog.pg_db_role_setting TO statsuser;
       
   pg_catalog          postgres    false    44            �           0    0    TABLE pg_default_acl    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_default_acl TO statsuser;
       
   pg_catalog          postgres    false    8            �           0    0    TABLE pg_depend    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_depend TO statsuser;
       
   pg_catalog          postgres    false    31            �           0    0    TABLE pg_description    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_description TO statsuser;
       
   pg_catalog          postgres    false    32            �           0    0    TABLE pg_enum    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_enum TO statsuser;
       
   pg_catalog          postgres    false    55            �           0    0    TABLE pg_event_trigger    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_event_trigger TO statsuser;
       
   pg_catalog          postgres    false    54            �           0    0    TABLE pg_extension    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_extension TO statsuser;
       
   pg_catalog          postgres    false    46            �           0    0    TABLE pg_file_settings    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_file_settings TO statsuser;
       
   pg_catalog          postgres    false    93            �           0    0    TABLE pg_foreign_data_wrapper    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_foreign_data_wrapper TO statsuser;
       
   pg_catalog          postgres    false    21            �           0    0    TABLE pg_foreign_server    ACL     >   GRANT ALL ON TABLE pg_catalog.pg_foreign_server TO statsuser;
       
   pg_catalog          postgres    false    18            �           0    0    TABLE pg_foreign_table    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_foreign_table TO statsuser;
       
   pg_catalog          postgres    false    47            �           0    0    TABLE pg_group    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_group TO statsuser;
       
   pg_catalog          postgres    false    72            �           0    0    TABLE pg_hba_file_rules    ACL     >   GRANT ALL ON TABLE pg_catalog.pg_hba_file_rules TO statsuser;
       
   pg_catalog          postgres    false    94            �           0    0    TABLE pg_index    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_index TO statsuser;
       
   pg_catalog          postgres    false    33            �           0    0    TABLE pg_indexes    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_indexes TO statsuser;
       
   pg_catalog          postgres    false    79            �           0    0    TABLE pg_inherits    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_inherits TO statsuser;
       
   pg_catalog          postgres    false    34            �           0    0    TABLE pg_init_privs    ACL     :   GRANT ALL ON TABLE pg_catalog.pg_init_privs TO statsuser;
       
   pg_catalog          postgres    false    51            �           0    0    TABLE pg_language    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_language TO statsuser;
       
   pg_catalog          postgres    false    35                        0    0    TABLE pg_largeobject    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_largeobject TO statsuser;
       
   pg_catalog          postgres    false    36                       0    0    TABLE pg_largeobject_metadata    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_largeobject_metadata TO statsuser;
       
   pg_catalog          postgres    false    45                       0    0    TABLE pg_locks    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_locks TO statsuser;
       
   pg_catalog          postgres    false    85                       0    0    TABLE pg_matviews    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_matviews TO statsuser;
       
   pg_catalog          postgres    false    78                       0    0    TABLE pg_namespace    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_namespace TO statsuser;
       
   pg_catalog          postgres    false    37                       0    0    TABLE pg_opclass    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_opclass TO statsuser;
       
   pg_catalog          postgres    false    38                       0    0    TABLE pg_operator    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_operator TO statsuser;
       
   pg_catalog          postgres    false    39                       0    0    TABLE pg_opfamily    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_opfamily TO statsuser;
       
   pg_catalog          postgres    false    43                       0    0    TABLE pg_partitioned_table    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_partitioned_table TO statsuser;
       
   pg_catalog          postgres    false    49            	           0    0    TABLE pg_policies    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_policies TO statsuser;
       
   pg_catalog          postgres    false    74            
           0    0    TABLE pg_policy    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_policy TO statsuser;
       
   pg_catalog          postgres    false    48                       0    0    TABLE pg_prepared_statements    ACL     C   GRANT ALL ON TABLE pg_catalog.pg_prepared_statements TO statsuser;
       
   pg_catalog          postgres    false    90                       0    0    TABLE pg_prepared_xacts    ACL     >   GRANT ALL ON TABLE pg_catalog.pg_prepared_xacts TO statsuser;
       
   pg_catalog          postgres    false    89                       0    0    TABLE pg_proc    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_proc TO statsuser;
       
   pg_catalog          postgres    false    13                       0    0    TABLE pg_publication    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_publication TO statsuser;
       
   pg_catalog          postgres    false    68                       0    0    TABLE pg_publication_rel    ACL     ?   GRANT ALL ON TABLE pg_catalog.pg_publication_rel TO statsuser;
       
   pg_catalog          postgres    false    69                       0    0    TABLE pg_publication_tables    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_publication_tables TO statsuser;
       
   pg_catalog          postgres    false    84                       0    0    TABLE pg_range    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_range TO statsuser;
       
   pg_catalog          postgres    false    56                       0    0    TABLE pg_replication_origin    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_replication_origin TO statsuser;
       
   pg_catalog          postgres    false    65                       0    0 "   TABLE pg_replication_origin_status    ACL     I   GRANT ALL ON TABLE pg_catalog.pg_replication_origin_status TO statsuser;
       
   pg_catalog          postgres    false    141                       0    0    TABLE pg_replication_slots    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_replication_slots TO statsuser;
       
   pg_catalog          postgres    false    125                       0    0    TABLE pg_rewrite    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_rewrite TO statsuser;
       
   pg_catalog          postgres    false    40                       0    0    TABLE pg_roles    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_roles TO statsuser;
       
   pg_catalog          postgres    false    70                       0    0    TABLE pg_rules    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_rules TO statsuser;
       
   pg_catalog          postgres    false    75                       0    0    TABLE pg_seclabel    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_seclabel TO statsuser;
       
   pg_catalog          postgres    false    59                       0    0    TABLE pg_seclabels    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_seclabels TO statsuser;
       
   pg_catalog          postgres    false    91                       0    0    TABLE pg_sequence    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_sequence TO statsuser;
       
   pg_catalog          postgres    false    20                       0    0    TABLE pg_sequences    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_sequences TO statsuser;
       
   pg_catalog          postgres    false    80                       0    0    TABLE pg_settings    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_settings TO statsuser;
       
   pg_catalog          postgres    false    92                       0    0    TABLE pg_shadow    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_shadow TO statsuser;
       
   pg_catalog          postgres    false    71                       0    0    TABLE pg_shdepend    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_shdepend TO statsuser;
       
   pg_catalog          postgres    false    10                       0    0    TABLE pg_shdescription    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_shdescription TO statsuser;
       
   pg_catalog          postgres    false    22                        0    0    TABLE pg_shmem_allocations    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_shmem_allocations TO statsuser;
       
   pg_catalog          postgres    false    98            !           0    0    TABLE pg_shseclabel    ACL     :   GRANT ALL ON TABLE pg_catalog.pg_shseclabel TO statsuser;
       
   pg_catalog          postgres    false    58            "           0    0    TABLE pg_stat_activity    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_stat_activity TO statsuser;
       
   pg_catalog          postgres    false    118            #           0    0    TABLE pg_stat_all_indexes    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_stat_all_indexes TO statsuser;
       
   pg_catalog          postgres    false    109            $           0    0    TABLE pg_stat_all_tables    ACL     ?   GRANT ALL ON TABLE pg_catalog.pg_stat_all_tables TO statsuser;
       
   pg_catalog          postgres    false    100            %           0    0    TABLE pg_stat_archiver    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_stat_archiver TO statsuser;
       
   pg_catalog          postgres    false    131            &           0    0    TABLE pg_stat_bgwriter    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_stat_bgwriter TO statsuser;
       
   pg_catalog          postgres    false    132            '           0    0    TABLE pg_stat_database    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_stat_database TO statsuser;
       
   pg_catalog          postgres    false    127            (           0    0     TABLE pg_stat_database_conflicts    ACL     G   GRANT ALL ON TABLE pg_catalog.pg_stat_database_conflicts TO statsuser;
       
   pg_catalog          postgres    false    128            )           0    0    TABLE pg_stat_gssapi    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_stat_gssapi TO statsuser;
       
   pg_catalog          postgres    false    124            *           0    0    TABLE pg_stat_progress_analyze    ACL     E   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_analyze TO statsuser;
       
   pg_catalog          postgres    false    134            +           0    0 !   TABLE pg_stat_progress_basebackup    ACL     H   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_basebackup TO statsuser;
       
   pg_catalog          postgres    false    138            ,           0    0    TABLE pg_stat_progress_cluster    ACL     E   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_cluster TO statsuser;
       
   pg_catalog          postgres    false    136            -           0    0    TABLE pg_stat_progress_copy    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_copy TO statsuser;
       
   pg_catalog          postgres    false    139            .           0    0 #   TABLE pg_stat_progress_create_index    ACL     J   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_create_index TO statsuser;
       
   pg_catalog          postgres    false    137            /           0    0    TABLE pg_stat_progress_vacuum    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_vacuum TO statsuser;
       
   pg_catalog          postgres    false    135            0           0    0    TABLE pg_stat_replication    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_stat_replication TO statsuser;
       
   pg_catalog          postgres    false    119            1           0    0    TABLE pg_stat_replication_slots    ACL     F   GRANT ALL ON TABLE pg_catalog.pg_stat_replication_slots TO statsuser;
       
   pg_catalog          postgres    false    126            2           0    0    TABLE pg_stat_slru    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_stat_slru TO statsuser;
       
   pg_catalog          postgres    false    120            3           0    0    TABLE pg_stat_ssl    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_stat_ssl TO statsuser;
       
   pg_catalog          postgres    false    123            4           0    0    TABLE pg_stat_subscription    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_stat_subscription TO statsuser;
       
   pg_catalog          postgres    false    122            5           0    0    TABLE pg_stat_sys_indexes    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_stat_sys_indexes TO statsuser;
       
   pg_catalog          postgres    false    110            6           0    0    TABLE pg_stat_sys_tables    ACL     ?   GRANT ALL ON TABLE pg_catalog.pg_stat_sys_tables TO statsuser;
       
   pg_catalog          postgres    false    102            7           0    0    TABLE pg_stat_user_functions    ACL     C   GRANT ALL ON TABLE pg_catalog.pg_stat_user_functions TO statsuser;
       
   pg_catalog          postgres    false    129            8           0    0    TABLE pg_stat_user_indexes    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_stat_user_indexes TO statsuser;
       
   pg_catalog          postgres    false    111            9           0    0    TABLE pg_stat_user_tables    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_stat_user_tables TO statsuser;
       
   pg_catalog          postgres    false    104            :           0    0    TABLE pg_stat_wal    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_stat_wal TO statsuser;
       
   pg_catalog          postgres    false    133            ;           0    0    TABLE pg_stat_wal_receiver    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_stat_wal_receiver TO statsuser;
       
   pg_catalog          postgres    false    121            <           0    0    TABLE pg_stat_xact_all_tables    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_stat_xact_all_tables TO statsuser;
       
   pg_catalog          postgres    false    101            =           0    0    TABLE pg_stat_xact_sys_tables    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_stat_xact_sys_tables TO statsuser;
       
   pg_catalog          postgres    false    103            >           0    0 !   TABLE pg_stat_xact_user_functions    ACL     H   GRANT ALL ON TABLE pg_catalog.pg_stat_xact_user_functions TO statsuser;
       
   pg_catalog          postgres    false    130            ?           0    0    TABLE pg_stat_xact_user_tables    ACL     E   GRANT ALL ON TABLE pg_catalog.pg_stat_xact_user_tables TO statsuser;
       
   pg_catalog          postgres    false    105            @           0    0    TABLE pg_statio_all_indexes    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_statio_all_indexes TO statsuser;
       
   pg_catalog          postgres    false    112            A           0    0    TABLE pg_statio_all_sequences    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_statio_all_sequences TO statsuser;
       
   pg_catalog          postgres    false    115            B           0    0    TABLE pg_statio_all_tables    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_statio_all_tables TO statsuser;
       
   pg_catalog          postgres    false    106            C           0    0    TABLE pg_statio_sys_indexes    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_statio_sys_indexes TO statsuser;
       
   pg_catalog          postgres    false    113            D           0    0    TABLE pg_statio_sys_sequences    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_statio_sys_sequences TO statsuser;
       
   pg_catalog          postgres    false    116            E           0    0    TABLE pg_statio_sys_tables    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_statio_sys_tables TO statsuser;
       
   pg_catalog          postgres    false    107            F           0    0    TABLE pg_statio_user_indexes    ACL     C   GRANT ALL ON TABLE pg_catalog.pg_statio_user_indexes TO statsuser;
       
   pg_catalog          postgres    false    114            G           0    0    TABLE pg_statio_user_sequences    ACL     E   GRANT ALL ON TABLE pg_catalog.pg_statio_user_sequences TO statsuser;
       
   pg_catalog          postgres    false    117            H           0    0    TABLE pg_statio_user_tables    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_statio_user_tables TO statsuser;
       
   pg_catalog          postgres    false    108            I           0    0    TABLE pg_statistic    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_statistic TO statsuser;
       
   pg_catalog          postgres    false    41            J           0    0    TABLE pg_statistic_ext    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_statistic_ext TO statsuser;
       
   pg_catalog          postgres    false    50            K           0    0    TABLE pg_statistic_ext_data    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_statistic_ext_data TO statsuser;
       
   pg_catalog          postgres    false    52            L           0    0    TABLE pg_stats    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_stats TO statsuser;
       
   pg_catalog          postgres    false    81            M           0    0    TABLE pg_stats_ext    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_stats_ext TO statsuser;
       
   pg_catalog          postgres    false    82            N           0    0    TABLE pg_stats_ext_exprs    ACL     ?   GRANT ALL ON TABLE pg_catalog.pg_stats_ext_exprs TO statsuser;
       
   pg_catalog          postgres    false    83            O           0    0    TABLE pg_subscription    ACL     <   GRANT ALL ON TABLE pg_catalog.pg_subscription TO statsuser;
       
   pg_catalog          postgres    false    66            P           0    0    TABLE pg_subscription_rel    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_subscription_rel TO statsuser;
       
   pg_catalog          postgres    false    67            Q           0    0    TABLE pg_tables    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_tables TO statsuser;
       
   pg_catalog          postgres    false    77            R           0    0    TABLE pg_tablespace    ACL     :   GRANT ALL ON TABLE pg_catalog.pg_tablespace TO statsuser;
       
   pg_catalog          postgres    false    9            S           0    0    TABLE pg_timezone_abbrevs    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_timezone_abbrevs TO statsuser;
       
   pg_catalog          postgres    false    95            T           0    0    TABLE pg_timezone_names    ACL     >   GRANT ALL ON TABLE pg_catalog.pg_timezone_names TO statsuser;
       
   pg_catalog          postgres    false    96            U           0    0    TABLE pg_transform    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_transform TO statsuser;
       
   pg_catalog          postgres    false    57            V           0    0    TABLE pg_trigger    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_trigger TO statsuser;
       
   pg_catalog          postgres    false    42            W           0    0    TABLE pg_ts_config    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_ts_config TO statsuser;
       
   pg_catalog          postgres    false    62            X           0    0    TABLE pg_ts_config_map    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_ts_config_map TO statsuser;
       
   pg_catalog          postgres    false    63            Y           0    0    TABLE pg_ts_dict    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_ts_dict TO statsuser;
       
   pg_catalog          postgres    false    60            Z           0    0    TABLE pg_ts_parser    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_ts_parser TO statsuser;
       
   pg_catalog          postgres    false    61            [           0    0    TABLE pg_ts_template    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_ts_template TO statsuser;
       
   pg_catalog          postgres    false    64            \           0    0    TABLE pg_type    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_type TO statsuser;
       
   pg_catalog          postgres    false    11            ]           0    0    TABLE pg_user    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_user TO statsuser;
       
   pg_catalog          postgres    false    73            ^           0    0    TABLE pg_user_mapping    ACL     <   GRANT ALL ON TABLE pg_catalog.pg_user_mapping TO statsuser;
       
   pg_catalog          postgres    false    19            _           0    0    TABLE pg_user_mappings    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_user_mappings TO statsuser;
       
   pg_catalog          postgres    false    140            `           0    0    TABLE pg_views    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_views TO statsuser;
       
   pg_catalog          postgres    false    76            �            1259    589611    category    TABLE     }   CREATE TABLE public.category (
    id bigint NOT NULL,
    title text NOT NULL,
    active boolean DEFAULT false NOT NULL
);
    DROP TABLE public.category;
       public         heap 	   statsuser    false            �            1259    589617    category_id_seq    SEQUENCE     �   ALTER TABLE public.category ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.category_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   statsuser    false    216            a           0    0    TABLE geography_columns    ACL     :   GRANT ALL ON TABLE public.geography_columns TO statsuser;
          public          postgres    false    214            b           0    0    TABLE geometry_columns    ACL     9   GRANT ALL ON TABLE public.geometry_columns TO statsuser;
          public          postgres    false    215            �            1259    589618    long_term_anomaly_info    TABLE     �   CREATE TABLE public.long_term_anomaly_info (
    id bigint NOT NULL,
    anomaly_product_description_id bigint NOT NULL,
    statistics_product_description_id bigint NOT NULL,
    current_product_description_id bigint NOT NULL
);
 *   DROP TABLE public.long_term_anomaly_info;
       public         heap 	   statsuser    false            �            1259    589621    long_term_anomaly_info_id_seq    SEQUENCE     �   CREATE SEQUENCE public.long_term_anomaly_info_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 4   DROP SEQUENCE public.long_term_anomaly_info_id_seq;
       public       	   statsuser    false    218            c           0    0    long_term_anomaly_info_id_seq    SEQUENCE OWNED BY     _   ALTER SEQUENCE public.long_term_anomaly_info_id_seq OWNED BY public.long_term_anomaly_info.id;
          public       	   statsuser    false    219            �            1259    589622    output_product_id_seq    SEQUENCE     ~   CREATE SEQUENCE public.output_product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE public.output_product_id_seq;
       public       	   statsuser    false            �            1259    589623 
   poly_stats    TABLE     �  CREATE TABLE public.poly_stats (
    id bigint NOT NULL,
    poly_id bigint,
    product_file_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
    DROP TABLE public.poly_stats;
       public         heap 	   statsuser    false            �            1259    589631    poly_stats_id_seq    SEQUENCE     z   CREATE SEQUENCE public.poly_stats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.poly_stats_id_seq;
       public       	   statsuser    false    221            d           0    0    poly_stats_id_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE public.poly_stats_id_seq OWNED BY public.poly_stats.id;
          public       	   statsuser    false    222            �            1259    589632    product    TABLE     �   CREATE TABLE public.product (
    id bigint NOT NULL,
    name text[] NOT NULL,
    type text DEFAULT 'raw'::text NOT NULL,
    category_id bigint
);
    DROP TABLE public.product;
       public         heap 	   statsuser    false            �            1259    589638    product_file    TABLE       CREATE TABLE public.product_file (
    id bigint NOT NULL,
    product_description_id bigint NOT NULL,
    rel_file_path text NOT NULL,
    date timestamp without time zone NOT NULL,
    date_created timestamp without time zone DEFAULT (now() AT TIME ZONE 'UTC'::text)
);
     DROP TABLE public.product_file;
       public         heap 	   statsuser    false            �            1259    589644    product_file_description    TABLE     p  CREATE TABLE public.product_file_description (
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
    file_name_creation_pattern text,
    histogram_bins smallint,
    min_value double precision,
    max_value double precision
);
 ,   DROP TABLE public.product_file_description;
       public         heap 	   statsuser    false            �            1259    589649    product_file_id_seq    SEQUENCE     |   CREATE SEQUENCE public.product_file_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.product_file_id_seq;
       public       	   statsuser    false    224            e           0    0    product_file_id_seq    SEQUENCE OWNED BY     K   ALTER SEQUENCE public.product_file_id_seq OWNED BY public.product_file.id;
          public       	   statsuser    false    226            �            1259    589650    product_id_seq    SEQUENCE     w   CREATE SEQUENCE public.product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public.product_id_seq;
       public       	   statsuser    false    225            f           0    0    product_id_seq    SEQUENCE OWNED BY     R   ALTER SEQUENCE public.product_id_seq OWNED BY public.product_file_description.id;
          public       	   statsuser    false    227            �            1259    589651    product_id_seq1    SEQUENCE     x   CREATE SEQUENCE public.product_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.product_id_seq1;
       public       	   statsuser    false    223            g           0    0    product_id_seq1    SEQUENCE OWNED BY     B   ALTER SEQUENCE public.product_id_seq1 OWNED BY public.product.id;
          public       	   statsuser    false    228            h           0    0    TABLE spatial_ref_sys    ACL     8   GRANT ALL ON TABLE public.spatial_ref_sys TO statsuser;
          public          postgres    false    212            �            1259    589652    stratification    TABLE     m   CREATE TABLE public.stratification (
    id bigint NOT NULL,
    description text,
    tilelayer_url text
);
 "   DROP TABLE public.stratification;
       public         heap 	   statsuser    false            �            1259    589657    stratification_geom    TABLE     �   CREATE TABLE public.stratification_geom (
    id bigint NOT NULL,
    stratification_id bigint NOT NULL,
    geom public.geometry(MultiPolygon,4326),
    geom3857 public.geometry(MultiPolygon,3857),
    description text
);
 '   DROP TABLE public.stratification_geom;
       public         heap 	   statsuser    false    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2            �            1259    589662    stratification_geom_id_seq    SEQUENCE     �   CREATE SEQUENCE public.stratification_geom_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE public.stratification_geom_id_seq;
       public       	   statsuser    false    230            i           0    0    stratification_geom_id_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE public.stratification_geom_id_seq OWNED BY public.stratification_geom.id;
          public       	   statsuser    false    231            �            1259    589663    stratification_id_seq    SEQUENCE     ~   CREATE SEQUENCE public.stratification_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE public.stratification_id_seq;
       public       	   statsuser    false    229            j           0    0    stratification_id_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE public.stratification_id_seq OWNED BY public.stratification.id;
          public       	   statsuser    false    232            �            1259    589664    poly_stats_per_region    TABLE     Z  CREATE TABLE tmp.poly_stats_per_region (
    id bigint NOT NULL,
    poly_id bigint,
    product_file_id bigint NOT NULL,
    region_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 &   DROP TABLE tmp.poly_stats_per_region;
       tmp         heap 	   statsuser    false    5            �            1259    589672    poly_stats_per_region_id_seq    SEQUENCE     �   CREATE SEQUENCE tmp.poly_stats_per_region_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE tmp.poly_stats_per_region_id_seq;
       tmp       	   statsuser    false    5    233            k           0    0    poly_stats_per_region_id_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE tmp.poly_stats_per_region_id_seq OWNED BY tmp.poly_stats_per_region.id;
          tmp       	   statsuser    false    234                       2604    589673    long_term_anomaly_info id    DEFAULT     �   ALTER TABLE ONLY public.long_term_anomaly_info ALTER COLUMN id SET DEFAULT nextval('public.long_term_anomaly_info_id_seq'::regclass);
 H   ALTER TABLE public.long_term_anomaly_info ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    219    218                       2604    589674    poly_stats id    DEFAULT     n   ALTER TABLE ONLY public.poly_stats ALTER COLUMN id SET DEFAULT nextval('public.poly_stats_id_seq'::regclass);
 <   ALTER TABLE public.poly_stats ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    222    221                       2604    589675 
   product id    DEFAULT     i   ALTER TABLE ONLY public.product ALTER COLUMN id SET DEFAULT nextval('public.product_id_seq1'::regclass);
 9   ALTER TABLE public.product ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    228    223                        2604    589676    product_file id    DEFAULT     r   ALTER TABLE ONLY public.product_file ALTER COLUMN id SET DEFAULT nextval('public.product_file_id_seq'::regclass);
 >   ALTER TABLE public.product_file ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    226    224            !           2604    589677    product_file_description id    DEFAULT     y   ALTER TABLE ONLY public.product_file_description ALTER COLUMN id SET DEFAULT nextval('public.product_id_seq'::regclass);
 J   ALTER TABLE public.product_file_description ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    227    225            "           2604    589678    stratification id    DEFAULT     v   ALTER TABLE ONLY public.stratification ALTER COLUMN id SET DEFAULT nextval('public.stratification_id_seq'::regclass);
 @   ALTER TABLE public.stratification ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    232    229            #           2604    589679    stratification_geom id    DEFAULT     �   ALTER TABLE ONLY public.stratification_geom ALTER COLUMN id SET DEFAULT nextval('public.stratification_geom_id_seq'::regclass);
 E   ALTER TABLE public.stratification_geom ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    231    230            '           2604    589680    poly_stats_per_region id    DEFAULT     ~   ALTER TABLE ONLY tmp.poly_stats_per_region ALTER COLUMN id SET DEFAULT nextval('tmp.poly_stats_per_region_id_seq'::regclass);
 D   ALTER TABLE tmp.poly_stats_per_region ALTER COLUMN id DROP DEFAULT;
       tmp       	   statsuser    false    234    233            �          0    589611    category 
   TABLE DATA           5   COPY public.category (id, title, active) FROM stdin;
    public       	   statsuser    false    216   ��       �          0    589618    long_term_anomaly_info 
   TABLE DATA           �   COPY public.long_term_anomaly_info (id, anomaly_product_description_id, statistics_product_description_id, current_product_description_id) FROM stdin;
    public       	   statsuser    false    218   ��       �          0    589623 
   poly_stats 
   TABLE DATA           	  COPY public.poly_stats (id, poly_id, product_file_id, mean, sd, min_val, max_val, noval_area_ha, sparse_area_ha, mid_area_ha, dense_area_ha, noval_color, sparseval_color, midval_color, highval_color, histogram, total_pixels, valid_pixels, date_created) FROM stdin;
    public       	   statsuser    false    221   �       �          0    589632    product 
   TABLE DATA           >   COPY public.product (id, name, type, category_id) FROM stdin;
    public       	   statsuser    false    223   0�       �          0    589638    product_file 
   TABLE DATA           e   COPY public.product_file (id, product_description_id, rel_file_path, date, date_created) FROM stdin;
    public       	   statsuser    false    224   ��       �          0    589644    product_file_description 
   TABLE DATA           @  COPY public.product_file_description (id, pattern, types, create_date, variable, style, description, low_value, mid_value, high_value, noval_colors, sparseval_colors, midval_colors, highval_colors, min_prod_value, max_prod_value, product_id, file_name_creation_pattern, histogram_bins, min_value, max_value) FROM stdin;
    public       	   statsuser    false    225   �                 0    588879    spatial_ref_sys 
   TABLE DATA           X   COPY public.spatial_ref_sys (srid, auth_name, auth_srid, srtext, proj4text) FROM stdin;
    public          postgres    false    212   �      �          0    589652    stratification 
   TABLE DATA           H   COPY public.stratification (id, description, tilelayer_url) FROM stdin;
    public       	   statsuser    false    229         �          0    589657    stratification_geom 
   TABLE DATA           a   COPY public.stratification_geom (id, stratification_id, geom, geom3857, description) FROM stdin;
    public       	   statsuser    false    230   5      �          0    589664    poly_stats_per_region 
   TABLE DATA           �   COPY tmp.poly_stats_per_region (id, poly_id, product_file_id, region_id, mean, sd, min_val, max_val, noval_area_ha, sparse_area_ha, mid_area_ha, dense_area_ha, histogram, total_pixels, valid_pixels, date_created) FROM stdin;
    tmp       	   statsuser    false    233   R      l           0    0    category_id_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public.category_id_seq', 6, true);
          public       	   statsuser    false    217            m           0    0    long_term_anomaly_info_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.long_term_anomaly_info_id_seq', 1, true);
          public       	   statsuser    false    219            n           0    0    output_product_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.output_product_id_seq', 1, false);
          public       	   statsuser    false    220            o           0    0    poly_stats_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.poly_stats_id_seq', 1, false);
          public       	   statsuser    false    222            p           0    0    product_file_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.product_file_id_seq', 1, false);
          public       	   statsuser    false    226            q           0    0    product_id_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public.product_id_seq', 20, true);
          public       	   statsuser    false    227            r           0    0    product_id_seq1    SEQUENCE SET     >   SELECT pg_catalog.setval('public.product_id_seq1', 10, true);
          public       	   statsuser    false    228            s           0    0    stratification_geom_id_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public.stratification_geom_id_seq', 1, false);
          public       	   statsuser    false    231            t           0    0    stratification_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.stratification_id_seq', 1, false);
          public       	   statsuser    false    232            u           0    0    poly_stats_per_region_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('tmp.poly_stats_per_region_id_seq', 1, false);
          tmp       	   statsuser    false    234                       2606    613910 0   long_term_anomaly_info long_term_anomaly_info_pk 
   CONSTRAINT     n   ALTER TABLE ONLY public.long_term_anomaly_info
    ADD CONSTRAINT long_term_anomaly_info_pk PRIMARY KEY (id);
 Z   ALTER TABLE ONLY public.long_term_anomaly_info DROP CONSTRAINT long_term_anomaly_info_pk;
       public         	   statsuser    false    218            	           2606    613912    category newtable_pk 
   CONSTRAINT     R   ALTER TABLE ONLY public.category
    ADD CONSTRAINT newtable_pk PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.category DROP CONSTRAINT newtable_pk;
       public         	   statsuser    false    216                       2606    613914    poly_stats poly_stats_pk 
   CONSTRAINT     V   ALTER TABLE ONLY public.poly_stats
    ADD CONSTRAINT poly_stats_pk PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.poly_stats DROP CONSTRAINT poly_stats_pk;
       public         	   statsuser    false    221                       2606    613922    poly_stats poly_stats_un 
   CONSTRAINT     g   ALTER TABLE ONLY public.poly_stats
    ADD CONSTRAINT poly_stats_un UNIQUE (poly_id, product_file_id);
 B   ALTER TABLE ONLY public.poly_stats DROP CONSTRAINT poly_stats_un;
       public         	   statsuser    false    221    221                       2606    613924 6   product_file product_file_date_product_description_idx 
   CONSTRAINT     �   ALTER TABLE ONLY public.product_file
    ADD CONSTRAINT product_file_date_product_description_idx UNIQUE (product_description_id, rel_file_path);
 `   ALTER TABLE ONLY public.product_file DROP CONSTRAINT product_file_date_product_description_idx;
       public         	   statsuser    false    224    224                       2606    613926    product_file product_file_pk 
   CONSTRAINT     Z   ALTER TABLE ONLY public.product_file
    ADD CONSTRAINT product_file_pk PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.product_file DROP CONSTRAINT product_file_pk;
       public         	   statsuser    false    224                       2606    613928 #   product_file_description product_pk 
   CONSTRAINT     a   ALTER TABLE ONLY public.product_file_description
    ADD CONSTRAINT product_pk PRIMARY KEY (id);
 M   ALTER TABLE ONLY public.product_file_description DROP CONSTRAINT product_pk;
       public         	   statsuser    false    225                       2606    613930    product product_pk1 
   CONSTRAINT     Q   ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_pk1 PRIMARY KEY (id);
 =   ALTER TABLE ONLY public.product DROP CONSTRAINT product_pk1;
       public         	   statsuser    false    223                       2606    613932     stratification stratification_pk 
   CONSTRAINT     ^   ALTER TABLE ONLY public.stratification
    ADD CONSTRAINT stratification_pk PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.stratification DROP CONSTRAINT stratification_pk;
       public         	   statsuser    false    229                        2606    613934 '   stratification_geom stratification_pkey 
   CONSTRAINT     e   ALTER TABLE ONLY public.stratification_geom
    ADD CONSTRAINT stratification_pkey PRIMARY KEY (id);
 Q   ALTER TABLE ONLY public.stratification_geom DROP CONSTRAINT stratification_pkey;
       public         	   statsuser    false    230                       2606    613936     stratification stratification_un 
   CONSTRAINT     b   ALTER TABLE ONLY public.stratification
    ADD CONSTRAINT stratification_un UNIQUE (description);
 J   ALTER TABLE ONLY public.stratification DROP CONSTRAINT stratification_un;
       public         	   statsuser    false    229            "           2606    613938 #   poly_stats_per_region poly_stats_pk 
   CONSTRAINT     ^   ALTER TABLE ONLY tmp.poly_stats_per_region
    ADD CONSTRAINT poly_stats_pk PRIMARY KEY (id);
 J   ALTER TABLE ONLY tmp.poly_stats_per_region DROP CONSTRAINT poly_stats_pk;
       tmp         	   statsuser    false    233            $           2606    613940 #   poly_stats_per_region poly_stats_un 
   CONSTRAINT     z   ALTER TABLE ONLY tmp.poly_stats_per_region
    ADD CONSTRAINT poly_stats_un UNIQUE (poly_id, product_file_id, region_id);
 J   ALTER TABLE ONLY tmp.poly_stats_per_region DROP CONSTRAINT poly_stats_un;
       tmp         	   statsuser    false    233    233    233                       1259    613941 '   product_file_product_description_id_idx    INDEX     �   CREATE UNIQUE INDEX product_file_product_description_id_idx ON public.product_file USING btree (product_description_id, rel_file_path);
 ;   DROP INDEX public.product_file_product_description_id_idx;
       public         	   statsuser    false    224    224                       1259    613942    sidx_stratification_geom    INDEX     W   CREATE INDEX sidx_stratification_geom ON public.stratification_geom USING gist (geom);
 ,   DROP INDEX public.sidx_stratification_geom;
       public         	   statsuser    false    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    230                       1259    613943    sidx_stratification_geom3857    INDEX     �   CREATE INDEX sidx_stratification_geom3857 ON public.stratification_geom USING gist (geom3857);

ALTER TABLE public.stratification_geom CLUSTER ON sidx_stratification_geom3857;
 0   DROP INDEX public.sidx_stratification_geom3857;
       public         	   statsuser    false    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    230            %           2606    613944 0   long_term_anomaly_info long_term_anomaly_info_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.long_term_anomaly_info
    ADD CONSTRAINT long_term_anomaly_info_fk FOREIGN KEY (anomaly_product_description_id) REFERENCES public.product_file_description(id) ON UPDATE CASCADE ON DELETE CASCADE;
 Z   ALTER TABLE ONLY public.long_term_anomaly_info DROP CONSTRAINT long_term_anomaly_info_fk;
       public       	   statsuser    false    225    4376    218            &           2606    613949 2   long_term_anomaly_info long_term_anomaly_info_fk_1    FK CONSTRAINT     �   ALTER TABLE ONLY public.long_term_anomaly_info
    ADD CONSTRAINT long_term_anomaly_info_fk_1 FOREIGN KEY (statistics_product_description_id) REFERENCES public.product_file_description(id) ON UPDATE CASCADE ON DELETE CASCADE;
 \   ALTER TABLE ONLY public.long_term_anomaly_info DROP CONSTRAINT long_term_anomaly_info_fk_1;
       public       	   statsuser    false    225    4376    218            '           2606    613954 2   long_term_anomaly_info long_term_anomaly_info_fk_2    FK CONSTRAINT     �   ALTER TABLE ONLY public.long_term_anomaly_info
    ADD CONSTRAINT long_term_anomaly_info_fk_2 FOREIGN KEY (current_product_description_id) REFERENCES public.product_file_description(id) ON UPDATE CASCADE ON DELETE CASCADE;
 \   ALTER TABLE ONLY public.long_term_anomaly_info DROP CONSTRAINT long_term_anomaly_info_fk_2;
       public       	   statsuser    false    4376    218    225            (           2606    613959 %   poly_stats poly_stats_product_file_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats
    ADD CONSTRAINT poly_stats_product_file_fk FOREIGN KEY (product_file_id) REFERENCES public.product_file(id) ON UPDATE CASCADE ON DELETE CASCADE;
 O   ALTER TABLE ONLY public.poly_stats DROP CONSTRAINT poly_stats_product_file_fk;
       public       	   statsuser    false    4373    224    221            )           2606    613964 ,   poly_stats poly_stats_stratification_geom_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats
    ADD CONSTRAINT poly_stats_stratification_geom_fk FOREIGN KEY (poly_id) REFERENCES public.stratification_geom(id) ON UPDATE CASCADE ON DELETE CASCADE;
 V   ALTER TABLE ONLY public.poly_stats DROP CONSTRAINT poly_stats_stratification_geom_fk;
       public       	   statsuser    false    230    4384    221            +           2606    613969    product_file product_file_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.product_file
    ADD CONSTRAINT product_file_fk FOREIGN KEY (product_description_id) REFERENCES public.product_file_description(id) ON UPDATE CASCADE ON DELETE CASCADE;
 F   ALTER TABLE ONLY public.product_file DROP CONSTRAINT product_file_fk;
       public       	   statsuser    false    225    224    4376            *           2606    613974    product product_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_fk FOREIGN KEY (category_id) REFERENCES public.category(id) ON UPDATE CASCADE ON DELETE CASCADE;
 <   ALTER TABLE ONLY public.product DROP CONSTRAINT product_fk;
       public       	   statsuser    false    4361    223    216            ,           2606    613979 *   stratification_geom stratification_geom_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.stratification_geom
    ADD CONSTRAINT stratification_geom_fk FOREIGN KEY (stratification_id) REFERENCES public.stratification(id) ON DELETE CASCADE;
 T   ALTER TABLE ONLY public.stratification_geom DROP CONSTRAINT stratification_geom_fk;
       public       	   statsuser    false    4378    229    230            -           2606    613984 0   poly_stats_per_region poly_stats_product_file_fk    FK CONSTRAINT     �   ALTER TABLE ONLY tmp.poly_stats_per_region
    ADD CONSTRAINT poly_stats_product_file_fk FOREIGN KEY (product_file_id) REFERENCES public.product_file(id) ON UPDATE CASCADE ON DELETE CASCADE;
 W   ALTER TABLE ONLY tmp.poly_stats_per_region DROP CONSTRAINT poly_stats_product_file_fk;
       tmp       	   statsuser    false    4373    233    224            .           2606    613989 7   poly_stats_per_region poly_stats_stratification_geom_fk    FK CONSTRAINT     �   ALTER TABLE ONLY tmp.poly_stats_per_region
    ADD CONSTRAINT poly_stats_stratification_geom_fk FOREIGN KEY (poly_id) REFERENCES public.stratification_geom(id) ON UPDATE CASCADE ON DELETE CASCADE;
 ^   ALTER TABLE ONLY tmp.poly_stats_per_region DROP CONSTRAINT poly_stats_stratification_geom_fk;
       tmp       	   statsuser    false    233    230    4384            �   Z   x�3�t�K-J��L�2�O,I-�L8��*�2R�R�\SN�������b όӽ(�4/E�)�85(`����Z�X����Y����� owq      �      x�3�44�4�4����� c�      �      x������ � �      �   �   x�U��
�0���g�pjE�K-Y҆�c���\,!B|��Ӊ������@w�T.4'q�����ju��pI��@�@0X�2���OH���Te�y�R�Hɗ��[5�QR�߸l�G�t�̦�ʏ8Ǘ�M6C4����md���v�Ý_��,��h�l��LXJ¨�B���NZ��m!��Jge      �      x������ � �      �      x���TG��������g\�2ݢ[�h���1n���#ULU���,�C�ΓLdQ�Y�8�]���
�Ɛ��<�y��sb��B�|�����ᓧ�_?~t����'�?����ᓋ����?���?=8�����gꦸ)o������/��?���_>��^�p���������u�����<���b�(���y��c����!~u�ٗ�>�OU������|��Ӄ�W�t���3M?���ƏP�#?>¿<�����~�c�pl���}J>zx���蜔���?:��i^�X�O�79��g�{�A�����??����g�7�(��t{�O�o�~����,���w��u�?����G����y*�<����)c"��c�I�^�t����������89�s�;7��q>)/��߹�ק����7ǟ=9{T�����ޯg��ū���������������[���'����g7������r�ho�/��������w/;y����?��e�_m}Y�F���?��Y=��.���ot���k:}Z������I�]���E��?}�
^s�̭_ֹPټ���HſJ/��0��R
)�?r��/�ڶ��os����������~\o_.'G/����!���m:>�GO�Q������k._��iz{��^p��''�Os�|��Op��|��oq������p��~�����?�W�����s�M:z]�n��������O�����t|�����D>JK=��]޼�΍���n���WR�R�JJ]WJ_I��J�+)s]){%e�+室�u������T��
ו�WR�ڧ�z����p�_����)/�}������>��z��k��r=���|������\O~y��_������/W �	P+���� ��h=,��"bE�a�� �X+�[	PH��J�a�� e���~Xl%@!�z��V�'bQ�a�� ���eXl%@!�V��/V4��eXl%@#�i]��V�"bV�a1��A�[	�H@v��a�� m�X6�w+	(��b+	(^��QC�h$�zm�G�����5�J�D,�0,�`��&|2�C�Y	0��3<�� 4��\�Mi�� �`,�ݰ�J����f%�x"��aV�LX��aV�l(v��k%�
��_�ؕ �����dW�"b�Av%�">z;<ٕ ����d���l�� �`���5�J�ERvx԰+61m�G�`��%Y;<j�� '����.n%�!9%;<�� ������V�&b�An%�!enx�p+�1�G�@��)7�[	p��i7�[	p��Y7|y�V\$b���W� b���W�$b���W<!`In'��	��	�+�P��j�J��T?L�_	���M���,�0~%����S�_	�H@��V� b�Oua% H"��0a% ("����V�&b!O(a% "�0Na% X"���	%�G�r�)�O�J�P����0�SX	��"���W"!��0�S\	�������W"!��0�S\	���b���W"!��8�S\	����Q�	%�a��J@$��'��	%�a�"b���')���8�`�	JA�Ó�`�	�A�q*)�������"Xc��PuK
0�����O.R�=&�%�u
� DT��')�"���0R�I&5��IF�Q�NqkuI�T�X�~�<.T�[�6?�8h�_��Z�l$����D�-c􌻜\�'��1��]N/� �}�.g��IG�q��q����#�:F���e20��"T���O=`KE��S�8d
K(--�SX�R*Z^�!Y*JE���*��.㐁�,�+Z����A��c��@�����2>@��,�Oni�*2^lT���b?Q�w��%z��w�q��T��8
mY�'F��EH�鐍�(`,Kt���r�`-KM��>����`.Kt���r��,���˛�s|&�Y��4Ϙg�b��c�]n20�%q�Ss�k��%��5v�qf�h��4��,���f�^suͤqf��a���r�̂�,��k:�_T��,�q��ˍ3��DϹʦ�8�`:Kt�K�\d�D��,�w.�ˍ3ƳD��&7�`=K�����ƙ�Y��\bm��m��%��%��'F0�%:��W�J��RT����YGZ�]L������CU����#Z�]d]���$X����/����$�����og�8�`GK��s�i|�S�!-ё�K�a�Y��%z�9�0��+����J����'F��%���W?�$.�h�U�!kZ�7�M������Ng]���!����Og���'F0�%:�YT3nI��%z�K�:0��
t�����'F��%��K�ʏ3F�D�zI]n�Y��%z�K�ҏO�`VKt�_Ÿ�*=�. ��r�#�����qf����Y/�ˍ3��D�zQ��;�lk���"J�B�`\Kt�S�r�̂u-ѻN����	�D�:�.7�,���봔~���`�X�x�[���B�gLl�.v?�8^|$�Ɩ�c'SC�l�NvRŏ�YI��%z�I�Ƈ 0�%�ٱˑ*�ώK1�jm��v�E�W�I��%z��F1�S[��m�\���kGU�xݡc[��En9lu*B�u��R�����9g�h��v7��C�G���>���T޶Bo;��gx�
���s��A�z�Af?^#���V�m���x��o[���s�9h~Coۧl�K�x�
�m2��\������6+�6�^g9^1���V�m{��x5�o[�����8r@zۮ,Վw\�����vi�9��m�e��B�����vnI�-
�m�޶3��D�����vr	��-
��۶m��7
[��۶�Ҙ#���@��_�x����h��mX�x��i���[4G�@oۚE��z)l�Fo۪E���)l�FoۊEp�
��MIm��Na�4z�fIe�P�����6�Oe9��m��b��Y�z�Ƥ4�H���V�m�"G�@oۈ�{Fx�
�m]��gU�m+����G�@o[�d�[wx�
�m�o+V�m+���M�!޶Bo[��;�x�
�m-����m���x��o[���rl��
�m��vg�p�
����y�g_�����V6.�y
�m��v?	G�@o�_�D3>ς���ۖ5��$޶Bo[��B�2��R�<�	t�|���{hKtܻ'in�g�0G�[?؟�D���B��j6�x���q���(k>��#@�E��}��It�xX�GDN�y�^�Z�G��t?�ͣ�݋��t���Z�ypS���>~��u��~�z3�_x��Otx3���ҥ�Y�L*�y��He�w3���;Zx��F.t�O�nb�����V����T�������c-���ñ������'����?~2	z�3�r&W��ʙ\���L��]j&W���ʙ\�El&W���m7xpG�fr�V��\9�+����ʙ\�El&W���-�_3�r&Wn�ɕ3�r��L��ɕ[�fr�L��"6�+gr���\9�+����ʙ\�El&W���]�fr�L��In&W���]�fr坙\���L��ɕ;���ʙ\���L��ɕ;���ʙ\���L��ɕ;���ʙ\���L��ɕ;���ʙ\���L��ɕ�����;3�r'��\9�+w��ɕ3�r'��\9�+w��ɕ3�r'��\9�+w��ɕ3�r'��\9�+w��ɕ3��Gɕ��������w9;9]j���ۓ󓳷�����9�ݿ�_���?N�E�x�������x7���=EB/�M;̻�$ā��͛ʹ˙v9�.g��R3�rw��v9$6�.g����v9�.���=!�i�[�f��L��"6�.g����v9�.��~ʹ˙v�El�]δ�-b3�r�]n�i�3�r��L��i�[�f��L��"6�.g����v9�.w��i�3�r'��v9�.w��i�wf��Nr3�r�]�$7�.g��Nr3�r�]�$7�.g��Nr3�r�]�$7�.g��Nr3�r�]�$7�.g��Nr3�r�]�"7�.�̴˝�f��L��In�]δ˝�f��L��In�]δ˝�f��L��In�]δ˝�f��L�� �  In�]δ��]~ur��������V���wY�_�����ߨOf��?ǻ��~����D�qS��}F��4����<ʹ�����H˧��n���-�^�n�n�9	�PR�l���-�/z������f�寚oy�^�O�\/����\�P�,��/P�����Xz
�e��W3(K.ϴ��si���KeY��ǰ���)���,=�o��`rKo\�
�^�y�޹D�@UB`�����[���;��EtÙ� "Yktay��"�.څ�*�(�u`]uD?��	.�3�X<Rp5�+������
.ad��1�"�b�1	+=x��(�?5�\6ʤ�cޘ-�b^�;�)�J��bY�pŜW�b��W�y��(ڌ�Q<E\�6d��)Z��d�y��rqW,>G3�bl�>G3d��9]�s�1C֍��%��<f�ұ�Cx[/Lx̐�c�R�K3dٻR!��y5��x/*$B�!����^ h3���]]G\�c��bh���cד�����1�	3�4�7�1�	3A4�%�1c3A5HS�1c3���v�������z>3��llHm{���3!�uV0<fp�٘��ʌ�1�K�FG��<fp�٨h�:�3�\�E��<fp�وQ��.;�3|���vU�M(���*�$	��1��Uc��<f��J��k˼�'��)6��1�MVڤ��1�}VZ�
c��1��VZ,�A�)��Rm鷆�"�l�Re��<y�`ϕZ�PW��l�RqIue����+�R׹����+�W{���_�MW���^���ʦB<*���R2�
��<f�K��:�:3�x�9�u4s<f�K�������,��ȳ�1�MY2Y ���euES A���f�Xl�W3؝%C�y��=�l��1C�'s����R<�l��%C�,����5�w�c��d���x�`����O5�"�l��z��I3�0S�)�<f�qK��L$�)"3���Wy�`�V���i�<f��K���z���Ш���
 ��>.e�D!�<f��K�Za�>��n��%n�T3�Х�E�ĕ"���Ңɸ~3���ui��{��~�i�X�1��]:6�ٴ<f��K��N�"�l�2�9�b�LG� L����&.���'W0]Ml�2����L_{��h�g�d:���euK��-��&vY�51���nb�]Z�p��7�̶�ł�pb3����<�&��Ď0�&�2]Nl��{b*�`rDz�D�$��LMl3�Z�����K,�͞/�&�#,�5����`���z��T�&�RꮉA�L��P�t��Xǭ�R���&�u�Z,�kb�)�#,��k�����k�ݘ$.5Ʈ�٧�:���]�^�a�@l�h8��u$=u�|�� ���l�5�������|ׄq�Y=@�TSl�62�H�j�]���251Ң��ї�����I:'�#,#XLD��,�yJʭX�H���dr��Kn�f�251��D��d��dr�%�4�C���
�o�h29²�k%�L��� �ZP�YY@"Ys��dr��E�D4�ayA�5 G����Zl%l2+HLk	�M&GXdPR�8�1�H`kɕD3�hjk-�h29�R�*J%�L��ؠ��q�dV��jJ"�L��࠺�Yq@�\k(�h29¢���!��*j��tQxƬ; 鮵A4�a�Am�M&Gd�Q����l<�r$�L����&{�dV ���f�%�L��n�.k���lJ�$�L��ޤa����D���d���G�D��$���lX�,�Of=I���fE��mM���5	$#�k���U	�nf�/0����4e��cV&���VS�m*��	$7�k:�I�Y�@�c����>��	$A�k
܏�Y�@bd[�E���F�d�n<a�6�*I7A�A���NAҽP�UkY�dV*H�%jT
�yf���;�����0�H�l+!�F>�z�4�6�:b�+�#�]jwWb�,��ٮ�q(f�	�mK�G�n��϶�3��Ŭ\ �-�(����Q5z'�wf�	�m�k	�3�H"m�^H��Y�@bi�s7bc�0�l�f]½�U$���q;;fI�m��q�Y�@�j�rd�Af-ɫm�V��Y�@Bk����Ȭg ɵ�و���z_�	a�LPf=ɰ���K4�dv�b=C]�4�}���3�*�M�Y�@"mk0���If=ɵ��D���>�z�j�h2�O���n��!łY�@bn�2�h29�z�*n���$�4�0��Y�@RoKхh29�z�������z�[��;�dr$ɺ����̬g I��iK4�a=C1Zc�5���d��%�dr����J4�a=C.*cR87�����@�����D���3d�<��ss��!�&�#�g�]�h29�z���d0������KQ�h29�z�e��h29�z�%�J4��z+3n/��g �����h29"��ߺ�&7M�lf#=�dr��)IG4�a=C
�M&GXϐ��D���3�~�@4�a=ClRM&GX��hD���3�(*j2�Hot�M&GX�7������B�wf=I���8�1�H4o"M&GX���D���3)�dr���	K4�a=��]C��a=�O�\3l�g�݄�>L�e���Ӗr�Z_���o�.���{*�=����}�ہ���^���.|���|��T{_����:|�����W��z�~�3O�<Ѷ��~��y�����_J���=���w �#������.�@�!�~+�L��U�zߤ���l<��r���ѽ�r|��u���}f�F�΃����{Y�T4��?yx�^W3��g#dH��K ��]l][�������\<ܯo^��������Ó��O����'�� ��_�=���f�����6��˄>����b�w�&��� �n^{���8����M=����3yS�T���������}�sy����������<�w�����a���a_�`w�za���������t�χ�d����G���            x������ � �      �      x������ � �      �      x������ � �      �      x������ � �     