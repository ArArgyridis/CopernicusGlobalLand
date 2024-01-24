PGDMP                       |            jrcstats    16.1    16.1 Y   �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            �           1262    16388    jrcstats    DATABASE     p   CREATE DATABASE jrcstats WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'C.UTF-8';
    DROP DATABASE jrcstats;
             	   statsuser    false            �           0    0    SCHEMA pg_catalog    ACL     -   GRANT ALL ON SCHEMA pg_catalog TO statsuser;
                   postgres    false    5            �           0    0    SCHEMA public    ACL     )   GRANT ALL ON SCHEMA public TO statsuser;
                   pg_database_owner    false    8                        2615    16390    tmp    SCHEMA        CREATE SCHEMA tmp;
    DROP SCHEMA tmp;
                postgres    false            �           0    0 
   SCHEMA tmp    ACL     &   GRANT ALL ON SCHEMA tmp TO statsuser;
                   postgres    false    4                        3079    16391    fuzzystrmatch 	   EXTENSION     A   CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;
    DROP EXTENSION fuzzystrmatch;
                   false            �           0    0    EXTENSION fuzzystrmatch    COMMENT     ]   COMMENT ON EXTENSION fuzzystrmatch IS 'determine similarities and distance between strings';
                        false    2                        3079    16403    postgis 	   EXTENSION     ;   CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;
    DROP EXTENSION postgis;
                   false            �           0    0    EXTENSION postgis    COMMENT     ^   COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';
                        false    3            �           1255    17479    clms_updatepolygonstats()    FUNCTION     �  CREATE FUNCTION public.clms_updatepolygonstats() RETURNS smallint
    LANGUAGE plpgsql COST 1000
    AS $$
declare ret smallint;
begin
	
	WITH merged_data AS (
	SELECT poly_id, product_file_id, product_file_variable_id, SUM(mean) mean, SUM(sd) sd, min(min_val) min_val, max(max_val) max_val, SUM(total_pixels) total_pixels, SUM(valid_pixels) valid_pixels,
	SUM(noval_area_ha) noval_area_ha, SUM(sparse_area_ha) sparse_area_ha, SUM(mid_area_ha) mid_area_ha, SUM(dense_area_ha) dense_area_ha
	FROM tmp.poly_stats_per_region pspr
	GROUP BY poly_id, product_file_id, product_file_variable_id
),raw_hist_data AS(
	SELECT x.poly_id, x.product_file_id, x.idx, SUM((x.cnt)::integer) hist_val
	FROM (
    	SELECT pspr.id, pspr.poly_id, pspr.product_file_id, pspr.product_file_variable_id, t.* 
    	FROM TMP.poly_stats_per_region pspr, jsonb_array_elements(histogram->'y') with ordinality as t(cnt, idx)
	) as x
	GROUP BY x.poly_id, x.product_file_id, x.product_file_variable_id, x.idx
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
insert into poly_stats (poly_id, product_file_id, product_file_variable_id, mean, sd, min_val, max_val, total_pixels,valid_pixels,noval_area_ha,
sparse_area_ha,mid_area_ha,dense_area_ha,histogram)
SELECT 
md.poly_id, md.product_file_id, md.product_file_variable_id
, CASE WHEN valid_pixels = 0 THEN null ELSE mean/valid_pixels END mean
, CASE WHEN valid_pixels = 0 OR sd/valid_pixels < power(mean/valid_pixels,2) THEN null ELSE sqrt(sd/valid_pixels - power(mean/valid_pixels,2))  END sd
,min_val, max_val, total_pixels, valid_pixels, noval_area_ha, sparse_area_ha, mid_area_ha, dense_area_ha
,hst.histogram
FROM merged_data md 
JOIN histogram hst ON md.product_file_id = hst.product_file_id AND md.poly_id = hst.poly_id
--ORDER BY md.product_file_id, md.poly_id
ON CONFLICT (poly_id, product_file_id, product_file_variable_id) DO NOTHING;
RETURN 0;

end;$$;
 0   DROP FUNCTION public.clms_updatepolygonstats();
       public          postgres    false            �           0    0    TABLE pg_aggregate    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_aggregate TO statsuser;
       
   pg_catalog          postgres    false    24            �           0    0    TABLE pg_am    ACL     2   GRANT ALL ON TABLE pg_catalog.pg_am TO statsuser;
       
   pg_catalog          postgres    false    25            �           0    0    TABLE pg_amop    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_amop TO statsuser;
       
   pg_catalog          postgres    false    26            �           0    0    TABLE pg_amproc    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_amproc TO statsuser;
       
   pg_catalog          postgres    false    27            �           0    0    TABLE pg_attrdef    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_attrdef TO statsuser;
       
   pg_catalog          postgres    false    28            �           0    0    TABLE pg_attribute    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_attribute TO statsuser;
       
   pg_catalog          postgres    false    13            �           0    0    TABLE pg_auth_members    ACL     <   GRANT ALL ON TABLE pg_catalog.pg_auth_members TO statsuser;
       
   pg_catalog          postgres    false    17            �           0    0    TABLE pg_authid    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_authid TO statsuser;
       
   pg_catalog          postgres    false    16            �           0    0 %   TABLE pg_available_extension_versions    ACL     L   GRANT ALL ON TABLE pg_catalog.pg_available_extension_versions TO statsuser;
       
   pg_catalog          postgres    false    91            �           0    0    TABLE pg_available_extensions    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_available_extensions TO statsuser;
       
   pg_catalog          postgres    false    90            �           0    0     TABLE pg_backend_memory_contexts    ACL     G   GRANT ALL ON TABLE pg_catalog.pg_backend_memory_contexts TO statsuser;
       
   pg_catalog          postgres    false    103            �           0    0    TABLE pg_cast    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_cast TO statsuser;
       
   pg_catalog          postgres    false    29            �           0    0    TABLE pg_class    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_class TO statsuser;
       
   pg_catalog          postgres    false    15            �           0    0    TABLE pg_collation    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_collation TO statsuser;
       
   pg_catalog          postgres    false    54            �           0    0    TABLE pg_config    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_config TO statsuser;
       
   pg_catalog          postgres    false    101            �           0    0    TABLE pg_constraint    ACL     :   GRANT ALL ON TABLE pg_catalog.pg_constraint TO statsuser;
       
   pg_catalog          postgres    false    30            �           0    0    TABLE pg_conversion    ACL     :   GRANT ALL ON TABLE pg_catalog.pg_conversion TO statsuser;
       
   pg_catalog          postgres    false    31            �           0    0    TABLE pg_cursors    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_cursors TO statsuser;
       
   pg_catalog          postgres    false    89            �           0    0    TABLE pg_database    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_database TO statsuser;
       
   pg_catalog          postgres    false    18            �           0    0    TABLE pg_db_role_setting    ACL     ?   GRANT ALL ON TABLE pg_catalog.pg_db_role_setting TO statsuser;
       
   pg_catalog          postgres    false    45            �           0    0    TABLE pg_default_acl    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_default_acl TO statsuser;
       
   pg_catalog          postgres    false    9            �           0    0    TABLE pg_depend    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_depend TO statsuser;
       
   pg_catalog          postgres    false    32            �           0    0    TABLE pg_description    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_description TO statsuser;
       
   pg_catalog          postgres    false    33            �           0    0    TABLE pg_enum    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_enum TO statsuser;
       
   pg_catalog          postgres    false    56            �           0    0    TABLE pg_event_trigger    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_event_trigger TO statsuser;
       
   pg_catalog          postgres    false    55            �           0    0    TABLE pg_extension    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_extension TO statsuser;
       
   pg_catalog          postgres    false    47            �           0    0    TABLE pg_file_settings    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_file_settings TO statsuser;
       
   pg_catalog          postgres    false    96            �           0    0    TABLE pg_foreign_data_wrapper    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_foreign_data_wrapper TO statsuser;
       
   pg_catalog          postgres    false    22            �           0    0    TABLE pg_foreign_server    ACL     >   GRANT ALL ON TABLE pg_catalog.pg_foreign_server TO statsuser;
       
   pg_catalog          postgres    false    19            �           0    0    TABLE pg_foreign_table    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_foreign_table TO statsuser;
       
   pg_catalog          postgres    false    48            �           0    0    TABLE pg_group    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_group TO statsuser;
       
   pg_catalog          postgres    false    75            �           0    0    TABLE pg_hba_file_rules    ACL     >   GRANT ALL ON TABLE pg_catalog.pg_hba_file_rules TO statsuser;
       
   pg_catalog          postgres    false    97            �           0    0    TABLE pg_ident_file_mappings    ACL     C   GRANT ALL ON TABLE pg_catalog.pg_ident_file_mappings TO statsuser;
       
   pg_catalog          postgres    false    98            �           0    0    TABLE pg_index    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_index TO statsuser;
       
   pg_catalog          postgres    false    34            �           0    0    TABLE pg_indexes    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_indexes TO statsuser;
       
   pg_catalog          postgres    false    82            �           0    0    TABLE pg_inherits    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_inherits TO statsuser;
       
   pg_catalog          postgres    false    35            �           0    0    TABLE pg_init_privs    ACL     :   GRANT ALL ON TABLE pg_catalog.pg_init_privs TO statsuser;
       
   pg_catalog          postgres    false    52            �           0    0    TABLE pg_language    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_language TO statsuser;
       
   pg_catalog          postgres    false    36            �           0    0    TABLE pg_largeobject    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_largeobject TO statsuser;
       
   pg_catalog          postgres    false    37            �           0    0    TABLE pg_largeobject_metadata    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_largeobject_metadata TO statsuser;
       
   pg_catalog          postgres    false    46            �           0    0    TABLE pg_locks    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_locks TO statsuser;
       
   pg_catalog          postgres    false    88            �           0    0    TABLE pg_matviews    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_matviews TO statsuser;
       
   pg_catalog          postgres    false    81            �           0    0    TABLE pg_namespace    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_namespace TO statsuser;
       
   pg_catalog          postgres    false    38            �           0    0    TABLE pg_opclass    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_opclass TO statsuser;
       
   pg_catalog          postgres    false    39            �           0    0    TABLE pg_operator    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_operator TO statsuser;
       
   pg_catalog          postgres    false    40            �           0    0    TABLE pg_opfamily    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_opfamily TO statsuser;
       
   pg_catalog          postgres    false    44            �           0    0    TABLE pg_parameter_acl    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_parameter_acl TO statsuser;
       
   pg_catalog          postgres    false    72            �           0    0    TABLE pg_partitioned_table    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_partitioned_table TO statsuser;
       
   pg_catalog          postgres    false    50            �           0    0    TABLE pg_policies    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_policies TO statsuser;
       
   pg_catalog          postgres    false    77            �           0    0    TABLE pg_policy    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_policy TO statsuser;
       
   pg_catalog          postgres    false    49            �           0    0    TABLE pg_prepared_statements    ACL     C   GRANT ALL ON TABLE pg_catalog.pg_prepared_statements TO statsuser;
       
   pg_catalog          postgres    false    93            �           0    0    TABLE pg_prepared_xacts    ACL     >   GRANT ALL ON TABLE pg_catalog.pg_prepared_xacts TO statsuser;
       
   pg_catalog          postgres    false    92            �           0    0    TABLE pg_proc    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_proc TO statsuser;
       
   pg_catalog          postgres    false    14            �           0    0    TABLE pg_publication    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_publication TO statsuser;
       
   pg_catalog          postgres    false    69            �           0    0    TABLE pg_publication_namespace    ACL     E   GRANT ALL ON TABLE pg_catalog.pg_publication_namespace TO statsuser;
       
   pg_catalog          postgres    false    71            �           0    0    TABLE pg_publication_rel    ACL     ?   GRANT ALL ON TABLE pg_catalog.pg_publication_rel TO statsuser;
       
   pg_catalog          postgres    false    70            �           0    0    TABLE pg_publication_tables    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_publication_tables TO statsuser;
       
   pg_catalog          postgres    false    87            �           0    0    TABLE pg_range    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_range TO statsuser;
       
   pg_catalog          postgres    false    57            �           0    0    TABLE pg_replication_origin    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_replication_origin TO statsuser;
       
   pg_catalog          postgres    false    66            �           0    0 "   TABLE pg_replication_origin_status    ACL     I   GRANT ALL ON TABLE pg_catalog.pg_replication_origin_status TO statsuser;
       
   pg_catalog          postgres    false    147            �           0    0    TABLE pg_replication_slots    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_replication_slots TO statsuser;
       
   pg_catalog          postgres    false    130            �           0    0    TABLE pg_rewrite    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_rewrite TO statsuser;
       
   pg_catalog          postgres    false    41            �           0    0    TABLE pg_roles    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_roles TO statsuser;
       
   pg_catalog          postgres    false    73            �           0    0    TABLE pg_rules    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_rules TO statsuser;
       
   pg_catalog          postgres    false    78            �           0    0    TABLE pg_seclabel    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_seclabel TO statsuser;
       
   pg_catalog          postgres    false    60            �           0    0    TABLE pg_seclabels    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_seclabels TO statsuser;
       
   pg_catalog          postgres    false    94            �           0    0    TABLE pg_sequence    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_sequence TO statsuser;
       
   pg_catalog          postgres    false    21            �           0    0    TABLE pg_sequences    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_sequences TO statsuser;
       
   pg_catalog          postgres    false    83            �           0    0    TABLE pg_settings    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_settings TO statsuser;
       
   pg_catalog          postgres    false    95            �           0    0    TABLE pg_shadow    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_shadow TO statsuser;
       
   pg_catalog          postgres    false    74            �           0    0    TABLE pg_shdepend    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_shdepend TO statsuser;
       
   pg_catalog          postgres    false    11            �           0    0    TABLE pg_shdescription    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_shdescription TO statsuser;
       
   pg_catalog          postgres    false    23            �           0    0    TABLE pg_shmem_allocations    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_shmem_allocations TO statsuser;
       
   pg_catalog          postgres    false    102            �           0    0    TABLE pg_shseclabel    ACL     :   GRANT ALL ON TABLE pg_catalog.pg_shseclabel TO statsuser;
       
   pg_catalog          postgres    false    59            �           0    0    TABLE pg_stat_activity    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_stat_activity TO statsuser;
       
   pg_catalog          postgres    false    122            �           0    0    TABLE pg_stat_all_indexes    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_stat_all_indexes TO statsuser;
       
   pg_catalog          postgres    false    113            �           0    0    TABLE pg_stat_all_tables    ACL     ?   GRANT ALL ON TABLE pg_catalog.pg_stat_all_tables TO statsuser;
       
   pg_catalog          postgres    false    104            �           0    0    TABLE pg_stat_archiver    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_stat_archiver TO statsuser;
       
   pg_catalog          postgres    false    136            �           0    0    TABLE pg_stat_bgwriter    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_stat_bgwriter TO statsuser;
       
   pg_catalog          postgres    false    137            �           0    0    TABLE pg_stat_database    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_stat_database TO statsuser;
       
   pg_catalog          postgres    false    132            �           0    0     TABLE pg_stat_database_conflicts    ACL     G   GRANT ALL ON TABLE pg_catalog.pg_stat_database_conflicts TO statsuser;
       
   pg_catalog          postgres    false    133            �           0    0    TABLE pg_stat_gssapi    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_stat_gssapi TO statsuser;
       
   pg_catalog          postgres    false    129            �           0    0    TABLE pg_stat_io    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_stat_io TO statsuser;
       
   pg_catalog          postgres    false    138            �           0    0    TABLE pg_stat_progress_analyze    ACL     E   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_analyze TO statsuser;
       
   pg_catalog          postgres    false    140            �           0    0 !   TABLE pg_stat_progress_basebackup    ACL     H   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_basebackup TO statsuser;
       
   pg_catalog          postgres    false    144            �           0    0    TABLE pg_stat_progress_cluster    ACL     E   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_cluster TO statsuser;
       
   pg_catalog          postgres    false    142            �           0    0    TABLE pg_stat_progress_copy    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_copy TO statsuser;
       
   pg_catalog          postgres    false    145            �           0    0 #   TABLE pg_stat_progress_create_index    ACL     J   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_create_index TO statsuser;
       
   pg_catalog          postgres    false    143            �           0    0    TABLE pg_stat_progress_vacuum    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_vacuum TO statsuser;
       
   pg_catalog          postgres    false    141            �           0    0    TABLE pg_stat_recovery_prefetch    ACL     F   GRANT ALL ON TABLE pg_catalog.pg_stat_recovery_prefetch TO statsuser;
       
   pg_catalog          postgres    false    126            �           0    0    TABLE pg_stat_replication    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_stat_replication TO statsuser;
       
   pg_catalog          postgres    false    123            �           0    0    TABLE pg_stat_replication_slots    ACL     F   GRANT ALL ON TABLE pg_catalog.pg_stat_replication_slots TO statsuser;
       
   pg_catalog          postgres    false    131            �           0    0    TABLE pg_stat_slru    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_stat_slru TO statsuser;
       
   pg_catalog          postgres    false    124            �           0    0    TABLE pg_stat_ssl    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_stat_ssl TO statsuser;
       
   pg_catalog          postgres    false    128            �           0    0    TABLE pg_stat_subscription    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_stat_subscription TO statsuser;
       
   pg_catalog          postgres    false    127            �           0    0     TABLE pg_stat_subscription_stats    ACL     G   GRANT ALL ON TABLE pg_catalog.pg_stat_subscription_stats TO statsuser;
       
   pg_catalog          postgres    false    148                        0    0    TABLE pg_stat_sys_indexes    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_stat_sys_indexes TO statsuser;
       
   pg_catalog          postgres    false    114                       0    0    TABLE pg_stat_sys_tables    ACL     ?   GRANT ALL ON TABLE pg_catalog.pg_stat_sys_tables TO statsuser;
       
   pg_catalog          postgres    false    106                       0    0    TABLE pg_stat_user_functions    ACL     C   GRANT ALL ON TABLE pg_catalog.pg_stat_user_functions TO statsuser;
       
   pg_catalog          postgres    false    134                       0    0    TABLE pg_stat_user_indexes    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_stat_user_indexes TO statsuser;
       
   pg_catalog          postgres    false    115                       0    0    TABLE pg_stat_user_tables    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_stat_user_tables TO statsuser;
       
   pg_catalog          postgres    false    108                       0    0    TABLE pg_stat_wal    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_stat_wal TO statsuser;
       
   pg_catalog          postgres    false    139                       0    0    TABLE pg_stat_wal_receiver    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_stat_wal_receiver TO statsuser;
       
   pg_catalog          postgres    false    125                       0    0    TABLE pg_stat_xact_all_tables    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_stat_xact_all_tables TO statsuser;
       
   pg_catalog          postgres    false    105                       0    0    TABLE pg_stat_xact_sys_tables    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_stat_xact_sys_tables TO statsuser;
       
   pg_catalog          postgres    false    107            	           0    0 !   TABLE pg_stat_xact_user_functions    ACL     H   GRANT ALL ON TABLE pg_catalog.pg_stat_xact_user_functions TO statsuser;
       
   pg_catalog          postgres    false    135            
           0    0    TABLE pg_stat_xact_user_tables    ACL     E   GRANT ALL ON TABLE pg_catalog.pg_stat_xact_user_tables TO statsuser;
       
   pg_catalog          postgres    false    109                       0    0    TABLE pg_statio_all_indexes    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_statio_all_indexes TO statsuser;
       
   pg_catalog          postgres    false    116                       0    0    TABLE pg_statio_all_sequences    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_statio_all_sequences TO statsuser;
       
   pg_catalog          postgres    false    119                       0    0    TABLE pg_statio_all_tables    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_statio_all_tables TO statsuser;
       
   pg_catalog          postgres    false    110                       0    0    TABLE pg_statio_sys_indexes    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_statio_sys_indexes TO statsuser;
       
   pg_catalog          postgres    false    117                       0    0    TABLE pg_statio_sys_sequences    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_statio_sys_sequences TO statsuser;
       
   pg_catalog          postgres    false    120                       0    0    TABLE pg_statio_sys_tables    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_statio_sys_tables TO statsuser;
       
   pg_catalog          postgres    false    111                       0    0    TABLE pg_statio_user_indexes    ACL     C   GRANT ALL ON TABLE pg_catalog.pg_statio_user_indexes TO statsuser;
       
   pg_catalog          postgres    false    118                       0    0    TABLE pg_statio_user_sequences    ACL     E   GRANT ALL ON TABLE pg_catalog.pg_statio_user_sequences TO statsuser;
       
   pg_catalog          postgres    false    121                       0    0    TABLE pg_statio_user_tables    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_statio_user_tables TO statsuser;
       
   pg_catalog          postgres    false    112                       0    0    TABLE pg_statistic    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_statistic TO statsuser;
       
   pg_catalog          postgres    false    42                       0    0    TABLE pg_statistic_ext    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_statistic_ext TO statsuser;
       
   pg_catalog          postgres    false    51                       0    0    TABLE pg_statistic_ext_data    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_statistic_ext_data TO statsuser;
       
   pg_catalog          postgres    false    53                       0    0    TABLE pg_stats    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_stats TO statsuser;
       
   pg_catalog          postgres    false    84                       0    0    TABLE pg_stats_ext    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_stats_ext TO statsuser;
       
   pg_catalog          postgres    false    85                       0    0    TABLE pg_stats_ext_exprs    ACL     ?   GRANT ALL ON TABLE pg_catalog.pg_stats_ext_exprs TO statsuser;
       
   pg_catalog          postgres    false    86                       0    0    TABLE pg_subscription    ACL     <   GRANT ALL ON TABLE pg_catalog.pg_subscription TO statsuser;
       
   pg_catalog          postgres    false    67                       0    0    TABLE pg_subscription_rel    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_subscription_rel TO statsuser;
       
   pg_catalog          postgres    false    68                       0    0    TABLE pg_tables    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_tables TO statsuser;
       
   pg_catalog          postgres    false    80                       0    0    TABLE pg_tablespace    ACL     :   GRANT ALL ON TABLE pg_catalog.pg_tablespace TO statsuser;
       
   pg_catalog          postgres    false    10                       0    0    TABLE pg_timezone_abbrevs    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_timezone_abbrevs TO statsuser;
       
   pg_catalog          postgres    false    99                       0    0    TABLE pg_timezone_names    ACL     >   GRANT ALL ON TABLE pg_catalog.pg_timezone_names TO statsuser;
       
   pg_catalog          postgres    false    100                        0    0    TABLE pg_transform    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_transform TO statsuser;
       
   pg_catalog          postgres    false    58            !           0    0    TABLE pg_trigger    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_trigger TO statsuser;
       
   pg_catalog          postgres    false    43            "           0    0    TABLE pg_ts_config    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_ts_config TO statsuser;
       
   pg_catalog          postgres    false    63            #           0    0    TABLE pg_ts_config_map    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_ts_config_map TO statsuser;
       
   pg_catalog          postgres    false    64            $           0    0    TABLE pg_ts_dict    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_ts_dict TO statsuser;
       
   pg_catalog          postgres    false    61            %           0    0    TABLE pg_ts_parser    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_ts_parser TO statsuser;
       
   pg_catalog          postgres    false    62            &           0    0    TABLE pg_ts_template    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_ts_template TO statsuser;
       
   pg_catalog          postgres    false    65            '           0    0    TABLE pg_type    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_type TO statsuser;
       
   pg_catalog          postgres    false    12            (           0    0    TABLE pg_user    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_user TO statsuser;
       
   pg_catalog          postgres    false    76            )           0    0    TABLE pg_user_mapping    ACL     <   GRANT ALL ON TABLE pg_catalog.pg_user_mapping TO statsuser;
       
   pg_catalog          postgres    false    20            *           0    0    TABLE pg_user_mappings    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_user_mappings TO statsuser;
       
   pg_catalog          postgres    false    146            +           0    0    TABLE pg_views    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_views TO statsuser;
       
   pg_catalog          postgres    false    79            �            1259    17480    category    TABLE     }   CREATE TABLE public.category (
    id bigint NOT NULL,
    title text NOT NULL,
    active boolean DEFAULT false NOT NULL
);
    DROP TABLE public.category;
       public         heap 	   statsuser    false            �            1259    17486    category_id_seq    SEQUENCE     �   ALTER TABLE public.category ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.category_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   statsuser    false    223            ,           0    0    TABLE geography_columns    ACL     :   GRANT ALL ON TABLE public.geography_columns TO statsuser;
          public          postgres    false    221            -           0    0    TABLE geometry_columns    ACL     9   GRANT ALL ON TABLE public.geometry_columns TO statsuser;
          public          postgres    false    222            �            1259    17487    long_term_anomaly_info    TABLE     �   CREATE TABLE public.long_term_anomaly_info (
    id bigint NOT NULL,
    anomaly_product_variable_id bigint NOT NULL,
    mean_variable_id bigint NOT NULL,
    stdev_variable_id bigint NOT NULL,
    raw_product_variable_id bigint NOT NULL
);
 *   DROP TABLE public.long_term_anomaly_info;
       public         heap 	   statsuser    false            �            1259    17490    long_term_anomaly_info_id_seq    SEQUENCE     �   CREATE SEQUENCE public.long_term_anomaly_info_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 4   DROP SEQUENCE public.long_term_anomaly_info_id_seq;
       public       	   statsuser    false    225            .           0    0    long_term_anomaly_info_id_seq    SEQUENCE OWNED BY     _   ALTER SEQUENCE public.long_term_anomaly_info_id_seq OWNED BY public.long_term_anomaly_info.id;
          public       	   statsuser    false    226            �            1259    17491    output_product_id_seq    SEQUENCE     ~   CREATE SEQUENCE public.output_product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE public.output_product_id_seq;
       public       	   statsuser    false            �            1259    17492 
   poly_stats    TABLE        CREATE TABLE public.poly_stats (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
)
PARTITION BY RANGE (product_file_variable_id, poly_id);
    DROP TABLE public.poly_stats;
       public         	   statsuser    false            �            1259    17498    poly_stats_10_1_257    TABLE     �  CREATE TABLE public.poly_stats_10_1_257 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 '   DROP TABLE public.poly_stats_10_1_257;
       public         heap 	   statsuser    false    228            �            1259    17506    poly_stats_10_257_279    TABLE     �  CREATE TABLE public.poly_stats_10_257_279 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 )   DROP TABLE public.poly_stats_10_257_279;
       public         heap 	   statsuser    false    228            �            1259    17514    poly_stats_10_279_285    TABLE     �  CREATE TABLE public.poly_stats_10_279_285 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 )   DROP TABLE public.poly_stats_10_279_285;
       public         heap 	   statsuser    false    228            �            1259    17522    poly_stats_10_285_38543    TABLE     �  CREATE TABLE public.poly_stats_10_285_38543 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 +   DROP TABLE public.poly_stats_10_285_38543;
       public         heap 	   statsuser    false    228            �            1259    17530    poly_stats_12_1_257    TABLE     �  CREATE TABLE public.poly_stats_12_1_257 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 '   DROP TABLE public.poly_stats_12_1_257;
       public         heap 	   statsuser    false    228            �            1259    17538    poly_stats_12_257_279    TABLE     �  CREATE TABLE public.poly_stats_12_257_279 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 )   DROP TABLE public.poly_stats_12_257_279;
       public         heap 	   statsuser    false    228            �            1259    17546    poly_stats_12_279_285    TABLE     �  CREATE TABLE public.poly_stats_12_279_285 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 )   DROP TABLE public.poly_stats_12_279_285;
       public         heap 	   statsuser    false    228            �            1259    17554    poly_stats_12_285_38543    TABLE     �  CREATE TABLE public.poly_stats_12_285_38543 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 +   DROP TABLE public.poly_stats_12_285_38543;
       public         heap 	   statsuser    false    228            �            1259    17562    poly_stats_14_1_257    TABLE     �  CREATE TABLE public.poly_stats_14_1_257 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 '   DROP TABLE public.poly_stats_14_1_257;
       public         heap 	   statsuser    false    228            �            1259    17570    poly_stats_14_257_279    TABLE     �  CREATE TABLE public.poly_stats_14_257_279 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 )   DROP TABLE public.poly_stats_14_257_279;
       public         heap 	   statsuser    false    228            �            1259    17578    poly_stats_14_279_285    TABLE     �  CREATE TABLE public.poly_stats_14_279_285 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 )   DROP TABLE public.poly_stats_14_279_285;
       public         heap 	   statsuser    false    228            �            1259    17586    poly_stats_14_285_38543    TABLE     �  CREATE TABLE public.poly_stats_14_285_38543 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 +   DROP TABLE public.poly_stats_14_285_38543;
       public         heap 	   statsuser    false    228            �            1259    17594    poly_stats_16_1_257    TABLE     �  CREATE TABLE public.poly_stats_16_1_257 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 '   DROP TABLE public.poly_stats_16_1_257;
       public         heap 	   statsuser    false    228            �            1259    17602    poly_stats_16_257_279    TABLE     �  CREATE TABLE public.poly_stats_16_257_279 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 )   DROP TABLE public.poly_stats_16_257_279;
       public         heap 	   statsuser    false    228            �            1259    17610    poly_stats_16_279_285    TABLE     �  CREATE TABLE public.poly_stats_16_279_285 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 )   DROP TABLE public.poly_stats_16_279_285;
       public         heap 	   statsuser    false    228            �            1259    17618    poly_stats_16_285_38543    TABLE     �  CREATE TABLE public.poly_stats_16_285_38543 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 +   DROP TABLE public.poly_stats_16_285_38543;
       public         heap 	   statsuser    false    228            �            1259    17626    poly_stats_17_1_257    TABLE     �  CREATE TABLE public.poly_stats_17_1_257 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 '   DROP TABLE public.poly_stats_17_1_257;
       public         heap 	   statsuser    false    228            �            1259    17634    poly_stats_17_257_279    TABLE     �  CREATE TABLE public.poly_stats_17_257_279 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 )   DROP TABLE public.poly_stats_17_257_279;
       public         heap 	   statsuser    false    228            �            1259    17642    poly_stats_17_279_285    TABLE     �  CREATE TABLE public.poly_stats_17_279_285 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 )   DROP TABLE public.poly_stats_17_279_285;
       public         heap 	   statsuser    false    228            �            1259    17650    poly_stats_17_285_38543    TABLE     �  CREATE TABLE public.poly_stats_17_285_38543 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 +   DROP TABLE public.poly_stats_17_285_38543;
       public         heap 	   statsuser    false    228            �            1259    17658    poly_stats_19_1_257    TABLE     �  CREATE TABLE public.poly_stats_19_1_257 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 '   DROP TABLE public.poly_stats_19_1_257;
       public         heap 	   statsuser    false    228            �            1259    17666    poly_stats_19_257_279    TABLE     �  CREATE TABLE public.poly_stats_19_257_279 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 )   DROP TABLE public.poly_stats_19_257_279;
       public         heap 	   statsuser    false    228            �            1259    17674    poly_stats_19_279_285    TABLE     �  CREATE TABLE public.poly_stats_19_279_285 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 )   DROP TABLE public.poly_stats_19_279_285;
       public         heap 	   statsuser    false    228            �            1259    17682    poly_stats_19_285_38543    TABLE     �  CREATE TABLE public.poly_stats_19_285_38543 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 +   DROP TABLE public.poly_stats_19_285_38543;
       public         heap 	   statsuser    false    228            �            1259    17690    poly_stats_1_1_257    TABLE     �  CREATE TABLE public.poly_stats_1_1_257 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 &   DROP TABLE public.poly_stats_1_1_257;
       public         heap 	   statsuser    false    228            �            1259    17698    poly_stats_1_257_279    TABLE     �  CREATE TABLE public.poly_stats_1_257_279 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 (   DROP TABLE public.poly_stats_1_257_279;
       public         heap 	   statsuser    false    228            �            1259    17706    poly_stats_1_279_285    TABLE     �  CREATE TABLE public.poly_stats_1_279_285 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 (   DROP TABLE public.poly_stats_1_279_285;
       public         heap 	   statsuser    false    228                        1259    17714    poly_stats_1_285_38543    TABLE     �  CREATE TABLE public.poly_stats_1_285_38543 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 *   DROP TABLE public.poly_stats_1_285_38543;
       public         heap 	   statsuser    false    228                       1259    17722    poly_stats_21_1_257    TABLE     �  CREATE TABLE public.poly_stats_21_1_257 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 '   DROP TABLE public.poly_stats_21_1_257;
       public         heap 	   statsuser    false    228                       1259    17730    poly_stats_21_257_279    TABLE     �  CREATE TABLE public.poly_stats_21_257_279 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 )   DROP TABLE public.poly_stats_21_257_279;
       public         heap 	   statsuser    false    228                       1259    17738    poly_stats_21_279_285    TABLE     �  CREATE TABLE public.poly_stats_21_279_285 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 )   DROP TABLE public.poly_stats_21_279_285;
       public         heap 	   statsuser    false    228                       1259    17746    poly_stats_21_285_38543    TABLE     �  CREATE TABLE public.poly_stats_21_285_38543 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 +   DROP TABLE public.poly_stats_21_285_38543;
       public         heap 	   statsuser    false    228                       1259    17754    poly_stats_24_1_257    TABLE     �  CREATE TABLE public.poly_stats_24_1_257 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 '   DROP TABLE public.poly_stats_24_1_257;
       public         heap 	   statsuser    false    228                       1259    17762    poly_stats_2_1_257    TABLE     �  CREATE TABLE public.poly_stats_2_1_257 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 &   DROP TABLE public.poly_stats_2_1_257;
       public         heap 	   statsuser    false    228                       1259    17770    poly_stats_2_257_279    TABLE     �  CREATE TABLE public.poly_stats_2_257_279 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 (   DROP TABLE public.poly_stats_2_257_279;
       public         heap 	   statsuser    false    228                       1259    17778    poly_stats_2_279_285    TABLE     �  CREATE TABLE public.poly_stats_2_279_285 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 (   DROP TABLE public.poly_stats_2_279_285;
       public         heap 	   statsuser    false    228            	           1259    17786    poly_stats_2_285_38543    TABLE     �  CREATE TABLE public.poly_stats_2_285_38543 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 *   DROP TABLE public.poly_stats_2_285_38543;
       public         heap 	   statsuser    false    228            
           1259    17794    poly_stats_3_1_257    TABLE     �  CREATE TABLE public.poly_stats_3_1_257 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 &   DROP TABLE public.poly_stats_3_1_257;
       public         heap 	   statsuser    false    228                       1259    17802    poly_stats_3_257_279    TABLE     �  CREATE TABLE public.poly_stats_3_257_279 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 (   DROP TABLE public.poly_stats_3_257_279;
       public         heap 	   statsuser    false    228                       1259    17810    poly_stats_3_279_285    TABLE     �  CREATE TABLE public.poly_stats_3_279_285 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 (   DROP TABLE public.poly_stats_3_279_285;
       public         heap 	   statsuser    false    228                       1259    17818    poly_stats_3_285_38543    TABLE     �  CREATE TABLE public.poly_stats_3_285_38543 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 *   DROP TABLE public.poly_stats_3_285_38543;
       public         heap 	   statsuser    false    228                       1259    17826    poly_stats_4_1_257    TABLE     �  CREATE TABLE public.poly_stats_4_1_257 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 &   DROP TABLE public.poly_stats_4_1_257;
       public         heap 	   statsuser    false    228                       1259    17834    poly_stats_4_257_279    TABLE     �  CREATE TABLE public.poly_stats_4_257_279 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 (   DROP TABLE public.poly_stats_4_257_279;
       public         heap 	   statsuser    false    228                       1259    17842    poly_stats_4_279_285    TABLE     �  CREATE TABLE public.poly_stats_4_279_285 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 (   DROP TABLE public.poly_stats_4_279_285;
       public         heap 	   statsuser    false    228                       1259    17850    poly_stats_4_285_38543    TABLE     �  CREATE TABLE public.poly_stats_4_285_38543 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 *   DROP TABLE public.poly_stats_4_285_38543;
       public         heap 	   statsuser    false    228                       1259    17858    poly_stats_5_1_257    TABLE     �  CREATE TABLE public.poly_stats_5_1_257 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 &   DROP TABLE public.poly_stats_5_1_257;
       public         heap 	   statsuser    false    228                       1259    17866    poly_stats_5_257_279    TABLE     �  CREATE TABLE public.poly_stats_5_257_279 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 (   DROP TABLE public.poly_stats_5_257_279;
       public         heap 	   statsuser    false    228                       1259    17874    poly_stats_5_279_285    TABLE     �  CREATE TABLE public.poly_stats_5_279_285 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 (   DROP TABLE public.poly_stats_5_279_285;
       public         heap 	   statsuser    false    228                       1259    17882    poly_stats_5_285_38543    TABLE     �  CREATE TABLE public.poly_stats_5_285_38543 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 *   DROP TABLE public.poly_stats_5_285_38543;
       public         heap 	   statsuser    false    228                       1259    17890    poly_stats_6_1_257    TABLE     �  CREATE TABLE public.poly_stats_6_1_257 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 &   DROP TABLE public.poly_stats_6_1_257;
       public         heap 	   statsuser    false    228                       1259    17898    poly_stats_6_257_279    TABLE     �  CREATE TABLE public.poly_stats_6_257_279 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 (   DROP TABLE public.poly_stats_6_257_279;
       public         heap 	   statsuser    false    228                       1259    17906    poly_stats_6_279_285    TABLE     �  CREATE TABLE public.poly_stats_6_279_285 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 (   DROP TABLE public.poly_stats_6_279_285;
       public         heap 	   statsuser    false    228                       1259    17914    poly_stats_6_285_38543    TABLE     �  CREATE TABLE public.poly_stats_6_285_38543 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 *   DROP TABLE public.poly_stats_6_285_38543;
       public         heap 	   statsuser    false    228                       1259    17922    poly_stats_7_1_257    TABLE     �  CREATE TABLE public.poly_stats_7_1_257 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 &   DROP TABLE public.poly_stats_7_1_257;
       public         heap 	   statsuser    false    228                       1259    17930    poly_stats_7_257_279    TABLE     �  CREATE TABLE public.poly_stats_7_257_279 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 (   DROP TABLE public.poly_stats_7_257_279;
       public         heap 	   statsuser    false    228                       1259    17938    poly_stats_7_279_285    TABLE     �  CREATE TABLE public.poly_stats_7_279_285 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 (   DROP TABLE public.poly_stats_7_279_285;
       public         heap 	   statsuser    false    228                       1259    17946    poly_stats_7_285_38543    TABLE     �  CREATE TABLE public.poly_stats_7_285_38543 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 *   DROP TABLE public.poly_stats_7_285_38543;
       public         heap 	   statsuser    false    228                       1259    17954    poly_stats_9_1_257    TABLE     �  CREATE TABLE public.poly_stats_9_1_257 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 &   DROP TABLE public.poly_stats_9_1_257;
       public         heap 	   statsuser    false    228                       1259    17962    poly_stats_9_257_279    TABLE     �  CREATE TABLE public.poly_stats_9_257_279 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 (   DROP TABLE public.poly_stats_9_257_279;
       public         heap 	   statsuser    false    228                        1259    17970    poly_stats_9_279_285    TABLE     �  CREATE TABLE public.poly_stats_9_279_285 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 (   DROP TABLE public.poly_stats_9_279_285;
       public         heap 	   statsuser    false    228            !           1259    17978    poly_stats_9_285_38543    TABLE     �  CREATE TABLE public.poly_stats_9_285_38543 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 *   DROP TABLE public.poly_stats_9_285_38543;
       public         heap 	   statsuser    false    228            "           1259    17986    product    TABLE     �   CREATE TABLE public.product (
    id bigint NOT NULL,
    name text[] NOT NULL,
    type text DEFAULT 'raw'::text NOT NULL,
    category_id bigint,
    description text
);
    DROP TABLE public.product;
       public         heap 	   statsuser    false            #           1259    17992    product_file    TABLE     +  CREATE TABLE public.product_file (
    id bigint NOT NULL,
    product_file_description_id bigint NOT NULL,
    rel_file_path text NOT NULL,
    rt_flag smallint,
    date timestamp without time zone NOT NULL,
    date_created timestamp without time zone DEFAULT (now() AT TIME ZONE 'UTC'::text)
);
     DROP TABLE public.product_file;
       public         heap 	   statsuser    false            $           1259    17998    product_file_description    TABLE     �   CREATE TABLE public.product_file_description (
    id bigint NOT NULL,
    product_id bigint,
    pattern text NOT NULL,
    types text NOT NULL,
    create_date text NOT NULL,
    file_name_creation_pattern text,
    rt_flag_pattern text
);
 ,   DROP TABLE public.product_file_description;
       public         heap 	   statsuser    false            %           1259    18003    product_file_description_id_seq    SEQUENCE     �   CREATE SEQUENCE public.product_file_description_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 6   DROP SEQUENCE public.product_file_description_id_seq;
       public       	   statsuser    false    292            /           0    0    product_file_description_id_seq    SEQUENCE OWNED BY     c   ALTER SEQUENCE public.product_file_description_id_seq OWNED BY public.product_file_description.id;
          public       	   statsuser    false    293            &           1259    18004    product_file_id_seq    SEQUENCE     |   CREATE SEQUENCE public.product_file_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.product_file_id_seq;
       public       	   statsuser    false            '           1259    18005    product_file_id_seq1    SEQUENCE     }   CREATE SEQUENCE public.product_file_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.product_file_id_seq1;
       public       	   statsuser    false    291            0           0    0    product_file_id_seq1    SEQUENCE OWNED BY     L   ALTER SEQUENCE public.product_file_id_seq1 OWNED BY public.product_file.id;
          public       	   statsuser    false    295            (           1259    18006    product_file_variable    TABLE     <  CREATE TABLE public.product_file_variable (
    id bigint NOT NULL,
    product_file_description_id bigint,
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
    histogram_bins smallint,
    min_value double precision,
    max_value double precision,
    compute_statistics boolean DEFAULT true NOT NULL
);
 )   DROP TABLE public.product_file_variable;
       public         heap 	   statsuser    false            )           1259    18012    product_file_variable_id_seq    SEQUENCE     �   CREATE SEQUENCE public.product_file_variable_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 3   DROP SEQUENCE public.product_file_variable_id_seq;
       public       	   statsuser    false    296            1           0    0    product_file_variable_id_seq    SEQUENCE OWNED BY     ]   ALTER SEQUENCE public.product_file_variable_id_seq OWNED BY public.product_file_variable.id;
          public       	   statsuser    false    297            *           1259    18013    product_id_seq    SEQUENCE     w   CREATE SEQUENCE public.product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public.product_id_seq;
       public       	   statsuser    false    290            2           0    0    product_id_seq    SEQUENCE OWNED BY     A   ALTER SEQUENCE public.product_id_seq OWNED BY public.product.id;
          public       	   statsuser    false    298            +           1259    18014    product_order    TABLE     /  CREATE TABLE public.product_order (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    email text,
    aoi public.geometry(MultiPolygon,3857),
    request_data jsonb,
    date_created timestamp without time zone DEFAULT (now() AT TIME ZONE 'UTC'::text),
    processed boolean DEFAULT false NOT NULL
);
 !   DROP TABLE public.product_order;
       public         heap 	   statsuser    false    3    3    3    3    3    3    3    3            3           0    0    TABLE spatial_ref_sys    ACL     8   GRANT ALL ON TABLE public.spatial_ref_sys TO statsuser;
          public          postgres    false    219            ,           1259    18022    stratification    TABLE     m   CREATE TABLE public.stratification (
    id bigint NOT NULL,
    description text,
    tilelayer_url text
);
 "   DROP TABLE public.stratification;
       public         heap 	   statsuser    false            -           1259    18027    stratification_geom    TABLE     �   CREATE TABLE public.stratification_geom (
    id bigint NOT NULL,
    stratification_id bigint NOT NULL,
    geom public.geometry(MultiPolygon,4326),
    geom3857 public.geometry(MultiPolygon,3857),
    description text
);
 '   DROP TABLE public.stratification_geom;
       public         heap 	   statsuser    false    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3            .           1259    18032    stratification_geom_id_seq    SEQUENCE     �   CREATE SEQUENCE public.stratification_geom_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE public.stratification_geom_id_seq;
       public       	   statsuser    false    301            4           0    0    stratification_geom_id_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE public.stratification_geom_id_seq OWNED BY public.stratification_geom.id;
          public       	   statsuser    false    302            /           1259    18033    stratification_id_seq    SEQUENCE     ~   CREATE SEQUENCE public.stratification_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE public.stratification_id_seq;
       public       	   statsuser    false    300            5           0    0    stratification_id_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE public.stratification_id_seq OWNED BY public.stratification.id;
          public       	   statsuser    false    303            0           1259    18034    tmp    TABLE     6   CREATE TABLE public.tmp (
    json_object_agg json
);
    DROP TABLE public.tmp;
       public         heap 	   statsuser    false            1           1259    18039    wms_file    TABLE     �   CREATE TABLE public.wms_file (
    id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint,
    rel_file_path text
);
    DROP TABLE public.wms_file;
       public         heap 	   statsuser    false            2           1259    18044    wms_file_id_seq    SEQUENCE     x   CREATE SEQUENCE public.wms_file_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.wms_file_id_seq;
       public       	   statsuser    false    305            6           0    0    wms_file_id_seq    SEQUENCE OWNED BY     C   ALTER SEQUENCE public.wms_file_id_seq OWNED BY public.wms_file.id;
          public       	   statsuser    false    306            3           1259    18045    poly_stats_per_region    TABLE     �  CREATE TABLE tmp.poly_stats_per_region (
    id bigint NOT NULL,
    poly_id bigint,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
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
       tmp         heap 	   statsuser    false    4            4           1259    18053    poly_stats_per_region_id_seq    SEQUENCE     �   CREATE SEQUENCE tmp.poly_stats_per_region_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE tmp.poly_stats_per_region_id_seq;
       tmp       	   statsuser    false    4    307            7           0    0    poly_stats_per_region_id_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE tmp.poly_stats_per_region_id_seq OWNED BY tmp.poly_stats_per_region.id;
          tmp       	   statsuser    false    308            �           0    0    poly_stats_10_1_257    TABLE ATTACH     }   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_10_1_257 FOR VALUES FROM ('10', '1') TO ('10', '257');
          public       	   statsuser    false    229    228            �           0    0    poly_stats_10_257_279    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_10_257_279 FOR VALUES FROM ('10', '257') TO ('10', '279');
          public       	   statsuser    false    230    228            �           0    0    poly_stats_10_279_285    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_10_279_285 FOR VALUES FROM ('10', '279') TO ('10', '285');
          public       	   statsuser    false    231    228            �           0    0    poly_stats_10_285_38543    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_10_285_38543 FOR VALUES FROM ('10', '285') TO ('10', '38543');
          public       	   statsuser    false    232    228            �           0    0    poly_stats_12_1_257    TABLE ATTACH     }   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_12_1_257 FOR VALUES FROM ('12', '1') TO ('12', '257');
          public       	   statsuser    false    233    228            �           0    0    poly_stats_12_257_279    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_12_257_279 FOR VALUES FROM ('12', '257') TO ('12', '279');
          public       	   statsuser    false    234    228            �           0    0    poly_stats_12_279_285    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_12_279_285 FOR VALUES FROM ('12', '279') TO ('12', '285');
          public       	   statsuser    false    235    228            �           0    0    poly_stats_12_285_38543    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_12_285_38543 FOR VALUES FROM ('12', '285') TO ('12', '38543');
          public       	   statsuser    false    236    228            �           0    0    poly_stats_14_1_257    TABLE ATTACH     }   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_14_1_257 FOR VALUES FROM ('14', '1') TO ('14', '257');
          public       	   statsuser    false    237    228            �           0    0    poly_stats_14_257_279    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_14_257_279 FOR VALUES FROM ('14', '257') TO ('14', '279');
          public       	   statsuser    false    238    228            �           0    0    poly_stats_14_279_285    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_14_279_285 FOR VALUES FROM ('14', '279') TO ('14', '285');
          public       	   statsuser    false    239    228            �           0    0    poly_stats_14_285_38543    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_14_285_38543 FOR VALUES FROM ('14', '285') TO ('14', '38543');
          public       	   statsuser    false    240    228            �           0    0    poly_stats_16_1_257    TABLE ATTACH     }   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_16_1_257 FOR VALUES FROM ('16', '1') TO ('16', '257');
          public       	   statsuser    false    241    228            �           0    0    poly_stats_16_257_279    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_16_257_279 FOR VALUES FROM ('16', '257') TO ('16', '279');
          public       	   statsuser    false    242    228            �           0    0    poly_stats_16_279_285    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_16_279_285 FOR VALUES FROM ('16', '279') TO ('16', '285');
          public       	   statsuser    false    243    228            �           0    0    poly_stats_16_285_38543    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_16_285_38543 FOR VALUES FROM ('16', '285') TO ('16', '38543');
          public       	   statsuser    false    244    228            �           0    0    poly_stats_17_1_257    TABLE ATTACH     }   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_17_1_257 FOR VALUES FROM ('17', '1') TO ('17', '257');
          public       	   statsuser    false    245    228            �           0    0    poly_stats_17_257_279    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_17_257_279 FOR VALUES FROM ('17', '257') TO ('17', '279');
          public       	   statsuser    false    246    228            �           0    0    poly_stats_17_279_285    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_17_279_285 FOR VALUES FROM ('17', '279') TO ('17', '285');
          public       	   statsuser    false    247    228            �           0    0    poly_stats_17_285_38543    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_17_285_38543 FOR VALUES FROM ('17', '285') TO ('17', '38543');
          public       	   statsuser    false    248    228            �           0    0    poly_stats_19_1_257    TABLE ATTACH     }   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_19_1_257 FOR VALUES FROM ('19', '1') TO ('19', '257');
          public       	   statsuser    false    249    228            �           0    0    poly_stats_19_257_279    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_19_257_279 FOR VALUES FROM ('19', '257') TO ('19', '279');
          public       	   statsuser    false    250    228            �           0    0    poly_stats_19_279_285    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_19_279_285 FOR VALUES FROM ('19', '279') TO ('19', '285');
          public       	   statsuser    false    251    228            �           0    0    poly_stats_19_285_38543    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_19_285_38543 FOR VALUES FROM ('19', '285') TO ('19', '38543');
          public       	   statsuser    false    252    228            �           0    0    poly_stats_1_1_257    TABLE ATTACH     z   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_1_1_257 FOR VALUES FROM ('1', '1') TO ('1', '257');
          public       	   statsuser    false    253    228            �           0    0    poly_stats_1_257_279    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_1_257_279 FOR VALUES FROM ('1', '257') TO ('1', '279');
          public       	   statsuser    false    254    228            �           0    0    poly_stats_1_279_285    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_1_279_285 FOR VALUES FROM ('1', '279') TO ('1', '285');
          public       	   statsuser    false    255    228            �           0    0    poly_stats_1_285_38543    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_1_285_38543 FOR VALUES FROM ('1', '285') TO ('1', '38543');
          public       	   statsuser    false    256    228            �           0    0    poly_stats_21_1_257    TABLE ATTACH     }   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_21_1_257 FOR VALUES FROM ('21', '1') TO ('21', '257');
          public       	   statsuser    false    257    228            �           0    0    poly_stats_21_257_279    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_21_257_279 FOR VALUES FROM ('21', '257') TO ('21', '279');
          public       	   statsuser    false    258    228            �           0    0    poly_stats_21_279_285    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_21_279_285 FOR VALUES FROM ('21', '279') TO ('21', '285');
          public       	   statsuser    false    259    228            �           0    0    poly_stats_21_285_38543    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_21_285_38543 FOR VALUES FROM ('21', '285') TO ('21', '38543');
          public       	   statsuser    false    260    228            �           0    0    poly_stats_24_1_257    TABLE ATTACH     }   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_24_1_257 FOR VALUES FROM ('24', '1') TO ('24', '257');
          public       	   statsuser    false    261    228            �           0    0    poly_stats_2_1_257    TABLE ATTACH     z   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_2_1_257 FOR VALUES FROM ('2', '1') TO ('2', '257');
          public       	   statsuser    false    262    228            �           0    0    poly_stats_2_257_279    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_2_257_279 FOR VALUES FROM ('2', '257') TO ('2', '279');
          public       	   statsuser    false    263    228            �           0    0    poly_stats_2_279_285    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_2_279_285 FOR VALUES FROM ('2', '279') TO ('2', '285');
          public       	   statsuser    false    264    228            �           0    0    poly_stats_2_285_38543    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_2_285_38543 FOR VALUES FROM ('2', '285') TO ('2', '38543');
          public       	   statsuser    false    265    228            �           0    0    poly_stats_3_1_257    TABLE ATTACH     z   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_3_1_257 FOR VALUES FROM ('3', '1') TO ('3', '257');
          public       	   statsuser    false    266    228            �           0    0    poly_stats_3_257_279    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_3_257_279 FOR VALUES FROM ('3', '257') TO ('3', '279');
          public       	   statsuser    false    267    228            �           0    0    poly_stats_3_279_285    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_3_279_285 FOR VALUES FROM ('3', '279') TO ('3', '285');
          public       	   statsuser    false    268    228            �           0    0    poly_stats_3_285_38543    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_3_285_38543 FOR VALUES FROM ('3', '285') TO ('3', '38543');
          public       	   statsuser    false    269    228            �           0    0    poly_stats_4_1_257    TABLE ATTACH     z   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_4_1_257 FOR VALUES FROM ('4', '1') TO ('4', '257');
          public       	   statsuser    false    270    228            �           0    0    poly_stats_4_257_279    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_4_257_279 FOR VALUES FROM ('4', '257') TO ('4', '279');
          public       	   statsuser    false    271    228            �           0    0    poly_stats_4_279_285    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_4_279_285 FOR VALUES FROM ('4', '279') TO ('4', '285');
          public       	   statsuser    false    272    228            �           0    0    poly_stats_4_285_38543    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_4_285_38543 FOR VALUES FROM ('4', '285') TO ('4', '38543');
          public       	   statsuser    false    273    228            �           0    0    poly_stats_5_1_257    TABLE ATTACH     z   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_5_1_257 FOR VALUES FROM ('5', '1') TO ('5', '257');
          public       	   statsuser    false    274    228            �           0    0    poly_stats_5_257_279    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_5_257_279 FOR VALUES FROM ('5', '257') TO ('5', '279');
          public       	   statsuser    false    275    228            �           0    0    poly_stats_5_279_285    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_5_279_285 FOR VALUES FROM ('5', '279') TO ('5', '285');
          public       	   statsuser    false    276    228            �           0    0    poly_stats_5_285_38543    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_5_285_38543 FOR VALUES FROM ('5', '285') TO ('5', '38543');
          public       	   statsuser    false    277    228            �           0    0    poly_stats_6_1_257    TABLE ATTACH     z   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_6_1_257 FOR VALUES FROM ('6', '1') TO ('6', '257');
          public       	   statsuser    false    278    228            �           0    0    poly_stats_6_257_279    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_6_257_279 FOR VALUES FROM ('6', '257') TO ('6', '279');
          public       	   statsuser    false    279    228            �           0    0    poly_stats_6_279_285    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_6_279_285 FOR VALUES FROM ('6', '279') TO ('6', '285');
          public       	   statsuser    false    280    228            �           0    0    poly_stats_6_285_38543    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_6_285_38543 FOR VALUES FROM ('6', '285') TO ('6', '38543');
          public       	   statsuser    false    281    228            �           0    0    poly_stats_7_1_257    TABLE ATTACH     z   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_7_1_257 FOR VALUES FROM ('7', '1') TO ('7', '257');
          public       	   statsuser    false    282    228            �           0    0    poly_stats_7_257_279    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_7_257_279 FOR VALUES FROM ('7', '257') TO ('7', '279');
          public       	   statsuser    false    283    228            �           0    0    poly_stats_7_279_285    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_7_279_285 FOR VALUES FROM ('7', '279') TO ('7', '285');
          public       	   statsuser    false    284    228            �           0    0    poly_stats_7_285_38543    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_7_285_38543 FOR VALUES FROM ('7', '285') TO ('7', '38543');
          public       	   statsuser    false    285    228            �           0    0    poly_stats_9_1_257    TABLE ATTACH     z   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_9_1_257 FOR VALUES FROM ('9', '1') TO ('9', '257');
          public       	   statsuser    false    286    228            �           0    0    poly_stats_9_257_279    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_9_257_279 FOR VALUES FROM ('9', '257') TO ('9', '279');
          public       	   statsuser    false    287    228            �           0    0    poly_stats_9_279_285    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_9_279_285 FOR VALUES FROM ('9', '279') TO ('9', '285');
          public       	   statsuser    false    288    228            �           0    0    poly_stats_9_285_38543    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_9_285_38543 FOR VALUES FROM ('9', '285') TO ('9', '38543');
          public       	   statsuser    false    289    228            �           2604    18054    long_term_anomaly_info id    DEFAULT     �   ALTER TABLE ONLY public.long_term_anomaly_info ALTER COLUMN id SET DEFAULT nextval('public.long_term_anomaly_info_id_seq'::regclass);
 H   ALTER TABLE public.long_term_anomaly_info ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    226    225            �           2604    18055 
   product id    DEFAULT     h   ALTER TABLE ONLY public.product ALTER COLUMN id SET DEFAULT nextval('public.product_id_seq'::regclass);
 9   ALTER TABLE public.product ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    298    290            �           2604    18056    product_file id    DEFAULT     s   ALTER TABLE ONLY public.product_file ALTER COLUMN id SET DEFAULT nextval('public.product_file_id_seq1'::regclass);
 >   ALTER TABLE public.product_file ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    295    291            �           2604    18057    product_file_description id    DEFAULT     �   ALTER TABLE ONLY public.product_file_description ALTER COLUMN id SET DEFAULT nextval('public.product_file_description_id_seq'::regclass);
 J   ALTER TABLE public.product_file_description ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    293    292            �           2604    18058    product_file_variable id    DEFAULT     �   ALTER TABLE ONLY public.product_file_variable ALTER COLUMN id SET DEFAULT nextval('public.product_file_variable_id_seq'::regclass);
 G   ALTER TABLE public.product_file_variable ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    297    296            �           2604    18059    stratification id    DEFAULT     v   ALTER TABLE ONLY public.stratification ALTER COLUMN id SET DEFAULT nextval('public.stratification_id_seq'::regclass);
 @   ALTER TABLE public.stratification ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    303    300            �           2604    18060    stratification_geom id    DEFAULT     �   ALTER TABLE ONLY public.stratification_geom ALTER COLUMN id SET DEFAULT nextval('public.stratification_geom_id_seq'::regclass);
 E   ALTER TABLE public.stratification_geom ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    302    301            �           2604    18061    wms_file id    DEFAULT     j   ALTER TABLE ONLY public.wms_file ALTER COLUMN id SET DEFAULT nextval('public.wms_file_id_seq'::regclass);
 :   ALTER TABLE public.wms_file ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    306    305            �           2604    18062    poly_stats_per_region id    DEFAULT     ~   ALTER TABLE ONLY tmp.poly_stats_per_region ALTER COLUMN id SET DEFAULT nextval('tmp.poly_stats_per_region_id_seq'::regclass);
 D   ALTER TABLE tmp.poly_stats_per_region ALTER COLUMN id DROP DEFAULT;
       tmp       	   statsuser    false    308    307            �           2606    18064 0   long_term_anomaly_info long_term_anomaly_info_pk 
   CONSTRAINT     n   ALTER TABLE ONLY public.long_term_anomaly_info
    ADD CONSTRAINT long_term_anomaly_info_pk PRIMARY KEY (id);
 Z   ALTER TABLE ONLY public.long_term_anomaly_info DROP CONSTRAINT long_term_anomaly_info_pk;
       public         	   statsuser    false    225            �           2606    18066    category newtable_pk 
   CONSTRAINT     R   ALTER TABLE ONLY public.category
    ADD CONSTRAINT newtable_pk PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.category DROP CONSTRAINT newtable_pk;
       public         	   statsuser    false    223            �           2606    18068    poly_stats poly_stats_pk_ 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats
    ADD CONSTRAINT poly_stats_pk_ PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 C   ALTER TABLE ONLY public.poly_stats DROP CONSTRAINT poly_stats_pk_;
       public         	   statsuser    false    228    228    228            �           2606    18070 ,   poly_stats_10_1_257 poly_stats_10_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_10_1_257
    ADD CONSTRAINT poly_stats_10_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 V   ALTER TABLE ONLY public.poly_stats_10_1_257 DROP CONSTRAINT poly_stats_10_1_257_pkey;
       public         	   statsuser    false    229    229    229    4769    229            �           2606    18072 0   poly_stats_10_257_279 poly_stats_10_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_10_257_279
    ADD CONSTRAINT poly_stats_10_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_10_257_279 DROP CONSTRAINT poly_stats_10_257_279_pkey;
       public         	   statsuser    false    230    4769    230    230    230            �           2606    18074 0   poly_stats_10_279_285 poly_stats_10_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_10_279_285
    ADD CONSTRAINT poly_stats_10_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_10_279_285 DROP CONSTRAINT poly_stats_10_279_285_pkey;
       public         	   statsuser    false    231    4769    231    231    231            �           2606    18076 4   poly_stats_10_285_38543 poly_stats_10_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_10_285_38543
    ADD CONSTRAINT poly_stats_10_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 ^   ALTER TABLE ONLY public.poly_stats_10_285_38543 DROP CONSTRAINT poly_stats_10_285_38543_pkey;
       public         	   statsuser    false    232    232    232    4769    232            �           2606    18078 ,   poly_stats_12_1_257 poly_stats_12_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_12_1_257
    ADD CONSTRAINT poly_stats_12_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 V   ALTER TABLE ONLY public.poly_stats_12_1_257 DROP CONSTRAINT poly_stats_12_1_257_pkey;
       public         	   statsuser    false    233    4769    233    233    233            �           2606    18080 0   poly_stats_12_257_279 poly_stats_12_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_12_257_279
    ADD CONSTRAINT poly_stats_12_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_12_257_279 DROP CONSTRAINT poly_stats_12_257_279_pkey;
       public         	   statsuser    false    4769    234    234    234    234            �           2606    18082 0   poly_stats_12_279_285 poly_stats_12_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_12_279_285
    ADD CONSTRAINT poly_stats_12_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_12_279_285 DROP CONSTRAINT poly_stats_12_279_285_pkey;
       public         	   statsuser    false    235    235    235    4769    235            �           2606    18084 4   poly_stats_12_285_38543 poly_stats_12_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_12_285_38543
    ADD CONSTRAINT poly_stats_12_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 ^   ALTER TABLE ONLY public.poly_stats_12_285_38543 DROP CONSTRAINT poly_stats_12_285_38543_pkey;
       public         	   statsuser    false    236    4769    236    236    236            �           2606    18086 ,   poly_stats_14_1_257 poly_stats_14_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_14_1_257
    ADD CONSTRAINT poly_stats_14_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 V   ALTER TABLE ONLY public.poly_stats_14_1_257 DROP CONSTRAINT poly_stats_14_1_257_pkey;
       public         	   statsuser    false    237    4769    237    237    237            �           2606    18088 0   poly_stats_14_257_279 poly_stats_14_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_14_257_279
    ADD CONSTRAINT poly_stats_14_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_14_257_279 DROP CONSTRAINT poly_stats_14_257_279_pkey;
       public         	   statsuser    false    238    238    238    4769    238            �           2606    18090 0   poly_stats_14_279_285 poly_stats_14_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_14_279_285
    ADD CONSTRAINT poly_stats_14_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_14_279_285 DROP CONSTRAINT poly_stats_14_279_285_pkey;
       public         	   statsuser    false    239    239    239    239    4769            �           2606    18092 4   poly_stats_14_285_38543 poly_stats_14_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_14_285_38543
    ADD CONSTRAINT poly_stats_14_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 ^   ALTER TABLE ONLY public.poly_stats_14_285_38543 DROP CONSTRAINT poly_stats_14_285_38543_pkey;
       public         	   statsuser    false    240    240    240    240    4769            �           2606    18094 ,   poly_stats_16_1_257 poly_stats_16_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_16_1_257
    ADD CONSTRAINT poly_stats_16_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 V   ALTER TABLE ONLY public.poly_stats_16_1_257 DROP CONSTRAINT poly_stats_16_1_257_pkey;
       public         	   statsuser    false    241    4769    241    241    241            �           2606    18096 0   poly_stats_16_257_279 poly_stats_16_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_16_257_279
    ADD CONSTRAINT poly_stats_16_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_16_257_279 DROP CONSTRAINT poly_stats_16_257_279_pkey;
       public         	   statsuser    false    242    242    242    242    4769            �           2606    18098 0   poly_stats_16_279_285 poly_stats_16_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_16_279_285
    ADD CONSTRAINT poly_stats_16_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_16_279_285 DROP CONSTRAINT poly_stats_16_279_285_pkey;
       public         	   statsuser    false    243    243    243    243    4769            �           2606    18100 4   poly_stats_16_285_38543 poly_stats_16_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_16_285_38543
    ADD CONSTRAINT poly_stats_16_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 ^   ALTER TABLE ONLY public.poly_stats_16_285_38543 DROP CONSTRAINT poly_stats_16_285_38543_pkey;
       public         	   statsuser    false    244    244    244    244    4769            �           2606    18102 ,   poly_stats_17_1_257 poly_stats_17_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_17_1_257
    ADD CONSTRAINT poly_stats_17_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 V   ALTER TABLE ONLY public.poly_stats_17_1_257 DROP CONSTRAINT poly_stats_17_1_257_pkey;
       public         	   statsuser    false    245    245    4769    245    245            �           2606    18104 0   poly_stats_17_257_279 poly_stats_17_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_17_257_279
    ADD CONSTRAINT poly_stats_17_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_17_257_279 DROP CONSTRAINT poly_stats_17_257_279_pkey;
       public         	   statsuser    false    246    4769    246    246    246            �           2606    18106 0   poly_stats_17_279_285 poly_stats_17_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_17_279_285
    ADD CONSTRAINT poly_stats_17_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_17_279_285 DROP CONSTRAINT poly_stats_17_279_285_pkey;
       public         	   statsuser    false    4769    247    247    247    247            �           2606    18108 4   poly_stats_17_285_38543 poly_stats_17_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_17_285_38543
    ADD CONSTRAINT poly_stats_17_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 ^   ALTER TABLE ONLY public.poly_stats_17_285_38543 DROP CONSTRAINT poly_stats_17_285_38543_pkey;
       public         	   statsuser    false    248    248    248    4769    248            �           2606    18110 ,   poly_stats_19_1_257 poly_stats_19_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_19_1_257
    ADD CONSTRAINT poly_stats_19_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 V   ALTER TABLE ONLY public.poly_stats_19_1_257 DROP CONSTRAINT poly_stats_19_1_257_pkey;
       public         	   statsuser    false    249    249    249    249    4769            �           2606    18112 0   poly_stats_19_257_279 poly_stats_19_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_19_257_279
    ADD CONSTRAINT poly_stats_19_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_19_257_279 DROP CONSTRAINT poly_stats_19_257_279_pkey;
       public         	   statsuser    false    4769    250    250    250    250            �           2606    18114 0   poly_stats_19_279_285 poly_stats_19_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_19_279_285
    ADD CONSTRAINT poly_stats_19_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_19_279_285 DROP CONSTRAINT poly_stats_19_279_285_pkey;
       public         	   statsuser    false    251    251    4769    251    251            �           2606    18116 4   poly_stats_19_285_38543 poly_stats_19_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_19_285_38543
    ADD CONSTRAINT poly_stats_19_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 ^   ALTER TABLE ONLY public.poly_stats_19_285_38543 DROP CONSTRAINT poly_stats_19_285_38543_pkey;
       public         	   statsuser    false    252    252    252    4769    252            �           2606    18118 *   poly_stats_1_1_257 poly_stats_1_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_1_1_257
    ADD CONSTRAINT poly_stats_1_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 T   ALTER TABLE ONLY public.poly_stats_1_1_257 DROP CONSTRAINT poly_stats_1_1_257_pkey;
       public         	   statsuser    false    253    4769    253    253    253            �           2606    18120 .   poly_stats_1_257_279 poly_stats_1_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_1_257_279
    ADD CONSTRAINT poly_stats_1_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_1_257_279 DROP CONSTRAINT poly_stats_1_257_279_pkey;
       public         	   statsuser    false    254    4769    254    254    254            �           2606    18122 .   poly_stats_1_279_285 poly_stats_1_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_1_279_285
    ADD CONSTRAINT poly_stats_1_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_1_279_285 DROP CONSTRAINT poly_stats_1_279_285_pkey;
       public         	   statsuser    false    255    4769    255    255    255            �           2606    18124 2   poly_stats_1_285_38543 poly_stats_1_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_1_285_38543
    ADD CONSTRAINT poly_stats_1_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 \   ALTER TABLE ONLY public.poly_stats_1_285_38543 DROP CONSTRAINT poly_stats_1_285_38543_pkey;
       public         	   statsuser    false    4769    256    256    256    256            �           2606    18126 ,   poly_stats_21_1_257 poly_stats_21_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_21_1_257
    ADD CONSTRAINT poly_stats_21_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 V   ALTER TABLE ONLY public.poly_stats_21_1_257 DROP CONSTRAINT poly_stats_21_1_257_pkey;
       public         	   statsuser    false    257    257    257    4769    257            �           2606    18128 0   poly_stats_21_257_279 poly_stats_21_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_21_257_279
    ADD CONSTRAINT poly_stats_21_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_21_257_279 DROP CONSTRAINT poly_stats_21_257_279_pkey;
       public         	   statsuser    false    258    258    258    258    4769            �           2606    18130 0   poly_stats_21_279_285 poly_stats_21_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_21_279_285
    ADD CONSTRAINT poly_stats_21_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_21_279_285 DROP CONSTRAINT poly_stats_21_279_285_pkey;
       public         	   statsuser    false    4769    259    259    259    259                       2606    18132 4   poly_stats_21_285_38543 poly_stats_21_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_21_285_38543
    ADD CONSTRAINT poly_stats_21_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 ^   ALTER TABLE ONLY public.poly_stats_21_285_38543 DROP CONSTRAINT poly_stats_21_285_38543_pkey;
       public         	   statsuser    false    260    260    260    4769    260                       2606    18134 ,   poly_stats_24_1_257 poly_stats_24_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_24_1_257
    ADD CONSTRAINT poly_stats_24_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 V   ALTER TABLE ONLY public.poly_stats_24_1_257 DROP CONSTRAINT poly_stats_24_1_257_pkey;
       public         	   statsuser    false    4769    261    261    261    261                       2606    18136 *   poly_stats_2_1_257 poly_stats_2_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_2_1_257
    ADD CONSTRAINT poly_stats_2_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 T   ALTER TABLE ONLY public.poly_stats_2_1_257 DROP CONSTRAINT poly_stats_2_1_257_pkey;
       public         	   statsuser    false    262    262    262    4769    262            
           2606    18138 .   poly_stats_2_257_279 poly_stats_2_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_2_257_279
    ADD CONSTRAINT poly_stats_2_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_2_257_279 DROP CONSTRAINT poly_stats_2_257_279_pkey;
       public         	   statsuser    false    4769    263    263    263    263                       2606    18140 .   poly_stats_2_279_285 poly_stats_2_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_2_279_285
    ADD CONSTRAINT poly_stats_2_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_2_279_285 DROP CONSTRAINT poly_stats_2_279_285_pkey;
       public         	   statsuser    false    264    264    264    4769    264                       2606    18142 2   poly_stats_2_285_38543 poly_stats_2_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_2_285_38543
    ADD CONSTRAINT poly_stats_2_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 \   ALTER TABLE ONLY public.poly_stats_2_285_38543 DROP CONSTRAINT poly_stats_2_285_38543_pkey;
       public         	   statsuser    false    265    265    265    265    4769                       2606    18144 *   poly_stats_3_1_257 poly_stats_3_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_3_1_257
    ADD CONSTRAINT poly_stats_3_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 T   ALTER TABLE ONLY public.poly_stats_3_1_257 DROP CONSTRAINT poly_stats_3_1_257_pkey;
       public         	   statsuser    false    266    266    4769    266    266                       2606    18146 .   poly_stats_3_257_279 poly_stats_3_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_3_257_279
    ADD CONSTRAINT poly_stats_3_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_3_257_279 DROP CONSTRAINT poly_stats_3_257_279_pkey;
       public         	   statsuser    false    267    267    267    267    4769                       2606    18148 .   poly_stats_3_279_285 poly_stats_3_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_3_279_285
    ADD CONSTRAINT poly_stats_3_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_3_279_285 DROP CONSTRAINT poly_stats_3_279_285_pkey;
       public         	   statsuser    false    268    268    4769    268    268                       2606    18150 2   poly_stats_3_285_38543 poly_stats_3_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_3_285_38543
    ADD CONSTRAINT poly_stats_3_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 \   ALTER TABLE ONLY public.poly_stats_3_285_38543 DROP CONSTRAINT poly_stats_3_285_38543_pkey;
       public         	   statsuser    false    269    269    4769    269    269                       2606    18152 *   poly_stats_4_1_257 poly_stats_4_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_4_1_257
    ADD CONSTRAINT poly_stats_4_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 T   ALTER TABLE ONLY public.poly_stats_4_1_257 DROP CONSTRAINT poly_stats_4_1_257_pkey;
       public         	   statsuser    false    270    4769    270    270    270            "           2606    18154 .   poly_stats_4_257_279 poly_stats_4_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_4_257_279
    ADD CONSTRAINT poly_stats_4_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_4_257_279 DROP CONSTRAINT poly_stats_4_257_279_pkey;
       public         	   statsuser    false    271    271    271    271    4769            %           2606    18156 .   poly_stats_4_279_285 poly_stats_4_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_4_279_285
    ADD CONSTRAINT poly_stats_4_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_4_279_285 DROP CONSTRAINT poly_stats_4_279_285_pkey;
       public         	   statsuser    false    272    272    272    272    4769            (           2606    18158 2   poly_stats_4_285_38543 poly_stats_4_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_4_285_38543
    ADD CONSTRAINT poly_stats_4_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 \   ALTER TABLE ONLY public.poly_stats_4_285_38543 DROP CONSTRAINT poly_stats_4_285_38543_pkey;
       public         	   statsuser    false    273    273    273    4769    273            +           2606    18160 *   poly_stats_5_1_257 poly_stats_5_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_5_1_257
    ADD CONSTRAINT poly_stats_5_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 T   ALTER TABLE ONLY public.poly_stats_5_1_257 DROP CONSTRAINT poly_stats_5_1_257_pkey;
       public         	   statsuser    false    4769    274    274    274    274            .           2606    18162 .   poly_stats_5_257_279 poly_stats_5_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_5_257_279
    ADD CONSTRAINT poly_stats_5_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_5_257_279 DROP CONSTRAINT poly_stats_5_257_279_pkey;
       public         	   statsuser    false    4769    275    275    275    275            1           2606    18164 .   poly_stats_5_279_285 poly_stats_5_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_5_279_285
    ADD CONSTRAINT poly_stats_5_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_5_279_285 DROP CONSTRAINT poly_stats_5_279_285_pkey;
       public         	   statsuser    false    276    276    276    4769    276            4           2606    18166 2   poly_stats_5_285_38543 poly_stats_5_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_5_285_38543
    ADD CONSTRAINT poly_stats_5_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 \   ALTER TABLE ONLY public.poly_stats_5_285_38543 DROP CONSTRAINT poly_stats_5_285_38543_pkey;
       public         	   statsuser    false    277    277    277    277    4769            7           2606    18168 *   poly_stats_6_1_257 poly_stats_6_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_6_1_257
    ADD CONSTRAINT poly_stats_6_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 T   ALTER TABLE ONLY public.poly_stats_6_1_257 DROP CONSTRAINT poly_stats_6_1_257_pkey;
       public         	   statsuser    false    278    278    4769    278    278            :           2606    18170 .   poly_stats_6_257_279 poly_stats_6_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_6_257_279
    ADD CONSTRAINT poly_stats_6_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_6_257_279 DROP CONSTRAINT poly_stats_6_257_279_pkey;
       public         	   statsuser    false    279    4769    279    279    279            =           2606    18172 .   poly_stats_6_279_285 poly_stats_6_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_6_279_285
    ADD CONSTRAINT poly_stats_6_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_6_279_285 DROP CONSTRAINT poly_stats_6_279_285_pkey;
       public         	   statsuser    false    4769    280    280    280    280            @           2606    18174 2   poly_stats_6_285_38543 poly_stats_6_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_6_285_38543
    ADD CONSTRAINT poly_stats_6_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 \   ALTER TABLE ONLY public.poly_stats_6_285_38543 DROP CONSTRAINT poly_stats_6_285_38543_pkey;
       public         	   statsuser    false    281    4769    281    281    281            C           2606    18176 *   poly_stats_7_1_257 poly_stats_7_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_7_1_257
    ADD CONSTRAINT poly_stats_7_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 T   ALTER TABLE ONLY public.poly_stats_7_1_257 DROP CONSTRAINT poly_stats_7_1_257_pkey;
       public         	   statsuser    false    282    282    282    4769    282            F           2606    18178 .   poly_stats_7_257_279 poly_stats_7_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_7_257_279
    ADD CONSTRAINT poly_stats_7_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_7_257_279 DROP CONSTRAINT poly_stats_7_257_279_pkey;
       public         	   statsuser    false    283    283    283    283    4769            I           2606    18180 .   poly_stats_7_279_285 poly_stats_7_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_7_279_285
    ADD CONSTRAINT poly_stats_7_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_7_279_285 DROP CONSTRAINT poly_stats_7_279_285_pkey;
       public         	   statsuser    false    284    284    4769    284    284            L           2606    18182 2   poly_stats_7_285_38543 poly_stats_7_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_7_285_38543
    ADD CONSTRAINT poly_stats_7_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 \   ALTER TABLE ONLY public.poly_stats_7_285_38543 DROP CONSTRAINT poly_stats_7_285_38543_pkey;
       public         	   statsuser    false    285    285    285    285    4769            O           2606    18184 *   poly_stats_9_1_257 poly_stats_9_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_9_1_257
    ADD CONSTRAINT poly_stats_9_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 T   ALTER TABLE ONLY public.poly_stats_9_1_257 DROP CONSTRAINT poly_stats_9_1_257_pkey;
       public         	   statsuser    false    286    286    286    286    4769            R           2606    18186 .   poly_stats_9_257_279 poly_stats_9_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_9_257_279
    ADD CONSTRAINT poly_stats_9_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_9_257_279 DROP CONSTRAINT poly_stats_9_257_279_pkey;
       public         	   statsuser    false    287    287    287    287    4769            U           2606    18188 .   poly_stats_9_279_285 poly_stats_9_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_9_279_285
    ADD CONSTRAINT poly_stats_9_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_9_279_285 DROP CONSTRAINT poly_stats_9_279_285_pkey;
       public         	   statsuser    false    288    288    4769    288    288            X           2606    18190 2   poly_stats_9_285_38543 poly_stats_9_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_9_285_38543
    ADD CONSTRAINT poly_stats_9_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 \   ALTER TABLE ONLY public.poly_stats_9_285_38543 DROP CONSTRAINT poly_stats_9_285_38543_pkey;
       public         	   statsuser    false    289    4769    289    289    289            ^           2606    18192 6   product_file product_file_date_product_description_idx 
   CONSTRAINT     �   ALTER TABLE ONLY public.product_file
    ADD CONSTRAINT product_file_date_product_description_idx UNIQUE (product_file_description_id, date, rt_flag);
 `   ALTER TABLE ONLY public.product_file DROP CONSTRAINT product_file_date_product_description_idx;
       public         	   statsuser    false    291    291    291            `           2606    18194    product_file product_file_pk 
   CONSTRAINT     Z   ALTER TABLE ONLY public.product_file
    ADD CONSTRAINT product_file_pk PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.product_file DROP CONSTRAINT product_file_pk;
       public         	   statsuser    false    291            d           2606    18196 .   product_file_variable product_file_variable_pk 
   CONSTRAINT     l   ALTER TABLE ONLY public.product_file_variable
    ADD CONSTRAINT product_file_variable_pk PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.product_file_variable DROP CONSTRAINT product_file_variable_pk;
       public         	   statsuser    false    296            g           2606    18198    product_order product_order_pk 
   CONSTRAINT     \   ALTER TABLE ONLY public.product_order
    ADD CONSTRAINT product_order_pk PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.product_order DROP CONSTRAINT product_order_pk;
       public         	   statsuser    false    299            [           2606    18200    product product_pk1 
   CONSTRAINT     Q   ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_pk1 PRIMARY KEY (id);
 =   ALTER TABLE ONLY public.product DROP CONSTRAINT product_pk1;
       public         	   statsuser    false    290            b           2606    18202 <   product_file_description product_product_file_description_pk 
   CONSTRAINT     z   ALTER TABLE ONLY public.product_file_description
    ADD CONSTRAINT product_product_file_description_pk PRIMARY KEY (id);
 f   ALTER TABLE ONLY public.product_file_description DROP CONSTRAINT product_product_file_description_pk;
       public         	   statsuser    false    292            i           2606    18204     stratification stratification_pk 
   CONSTRAINT     ^   ALTER TABLE ONLY public.stratification
    ADD CONSTRAINT stratification_pk PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.stratification DROP CONSTRAINT stratification_pk;
       public         	   statsuser    false    300            o           2606    18206 '   stratification_geom stratification_pkey 
   CONSTRAINT     e   ALTER TABLE ONLY public.stratification_geom
    ADD CONSTRAINT stratification_pkey PRIMARY KEY (id);
 Q   ALTER TABLE ONLY public.stratification_geom DROP CONSTRAINT stratification_pkey;
       public         	   statsuser    false    301            k           2606    18208     stratification stratification_un 
   CONSTRAINT     b   ALTER TABLE ONLY public.stratification
    ADD CONSTRAINT stratification_un UNIQUE (description);
 J   ALTER TABLE ONLY public.stratification DROP CONSTRAINT stratification_un;
       public         	   statsuser    false    300            q           2606    18210    wms_file wms_file_pk 
   CONSTRAINT     R   ALTER TABLE ONLY public.wms_file
    ADD CONSTRAINT wms_file_pk PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.wms_file DROP CONSTRAINT wms_file_pk;
       public         	   statsuser    false    305            s           2606    18212    wms_file wms_file_un 
   CONSTRAINT     t   ALTER TABLE ONLY public.wms_file
    ADD CONSTRAINT wms_file_un UNIQUE (product_file_id, product_file_variable_id);
 >   ALTER TABLE ONLY public.wms_file DROP CONSTRAINT wms_file_un;
       public         	   statsuser    false    305    305            u           2606    18214 #   poly_stats_per_region poly_stats_pk 
   CONSTRAINT     ^   ALTER TABLE ONLY tmp.poly_stats_per_region
    ADD CONSTRAINT poly_stats_pk PRIMARY KEY (id);
 J   ALTER TABLE ONLY tmp.poly_stats_per_region DROP CONSTRAINT poly_stats_pk;
       tmp         	   statsuser    false    307            w           2606    18216 #   poly_stats_per_region poly_stats_un 
   CONSTRAINT     �   ALTER TABLE ONLY tmp.poly_stats_per_region
    ADD CONSTRAINT poly_stats_un UNIQUE (poly_id, product_file_id, product_file_variable_id, region_id);
 J   ALTER TABLE ONLY tmp.poly_stats_per_region DROP CONSTRAINT poly_stats_un;
       tmp         	   statsuser    false    307    307    307    307            �           1259    18217    poly_stats_product_file_id_idx    INDEX        CREATE INDEX poly_stats_product_file_id_idx ON ONLY public.poly_stats USING btree (product_file_id, product_file_variable_id);
 2   DROP INDEX public.poly_stats_product_file_id_idx;
       public         	   statsuser    false    228    228            �           1259    18218 ?   poly_stats_10_1_257_product_file_id_product_file_variable_i_idx    INDEX     �   CREATE INDEX poly_stats_10_1_257_product_file_id_product_file_variable_i_idx ON public.poly_stats_10_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_10_1_257_product_file_id_product_file_variable_i_idx;
       public         	   statsuser    false    229    229    229    4770            �           1259    18219 ?   poly_stats_10_257_279_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_10_257_279_product_file_id_product_file_variable_idx ON public.poly_stats_10_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_10_257_279_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    230    230    4770    230            �           1259    18220 ?   poly_stats_10_279_285_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_10_279_285_product_file_id_product_file_variable_idx ON public.poly_stats_10_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_10_279_285_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    4770    231    231    231            �           1259    18221 ?   poly_stats_10_285_38543_product_file_id_product_file_variab_idx    INDEX     �   CREATE INDEX poly_stats_10_285_38543_product_file_id_product_file_variab_idx ON public.poly_stats_10_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_10_285_38543_product_file_id_product_file_variab_idx;
       public         	   statsuser    false    232    232    4770    232            �           1259    18222 ?   poly_stats_12_1_257_product_file_id_product_file_variable_i_idx    INDEX     �   CREATE INDEX poly_stats_12_1_257_product_file_id_product_file_variable_i_idx ON public.poly_stats_12_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_12_1_257_product_file_id_product_file_variable_i_idx;
       public         	   statsuser    false    233    4770    233    233            �           1259    18223 ?   poly_stats_12_257_279_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_12_257_279_product_file_id_product_file_variable_idx ON public.poly_stats_12_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_12_257_279_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    234    234    234    4770            �           1259    18224 ?   poly_stats_12_279_285_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_12_279_285_product_file_id_product_file_variable_idx ON public.poly_stats_12_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_12_279_285_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    4770    235    235    235            �           1259    18225 ?   poly_stats_12_285_38543_product_file_id_product_file_variab_idx    INDEX     �   CREATE INDEX poly_stats_12_285_38543_product_file_id_product_file_variab_idx ON public.poly_stats_12_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_12_285_38543_product_file_id_product_file_variab_idx;
       public         	   statsuser    false    236    236    4770    236            �           1259    18226 ?   poly_stats_14_1_257_product_file_id_product_file_variable_i_idx    INDEX     �   CREATE INDEX poly_stats_14_1_257_product_file_id_product_file_variable_i_idx ON public.poly_stats_14_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_14_1_257_product_file_id_product_file_variable_i_idx;
       public         	   statsuser    false    4770    237    237    237            �           1259    18227 ?   poly_stats_14_257_279_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_14_257_279_product_file_id_product_file_variable_idx ON public.poly_stats_14_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_14_257_279_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    238    238    238    4770            �           1259    18228 ?   poly_stats_14_279_285_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_14_279_285_product_file_id_product_file_variable_idx ON public.poly_stats_14_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_14_279_285_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    239    4770    239    239            �           1259    18229 ?   poly_stats_14_285_38543_product_file_id_product_file_variab_idx    INDEX     �   CREATE INDEX poly_stats_14_285_38543_product_file_id_product_file_variab_idx ON public.poly_stats_14_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_14_285_38543_product_file_id_product_file_variab_idx;
       public         	   statsuser    false    240    240    240    4770            �           1259    18230 ?   poly_stats_16_1_257_product_file_id_product_file_variable_i_idx    INDEX     �   CREATE INDEX poly_stats_16_1_257_product_file_id_product_file_variable_i_idx ON public.poly_stats_16_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_16_1_257_product_file_id_product_file_variable_i_idx;
       public         	   statsuser    false    4770    241    241    241            �           1259    18231 ?   poly_stats_16_257_279_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_16_257_279_product_file_id_product_file_variable_idx ON public.poly_stats_16_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_16_257_279_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    242    4770    242    242            �           1259    18232 ?   poly_stats_16_279_285_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_16_279_285_product_file_id_product_file_variable_idx ON public.poly_stats_16_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_16_279_285_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    4770    243    243    243            �           1259    18233 ?   poly_stats_16_285_38543_product_file_id_product_file_variab_idx    INDEX     �   CREATE INDEX poly_stats_16_285_38543_product_file_id_product_file_variab_idx ON public.poly_stats_16_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_16_285_38543_product_file_id_product_file_variab_idx;
       public         	   statsuser    false    4770    244    244    244            �           1259    18234 ?   poly_stats_17_1_257_product_file_id_product_file_variable_i_idx    INDEX     �   CREATE INDEX poly_stats_17_1_257_product_file_id_product_file_variable_i_idx ON public.poly_stats_17_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_17_1_257_product_file_id_product_file_variable_i_idx;
       public         	   statsuser    false    245    245    4770    245            �           1259    18235 ?   poly_stats_17_257_279_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_17_257_279_product_file_id_product_file_variable_idx ON public.poly_stats_17_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_17_257_279_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    246    246    246    4770            �           1259    18236 ?   poly_stats_17_279_285_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_17_279_285_product_file_id_product_file_variable_idx ON public.poly_stats_17_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_17_279_285_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    247    4770    247    247            �           1259    18237 ?   poly_stats_17_285_38543_product_file_id_product_file_variab_idx    INDEX     �   CREATE INDEX poly_stats_17_285_38543_product_file_id_product_file_variab_idx ON public.poly_stats_17_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_17_285_38543_product_file_id_product_file_variab_idx;
       public         	   statsuser    false    248    248    4770    248            �           1259    18238 ?   poly_stats_19_1_257_product_file_id_product_file_variable_i_idx    INDEX     �   CREATE INDEX poly_stats_19_1_257_product_file_id_product_file_variable_i_idx ON public.poly_stats_19_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_19_1_257_product_file_id_product_file_variable_i_idx;
       public         	   statsuser    false    4770    249    249    249            �           1259    18239 ?   poly_stats_19_257_279_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_19_257_279_product_file_id_product_file_variable_idx ON public.poly_stats_19_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_19_257_279_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    250    250    4770    250            �           1259    18240 ?   poly_stats_19_279_285_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_19_279_285_product_file_id_product_file_variable_idx ON public.poly_stats_19_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_19_279_285_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    251    251    4770    251            �           1259    18241 ?   poly_stats_19_285_38543_product_file_id_product_file_variab_idx    INDEX     �   CREATE INDEX poly_stats_19_285_38543_product_file_id_product_file_variab_idx ON public.poly_stats_19_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_19_285_38543_product_file_id_product_file_variab_idx;
       public         	   statsuser    false    4770    252    252    252            �           1259    18242 ?   poly_stats_1_1_257_product_file_id_product_file_variable_id_idx    INDEX     �   CREATE INDEX poly_stats_1_1_257_product_file_id_product_file_variable_id_idx ON public.poly_stats_1_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_1_1_257_product_file_id_product_file_variable_id_idx;
       public         	   statsuser    false    253    253    253    4770            �           1259    18243 ?   poly_stats_1_257_279_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_1_257_279_product_file_id_product_file_variable__idx ON public.poly_stats_1_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_1_257_279_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    254    254    4770    254            �           1259    18244 ?   poly_stats_1_279_285_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_1_279_285_product_file_id_product_file_variable__idx ON public.poly_stats_1_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_1_279_285_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    4770    255    255    255            �           1259    18245 ?   poly_stats_1_285_38543_product_file_id_product_file_variabl_idx    INDEX     �   CREATE INDEX poly_stats_1_285_38543_product_file_id_product_file_variabl_idx ON public.poly_stats_1_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_1_285_38543_product_file_id_product_file_variabl_idx;
       public         	   statsuser    false    256    256    256    4770            �           1259    18246 ?   poly_stats_21_1_257_product_file_id_product_file_variable_i_idx    INDEX     �   CREATE INDEX poly_stats_21_1_257_product_file_id_product_file_variable_i_idx ON public.poly_stats_21_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_21_1_257_product_file_id_product_file_variable_i_idx;
       public         	   statsuser    false    4770    257    257    257            �           1259    18247 ?   poly_stats_21_257_279_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_21_257_279_product_file_id_product_file_variable_idx ON public.poly_stats_21_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_21_257_279_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    258    258    4770    258            �           1259    18248 ?   poly_stats_21_279_285_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_21_279_285_product_file_id_product_file_variable_idx ON public.poly_stats_21_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_21_279_285_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    259    259    4770    259                       1259    18249 ?   poly_stats_21_285_38543_product_file_id_product_file_variab_idx    INDEX     �   CREATE INDEX poly_stats_21_285_38543_product_file_id_product_file_variab_idx ON public.poly_stats_21_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_21_285_38543_product_file_id_product_file_variab_idx;
       public         	   statsuser    false    260    260    4770    260                       1259    18250 ?   poly_stats_24_1_257_product_file_id_product_file_variable_i_idx    INDEX     �   CREATE INDEX poly_stats_24_1_257_product_file_id_product_file_variable_i_idx ON public.poly_stats_24_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_24_1_257_product_file_id_product_file_variable_i_idx;
       public         	   statsuser    false    4770    261    261    261                       1259    18251 ?   poly_stats_2_1_257_product_file_id_product_file_variable_id_idx    INDEX     �   CREATE INDEX poly_stats_2_1_257_product_file_id_product_file_variable_id_idx ON public.poly_stats_2_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_2_1_257_product_file_id_product_file_variable_id_idx;
       public         	   statsuser    false    262    262    4770    262                       1259    18252 ?   poly_stats_2_257_279_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_2_257_279_product_file_id_product_file_variable__idx ON public.poly_stats_2_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_2_257_279_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    263    263    263    4770                       1259    18253 ?   poly_stats_2_279_285_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_2_279_285_product_file_id_product_file_variable__idx ON public.poly_stats_2_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_2_279_285_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    264    4770    264    264                       1259    18254 ?   poly_stats_2_285_38543_product_file_id_product_file_variabl_idx    INDEX     �   CREATE INDEX poly_stats_2_285_38543_product_file_id_product_file_variabl_idx ON public.poly_stats_2_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_2_285_38543_product_file_id_product_file_variabl_idx;
       public         	   statsuser    false    4770    265    265    265                       1259    18255 ?   poly_stats_3_1_257_product_file_id_product_file_variable_id_idx    INDEX     �   CREATE INDEX poly_stats_3_1_257_product_file_id_product_file_variable_id_idx ON public.poly_stats_3_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_3_1_257_product_file_id_product_file_variable_id_idx;
       public         	   statsuser    false    266    266    4770    266                       1259    18256 ?   poly_stats_3_257_279_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_3_257_279_product_file_id_product_file_variable__idx ON public.poly_stats_3_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_3_257_279_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    267    267    4770    267                       1259    18257 ?   poly_stats_3_279_285_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_3_279_285_product_file_id_product_file_variable__idx ON public.poly_stats_3_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_3_279_285_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    268    4770    268    268                       1259    18258 ?   poly_stats_3_285_38543_product_file_id_product_file_variabl_idx    INDEX     �   CREATE INDEX poly_stats_3_285_38543_product_file_id_product_file_variabl_idx ON public.poly_stats_3_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_3_285_38543_product_file_id_product_file_variabl_idx;
       public         	   statsuser    false    269    269    4770    269                        1259    18259 ?   poly_stats_4_1_257_product_file_id_product_file_variable_id_idx    INDEX     �   CREATE INDEX poly_stats_4_1_257_product_file_id_product_file_variable_id_idx ON public.poly_stats_4_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_4_1_257_product_file_id_product_file_variable_id_idx;
       public         	   statsuser    false    270    270    4770    270            #           1259    18260 ?   poly_stats_4_257_279_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_4_257_279_product_file_id_product_file_variable__idx ON public.poly_stats_4_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_4_257_279_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    271    271    4770    271            &           1259    18261 ?   poly_stats_4_279_285_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_4_279_285_product_file_id_product_file_variable__idx ON public.poly_stats_4_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_4_279_285_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    4770    272    272    272            )           1259    18262 ?   poly_stats_4_285_38543_product_file_id_product_file_variabl_idx    INDEX     �   CREATE INDEX poly_stats_4_285_38543_product_file_id_product_file_variabl_idx ON public.poly_stats_4_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_4_285_38543_product_file_id_product_file_variabl_idx;
       public         	   statsuser    false    273    273    4770    273            ,           1259    18263 ?   poly_stats_5_1_257_product_file_id_product_file_variable_id_idx    INDEX     �   CREATE INDEX poly_stats_5_1_257_product_file_id_product_file_variable_id_idx ON public.poly_stats_5_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_5_1_257_product_file_id_product_file_variable_id_idx;
       public         	   statsuser    false    274    274    274    4770            /           1259    18264 ?   poly_stats_5_257_279_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_5_257_279_product_file_id_product_file_variable__idx ON public.poly_stats_5_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_5_257_279_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    275    4770    275    275            2           1259    18265 ?   poly_stats_5_279_285_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_5_279_285_product_file_id_product_file_variable__idx ON public.poly_stats_5_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_5_279_285_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    276    276    4770    276            5           1259    18266 ?   poly_stats_5_285_38543_product_file_id_product_file_variabl_idx    INDEX     �   CREATE INDEX poly_stats_5_285_38543_product_file_id_product_file_variabl_idx ON public.poly_stats_5_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_5_285_38543_product_file_id_product_file_variabl_idx;
       public         	   statsuser    false    4770    277    277    277            8           1259    18267 ?   poly_stats_6_1_257_product_file_id_product_file_variable_id_idx    INDEX     �   CREATE INDEX poly_stats_6_1_257_product_file_id_product_file_variable_id_idx ON public.poly_stats_6_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_6_1_257_product_file_id_product_file_variable_id_idx;
       public         	   statsuser    false    278    4770    278    278            ;           1259    18268 ?   poly_stats_6_257_279_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_6_257_279_product_file_id_product_file_variable__idx ON public.poly_stats_6_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_6_257_279_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    4770    279    279    279            >           1259    18269 ?   poly_stats_6_279_285_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_6_279_285_product_file_id_product_file_variable__idx ON public.poly_stats_6_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_6_279_285_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    280    4770    280    280            A           1259    18270 ?   poly_stats_6_285_38543_product_file_id_product_file_variabl_idx    INDEX     �   CREATE INDEX poly_stats_6_285_38543_product_file_id_product_file_variabl_idx ON public.poly_stats_6_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_6_285_38543_product_file_id_product_file_variabl_idx;
       public         	   statsuser    false    281    4770    281    281            D           1259    18271 ?   poly_stats_7_1_257_product_file_id_product_file_variable_id_idx    INDEX     �   CREATE INDEX poly_stats_7_1_257_product_file_id_product_file_variable_id_idx ON public.poly_stats_7_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_7_1_257_product_file_id_product_file_variable_id_idx;
       public         	   statsuser    false    4770    282    282    282            G           1259    18272 ?   poly_stats_7_257_279_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_7_257_279_product_file_id_product_file_variable__idx ON public.poly_stats_7_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_7_257_279_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    283    4770    283    283            J           1259    18273 ?   poly_stats_7_279_285_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_7_279_285_product_file_id_product_file_variable__idx ON public.poly_stats_7_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_7_279_285_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    4770    284    284    284            M           1259    18274 ?   poly_stats_7_285_38543_product_file_id_product_file_variabl_idx    INDEX     �   CREATE INDEX poly_stats_7_285_38543_product_file_id_product_file_variabl_idx ON public.poly_stats_7_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_7_285_38543_product_file_id_product_file_variabl_idx;
       public         	   statsuser    false    285    285    4770    285            P           1259    18275 ?   poly_stats_9_1_257_product_file_id_product_file_variable_id_idx    INDEX     �   CREATE INDEX poly_stats_9_1_257_product_file_id_product_file_variable_id_idx ON public.poly_stats_9_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_9_1_257_product_file_id_product_file_variable_id_idx;
       public         	   statsuser    false    4770    286    286    286            S           1259    18276 ?   poly_stats_9_257_279_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_9_257_279_product_file_id_product_file_variable__idx ON public.poly_stats_9_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_9_257_279_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    287    4770    287    287            V           1259    18277 ?   poly_stats_9_279_285_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_9_279_285_product_file_id_product_file_variable__idx ON public.poly_stats_9_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_9_279_285_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    288    4770    288    288            Y           1259    18278 ?   poly_stats_9_285_38543_product_file_id_product_file_variabl_idx    INDEX     �   CREATE INDEX poly_stats_9_285_38543_product_file_id_product_file_variabl_idx ON public.poly_stats_9_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_9_285_38543_product_file_id_product_file_variabl_idx;
       public         	   statsuser    false    289    289    289    4770            \           1259    18279    product_file_date_idx    INDEX     W   CREATE INDEX product_file_date_idx ON public.product_file USING btree (date, rt_flag);
 )   DROP INDEX public.product_file_date_idx;
       public         	   statsuser    false    291    291            e           1259    18280    product_order_email_idx    INDEX     `   CREATE INDEX product_order_email_idx ON public.product_order USING btree (email, date_created);
 +   DROP INDEX public.product_order_email_idx;
       public         	   statsuser    false    299    299            l           1259    18281    sidx_stratification_geom    INDEX     W   CREATE INDEX sidx_stratification_geom ON public.stratification_geom USING gist (geom);
 ,   DROP INDEX public.sidx_stratification_geom;
       public         	   statsuser    false    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    301            m           1259    18282    sidx_stratification_geom3857    INDEX     �   CREATE INDEX sidx_stratification_geom3857 ON public.stratification_geom USING gist (geom3857);

ALTER TABLE public.stratification_geom CLUSTER ON sidx_stratification_geom3857;
 0   DROP INDEX public.sidx_stratification_geom3857;
       public         	   statsuser    false    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    301            x           0    0    poly_stats_10_1_257_pkey    INDEX ATTACH     T   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_10_1_257_pkey;
          public       	   statsuser    false    229    4769    4772    4769    229    228            y           0    0 ?   poly_stats_10_1_257_product_file_id_product_file_variable_i_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_10_1_257_product_file_id_product_file_variable_i_idx;
          public       	   statsuser    false    4773    4770    229    228            z           0    0    poly_stats_10_257_279_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_10_257_279_pkey;
          public       	   statsuser    false    230    4775    4769    4769    230    228            {           0    0 ?   poly_stats_10_257_279_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_10_257_279_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4776    4770    230    228            |           0    0    poly_stats_10_279_285_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_10_279_285_pkey;
          public       	   statsuser    false    4769    4778    231    4769    231    228            }           0    0 ?   poly_stats_10_279_285_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_10_279_285_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4779    4770    231    228            ~           0    0    poly_stats_10_285_38543_pkey    INDEX ATTACH     X   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_10_285_38543_pkey;
          public       	   statsuser    false    4781    4769    232    4769    232    228                       0    0 ?   poly_stats_10_285_38543_product_file_id_product_file_variab_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_10_285_38543_product_file_id_product_file_variab_idx;
          public       	   statsuser    false    4782    4770    232    228            �           0    0    poly_stats_12_1_257_pkey    INDEX ATTACH     T   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_12_1_257_pkey;
          public       	   statsuser    false    233    4784    4769    4769    233    228            �           0    0 ?   poly_stats_12_1_257_product_file_id_product_file_variable_i_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_12_1_257_product_file_id_product_file_variable_i_idx;
          public       	   statsuser    false    4785    4770    233    228            �           0    0    poly_stats_12_257_279_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_12_257_279_pkey;
          public       	   statsuser    false    4769    4787    234    4769    234    228            �           0    0 ?   poly_stats_12_257_279_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_12_257_279_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4788    4770    234    228            �           0    0    poly_stats_12_279_285_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_12_279_285_pkey;
          public       	   statsuser    false    4769    235    4790    4769    235    228            �           0    0 ?   poly_stats_12_279_285_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_12_279_285_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4791    4770    235    228            �           0    0    poly_stats_12_285_38543_pkey    INDEX ATTACH     X   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_12_285_38543_pkey;
          public       	   statsuser    false    236    4769    4793    4769    236    228            �           0    0 ?   poly_stats_12_285_38543_product_file_id_product_file_variab_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_12_285_38543_product_file_id_product_file_variab_idx;
          public       	   statsuser    false    4794    4770    236    228            �           0    0    poly_stats_14_1_257_pkey    INDEX ATTACH     T   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_14_1_257_pkey;
          public       	   statsuser    false    4769    4796    237    4769    237    228            �           0    0 ?   poly_stats_14_1_257_product_file_id_product_file_variable_i_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_14_1_257_product_file_id_product_file_variable_i_idx;
          public       	   statsuser    false    4797    4770    237    228            �           0    0    poly_stats_14_257_279_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_14_257_279_pkey;
          public       	   statsuser    false    238    4769    4799    4769    238    228            �           0    0 ?   poly_stats_14_257_279_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_14_257_279_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4800    4770    238    228            �           0    0    poly_stats_14_279_285_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_14_279_285_pkey;
          public       	   statsuser    false    4802    4769    239    4769    239    228            �           0    0 ?   poly_stats_14_279_285_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_14_279_285_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4803    4770    239    228            �           0    0    poly_stats_14_285_38543_pkey    INDEX ATTACH     X   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_14_285_38543_pkey;
          public       	   statsuser    false    4805    240    4769    4769    240    228            �           0    0 ?   poly_stats_14_285_38543_product_file_id_product_file_variab_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_14_285_38543_product_file_id_product_file_variab_idx;
          public       	   statsuser    false    4806    4770    240    228            �           0    0    poly_stats_16_1_257_pkey    INDEX ATTACH     T   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_16_1_257_pkey;
          public       	   statsuser    false    241    4769    4808    4769    241    228            �           0    0 ?   poly_stats_16_1_257_product_file_id_product_file_variable_i_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_16_1_257_product_file_id_product_file_variable_i_idx;
          public       	   statsuser    false    4809    4770    241    228            �           0    0    poly_stats_16_257_279_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_16_257_279_pkey;
          public       	   statsuser    false    4811    242    4769    4769    242    228            �           0    0 ?   poly_stats_16_257_279_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_16_257_279_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4812    4770    242    228            �           0    0    poly_stats_16_279_285_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_16_279_285_pkey;
          public       	   statsuser    false    4814    243    4769    4769    243    228            �           0    0 ?   poly_stats_16_279_285_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_16_279_285_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4815    4770    243    228            �           0    0    poly_stats_16_285_38543_pkey    INDEX ATTACH     X   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_16_285_38543_pkey;
          public       	   statsuser    false    4769    4817    244    4769    244    228            �           0    0 ?   poly_stats_16_285_38543_product_file_id_product_file_variab_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_16_285_38543_product_file_id_product_file_variab_idx;
          public       	   statsuser    false    4818    4770    244    228            �           0    0    poly_stats_17_1_257_pkey    INDEX ATTACH     T   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_17_1_257_pkey;
          public       	   statsuser    false    4769    4820    245    4769    245    228            �           0    0 ?   poly_stats_17_1_257_product_file_id_product_file_variable_i_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_17_1_257_product_file_id_product_file_variable_i_idx;
          public       	   statsuser    false    4821    4770    245    228            �           0    0    poly_stats_17_257_279_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_17_257_279_pkey;
          public       	   statsuser    false    4823    246    4769    4769    246    228            �           0    0 ?   poly_stats_17_257_279_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_17_257_279_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4824    4770    246    228            �           0    0    poly_stats_17_279_285_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_17_279_285_pkey;
          public       	   statsuser    false    4826    4769    247    4769    247    228            �           0    0 ?   poly_stats_17_279_285_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_17_279_285_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4827    4770    247    228            �           0    0    poly_stats_17_285_38543_pkey    INDEX ATTACH     X   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_17_285_38543_pkey;
          public       	   statsuser    false    248    4769    4829    4769    248    228            �           0    0 ?   poly_stats_17_285_38543_product_file_id_product_file_variab_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_17_285_38543_product_file_id_product_file_variab_idx;
          public       	   statsuser    false    4830    4770    248    228            �           0    0    poly_stats_19_1_257_pkey    INDEX ATTACH     T   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_19_1_257_pkey;
          public       	   statsuser    false    4769    4832    249    4769    249    228            �           0    0 ?   poly_stats_19_1_257_product_file_id_product_file_variable_i_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_19_1_257_product_file_id_product_file_variable_i_idx;
          public       	   statsuser    false    4833    4770    249    228            �           0    0    poly_stats_19_257_279_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_19_257_279_pkey;
          public       	   statsuser    false    250    4835    4769    4769    250    228            �           0    0 ?   poly_stats_19_257_279_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_19_257_279_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4836    4770    250    228            �           0    0    poly_stats_19_279_285_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_19_279_285_pkey;
          public       	   statsuser    false    251    4769    4838    4769    251    228            �           0    0 ?   poly_stats_19_279_285_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_19_279_285_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4839    4770    251    228            �           0    0    poly_stats_19_285_38543_pkey    INDEX ATTACH     X   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_19_285_38543_pkey;
          public       	   statsuser    false    4841    4769    252    4769    252    228            �           0    0 ?   poly_stats_19_285_38543_product_file_id_product_file_variab_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_19_285_38543_product_file_id_product_file_variab_idx;
          public       	   statsuser    false    4842    4770    252    228            �           0    0    poly_stats_1_1_257_pkey    INDEX ATTACH     S   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_1_1_257_pkey;
          public       	   statsuser    false    253    4844    4769    4769    253    228            �           0    0 ?   poly_stats_1_1_257_product_file_id_product_file_variable_id_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_1_1_257_product_file_id_product_file_variable_id_idx;
          public       	   statsuser    false    4845    4770    253    228            �           0    0    poly_stats_1_257_279_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_1_257_279_pkey;
          public       	   statsuser    false    4769    254    4847    4769    254    228            �           0    0 ?   poly_stats_1_257_279_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_1_257_279_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4848    4770    254    228            �           0    0    poly_stats_1_279_285_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_1_279_285_pkey;
          public       	   statsuser    false    4850    4769    255    4769    255    228            �           0    0 ?   poly_stats_1_279_285_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_1_279_285_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4851    4770    255    228            �           0    0    poly_stats_1_285_38543_pkey    INDEX ATTACH     W   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_1_285_38543_pkey;
          public       	   statsuser    false    4853    4769    256    4769    256    228            �           0    0 ?   poly_stats_1_285_38543_product_file_id_product_file_variabl_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_1_285_38543_product_file_id_product_file_variabl_idx;
          public       	   statsuser    false    4854    4770    256    228            �           0    0    poly_stats_21_1_257_pkey    INDEX ATTACH     T   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_21_1_257_pkey;
          public       	   statsuser    false    257    4856    4769    4769    257    228            �           0    0 ?   poly_stats_21_1_257_product_file_id_product_file_variable_i_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_21_1_257_product_file_id_product_file_variable_i_idx;
          public       	   statsuser    false    4857    4770    257    228            �           0    0    poly_stats_21_257_279_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_21_257_279_pkey;
          public       	   statsuser    false    4859    4769    258    4769    258    228            �           0    0 ?   poly_stats_21_257_279_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_21_257_279_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4860    4770    258    228            �           0    0    poly_stats_21_279_285_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_21_279_285_pkey;
          public       	   statsuser    false    259    4862    4769    4769    259    228            �           0    0 ?   poly_stats_21_279_285_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_21_279_285_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4863    4770    259    228            �           0    0    poly_stats_21_285_38543_pkey    INDEX ATTACH     X   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_21_285_38543_pkey;
          public       	   statsuser    false    260    4865    4769    4769    260    228            �           0    0 ?   poly_stats_21_285_38543_product_file_id_product_file_variab_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_21_285_38543_product_file_id_product_file_variab_idx;
          public       	   statsuser    false    4866    4770    260    228            �           0    0    poly_stats_24_1_257_pkey    INDEX ATTACH     T   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_24_1_257_pkey;
          public       	   statsuser    false    4769    261    4868    4769    261    228            �           0    0 ?   poly_stats_24_1_257_product_file_id_product_file_variable_i_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_24_1_257_product_file_id_product_file_variable_i_idx;
          public       	   statsuser    false    4869    4770    261    228            �           0    0    poly_stats_2_1_257_pkey    INDEX ATTACH     S   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_2_1_257_pkey;
          public       	   statsuser    false    4769    4871    262    4769    262    228            �           0    0 ?   poly_stats_2_1_257_product_file_id_product_file_variable_id_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_2_1_257_product_file_id_product_file_variable_id_idx;
          public       	   statsuser    false    4872    4770    262    228            �           0    0    poly_stats_2_257_279_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_2_257_279_pkey;
          public       	   statsuser    false    4874    4769    263    4769    263    228            �           0    0 ?   poly_stats_2_257_279_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_2_257_279_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4875    4770    263    228            �           0    0    poly_stats_2_279_285_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_2_279_285_pkey;
          public       	   statsuser    false    4877    4769    264    4769    264    228            �           0    0 ?   poly_stats_2_279_285_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_2_279_285_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4878    4770    264    228            �           0    0    poly_stats_2_285_38543_pkey    INDEX ATTACH     W   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_2_285_38543_pkey;
          public       	   statsuser    false    4880    265    4769    4769    265    228            �           0    0 ?   poly_stats_2_285_38543_product_file_id_product_file_variabl_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_2_285_38543_product_file_id_product_file_variabl_idx;
          public       	   statsuser    false    4881    4770    265    228            �           0    0    poly_stats_3_1_257_pkey    INDEX ATTACH     S   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_3_1_257_pkey;
          public       	   statsuser    false    4883    4769    266    4769    266    228            �           0    0 ?   poly_stats_3_1_257_product_file_id_product_file_variable_id_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_3_1_257_product_file_id_product_file_variable_id_idx;
          public       	   statsuser    false    4884    4770    266    228            �           0    0    poly_stats_3_257_279_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_3_257_279_pkey;
          public       	   statsuser    false    4769    4886    267    4769    267    228            �           0    0 ?   poly_stats_3_257_279_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_3_257_279_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4887    4770    267    228            �           0    0    poly_stats_3_279_285_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_3_279_285_pkey;
          public       	   statsuser    false    268    4889    4769    4769    268    228            �           0    0 ?   poly_stats_3_279_285_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_3_279_285_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4890    4770    268    228            �           0    0    poly_stats_3_285_38543_pkey    INDEX ATTACH     W   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_3_285_38543_pkey;
          public       	   statsuser    false    269    4892    4769    4769    269    228            �           0    0 ?   poly_stats_3_285_38543_product_file_id_product_file_variabl_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_3_285_38543_product_file_id_product_file_variabl_idx;
          public       	   statsuser    false    4893    4770    269    228            �           0    0    poly_stats_4_1_257_pkey    INDEX ATTACH     S   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_4_1_257_pkey;
          public       	   statsuser    false    270    4895    4769    4769    270    228            �           0    0 ?   poly_stats_4_1_257_product_file_id_product_file_variable_id_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_4_1_257_product_file_id_product_file_variable_id_idx;
          public       	   statsuser    false    4896    4770    270    228            �           0    0    poly_stats_4_257_279_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_4_257_279_pkey;
          public       	   statsuser    false    4769    271    4898    4769    271    228            �           0    0 ?   poly_stats_4_257_279_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_4_257_279_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4899    4770    271    228            �           0    0    poly_stats_4_279_285_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_4_279_285_pkey;
          public       	   statsuser    false    272    4901    4769    4769    272    228            �           0    0 ?   poly_stats_4_279_285_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_4_279_285_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4902    4770    272    228            �           0    0    poly_stats_4_285_38543_pkey    INDEX ATTACH     W   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_4_285_38543_pkey;
          public       	   statsuser    false    4904    273    4769    4769    273    228            �           0    0 ?   poly_stats_4_285_38543_product_file_id_product_file_variabl_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_4_285_38543_product_file_id_product_file_variabl_idx;
          public       	   statsuser    false    4905    4770    273    228            �           0    0    poly_stats_5_1_257_pkey    INDEX ATTACH     S   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_5_1_257_pkey;
          public       	   statsuser    false    4907    4769    274    4769    274    228            �           0    0 ?   poly_stats_5_1_257_product_file_id_product_file_variable_id_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_5_1_257_product_file_id_product_file_variable_id_idx;
          public       	   statsuser    false    4908    4770    274    228            �           0    0    poly_stats_5_257_279_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_5_257_279_pkey;
          public       	   statsuser    false    4910    4769    275    4769    275    228            �           0    0 ?   poly_stats_5_257_279_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_5_257_279_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4911    4770    275    228            �           0    0    poly_stats_5_279_285_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_5_279_285_pkey;
          public       	   statsuser    false    276    4769    4913    4769    276    228            �           0    0 ?   poly_stats_5_279_285_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_5_279_285_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4914    4770    276    228            �           0    0    poly_stats_5_285_38543_pkey    INDEX ATTACH     W   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_5_285_38543_pkey;
          public       	   statsuser    false    277    4769    4916    4769    277    228            �           0    0 ?   poly_stats_5_285_38543_product_file_id_product_file_variabl_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_5_285_38543_product_file_id_product_file_variabl_idx;
          public       	   statsuser    false    4917    4770    277    228            �           0    0    poly_stats_6_1_257_pkey    INDEX ATTACH     S   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_6_1_257_pkey;
          public       	   statsuser    false    4919    278    4769    4769    278    228            �           0    0 ?   poly_stats_6_1_257_product_file_id_product_file_variable_id_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_6_1_257_product_file_id_product_file_variable_id_idx;
          public       	   statsuser    false    4920    4770    278    228            �           0    0    poly_stats_6_257_279_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_6_257_279_pkey;
          public       	   statsuser    false    4769    279    4922    4769    279    228            �           0    0 ?   poly_stats_6_257_279_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_6_257_279_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4923    4770    279    228            �           0    0    poly_stats_6_279_285_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_6_279_285_pkey;
          public       	   statsuser    false    280    4769    4925    4769    280    228            �           0    0 ?   poly_stats_6_279_285_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_6_279_285_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4926    4770    280    228            �           0    0    poly_stats_6_285_38543_pkey    INDEX ATTACH     W   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_6_285_38543_pkey;
          public       	   statsuser    false    4769    281    4928    4769    281    228            �           0    0 ?   poly_stats_6_285_38543_product_file_id_product_file_variabl_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_6_285_38543_product_file_id_product_file_variabl_idx;
          public       	   statsuser    false    4929    4770    281    228            �           0    0    poly_stats_7_1_257_pkey    INDEX ATTACH     S   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_7_1_257_pkey;
          public       	   statsuser    false    4769    282    4931    4769    282    228            �           0    0 ?   poly_stats_7_1_257_product_file_id_product_file_variable_id_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_7_1_257_product_file_id_product_file_variable_id_idx;
          public       	   statsuser    false    4932    4770    282    228            �           0    0    poly_stats_7_257_279_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_7_257_279_pkey;
          public       	   statsuser    false    4769    4934    283    4769    283    228            �           0    0 ?   poly_stats_7_257_279_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_7_257_279_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4935    4770    283    228            �           0    0    poly_stats_7_279_285_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_7_279_285_pkey;
          public       	   statsuser    false    284    4769    4937    4769    284    228            �           0    0 ?   poly_stats_7_279_285_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_7_279_285_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4938    4770    284    228            �           0    0    poly_stats_7_285_38543_pkey    INDEX ATTACH     W   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_7_285_38543_pkey;
          public       	   statsuser    false    285    4769    4940    4769    285    228            �           0    0 ?   poly_stats_7_285_38543_product_file_id_product_file_variabl_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_7_285_38543_product_file_id_product_file_variabl_idx;
          public       	   statsuser    false    4941    4770    285    228            �           0    0    poly_stats_9_1_257_pkey    INDEX ATTACH     S   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_9_1_257_pkey;
          public       	   statsuser    false    286    4769    4943    4769    286    228            �           0    0 ?   poly_stats_9_1_257_product_file_id_product_file_variable_id_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_9_1_257_product_file_id_product_file_variable_id_idx;
          public       	   statsuser    false    4944    4770    286    228            �           0    0    poly_stats_9_257_279_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_9_257_279_pkey;
          public       	   statsuser    false    287    4769    4946    4769    287    228            �           0    0 ?   poly_stats_9_257_279_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_9_257_279_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4947    4770    287    228            �           0    0    poly_stats_9_279_285_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_9_279_285_pkey;
          public       	   statsuser    false    4769    4949    288    4769    288    228            �           0    0 ?   poly_stats_9_279_285_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_9_279_285_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4950    4770    288    228            �           0    0    poly_stats_9_285_38543_pkey    INDEX ATTACH     W   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_9_285_38543_pkey;
          public       	   statsuser    false    4769    289    4952    4769    289    228            �           0    0 ?   poly_stats_9_285_38543_product_file_id_product_file_variabl_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_9_285_38543_product_file_id_product_file_variabl_idx;
          public       	   statsuser    false    4953    4770    289    228            �           2606    18283 0   long_term_anomaly_info long_term_anomaly_info_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.long_term_anomaly_info
    ADD CONSTRAINT long_term_anomaly_info_fk FOREIGN KEY (anomaly_product_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 Z   ALTER TABLE ONLY public.long_term_anomaly_info DROP CONSTRAINT long_term_anomaly_info_fk;
       public       	   statsuser    false    4964    225    296            �           2606    18288 2   long_term_anomaly_info long_term_anomaly_info_fk_1    FK CONSTRAINT     �   ALTER TABLE ONLY public.long_term_anomaly_info
    ADD CONSTRAINT long_term_anomaly_info_fk_1 FOREIGN KEY (mean_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 \   ALTER TABLE ONLY public.long_term_anomaly_info DROP CONSTRAINT long_term_anomaly_info_fk_1;
       public       	   statsuser    false    225    296    4964            �           2606    18293 2   long_term_anomaly_info long_term_anomaly_info_fk_2    FK CONSTRAINT     �   ALTER TABLE ONLY public.long_term_anomaly_info
    ADD CONSTRAINT long_term_anomaly_info_fk_2 FOREIGN KEY (stdev_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 \   ALTER TABLE ONLY public.long_term_anomaly_info DROP CONSTRAINT long_term_anomaly_info_fk_2;
       public       	   statsuser    false    296    4964    225            �           2606    18298 2   long_term_anomaly_info long_term_anomaly_info_fk_3    FK CONSTRAINT     �   ALTER TABLE ONLY public.long_term_anomaly_info
    ADD CONSTRAINT long_term_anomaly_info_fk_3 FOREIGN KEY (raw_product_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 \   ALTER TABLE ONLY public.long_term_anomaly_info DROP CONSTRAINT long_term_anomaly_info_fk_3;
       public       	   statsuser    false    296    225    4964            �           2606    18303 &   poly_stats poly_stats_product_file_fk_    FK CONSTRAINT     �   ALTER TABLE public.poly_stats
    ADD CONSTRAINT poly_stats_product_file_fk_ FOREIGN KEY (product_file_id) REFERENCES public.product_file(id) ON UPDATE CASCADE ON DELETE CASCADE;
 K   ALTER TABLE public.poly_stats DROP CONSTRAINT poly_stats_product_file_fk_;
       public       	   statsuser    false    228    4960    291            �           2606    18491 *   poly_stats poly_stats_product_variable_fk_    FK CONSTRAINT     �   ALTER TABLE public.poly_stats
    ADD CONSTRAINT poly_stats_product_variable_fk_ FOREIGN KEY (product_file_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 O   ALTER TABLE public.poly_stats DROP CONSTRAINT poly_stats_product_variable_fk_;
       public       	   statsuser    false    296    228    4964            �           2606    18679 -   poly_stats poly_stats_stratification_geom_fk_    FK CONSTRAINT     �   ALTER TABLE public.poly_stats
    ADD CONSTRAINT poly_stats_stratification_geom_fk_ FOREIGN KEY (poly_id) REFERENCES public.stratification_geom(id) ON UPDATE CASCADE ON DELETE CASCADE;
 R   ALTER TABLE public.poly_stats DROP CONSTRAINT poly_stats_stratification_geom_fk_;
       public       	   statsuser    false    4975    301    228            �           2606    18867 4   product_file_description product_file_description_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.product_file_description
    ADD CONSTRAINT product_file_description_fk FOREIGN KEY (product_id) REFERENCES public.product(id) ON UPDATE CASCADE ON DELETE CASCADE;
 ^   ALTER TABLE ONLY public.product_file_description DROP CONSTRAINT product_file_description_fk;
       public       	   statsuser    false    292    4955    290            �           2606    18872    product product_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_fk FOREIGN KEY (category_id) REFERENCES public.category(id) ON UPDATE CASCADE ON DELETE CASCADE;
 <   ALTER TABLE ONLY public.product DROP CONSTRAINT product_fk;
       public       	   statsuser    false    4765    290    223            �           2606    18877 *   stratification_geom stratification_geom_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.stratification_geom
    ADD CONSTRAINT stratification_geom_fk FOREIGN KEY (stratification_id) REFERENCES public.stratification(id) ON DELETE CASCADE;
 T   ALTER TABLE ONLY public.stratification_geom DROP CONSTRAINT stratification_geom_fk;
       public       	   statsuser    false    300    4969    301            �           2606    18882    wms_file wms_file_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.wms_file
    ADD CONSTRAINT wms_file_fk FOREIGN KEY (product_file_id) REFERENCES public.product_file(id) ON UPDATE CASCADE ON DELETE CASCADE;
 >   ALTER TABLE ONLY public.wms_file DROP CONSTRAINT wms_file_fk;
       public       	   statsuser    false    4960    291    305            �           2606    18887    wms_file wms_file_fk2    FK CONSTRAINT     �   ALTER TABLE ONLY public.wms_file
    ADD CONSTRAINT wms_file_fk2 FOREIGN KEY (product_file_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 ?   ALTER TABLE ONLY public.wms_file DROP CONSTRAINT wms_file_fk2;
       public       	   statsuser    false    4964    305    296            �           2606    18892 0   poly_stats_per_region poly_stats_product_file_fk    FK CONSTRAINT     �   ALTER TABLE ONLY tmp.poly_stats_per_region
    ADD CONSTRAINT poly_stats_product_file_fk FOREIGN KEY (product_file_id) REFERENCES public.product_file(id) ON UPDATE CASCADE ON DELETE CASCADE;
 W   ALTER TABLE ONLY tmp.poly_stats_per_region DROP CONSTRAINT poly_stats_product_file_fk;
       tmp       	   statsuser    false    291    4960    307            �           2606    18897 9   poly_stats_per_region poly_stats_product_file_variable_fk    FK CONSTRAINT     �   ALTER TABLE ONLY tmp.poly_stats_per_region
    ADD CONSTRAINT poly_stats_product_file_variable_fk FOREIGN KEY (product_file_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 `   ALTER TABLE ONLY tmp.poly_stats_per_region DROP CONSTRAINT poly_stats_product_file_variable_fk;
       tmp       	   statsuser    false    4964    296    307                        2606    18902 7   poly_stats_per_region poly_stats_stratification_geom_fk    FK CONSTRAINT     �   ALTER TABLE ONLY tmp.poly_stats_per_region
    ADD CONSTRAINT poly_stats_stratification_geom_fk FOREIGN KEY (poly_id) REFERENCES public.stratification_geom(id) ON UPDATE CASCADE ON DELETE CASCADE;
 ^   ALTER TABLE ONLY tmp.poly_stats_per_region DROP CONSTRAINT poly_stats_stratification_geom_fk;
       tmp       	   statsuser    false    301    4975    307            Y   �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            �           1262    16388    jrcstats    DATABASE     p   CREATE DATABASE jrcstats WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'C.UTF-8';
    DROP DATABASE jrcstats;
             	   statsuser    false            �           0    0    SCHEMA pg_catalog    ACL     -   GRANT ALL ON SCHEMA pg_catalog TO statsuser;
                   postgres    false    5            �           0    0    SCHEMA public    ACL     )   GRANT ALL ON SCHEMA public TO statsuser;
                   pg_database_owner    false    8                        2615    16390    tmp    SCHEMA        CREATE SCHEMA tmp;
    DROP SCHEMA tmp;
                postgres    false            �           0    0 
   SCHEMA tmp    ACL     &   GRANT ALL ON SCHEMA tmp TO statsuser;
                   postgres    false    4                        3079    16391    fuzzystrmatch 	   EXTENSION     A   CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;
    DROP EXTENSION fuzzystrmatch;
                   false            �           0    0    EXTENSION fuzzystrmatch    COMMENT     ]   COMMENT ON EXTENSION fuzzystrmatch IS 'determine similarities and distance between strings';
                        false    2                        3079    16403    postgis 	   EXTENSION     ;   CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;
    DROP EXTENSION postgis;
                   false            �           0    0    EXTENSION postgis    COMMENT     ^   COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';
                        false    3            �           1255    17479    clms_updatepolygonstats()    FUNCTION     �  CREATE FUNCTION public.clms_updatepolygonstats() RETURNS smallint
    LANGUAGE plpgsql COST 1000
    AS $$
declare ret smallint;
begin
	
	WITH merged_data AS (
	SELECT poly_id, product_file_id, product_file_variable_id, SUM(mean) mean, SUM(sd) sd, min(min_val) min_val, max(max_val) max_val, SUM(total_pixels) total_pixels, SUM(valid_pixels) valid_pixels,
	SUM(noval_area_ha) noval_area_ha, SUM(sparse_area_ha) sparse_area_ha, SUM(mid_area_ha) mid_area_ha, SUM(dense_area_ha) dense_area_ha
	FROM tmp.poly_stats_per_region pspr
	GROUP BY poly_id, product_file_id, product_file_variable_id
),raw_hist_data AS(
	SELECT x.poly_id, x.product_file_id, x.idx, SUM((x.cnt)::integer) hist_val
	FROM (
    	SELECT pspr.id, pspr.poly_id, pspr.product_file_id, pspr.product_file_variable_id, t.* 
    	FROM TMP.poly_stats_per_region pspr, jsonb_array_elements(histogram->'y') with ordinality as t(cnt, idx)
	) as x
	GROUP BY x.poly_id, x.product_file_id, x.product_file_variable_id, x.idx
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
insert into poly_stats (poly_id, product_file_id, product_file_variable_id, mean, sd, min_val, max_val, total_pixels,valid_pixels,noval_area_ha,
sparse_area_ha,mid_area_ha,dense_area_ha,histogram)
SELECT 
md.poly_id, md.product_file_id, md.product_file_variable_id
, CASE WHEN valid_pixels = 0 THEN null ELSE mean/valid_pixels END mean
, CASE WHEN valid_pixels = 0 OR sd/valid_pixels < power(mean/valid_pixels,2) THEN null ELSE sqrt(sd/valid_pixels - power(mean/valid_pixels,2))  END sd
,min_val, max_val, total_pixels, valid_pixels, noval_area_ha, sparse_area_ha, mid_area_ha, dense_area_ha
,hst.histogram
FROM merged_data md 
JOIN histogram hst ON md.product_file_id = hst.product_file_id AND md.poly_id = hst.poly_id
--ORDER BY md.product_file_id, md.poly_id
ON CONFLICT (poly_id, product_file_id, product_file_variable_id) DO NOTHING;
RETURN 0;

end;$$;
 0   DROP FUNCTION public.clms_updatepolygonstats();
       public          postgres    false            �           0    0    TABLE pg_aggregate    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_aggregate TO statsuser;
       
   pg_catalog          postgres    false    24            �           0    0    TABLE pg_am    ACL     2   GRANT ALL ON TABLE pg_catalog.pg_am TO statsuser;
       
   pg_catalog          postgres    false    25            �           0    0    TABLE pg_amop    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_amop TO statsuser;
       
   pg_catalog          postgres    false    26            �           0    0    TABLE pg_amproc    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_amproc TO statsuser;
       
   pg_catalog          postgres    false    27            �           0    0    TABLE pg_attrdef    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_attrdef TO statsuser;
       
   pg_catalog          postgres    false    28            �           0    0    TABLE pg_attribute    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_attribute TO statsuser;
       
   pg_catalog          postgres    false    13            �           0    0    TABLE pg_auth_members    ACL     <   GRANT ALL ON TABLE pg_catalog.pg_auth_members TO statsuser;
       
   pg_catalog          postgres    false    17            �           0    0    TABLE pg_authid    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_authid TO statsuser;
       
   pg_catalog          postgres    false    16            �           0    0 %   TABLE pg_available_extension_versions    ACL     L   GRANT ALL ON TABLE pg_catalog.pg_available_extension_versions TO statsuser;
       
   pg_catalog          postgres    false    91            �           0    0    TABLE pg_available_extensions    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_available_extensions TO statsuser;
       
   pg_catalog          postgres    false    90            �           0    0     TABLE pg_backend_memory_contexts    ACL     G   GRANT ALL ON TABLE pg_catalog.pg_backend_memory_contexts TO statsuser;
       
   pg_catalog          postgres    false    103            �           0    0    TABLE pg_cast    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_cast TO statsuser;
       
   pg_catalog          postgres    false    29            �           0    0    TABLE pg_class    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_class TO statsuser;
       
   pg_catalog          postgres    false    15            �           0    0    TABLE pg_collation    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_collation TO statsuser;
       
   pg_catalog          postgres    false    54            �           0    0    TABLE pg_config    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_config TO statsuser;
       
   pg_catalog          postgres    false    101            �           0    0    TABLE pg_constraint    ACL     :   GRANT ALL ON TABLE pg_catalog.pg_constraint TO statsuser;
       
   pg_catalog          postgres    false    30            �           0    0    TABLE pg_conversion    ACL     :   GRANT ALL ON TABLE pg_catalog.pg_conversion TO statsuser;
       
   pg_catalog          postgres    false    31            �           0    0    TABLE pg_cursors    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_cursors TO statsuser;
       
   pg_catalog          postgres    false    89            �           0    0    TABLE pg_database    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_database TO statsuser;
       
   pg_catalog          postgres    false    18            �           0    0    TABLE pg_db_role_setting    ACL     ?   GRANT ALL ON TABLE pg_catalog.pg_db_role_setting TO statsuser;
       
   pg_catalog          postgres    false    45            �           0    0    TABLE pg_default_acl    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_default_acl TO statsuser;
       
   pg_catalog          postgres    false    9            �           0    0    TABLE pg_depend    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_depend TO statsuser;
       
   pg_catalog          postgres    false    32            �           0    0    TABLE pg_description    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_description TO statsuser;
       
   pg_catalog          postgres    false    33            �           0    0    TABLE pg_enum    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_enum TO statsuser;
       
   pg_catalog          postgres    false    56            �           0    0    TABLE pg_event_trigger    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_event_trigger TO statsuser;
       
   pg_catalog          postgres    false    55            �           0    0    TABLE pg_extension    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_extension TO statsuser;
       
   pg_catalog          postgres    false    47            �           0    0    TABLE pg_file_settings    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_file_settings TO statsuser;
       
   pg_catalog          postgres    false    96            �           0    0    TABLE pg_foreign_data_wrapper    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_foreign_data_wrapper TO statsuser;
       
   pg_catalog          postgres    false    22            �           0    0    TABLE pg_foreign_server    ACL     >   GRANT ALL ON TABLE pg_catalog.pg_foreign_server TO statsuser;
       
   pg_catalog          postgres    false    19            �           0    0    TABLE pg_foreign_table    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_foreign_table TO statsuser;
       
   pg_catalog          postgres    false    48            �           0    0    TABLE pg_group    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_group TO statsuser;
       
   pg_catalog          postgres    false    75            �           0    0    TABLE pg_hba_file_rules    ACL     >   GRANT ALL ON TABLE pg_catalog.pg_hba_file_rules TO statsuser;
       
   pg_catalog          postgres    false    97            �           0    0    TABLE pg_ident_file_mappings    ACL     C   GRANT ALL ON TABLE pg_catalog.pg_ident_file_mappings TO statsuser;
       
   pg_catalog          postgres    false    98            �           0    0    TABLE pg_index    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_index TO statsuser;
       
   pg_catalog          postgres    false    34            �           0    0    TABLE pg_indexes    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_indexes TO statsuser;
       
   pg_catalog          postgres    false    82            �           0    0    TABLE pg_inherits    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_inherits TO statsuser;
       
   pg_catalog          postgres    false    35            �           0    0    TABLE pg_init_privs    ACL     :   GRANT ALL ON TABLE pg_catalog.pg_init_privs TO statsuser;
       
   pg_catalog          postgres    false    52            �           0    0    TABLE pg_language    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_language TO statsuser;
       
   pg_catalog          postgres    false    36            �           0    0    TABLE pg_largeobject    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_largeobject TO statsuser;
       
   pg_catalog          postgres    false    37            �           0    0    TABLE pg_largeobject_metadata    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_largeobject_metadata TO statsuser;
       
   pg_catalog          postgres    false    46            �           0    0    TABLE pg_locks    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_locks TO statsuser;
       
   pg_catalog          postgres    false    88            �           0    0    TABLE pg_matviews    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_matviews TO statsuser;
       
   pg_catalog          postgres    false    81            �           0    0    TABLE pg_namespace    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_namespace TO statsuser;
       
   pg_catalog          postgres    false    38            �           0    0    TABLE pg_opclass    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_opclass TO statsuser;
       
   pg_catalog          postgres    false    39            �           0    0    TABLE pg_operator    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_operator TO statsuser;
       
   pg_catalog          postgres    false    40            �           0    0    TABLE pg_opfamily    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_opfamily TO statsuser;
       
   pg_catalog          postgres    false    44            �           0    0    TABLE pg_parameter_acl    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_parameter_acl TO statsuser;
       
   pg_catalog          postgres    false    72            �           0    0    TABLE pg_partitioned_table    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_partitioned_table TO statsuser;
       
   pg_catalog          postgres    false    50            �           0    0    TABLE pg_policies    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_policies TO statsuser;
       
   pg_catalog          postgres    false    77            �           0    0    TABLE pg_policy    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_policy TO statsuser;
       
   pg_catalog          postgres    false    49            �           0    0    TABLE pg_prepared_statements    ACL     C   GRANT ALL ON TABLE pg_catalog.pg_prepared_statements TO statsuser;
       
   pg_catalog          postgres    false    93            �           0    0    TABLE pg_prepared_xacts    ACL     >   GRANT ALL ON TABLE pg_catalog.pg_prepared_xacts TO statsuser;
       
   pg_catalog          postgres    false    92            �           0    0    TABLE pg_proc    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_proc TO statsuser;
       
   pg_catalog          postgres    false    14            �           0    0    TABLE pg_publication    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_publication TO statsuser;
       
   pg_catalog          postgres    false    69            �           0    0    TABLE pg_publication_namespace    ACL     E   GRANT ALL ON TABLE pg_catalog.pg_publication_namespace TO statsuser;
       
   pg_catalog          postgres    false    71            �           0    0    TABLE pg_publication_rel    ACL     ?   GRANT ALL ON TABLE pg_catalog.pg_publication_rel TO statsuser;
       
   pg_catalog          postgres    false    70            �           0    0    TABLE pg_publication_tables    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_publication_tables TO statsuser;
       
   pg_catalog          postgres    false    87            �           0    0    TABLE pg_range    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_range TO statsuser;
       
   pg_catalog          postgres    false    57            �           0    0    TABLE pg_replication_origin    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_replication_origin TO statsuser;
       
   pg_catalog          postgres    false    66            �           0    0 "   TABLE pg_replication_origin_status    ACL     I   GRANT ALL ON TABLE pg_catalog.pg_replication_origin_status TO statsuser;
       
   pg_catalog          postgres    false    147            �           0    0    TABLE pg_replication_slots    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_replication_slots TO statsuser;
       
   pg_catalog          postgres    false    130            �           0    0    TABLE pg_rewrite    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_rewrite TO statsuser;
       
   pg_catalog          postgres    false    41            �           0    0    TABLE pg_roles    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_roles TO statsuser;
       
   pg_catalog          postgres    false    73            �           0    0    TABLE pg_rules    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_rules TO statsuser;
       
   pg_catalog          postgres    false    78            �           0    0    TABLE pg_seclabel    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_seclabel TO statsuser;
       
   pg_catalog          postgres    false    60            �           0    0    TABLE pg_seclabels    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_seclabels TO statsuser;
       
   pg_catalog          postgres    false    94            �           0    0    TABLE pg_sequence    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_sequence TO statsuser;
       
   pg_catalog          postgres    false    21            �           0    0    TABLE pg_sequences    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_sequences TO statsuser;
       
   pg_catalog          postgres    false    83            �           0    0    TABLE pg_settings    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_settings TO statsuser;
       
   pg_catalog          postgres    false    95            �           0    0    TABLE pg_shadow    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_shadow TO statsuser;
       
   pg_catalog          postgres    false    74            �           0    0    TABLE pg_shdepend    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_shdepend TO statsuser;
       
   pg_catalog          postgres    false    11            �           0    0    TABLE pg_shdescription    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_shdescription TO statsuser;
       
   pg_catalog          postgres    false    23            �           0    0    TABLE pg_shmem_allocations    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_shmem_allocations TO statsuser;
       
   pg_catalog          postgres    false    102            �           0    0    TABLE pg_shseclabel    ACL     :   GRANT ALL ON TABLE pg_catalog.pg_shseclabel TO statsuser;
       
   pg_catalog          postgres    false    59            �           0    0    TABLE pg_stat_activity    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_stat_activity TO statsuser;
       
   pg_catalog          postgres    false    122            �           0    0    TABLE pg_stat_all_indexes    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_stat_all_indexes TO statsuser;
       
   pg_catalog          postgres    false    113            �           0    0    TABLE pg_stat_all_tables    ACL     ?   GRANT ALL ON TABLE pg_catalog.pg_stat_all_tables TO statsuser;
       
   pg_catalog          postgres    false    104            �           0    0    TABLE pg_stat_archiver    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_stat_archiver TO statsuser;
       
   pg_catalog          postgres    false    136            �           0    0    TABLE pg_stat_bgwriter    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_stat_bgwriter TO statsuser;
       
   pg_catalog          postgres    false    137            �           0    0    TABLE pg_stat_database    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_stat_database TO statsuser;
       
   pg_catalog          postgres    false    132            �           0    0     TABLE pg_stat_database_conflicts    ACL     G   GRANT ALL ON TABLE pg_catalog.pg_stat_database_conflicts TO statsuser;
       
   pg_catalog          postgres    false    133            �           0    0    TABLE pg_stat_gssapi    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_stat_gssapi TO statsuser;
       
   pg_catalog          postgres    false    129            �           0    0    TABLE pg_stat_io    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_stat_io TO statsuser;
       
   pg_catalog          postgres    false    138            �           0    0    TABLE pg_stat_progress_analyze    ACL     E   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_analyze TO statsuser;
       
   pg_catalog          postgres    false    140            �           0    0 !   TABLE pg_stat_progress_basebackup    ACL     H   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_basebackup TO statsuser;
       
   pg_catalog          postgres    false    144            �           0    0    TABLE pg_stat_progress_cluster    ACL     E   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_cluster TO statsuser;
       
   pg_catalog          postgres    false    142            �           0    0    TABLE pg_stat_progress_copy    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_copy TO statsuser;
       
   pg_catalog          postgres    false    145            �           0    0 #   TABLE pg_stat_progress_create_index    ACL     J   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_create_index TO statsuser;
       
   pg_catalog          postgres    false    143            �           0    0    TABLE pg_stat_progress_vacuum    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_vacuum TO statsuser;
       
   pg_catalog          postgres    false    141            �           0    0    TABLE pg_stat_recovery_prefetch    ACL     F   GRANT ALL ON TABLE pg_catalog.pg_stat_recovery_prefetch TO statsuser;
       
   pg_catalog          postgres    false    126            �           0    0    TABLE pg_stat_replication    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_stat_replication TO statsuser;
       
   pg_catalog          postgres    false    123            �           0    0    TABLE pg_stat_replication_slots    ACL     F   GRANT ALL ON TABLE pg_catalog.pg_stat_replication_slots TO statsuser;
       
   pg_catalog          postgres    false    131            �           0    0    TABLE pg_stat_slru    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_stat_slru TO statsuser;
       
   pg_catalog          postgres    false    124            �           0    0    TABLE pg_stat_ssl    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_stat_ssl TO statsuser;
       
   pg_catalog          postgres    false    128            �           0    0    TABLE pg_stat_subscription    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_stat_subscription TO statsuser;
       
   pg_catalog          postgres    false    127            �           0    0     TABLE pg_stat_subscription_stats    ACL     G   GRANT ALL ON TABLE pg_catalog.pg_stat_subscription_stats TO statsuser;
       
   pg_catalog          postgres    false    148                        0    0    TABLE pg_stat_sys_indexes    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_stat_sys_indexes TO statsuser;
       
   pg_catalog          postgres    false    114                       0    0    TABLE pg_stat_sys_tables    ACL     ?   GRANT ALL ON TABLE pg_catalog.pg_stat_sys_tables TO statsuser;
       
   pg_catalog          postgres    false    106                       0    0    TABLE pg_stat_user_functions    ACL     C   GRANT ALL ON TABLE pg_catalog.pg_stat_user_functions TO statsuser;
       
   pg_catalog          postgres    false    134                       0    0    TABLE pg_stat_user_indexes    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_stat_user_indexes TO statsuser;
       
   pg_catalog          postgres    false    115                       0    0    TABLE pg_stat_user_tables    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_stat_user_tables TO statsuser;
       
   pg_catalog          postgres    false    108                       0    0    TABLE pg_stat_wal    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_stat_wal TO statsuser;
       
   pg_catalog          postgres    false    139                       0    0    TABLE pg_stat_wal_receiver    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_stat_wal_receiver TO statsuser;
       
   pg_catalog          postgres    false    125                       0    0    TABLE pg_stat_xact_all_tables    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_stat_xact_all_tables TO statsuser;
       
   pg_catalog          postgres    false    105                       0    0    TABLE pg_stat_xact_sys_tables    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_stat_xact_sys_tables TO statsuser;
       
   pg_catalog          postgres    false    107            	           0    0 !   TABLE pg_stat_xact_user_functions    ACL     H   GRANT ALL ON TABLE pg_catalog.pg_stat_xact_user_functions TO statsuser;
       
   pg_catalog          postgres    false    135            
           0    0    TABLE pg_stat_xact_user_tables    ACL     E   GRANT ALL ON TABLE pg_catalog.pg_stat_xact_user_tables TO statsuser;
       
   pg_catalog          postgres    false    109                       0    0    TABLE pg_statio_all_indexes    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_statio_all_indexes TO statsuser;
       
   pg_catalog          postgres    false    116                       0    0    TABLE pg_statio_all_sequences    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_statio_all_sequences TO statsuser;
       
   pg_catalog          postgres    false    119                       0    0    TABLE pg_statio_all_tables    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_statio_all_tables TO statsuser;
       
   pg_catalog          postgres    false    110                       0    0    TABLE pg_statio_sys_indexes    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_statio_sys_indexes TO statsuser;
       
   pg_catalog          postgres    false    117                       0    0    TABLE pg_statio_sys_sequences    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_statio_sys_sequences TO statsuser;
       
   pg_catalog          postgres    false    120                       0    0    TABLE pg_statio_sys_tables    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_statio_sys_tables TO statsuser;
       
   pg_catalog          postgres    false    111                       0    0    TABLE pg_statio_user_indexes    ACL     C   GRANT ALL ON TABLE pg_catalog.pg_statio_user_indexes TO statsuser;
       
   pg_catalog          postgres    false    118                       0    0    TABLE pg_statio_user_sequences    ACL     E   GRANT ALL ON TABLE pg_catalog.pg_statio_user_sequences TO statsuser;
       
   pg_catalog          postgres    false    121                       0    0    TABLE pg_statio_user_tables    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_statio_user_tables TO statsuser;
       
   pg_catalog          postgres    false    112                       0    0    TABLE pg_statistic    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_statistic TO statsuser;
       
   pg_catalog          postgres    false    42                       0    0    TABLE pg_statistic_ext    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_statistic_ext TO statsuser;
       
   pg_catalog          postgres    false    51                       0    0    TABLE pg_statistic_ext_data    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_statistic_ext_data TO statsuser;
       
   pg_catalog          postgres    false    53                       0    0    TABLE pg_stats    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_stats TO statsuser;
       
   pg_catalog          postgres    false    84                       0    0    TABLE pg_stats_ext    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_stats_ext TO statsuser;
       
   pg_catalog          postgres    false    85                       0    0    TABLE pg_stats_ext_exprs    ACL     ?   GRANT ALL ON TABLE pg_catalog.pg_stats_ext_exprs TO statsuser;
       
   pg_catalog          postgres    false    86                       0    0    TABLE pg_subscription    ACL     <   GRANT ALL ON TABLE pg_catalog.pg_subscription TO statsuser;
       
   pg_catalog          postgres    false    67                       0    0    TABLE pg_subscription_rel    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_subscription_rel TO statsuser;
       
   pg_catalog          postgres    false    68                       0    0    TABLE pg_tables    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_tables TO statsuser;
       
   pg_catalog          postgres    false    80                       0    0    TABLE pg_tablespace    ACL     :   GRANT ALL ON TABLE pg_catalog.pg_tablespace TO statsuser;
       
   pg_catalog          postgres    false    10                       0    0    TABLE pg_timezone_abbrevs    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_timezone_abbrevs TO statsuser;
       
   pg_catalog          postgres    false    99                       0    0    TABLE pg_timezone_names    ACL     >   GRANT ALL ON TABLE pg_catalog.pg_timezone_names TO statsuser;
       
   pg_catalog          postgres    false    100                        0    0    TABLE pg_transform    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_transform TO statsuser;
       
   pg_catalog          postgres    false    58            !           0    0    TABLE pg_trigger    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_trigger TO statsuser;
       
   pg_catalog          postgres    false    43            "           0    0    TABLE pg_ts_config    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_ts_config TO statsuser;
       
   pg_catalog          postgres    false    63            #           0    0    TABLE pg_ts_config_map    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_ts_config_map TO statsuser;
       
   pg_catalog          postgres    false    64            $           0    0    TABLE pg_ts_dict    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_ts_dict TO statsuser;
       
   pg_catalog          postgres    false    61            %           0    0    TABLE pg_ts_parser    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_ts_parser TO statsuser;
       
   pg_catalog          postgres    false    62            &           0    0    TABLE pg_ts_template    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_ts_template TO statsuser;
       
   pg_catalog          postgres    false    65            '           0    0    TABLE pg_type    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_type TO statsuser;
       
   pg_catalog          postgres    false    12            (           0    0    TABLE pg_user    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_user TO statsuser;
       
   pg_catalog          postgres    false    76            )           0    0    TABLE pg_user_mapping    ACL     <   GRANT ALL ON TABLE pg_catalog.pg_user_mapping TO statsuser;
       
   pg_catalog          postgres    false    20            *           0    0    TABLE pg_user_mappings    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_user_mappings TO statsuser;
       
   pg_catalog          postgres    false    146            +           0    0    TABLE pg_views    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_views TO statsuser;
       
   pg_catalog          postgres    false    79            �            1259    17480    category    TABLE     }   CREATE TABLE public.category (
    id bigint NOT NULL,
    title text NOT NULL,
    active boolean DEFAULT false NOT NULL
);
    DROP TABLE public.category;
       public         heap 	   statsuser    false            �            1259    17486    category_id_seq    SEQUENCE     �   ALTER TABLE public.category ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.category_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   statsuser    false    223            ,           0    0    TABLE geography_columns    ACL     :   GRANT ALL ON TABLE public.geography_columns TO statsuser;
          public          postgres    false    221            -           0    0    TABLE geometry_columns    ACL     9   GRANT ALL ON TABLE public.geometry_columns TO statsuser;
          public          postgres    false    222            �            1259    17487    long_term_anomaly_info    TABLE     �   CREATE TABLE public.long_term_anomaly_info (
    id bigint NOT NULL,
    anomaly_product_variable_id bigint NOT NULL,
    mean_variable_id bigint NOT NULL,
    stdev_variable_id bigint NOT NULL,
    raw_product_variable_id bigint NOT NULL
);
 *   DROP TABLE public.long_term_anomaly_info;
       public         heap 	   statsuser    false            �            1259    17490    long_term_anomaly_info_id_seq    SEQUENCE     �   CREATE SEQUENCE public.long_term_anomaly_info_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 4   DROP SEQUENCE public.long_term_anomaly_info_id_seq;
       public       	   statsuser    false    225            .           0    0    long_term_anomaly_info_id_seq    SEQUENCE OWNED BY     _   ALTER SEQUENCE public.long_term_anomaly_info_id_seq OWNED BY public.long_term_anomaly_info.id;
          public       	   statsuser    false    226            �            1259    17491    output_product_id_seq    SEQUENCE     ~   CREATE SEQUENCE public.output_product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE public.output_product_id_seq;
       public       	   statsuser    false            �            1259    17492 
   poly_stats    TABLE        CREATE TABLE public.poly_stats (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
)
PARTITION BY RANGE (product_file_variable_id, poly_id);
    DROP TABLE public.poly_stats;
       public         	   statsuser    false            �            1259    17498    poly_stats_10_1_257    TABLE     �  CREATE TABLE public.poly_stats_10_1_257 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 '   DROP TABLE public.poly_stats_10_1_257;
       public         heap 	   statsuser    false    228            �            1259    17506    poly_stats_10_257_279    TABLE     �  CREATE TABLE public.poly_stats_10_257_279 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 )   DROP TABLE public.poly_stats_10_257_279;
       public         heap 	   statsuser    false    228            �            1259    17514    poly_stats_10_279_285    TABLE     �  CREATE TABLE public.poly_stats_10_279_285 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 )   DROP TABLE public.poly_stats_10_279_285;
       public         heap 	   statsuser    false    228            �            1259    17522    poly_stats_10_285_38543    TABLE     �  CREATE TABLE public.poly_stats_10_285_38543 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 +   DROP TABLE public.poly_stats_10_285_38543;
       public         heap 	   statsuser    false    228            �            1259    17530    poly_stats_12_1_257    TABLE     �  CREATE TABLE public.poly_stats_12_1_257 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 '   DROP TABLE public.poly_stats_12_1_257;
       public         heap 	   statsuser    false    228            �            1259    17538    poly_stats_12_257_279    TABLE     �  CREATE TABLE public.poly_stats_12_257_279 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 )   DROP TABLE public.poly_stats_12_257_279;
       public         heap 	   statsuser    false    228            �            1259    17546    poly_stats_12_279_285    TABLE     �  CREATE TABLE public.poly_stats_12_279_285 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 )   DROP TABLE public.poly_stats_12_279_285;
       public         heap 	   statsuser    false    228            �            1259    17554    poly_stats_12_285_38543    TABLE     �  CREATE TABLE public.poly_stats_12_285_38543 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 +   DROP TABLE public.poly_stats_12_285_38543;
       public         heap 	   statsuser    false    228            �            1259    17562    poly_stats_14_1_257    TABLE     �  CREATE TABLE public.poly_stats_14_1_257 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 '   DROP TABLE public.poly_stats_14_1_257;
       public         heap 	   statsuser    false    228            �            1259    17570    poly_stats_14_257_279    TABLE     �  CREATE TABLE public.poly_stats_14_257_279 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 )   DROP TABLE public.poly_stats_14_257_279;
       public         heap 	   statsuser    false    228            �            1259    17578    poly_stats_14_279_285    TABLE     �  CREATE TABLE public.poly_stats_14_279_285 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 )   DROP TABLE public.poly_stats_14_279_285;
       public         heap 	   statsuser    false    228            �            1259    17586    poly_stats_14_285_38543    TABLE     �  CREATE TABLE public.poly_stats_14_285_38543 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 +   DROP TABLE public.poly_stats_14_285_38543;
       public         heap 	   statsuser    false    228            �            1259    17594    poly_stats_16_1_257    TABLE     �  CREATE TABLE public.poly_stats_16_1_257 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 '   DROP TABLE public.poly_stats_16_1_257;
       public         heap 	   statsuser    false    228            �            1259    17602    poly_stats_16_257_279    TABLE     �  CREATE TABLE public.poly_stats_16_257_279 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 )   DROP TABLE public.poly_stats_16_257_279;
       public         heap 	   statsuser    false    228            �            1259    17610    poly_stats_16_279_285    TABLE     �  CREATE TABLE public.poly_stats_16_279_285 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 )   DROP TABLE public.poly_stats_16_279_285;
       public         heap 	   statsuser    false    228            �            1259    17618    poly_stats_16_285_38543    TABLE     �  CREATE TABLE public.poly_stats_16_285_38543 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 +   DROP TABLE public.poly_stats_16_285_38543;
       public         heap 	   statsuser    false    228            �            1259    17626    poly_stats_17_1_257    TABLE     �  CREATE TABLE public.poly_stats_17_1_257 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 '   DROP TABLE public.poly_stats_17_1_257;
       public         heap 	   statsuser    false    228            �            1259    17634    poly_stats_17_257_279    TABLE     �  CREATE TABLE public.poly_stats_17_257_279 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 )   DROP TABLE public.poly_stats_17_257_279;
       public         heap 	   statsuser    false    228            �            1259    17642    poly_stats_17_279_285    TABLE     �  CREATE TABLE public.poly_stats_17_279_285 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 )   DROP TABLE public.poly_stats_17_279_285;
       public         heap 	   statsuser    false    228            �            1259    17650    poly_stats_17_285_38543    TABLE     �  CREATE TABLE public.poly_stats_17_285_38543 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 +   DROP TABLE public.poly_stats_17_285_38543;
       public         heap 	   statsuser    false    228            �            1259    17658    poly_stats_19_1_257    TABLE     �  CREATE TABLE public.poly_stats_19_1_257 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 '   DROP TABLE public.poly_stats_19_1_257;
       public         heap 	   statsuser    false    228            �            1259    17666    poly_stats_19_257_279    TABLE     �  CREATE TABLE public.poly_stats_19_257_279 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 )   DROP TABLE public.poly_stats_19_257_279;
       public         heap 	   statsuser    false    228            �            1259    17674    poly_stats_19_279_285    TABLE     �  CREATE TABLE public.poly_stats_19_279_285 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 )   DROP TABLE public.poly_stats_19_279_285;
       public         heap 	   statsuser    false    228            �            1259    17682    poly_stats_19_285_38543    TABLE     �  CREATE TABLE public.poly_stats_19_285_38543 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 +   DROP TABLE public.poly_stats_19_285_38543;
       public         heap 	   statsuser    false    228            �            1259    17690    poly_stats_1_1_257    TABLE     �  CREATE TABLE public.poly_stats_1_1_257 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 &   DROP TABLE public.poly_stats_1_1_257;
       public         heap 	   statsuser    false    228            �            1259    17698    poly_stats_1_257_279    TABLE     �  CREATE TABLE public.poly_stats_1_257_279 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 (   DROP TABLE public.poly_stats_1_257_279;
       public         heap 	   statsuser    false    228            �            1259    17706    poly_stats_1_279_285    TABLE     �  CREATE TABLE public.poly_stats_1_279_285 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 (   DROP TABLE public.poly_stats_1_279_285;
       public         heap 	   statsuser    false    228                        1259    17714    poly_stats_1_285_38543    TABLE     �  CREATE TABLE public.poly_stats_1_285_38543 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 *   DROP TABLE public.poly_stats_1_285_38543;
       public         heap 	   statsuser    false    228                       1259    17722    poly_stats_21_1_257    TABLE     �  CREATE TABLE public.poly_stats_21_1_257 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 '   DROP TABLE public.poly_stats_21_1_257;
       public         heap 	   statsuser    false    228                       1259    17730    poly_stats_21_257_279    TABLE     �  CREATE TABLE public.poly_stats_21_257_279 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 )   DROP TABLE public.poly_stats_21_257_279;
       public         heap 	   statsuser    false    228                       1259    17738    poly_stats_21_279_285    TABLE     �  CREATE TABLE public.poly_stats_21_279_285 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 )   DROP TABLE public.poly_stats_21_279_285;
       public         heap 	   statsuser    false    228                       1259    17746    poly_stats_21_285_38543    TABLE     �  CREATE TABLE public.poly_stats_21_285_38543 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 +   DROP TABLE public.poly_stats_21_285_38543;
       public         heap 	   statsuser    false    228                       1259    17754    poly_stats_24_1_257    TABLE     �  CREATE TABLE public.poly_stats_24_1_257 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 '   DROP TABLE public.poly_stats_24_1_257;
       public         heap 	   statsuser    false    228                       1259    17762    poly_stats_2_1_257    TABLE     �  CREATE TABLE public.poly_stats_2_1_257 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 &   DROP TABLE public.poly_stats_2_1_257;
       public         heap 	   statsuser    false    228                       1259    17770    poly_stats_2_257_279    TABLE     �  CREATE TABLE public.poly_stats_2_257_279 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 (   DROP TABLE public.poly_stats_2_257_279;
       public         heap 	   statsuser    false    228                       1259    17778    poly_stats_2_279_285    TABLE     �  CREATE TABLE public.poly_stats_2_279_285 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 (   DROP TABLE public.poly_stats_2_279_285;
       public         heap 	   statsuser    false    228            	           1259    17786    poly_stats_2_285_38543    TABLE     �  CREATE TABLE public.poly_stats_2_285_38543 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 *   DROP TABLE public.poly_stats_2_285_38543;
       public         heap 	   statsuser    false    228            
           1259    17794    poly_stats_3_1_257    TABLE     �  CREATE TABLE public.poly_stats_3_1_257 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 &   DROP TABLE public.poly_stats_3_1_257;
       public         heap 	   statsuser    false    228                       1259    17802    poly_stats_3_257_279    TABLE     �  CREATE TABLE public.poly_stats_3_257_279 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 (   DROP TABLE public.poly_stats_3_257_279;
       public         heap 	   statsuser    false    228                       1259    17810    poly_stats_3_279_285    TABLE     �  CREATE TABLE public.poly_stats_3_279_285 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 (   DROP TABLE public.poly_stats_3_279_285;
       public         heap 	   statsuser    false    228                       1259    17818    poly_stats_3_285_38543    TABLE     �  CREATE TABLE public.poly_stats_3_285_38543 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 *   DROP TABLE public.poly_stats_3_285_38543;
       public         heap 	   statsuser    false    228                       1259    17826    poly_stats_4_1_257    TABLE     �  CREATE TABLE public.poly_stats_4_1_257 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 &   DROP TABLE public.poly_stats_4_1_257;
       public         heap 	   statsuser    false    228                       1259    17834    poly_stats_4_257_279    TABLE     �  CREATE TABLE public.poly_stats_4_257_279 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 (   DROP TABLE public.poly_stats_4_257_279;
       public         heap 	   statsuser    false    228                       1259    17842    poly_stats_4_279_285    TABLE     �  CREATE TABLE public.poly_stats_4_279_285 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 (   DROP TABLE public.poly_stats_4_279_285;
       public         heap 	   statsuser    false    228                       1259    17850    poly_stats_4_285_38543    TABLE     �  CREATE TABLE public.poly_stats_4_285_38543 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 *   DROP TABLE public.poly_stats_4_285_38543;
       public         heap 	   statsuser    false    228                       1259    17858    poly_stats_5_1_257    TABLE     �  CREATE TABLE public.poly_stats_5_1_257 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 &   DROP TABLE public.poly_stats_5_1_257;
       public         heap 	   statsuser    false    228                       1259    17866    poly_stats_5_257_279    TABLE     �  CREATE TABLE public.poly_stats_5_257_279 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 (   DROP TABLE public.poly_stats_5_257_279;
       public         heap 	   statsuser    false    228                       1259    17874    poly_stats_5_279_285    TABLE     �  CREATE TABLE public.poly_stats_5_279_285 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 (   DROP TABLE public.poly_stats_5_279_285;
       public         heap 	   statsuser    false    228                       1259    17882    poly_stats_5_285_38543    TABLE     �  CREATE TABLE public.poly_stats_5_285_38543 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 *   DROP TABLE public.poly_stats_5_285_38543;
       public         heap 	   statsuser    false    228                       1259    17890    poly_stats_6_1_257    TABLE     �  CREATE TABLE public.poly_stats_6_1_257 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 &   DROP TABLE public.poly_stats_6_1_257;
       public         heap 	   statsuser    false    228                       1259    17898    poly_stats_6_257_279    TABLE     �  CREATE TABLE public.poly_stats_6_257_279 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 (   DROP TABLE public.poly_stats_6_257_279;
       public         heap 	   statsuser    false    228                       1259    17906    poly_stats_6_279_285    TABLE     �  CREATE TABLE public.poly_stats_6_279_285 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 (   DROP TABLE public.poly_stats_6_279_285;
       public         heap 	   statsuser    false    228                       1259    17914    poly_stats_6_285_38543    TABLE     �  CREATE TABLE public.poly_stats_6_285_38543 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 *   DROP TABLE public.poly_stats_6_285_38543;
       public         heap 	   statsuser    false    228                       1259    17922    poly_stats_7_1_257    TABLE     �  CREATE TABLE public.poly_stats_7_1_257 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 &   DROP TABLE public.poly_stats_7_1_257;
       public         heap 	   statsuser    false    228                       1259    17930    poly_stats_7_257_279    TABLE     �  CREATE TABLE public.poly_stats_7_257_279 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 (   DROP TABLE public.poly_stats_7_257_279;
       public         heap 	   statsuser    false    228                       1259    17938    poly_stats_7_279_285    TABLE     �  CREATE TABLE public.poly_stats_7_279_285 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 (   DROP TABLE public.poly_stats_7_279_285;
       public         heap 	   statsuser    false    228                       1259    17946    poly_stats_7_285_38543    TABLE     �  CREATE TABLE public.poly_stats_7_285_38543 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 *   DROP TABLE public.poly_stats_7_285_38543;
       public         heap 	   statsuser    false    228                       1259    17954    poly_stats_9_1_257    TABLE     �  CREATE TABLE public.poly_stats_9_1_257 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 &   DROP TABLE public.poly_stats_9_1_257;
       public         heap 	   statsuser    false    228                       1259    17962    poly_stats_9_257_279    TABLE     �  CREATE TABLE public.poly_stats_9_257_279 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 (   DROP TABLE public.poly_stats_9_257_279;
       public         heap 	   statsuser    false    228                        1259    17970    poly_stats_9_279_285    TABLE     �  CREATE TABLE public.poly_stats_9_279_285 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 (   DROP TABLE public.poly_stats_9_279_285;
       public         heap 	   statsuser    false    228            !           1259    17978    poly_stats_9_285_38543    TABLE     �  CREATE TABLE public.poly_stats_9_285_38543 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
    noval_color text,
    sparseval_color text,
    midval_color text,
    highval_color text,
    histogram jsonb,
    total_pixels bigint DEFAULT 0 NOT NULL,
    valid_pixels bigint DEFAULT 0 NOT NULL,
    date_created timestamp without time zone DEFAULT timezone('utc'::text, now())
);
 *   DROP TABLE public.poly_stats_9_285_38543;
       public         heap 	   statsuser    false    228            "           1259    17986    product    TABLE     �   CREATE TABLE public.product (
    id bigint NOT NULL,
    name text[] NOT NULL,
    type text DEFAULT 'raw'::text NOT NULL,
    category_id bigint,
    description text
);
    DROP TABLE public.product;
       public         heap 	   statsuser    false            #           1259    17992    product_file    TABLE     +  CREATE TABLE public.product_file (
    id bigint NOT NULL,
    product_file_description_id bigint NOT NULL,
    rel_file_path text NOT NULL,
    rt_flag smallint,
    date timestamp without time zone NOT NULL,
    date_created timestamp without time zone DEFAULT (now() AT TIME ZONE 'UTC'::text)
);
     DROP TABLE public.product_file;
       public         heap 	   statsuser    false            $           1259    17998    product_file_description    TABLE     �   CREATE TABLE public.product_file_description (
    id bigint NOT NULL,
    product_id bigint,
    pattern text NOT NULL,
    types text NOT NULL,
    create_date text NOT NULL,
    file_name_creation_pattern text,
    rt_flag_pattern text
);
 ,   DROP TABLE public.product_file_description;
       public         heap 	   statsuser    false            %           1259    18003    product_file_description_id_seq    SEQUENCE     �   CREATE SEQUENCE public.product_file_description_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 6   DROP SEQUENCE public.product_file_description_id_seq;
       public       	   statsuser    false    292            /           0    0    product_file_description_id_seq    SEQUENCE OWNED BY     c   ALTER SEQUENCE public.product_file_description_id_seq OWNED BY public.product_file_description.id;
          public       	   statsuser    false    293            &           1259    18004    product_file_id_seq    SEQUENCE     |   CREATE SEQUENCE public.product_file_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.product_file_id_seq;
       public       	   statsuser    false            '           1259    18005    product_file_id_seq1    SEQUENCE     }   CREATE SEQUENCE public.product_file_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.product_file_id_seq1;
       public       	   statsuser    false    291            0           0    0    product_file_id_seq1    SEQUENCE OWNED BY     L   ALTER SEQUENCE public.product_file_id_seq1 OWNED BY public.product_file.id;
          public       	   statsuser    false    295            (           1259    18006    product_file_variable    TABLE     <  CREATE TABLE public.product_file_variable (
    id bigint NOT NULL,
    product_file_description_id bigint,
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
    histogram_bins smallint,
    min_value double precision,
    max_value double precision,
    compute_statistics boolean DEFAULT true NOT NULL
);
 )   DROP TABLE public.product_file_variable;
       public         heap 	   statsuser    false            )           1259    18012    product_file_variable_id_seq    SEQUENCE     �   CREATE SEQUENCE public.product_file_variable_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 3   DROP SEQUENCE public.product_file_variable_id_seq;
       public       	   statsuser    false    296            1           0    0    product_file_variable_id_seq    SEQUENCE OWNED BY     ]   ALTER SEQUENCE public.product_file_variable_id_seq OWNED BY public.product_file_variable.id;
          public       	   statsuser    false    297            *           1259    18013    product_id_seq    SEQUENCE     w   CREATE SEQUENCE public.product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public.product_id_seq;
       public       	   statsuser    false    290            2           0    0    product_id_seq    SEQUENCE OWNED BY     A   ALTER SEQUENCE public.product_id_seq OWNED BY public.product.id;
          public       	   statsuser    false    298            +           1259    18014    product_order    TABLE     /  CREATE TABLE public.product_order (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    email text,
    aoi public.geometry(MultiPolygon,3857),
    request_data jsonb,
    date_created timestamp without time zone DEFAULT (now() AT TIME ZONE 'UTC'::text),
    processed boolean DEFAULT false NOT NULL
);
 !   DROP TABLE public.product_order;
       public         heap 	   statsuser    false    3    3    3    3    3    3    3    3            3           0    0    TABLE spatial_ref_sys    ACL     8   GRANT ALL ON TABLE public.spatial_ref_sys TO statsuser;
          public          postgres    false    219            ,           1259    18022    stratification    TABLE     m   CREATE TABLE public.stratification (
    id bigint NOT NULL,
    description text,
    tilelayer_url text
);
 "   DROP TABLE public.stratification;
       public         heap 	   statsuser    false            -           1259    18027    stratification_geom    TABLE     �   CREATE TABLE public.stratification_geom (
    id bigint NOT NULL,
    stratification_id bigint NOT NULL,
    geom public.geometry(MultiPolygon,4326),
    geom3857 public.geometry(MultiPolygon,3857),
    description text
);
 '   DROP TABLE public.stratification_geom;
       public         heap 	   statsuser    false    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3            .           1259    18032    stratification_geom_id_seq    SEQUENCE     �   CREATE SEQUENCE public.stratification_geom_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE public.stratification_geom_id_seq;
       public       	   statsuser    false    301            4           0    0    stratification_geom_id_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE public.stratification_geom_id_seq OWNED BY public.stratification_geom.id;
          public       	   statsuser    false    302            /           1259    18033    stratification_id_seq    SEQUENCE     ~   CREATE SEQUENCE public.stratification_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE public.stratification_id_seq;
       public       	   statsuser    false    300            5           0    0    stratification_id_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE public.stratification_id_seq OWNED BY public.stratification.id;
          public       	   statsuser    false    303            0           1259    18034    tmp    TABLE     6   CREATE TABLE public.tmp (
    json_object_agg json
);
    DROP TABLE public.tmp;
       public         heap 	   statsuser    false            1           1259    18039    wms_file    TABLE     �   CREATE TABLE public.wms_file (
    id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint,
    rel_file_path text
);
    DROP TABLE public.wms_file;
       public         heap 	   statsuser    false            2           1259    18044    wms_file_id_seq    SEQUENCE     x   CREATE SEQUENCE public.wms_file_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.wms_file_id_seq;
       public       	   statsuser    false    305            6           0    0    wms_file_id_seq    SEQUENCE OWNED BY     C   ALTER SEQUENCE public.wms_file_id_seq OWNED BY public.wms_file.id;
          public       	   statsuser    false    306            3           1259    18045    poly_stats_per_region    TABLE     �  CREATE TABLE tmp.poly_stats_per_region (
    id bigint NOT NULL,
    poly_id bigint,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
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
       tmp         heap 	   statsuser    false    4            4           1259    18053    poly_stats_per_region_id_seq    SEQUENCE     �   CREATE SEQUENCE tmp.poly_stats_per_region_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE tmp.poly_stats_per_region_id_seq;
       tmp       	   statsuser    false    4    307            7           0    0    poly_stats_per_region_id_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE tmp.poly_stats_per_region_id_seq OWNED BY tmp.poly_stats_per_region.id;
          tmp       	   statsuser    false    308            �           0    0    poly_stats_10_1_257    TABLE ATTACH     }   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_10_1_257 FOR VALUES FROM ('10', '1') TO ('10', '257');
          public       	   statsuser    false    229    228            �           0    0    poly_stats_10_257_279    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_10_257_279 FOR VALUES FROM ('10', '257') TO ('10', '279');
          public       	   statsuser    false    230    228            �           0    0    poly_stats_10_279_285    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_10_279_285 FOR VALUES FROM ('10', '279') TO ('10', '285');
          public       	   statsuser    false    231    228            �           0    0    poly_stats_10_285_38543    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_10_285_38543 FOR VALUES FROM ('10', '285') TO ('10', '38543');
          public       	   statsuser    false    232    228            �           0    0    poly_stats_12_1_257    TABLE ATTACH     }   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_12_1_257 FOR VALUES FROM ('12', '1') TO ('12', '257');
          public       	   statsuser    false    233    228            �           0    0    poly_stats_12_257_279    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_12_257_279 FOR VALUES FROM ('12', '257') TO ('12', '279');
          public       	   statsuser    false    234    228            �           0    0    poly_stats_12_279_285    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_12_279_285 FOR VALUES FROM ('12', '279') TO ('12', '285');
          public       	   statsuser    false    235    228            �           0    0    poly_stats_12_285_38543    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_12_285_38543 FOR VALUES FROM ('12', '285') TO ('12', '38543');
          public       	   statsuser    false    236    228            �           0    0    poly_stats_14_1_257    TABLE ATTACH     }   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_14_1_257 FOR VALUES FROM ('14', '1') TO ('14', '257');
          public       	   statsuser    false    237    228            �           0    0    poly_stats_14_257_279    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_14_257_279 FOR VALUES FROM ('14', '257') TO ('14', '279');
          public       	   statsuser    false    238    228            �           0    0    poly_stats_14_279_285    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_14_279_285 FOR VALUES FROM ('14', '279') TO ('14', '285');
          public       	   statsuser    false    239    228            �           0    0    poly_stats_14_285_38543    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_14_285_38543 FOR VALUES FROM ('14', '285') TO ('14', '38543');
          public       	   statsuser    false    240    228            �           0    0    poly_stats_16_1_257    TABLE ATTACH     }   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_16_1_257 FOR VALUES FROM ('16', '1') TO ('16', '257');
          public       	   statsuser    false    241    228            �           0    0    poly_stats_16_257_279    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_16_257_279 FOR VALUES FROM ('16', '257') TO ('16', '279');
          public       	   statsuser    false    242    228            �           0    0    poly_stats_16_279_285    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_16_279_285 FOR VALUES FROM ('16', '279') TO ('16', '285');
          public       	   statsuser    false    243    228            �           0    0    poly_stats_16_285_38543    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_16_285_38543 FOR VALUES FROM ('16', '285') TO ('16', '38543');
          public       	   statsuser    false    244    228            �           0    0    poly_stats_17_1_257    TABLE ATTACH     }   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_17_1_257 FOR VALUES FROM ('17', '1') TO ('17', '257');
          public       	   statsuser    false    245    228            �           0    0    poly_stats_17_257_279    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_17_257_279 FOR VALUES FROM ('17', '257') TO ('17', '279');
          public       	   statsuser    false    246    228            �           0    0    poly_stats_17_279_285    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_17_279_285 FOR VALUES FROM ('17', '279') TO ('17', '285');
          public       	   statsuser    false    247    228            �           0    0    poly_stats_17_285_38543    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_17_285_38543 FOR VALUES FROM ('17', '285') TO ('17', '38543');
          public       	   statsuser    false    248    228            �           0    0    poly_stats_19_1_257    TABLE ATTACH     }   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_19_1_257 FOR VALUES FROM ('19', '1') TO ('19', '257');
          public       	   statsuser    false    249    228            �           0    0    poly_stats_19_257_279    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_19_257_279 FOR VALUES FROM ('19', '257') TO ('19', '279');
          public       	   statsuser    false    250    228            �           0    0    poly_stats_19_279_285    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_19_279_285 FOR VALUES FROM ('19', '279') TO ('19', '285');
          public       	   statsuser    false    251    228            �           0    0    poly_stats_19_285_38543    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_19_285_38543 FOR VALUES FROM ('19', '285') TO ('19', '38543');
          public       	   statsuser    false    252    228            �           0    0    poly_stats_1_1_257    TABLE ATTACH     z   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_1_1_257 FOR VALUES FROM ('1', '1') TO ('1', '257');
          public       	   statsuser    false    253    228            �           0    0    poly_stats_1_257_279    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_1_257_279 FOR VALUES FROM ('1', '257') TO ('1', '279');
          public       	   statsuser    false    254    228            �           0    0    poly_stats_1_279_285    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_1_279_285 FOR VALUES FROM ('1', '279') TO ('1', '285');
          public       	   statsuser    false    255    228            �           0    0    poly_stats_1_285_38543    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_1_285_38543 FOR VALUES FROM ('1', '285') TO ('1', '38543');
          public       	   statsuser    false    256    228            �           0    0    poly_stats_21_1_257    TABLE ATTACH     }   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_21_1_257 FOR VALUES FROM ('21', '1') TO ('21', '257');
          public       	   statsuser    false    257    228            �           0    0    poly_stats_21_257_279    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_21_257_279 FOR VALUES FROM ('21', '257') TO ('21', '279');
          public       	   statsuser    false    258    228            �           0    0    poly_stats_21_279_285    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_21_279_285 FOR VALUES FROM ('21', '279') TO ('21', '285');
          public       	   statsuser    false    259    228            �           0    0    poly_stats_21_285_38543    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_21_285_38543 FOR VALUES FROM ('21', '285') TO ('21', '38543');
          public       	   statsuser    false    260    228            �           0    0    poly_stats_24_1_257    TABLE ATTACH     }   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_24_1_257 FOR VALUES FROM ('24', '1') TO ('24', '257');
          public       	   statsuser    false    261    228            �           0    0    poly_stats_2_1_257    TABLE ATTACH     z   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_2_1_257 FOR VALUES FROM ('2', '1') TO ('2', '257');
          public       	   statsuser    false    262    228            �           0    0    poly_stats_2_257_279    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_2_257_279 FOR VALUES FROM ('2', '257') TO ('2', '279');
          public       	   statsuser    false    263    228            �           0    0    poly_stats_2_279_285    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_2_279_285 FOR VALUES FROM ('2', '279') TO ('2', '285');
          public       	   statsuser    false    264    228            �           0    0    poly_stats_2_285_38543    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_2_285_38543 FOR VALUES FROM ('2', '285') TO ('2', '38543');
          public       	   statsuser    false    265    228            �           0    0    poly_stats_3_1_257    TABLE ATTACH     z   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_3_1_257 FOR VALUES FROM ('3', '1') TO ('3', '257');
          public       	   statsuser    false    266    228            �           0    0    poly_stats_3_257_279    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_3_257_279 FOR VALUES FROM ('3', '257') TO ('3', '279');
          public       	   statsuser    false    267    228            �           0    0    poly_stats_3_279_285    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_3_279_285 FOR VALUES FROM ('3', '279') TO ('3', '285');
          public       	   statsuser    false    268    228            �           0    0    poly_stats_3_285_38543    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_3_285_38543 FOR VALUES FROM ('3', '285') TO ('3', '38543');
          public       	   statsuser    false    269    228            �           0    0    poly_stats_4_1_257    TABLE ATTACH     z   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_4_1_257 FOR VALUES FROM ('4', '1') TO ('4', '257');
          public       	   statsuser    false    270    228            �           0    0    poly_stats_4_257_279    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_4_257_279 FOR VALUES FROM ('4', '257') TO ('4', '279');
          public       	   statsuser    false    271    228            �           0    0    poly_stats_4_279_285    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_4_279_285 FOR VALUES FROM ('4', '279') TO ('4', '285');
          public       	   statsuser    false    272    228            �           0    0    poly_stats_4_285_38543    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_4_285_38543 FOR VALUES FROM ('4', '285') TO ('4', '38543');
          public       	   statsuser    false    273    228            �           0    0    poly_stats_5_1_257    TABLE ATTACH     z   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_5_1_257 FOR VALUES FROM ('5', '1') TO ('5', '257');
          public       	   statsuser    false    274    228            �           0    0    poly_stats_5_257_279    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_5_257_279 FOR VALUES FROM ('5', '257') TO ('5', '279');
          public       	   statsuser    false    275    228            �           0    0    poly_stats_5_279_285    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_5_279_285 FOR VALUES FROM ('5', '279') TO ('5', '285');
          public       	   statsuser    false    276    228            �           0    0    poly_stats_5_285_38543    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_5_285_38543 FOR VALUES FROM ('5', '285') TO ('5', '38543');
          public       	   statsuser    false    277    228            �           0    0    poly_stats_6_1_257    TABLE ATTACH     z   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_6_1_257 FOR VALUES FROM ('6', '1') TO ('6', '257');
          public       	   statsuser    false    278    228            �           0    0    poly_stats_6_257_279    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_6_257_279 FOR VALUES FROM ('6', '257') TO ('6', '279');
          public       	   statsuser    false    279    228            �           0    0    poly_stats_6_279_285    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_6_279_285 FOR VALUES FROM ('6', '279') TO ('6', '285');
          public       	   statsuser    false    280    228            �           0    0    poly_stats_6_285_38543    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_6_285_38543 FOR VALUES FROM ('6', '285') TO ('6', '38543');
          public       	   statsuser    false    281    228            �           0    0    poly_stats_7_1_257    TABLE ATTACH     z   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_7_1_257 FOR VALUES FROM ('7', '1') TO ('7', '257');
          public       	   statsuser    false    282    228            �           0    0    poly_stats_7_257_279    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_7_257_279 FOR VALUES FROM ('7', '257') TO ('7', '279');
          public       	   statsuser    false    283    228            �           0    0    poly_stats_7_279_285    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_7_279_285 FOR VALUES FROM ('7', '279') TO ('7', '285');
          public       	   statsuser    false    284    228            �           0    0    poly_stats_7_285_38543    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_7_285_38543 FOR VALUES FROM ('7', '285') TO ('7', '38543');
          public       	   statsuser    false    285    228            �           0    0    poly_stats_9_1_257    TABLE ATTACH     z   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_9_1_257 FOR VALUES FROM ('9', '1') TO ('9', '257');
          public       	   statsuser    false    286    228            �           0    0    poly_stats_9_257_279    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_9_257_279 FOR VALUES FROM ('9', '257') TO ('9', '279');
          public       	   statsuser    false    287    228            �           0    0    poly_stats_9_279_285    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_9_279_285 FOR VALUES FROM ('9', '279') TO ('9', '285');
          public       	   statsuser    false    288    228            �           0    0    poly_stats_9_285_38543    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_9_285_38543 FOR VALUES FROM ('9', '285') TO ('9', '38543');
          public       	   statsuser    false    289    228            �           2604    18054    long_term_anomaly_info id    DEFAULT     �   ALTER TABLE ONLY public.long_term_anomaly_info ALTER COLUMN id SET DEFAULT nextval('public.long_term_anomaly_info_id_seq'::regclass);
 H   ALTER TABLE public.long_term_anomaly_info ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    226    225            �           2604    18055 
   product id    DEFAULT     h   ALTER TABLE ONLY public.product ALTER COLUMN id SET DEFAULT nextval('public.product_id_seq'::regclass);
 9   ALTER TABLE public.product ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    298    290            �           2604    18056    product_file id    DEFAULT     s   ALTER TABLE ONLY public.product_file ALTER COLUMN id SET DEFAULT nextval('public.product_file_id_seq1'::regclass);
 >   ALTER TABLE public.product_file ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    295    291            �           2604    18057    product_file_description id    DEFAULT     �   ALTER TABLE ONLY public.product_file_description ALTER COLUMN id SET DEFAULT nextval('public.product_file_description_id_seq'::regclass);
 J   ALTER TABLE public.product_file_description ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    293    292            �           2604    18058    product_file_variable id    DEFAULT     �   ALTER TABLE ONLY public.product_file_variable ALTER COLUMN id SET DEFAULT nextval('public.product_file_variable_id_seq'::regclass);
 G   ALTER TABLE public.product_file_variable ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    297    296            �           2604    18059    stratification id    DEFAULT     v   ALTER TABLE ONLY public.stratification ALTER COLUMN id SET DEFAULT nextval('public.stratification_id_seq'::regclass);
 @   ALTER TABLE public.stratification ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    303    300            �           2604    18060    stratification_geom id    DEFAULT     �   ALTER TABLE ONLY public.stratification_geom ALTER COLUMN id SET DEFAULT nextval('public.stratification_geom_id_seq'::regclass);
 E   ALTER TABLE public.stratification_geom ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    302    301            �           2604    18061    wms_file id    DEFAULT     j   ALTER TABLE ONLY public.wms_file ALTER COLUMN id SET DEFAULT nextval('public.wms_file_id_seq'::regclass);
 :   ALTER TABLE public.wms_file ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    306    305            �           2604    18062    poly_stats_per_region id    DEFAULT     ~   ALTER TABLE ONLY tmp.poly_stats_per_region ALTER COLUMN id SET DEFAULT nextval('tmp.poly_stats_per_region_id_seq'::regclass);
 D   ALTER TABLE tmp.poly_stats_per_region ALTER COLUMN id DROP DEFAULT;
       tmp       	   statsuser    false    308    307            �           2606    18064 0   long_term_anomaly_info long_term_anomaly_info_pk 
   CONSTRAINT     n   ALTER TABLE ONLY public.long_term_anomaly_info
    ADD CONSTRAINT long_term_anomaly_info_pk PRIMARY KEY (id);
 Z   ALTER TABLE ONLY public.long_term_anomaly_info DROP CONSTRAINT long_term_anomaly_info_pk;
       public         	   statsuser    false    225            �           2606    18066    category newtable_pk 
   CONSTRAINT     R   ALTER TABLE ONLY public.category
    ADD CONSTRAINT newtable_pk PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.category DROP CONSTRAINT newtable_pk;
       public         	   statsuser    false    223            �           2606    18068    poly_stats poly_stats_pk_ 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats
    ADD CONSTRAINT poly_stats_pk_ PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 C   ALTER TABLE ONLY public.poly_stats DROP CONSTRAINT poly_stats_pk_;
       public         	   statsuser    false    228    228    228            �           2606    18070 ,   poly_stats_10_1_257 poly_stats_10_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_10_1_257
    ADD CONSTRAINT poly_stats_10_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 V   ALTER TABLE ONLY public.poly_stats_10_1_257 DROP CONSTRAINT poly_stats_10_1_257_pkey;
       public         	   statsuser    false    229    229    229    4769    229            �           2606    18072 0   poly_stats_10_257_279 poly_stats_10_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_10_257_279
    ADD CONSTRAINT poly_stats_10_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_10_257_279 DROP CONSTRAINT poly_stats_10_257_279_pkey;
       public         	   statsuser    false    230    4769    230    230    230            �           2606    18074 0   poly_stats_10_279_285 poly_stats_10_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_10_279_285
    ADD CONSTRAINT poly_stats_10_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_10_279_285 DROP CONSTRAINT poly_stats_10_279_285_pkey;
       public         	   statsuser    false    231    4769    231    231    231            �           2606    18076 4   poly_stats_10_285_38543 poly_stats_10_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_10_285_38543
    ADD CONSTRAINT poly_stats_10_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 ^   ALTER TABLE ONLY public.poly_stats_10_285_38543 DROP CONSTRAINT poly_stats_10_285_38543_pkey;
       public         	   statsuser    false    232    232    232    4769    232            �           2606    18078 ,   poly_stats_12_1_257 poly_stats_12_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_12_1_257
    ADD CONSTRAINT poly_stats_12_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 V   ALTER TABLE ONLY public.poly_stats_12_1_257 DROP CONSTRAINT poly_stats_12_1_257_pkey;
       public         	   statsuser    false    233    4769    233    233    233            �           2606    18080 0   poly_stats_12_257_279 poly_stats_12_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_12_257_279
    ADD CONSTRAINT poly_stats_12_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_12_257_279 DROP CONSTRAINT poly_stats_12_257_279_pkey;
       public         	   statsuser    false    4769    234    234    234    234            �           2606    18082 0   poly_stats_12_279_285 poly_stats_12_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_12_279_285
    ADD CONSTRAINT poly_stats_12_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_12_279_285 DROP CONSTRAINT poly_stats_12_279_285_pkey;
       public         	   statsuser    false    235    235    235    4769    235            �           2606    18084 4   poly_stats_12_285_38543 poly_stats_12_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_12_285_38543
    ADD CONSTRAINT poly_stats_12_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 ^   ALTER TABLE ONLY public.poly_stats_12_285_38543 DROP CONSTRAINT poly_stats_12_285_38543_pkey;
       public         	   statsuser    false    236    4769    236    236    236            �           2606    18086 ,   poly_stats_14_1_257 poly_stats_14_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_14_1_257
    ADD CONSTRAINT poly_stats_14_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 V   ALTER TABLE ONLY public.poly_stats_14_1_257 DROP CONSTRAINT poly_stats_14_1_257_pkey;
       public         	   statsuser    false    237    4769    237    237    237            �           2606    18088 0   poly_stats_14_257_279 poly_stats_14_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_14_257_279
    ADD CONSTRAINT poly_stats_14_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_14_257_279 DROP CONSTRAINT poly_stats_14_257_279_pkey;
       public         	   statsuser    false    238    238    238    4769    238            �           2606    18090 0   poly_stats_14_279_285 poly_stats_14_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_14_279_285
    ADD CONSTRAINT poly_stats_14_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_14_279_285 DROP CONSTRAINT poly_stats_14_279_285_pkey;
       public         	   statsuser    false    239    239    239    239    4769            �           2606    18092 4   poly_stats_14_285_38543 poly_stats_14_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_14_285_38543
    ADD CONSTRAINT poly_stats_14_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 ^   ALTER TABLE ONLY public.poly_stats_14_285_38543 DROP CONSTRAINT poly_stats_14_285_38543_pkey;
       public         	   statsuser    false    240    240    240    240    4769            �           2606    18094 ,   poly_stats_16_1_257 poly_stats_16_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_16_1_257
    ADD CONSTRAINT poly_stats_16_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 V   ALTER TABLE ONLY public.poly_stats_16_1_257 DROP CONSTRAINT poly_stats_16_1_257_pkey;
       public         	   statsuser    false    241    4769    241    241    241            �           2606    18096 0   poly_stats_16_257_279 poly_stats_16_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_16_257_279
    ADD CONSTRAINT poly_stats_16_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_16_257_279 DROP CONSTRAINT poly_stats_16_257_279_pkey;
       public         	   statsuser    false    242    242    242    242    4769            �           2606    18098 0   poly_stats_16_279_285 poly_stats_16_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_16_279_285
    ADD CONSTRAINT poly_stats_16_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_16_279_285 DROP CONSTRAINT poly_stats_16_279_285_pkey;
       public         	   statsuser    false    243    243    243    243    4769            �           2606    18100 4   poly_stats_16_285_38543 poly_stats_16_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_16_285_38543
    ADD CONSTRAINT poly_stats_16_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 ^   ALTER TABLE ONLY public.poly_stats_16_285_38543 DROP CONSTRAINT poly_stats_16_285_38543_pkey;
       public         	   statsuser    false    244    244    244    244    4769            �           2606    18102 ,   poly_stats_17_1_257 poly_stats_17_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_17_1_257
    ADD CONSTRAINT poly_stats_17_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 V   ALTER TABLE ONLY public.poly_stats_17_1_257 DROP CONSTRAINT poly_stats_17_1_257_pkey;
       public         	   statsuser    false    245    245    4769    245    245            �           2606    18104 0   poly_stats_17_257_279 poly_stats_17_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_17_257_279
    ADD CONSTRAINT poly_stats_17_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_17_257_279 DROP CONSTRAINT poly_stats_17_257_279_pkey;
       public         	   statsuser    false    246    4769    246    246    246            �           2606    18106 0   poly_stats_17_279_285 poly_stats_17_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_17_279_285
    ADD CONSTRAINT poly_stats_17_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_17_279_285 DROP CONSTRAINT poly_stats_17_279_285_pkey;
       public         	   statsuser    false    4769    247    247    247    247            �           2606    18108 4   poly_stats_17_285_38543 poly_stats_17_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_17_285_38543
    ADD CONSTRAINT poly_stats_17_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 ^   ALTER TABLE ONLY public.poly_stats_17_285_38543 DROP CONSTRAINT poly_stats_17_285_38543_pkey;
       public         	   statsuser    false    248    248    248    4769    248            �           2606    18110 ,   poly_stats_19_1_257 poly_stats_19_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_19_1_257
    ADD CONSTRAINT poly_stats_19_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 V   ALTER TABLE ONLY public.poly_stats_19_1_257 DROP CONSTRAINT poly_stats_19_1_257_pkey;
       public         	   statsuser    false    249    249    249    249    4769            �           2606    18112 0   poly_stats_19_257_279 poly_stats_19_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_19_257_279
    ADD CONSTRAINT poly_stats_19_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_19_257_279 DROP CONSTRAINT poly_stats_19_257_279_pkey;
       public         	   statsuser    false    4769    250    250    250    250            �           2606    18114 0   poly_stats_19_279_285 poly_stats_19_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_19_279_285
    ADD CONSTRAINT poly_stats_19_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_19_279_285 DROP CONSTRAINT poly_stats_19_279_285_pkey;
       public         	   statsuser    false    251    251    4769    251    251            �           2606    18116 4   poly_stats_19_285_38543 poly_stats_19_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_19_285_38543
    ADD CONSTRAINT poly_stats_19_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 ^   ALTER TABLE ONLY public.poly_stats_19_285_38543 DROP CONSTRAINT poly_stats_19_285_38543_pkey;
       public         	   statsuser    false    252    252    252    4769    252            �           2606    18118 *   poly_stats_1_1_257 poly_stats_1_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_1_1_257
    ADD CONSTRAINT poly_stats_1_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 T   ALTER TABLE ONLY public.poly_stats_1_1_257 DROP CONSTRAINT poly_stats_1_1_257_pkey;
       public         	   statsuser    false    253    4769    253    253    253            �           2606    18120 .   poly_stats_1_257_279 poly_stats_1_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_1_257_279
    ADD CONSTRAINT poly_stats_1_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_1_257_279 DROP CONSTRAINT poly_stats_1_257_279_pkey;
       public         	   statsuser    false    254    4769    254    254    254            �           2606    18122 .   poly_stats_1_279_285 poly_stats_1_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_1_279_285
    ADD CONSTRAINT poly_stats_1_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_1_279_285 DROP CONSTRAINT poly_stats_1_279_285_pkey;
       public         	   statsuser    false    255    4769    255    255    255            �           2606    18124 2   poly_stats_1_285_38543 poly_stats_1_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_1_285_38543
    ADD CONSTRAINT poly_stats_1_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 \   ALTER TABLE ONLY public.poly_stats_1_285_38543 DROP CONSTRAINT poly_stats_1_285_38543_pkey;
       public         	   statsuser    false    4769    256    256    256    256            �           2606    18126 ,   poly_stats_21_1_257 poly_stats_21_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_21_1_257
    ADD CONSTRAINT poly_stats_21_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 V   ALTER TABLE ONLY public.poly_stats_21_1_257 DROP CONSTRAINT poly_stats_21_1_257_pkey;
       public         	   statsuser    false    257    257    257    4769    257            �           2606    18128 0   poly_stats_21_257_279 poly_stats_21_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_21_257_279
    ADD CONSTRAINT poly_stats_21_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_21_257_279 DROP CONSTRAINT poly_stats_21_257_279_pkey;
       public         	   statsuser    false    258    258    258    258    4769            �           2606    18130 0   poly_stats_21_279_285 poly_stats_21_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_21_279_285
    ADD CONSTRAINT poly_stats_21_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_21_279_285 DROP CONSTRAINT poly_stats_21_279_285_pkey;
       public         	   statsuser    false    4769    259    259    259    259                       2606    18132 4   poly_stats_21_285_38543 poly_stats_21_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_21_285_38543
    ADD CONSTRAINT poly_stats_21_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 ^   ALTER TABLE ONLY public.poly_stats_21_285_38543 DROP CONSTRAINT poly_stats_21_285_38543_pkey;
       public         	   statsuser    false    260    260    260    4769    260                       2606    18134 ,   poly_stats_24_1_257 poly_stats_24_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_24_1_257
    ADD CONSTRAINT poly_stats_24_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 V   ALTER TABLE ONLY public.poly_stats_24_1_257 DROP CONSTRAINT poly_stats_24_1_257_pkey;
       public         	   statsuser    false    4769    261    261    261    261                       2606    18136 *   poly_stats_2_1_257 poly_stats_2_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_2_1_257
    ADD CONSTRAINT poly_stats_2_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 T   ALTER TABLE ONLY public.poly_stats_2_1_257 DROP CONSTRAINT poly_stats_2_1_257_pkey;
       public         	   statsuser    false    262    262    262    4769    262            
           2606    18138 .   poly_stats_2_257_279 poly_stats_2_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_2_257_279
    ADD CONSTRAINT poly_stats_2_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_2_257_279 DROP CONSTRAINT poly_stats_2_257_279_pkey;
       public         	   statsuser    false    4769    263    263    263    263                       2606    18140 .   poly_stats_2_279_285 poly_stats_2_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_2_279_285
    ADD CONSTRAINT poly_stats_2_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_2_279_285 DROP CONSTRAINT poly_stats_2_279_285_pkey;
       public         	   statsuser    false    264    264    264    4769    264                       2606    18142 2   poly_stats_2_285_38543 poly_stats_2_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_2_285_38543
    ADD CONSTRAINT poly_stats_2_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 \   ALTER TABLE ONLY public.poly_stats_2_285_38543 DROP CONSTRAINT poly_stats_2_285_38543_pkey;
       public         	   statsuser    false    265    265    265    265    4769                       2606    18144 *   poly_stats_3_1_257 poly_stats_3_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_3_1_257
    ADD CONSTRAINT poly_stats_3_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 T   ALTER TABLE ONLY public.poly_stats_3_1_257 DROP CONSTRAINT poly_stats_3_1_257_pkey;
       public         	   statsuser    false    266    266    4769    266    266                       2606    18146 .   poly_stats_3_257_279 poly_stats_3_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_3_257_279
    ADD CONSTRAINT poly_stats_3_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_3_257_279 DROP CONSTRAINT poly_stats_3_257_279_pkey;
       public         	   statsuser    false    267    267    267    267    4769                       2606    18148 .   poly_stats_3_279_285 poly_stats_3_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_3_279_285
    ADD CONSTRAINT poly_stats_3_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_3_279_285 DROP CONSTRAINT poly_stats_3_279_285_pkey;
       public         	   statsuser    false    268    268    4769    268    268                       2606    18150 2   poly_stats_3_285_38543 poly_stats_3_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_3_285_38543
    ADD CONSTRAINT poly_stats_3_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 \   ALTER TABLE ONLY public.poly_stats_3_285_38543 DROP CONSTRAINT poly_stats_3_285_38543_pkey;
       public         	   statsuser    false    269    269    4769    269    269                       2606    18152 *   poly_stats_4_1_257 poly_stats_4_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_4_1_257
    ADD CONSTRAINT poly_stats_4_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 T   ALTER TABLE ONLY public.poly_stats_4_1_257 DROP CONSTRAINT poly_stats_4_1_257_pkey;
       public         	   statsuser    false    270    4769    270    270    270            "           2606    18154 .   poly_stats_4_257_279 poly_stats_4_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_4_257_279
    ADD CONSTRAINT poly_stats_4_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_4_257_279 DROP CONSTRAINT poly_stats_4_257_279_pkey;
       public         	   statsuser    false    271    271    271    271    4769            %           2606    18156 .   poly_stats_4_279_285 poly_stats_4_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_4_279_285
    ADD CONSTRAINT poly_stats_4_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_4_279_285 DROP CONSTRAINT poly_stats_4_279_285_pkey;
       public         	   statsuser    false    272    272    272    272    4769            (           2606    18158 2   poly_stats_4_285_38543 poly_stats_4_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_4_285_38543
    ADD CONSTRAINT poly_stats_4_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 \   ALTER TABLE ONLY public.poly_stats_4_285_38543 DROP CONSTRAINT poly_stats_4_285_38543_pkey;
       public         	   statsuser    false    273    273    273    4769    273            +           2606    18160 *   poly_stats_5_1_257 poly_stats_5_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_5_1_257
    ADD CONSTRAINT poly_stats_5_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 T   ALTER TABLE ONLY public.poly_stats_5_1_257 DROP CONSTRAINT poly_stats_5_1_257_pkey;
       public         	   statsuser    false    4769    274    274    274    274            .           2606    18162 .   poly_stats_5_257_279 poly_stats_5_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_5_257_279
    ADD CONSTRAINT poly_stats_5_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_5_257_279 DROP CONSTRAINT poly_stats_5_257_279_pkey;
       public         	   statsuser    false    4769    275    275    275    275            1           2606    18164 .   poly_stats_5_279_285 poly_stats_5_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_5_279_285
    ADD CONSTRAINT poly_stats_5_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_5_279_285 DROP CONSTRAINT poly_stats_5_279_285_pkey;
       public         	   statsuser    false    276    276    276    4769    276            4           2606    18166 2   poly_stats_5_285_38543 poly_stats_5_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_5_285_38543
    ADD CONSTRAINT poly_stats_5_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 \   ALTER TABLE ONLY public.poly_stats_5_285_38543 DROP CONSTRAINT poly_stats_5_285_38543_pkey;
       public         	   statsuser    false    277    277    277    277    4769            7           2606    18168 *   poly_stats_6_1_257 poly_stats_6_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_6_1_257
    ADD CONSTRAINT poly_stats_6_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 T   ALTER TABLE ONLY public.poly_stats_6_1_257 DROP CONSTRAINT poly_stats_6_1_257_pkey;
       public         	   statsuser    false    278    278    4769    278    278            :           2606    18170 .   poly_stats_6_257_279 poly_stats_6_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_6_257_279
    ADD CONSTRAINT poly_stats_6_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_6_257_279 DROP CONSTRAINT poly_stats_6_257_279_pkey;
       public         	   statsuser    false    279    4769    279    279    279            =           2606    18172 .   poly_stats_6_279_285 poly_stats_6_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_6_279_285
    ADD CONSTRAINT poly_stats_6_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_6_279_285 DROP CONSTRAINT poly_stats_6_279_285_pkey;
       public         	   statsuser    false    4769    280    280    280    280            @           2606    18174 2   poly_stats_6_285_38543 poly_stats_6_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_6_285_38543
    ADD CONSTRAINT poly_stats_6_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 \   ALTER TABLE ONLY public.poly_stats_6_285_38543 DROP CONSTRAINT poly_stats_6_285_38543_pkey;
       public         	   statsuser    false    281    4769    281    281    281            C           2606    18176 *   poly_stats_7_1_257 poly_stats_7_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_7_1_257
    ADD CONSTRAINT poly_stats_7_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 T   ALTER TABLE ONLY public.poly_stats_7_1_257 DROP CONSTRAINT poly_stats_7_1_257_pkey;
       public         	   statsuser    false    282    282    282    4769    282            F           2606    18178 .   poly_stats_7_257_279 poly_stats_7_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_7_257_279
    ADD CONSTRAINT poly_stats_7_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_7_257_279 DROP CONSTRAINT poly_stats_7_257_279_pkey;
       public         	   statsuser    false    283    283    283    283    4769            I           2606    18180 .   poly_stats_7_279_285 poly_stats_7_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_7_279_285
    ADD CONSTRAINT poly_stats_7_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_7_279_285 DROP CONSTRAINT poly_stats_7_279_285_pkey;
       public         	   statsuser    false    284    284    4769    284    284            L           2606    18182 2   poly_stats_7_285_38543 poly_stats_7_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_7_285_38543
    ADD CONSTRAINT poly_stats_7_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 \   ALTER TABLE ONLY public.poly_stats_7_285_38543 DROP CONSTRAINT poly_stats_7_285_38543_pkey;
       public         	   statsuser    false    285    285    285    285    4769            O           2606    18184 *   poly_stats_9_1_257 poly_stats_9_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_9_1_257
    ADD CONSTRAINT poly_stats_9_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 T   ALTER TABLE ONLY public.poly_stats_9_1_257 DROP CONSTRAINT poly_stats_9_1_257_pkey;
       public         	   statsuser    false    286    286    286    286    4769            R           2606    18186 .   poly_stats_9_257_279 poly_stats_9_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_9_257_279
    ADD CONSTRAINT poly_stats_9_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_9_257_279 DROP CONSTRAINT poly_stats_9_257_279_pkey;
       public         	   statsuser    false    287    287    287    287    4769            U           2606    18188 .   poly_stats_9_279_285 poly_stats_9_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_9_279_285
    ADD CONSTRAINT poly_stats_9_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_9_279_285 DROP CONSTRAINT poly_stats_9_279_285_pkey;
       public         	   statsuser    false    288    288    4769    288    288            X           2606    18190 2   poly_stats_9_285_38543 poly_stats_9_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_9_285_38543
    ADD CONSTRAINT poly_stats_9_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 \   ALTER TABLE ONLY public.poly_stats_9_285_38543 DROP CONSTRAINT poly_stats_9_285_38543_pkey;
       public         	   statsuser    false    289    4769    289    289    289            ^           2606    18192 6   product_file product_file_date_product_description_idx 
   CONSTRAINT     �   ALTER TABLE ONLY public.product_file
    ADD CONSTRAINT product_file_date_product_description_idx UNIQUE (product_file_description_id, date, rt_flag);
 `   ALTER TABLE ONLY public.product_file DROP CONSTRAINT product_file_date_product_description_idx;
       public         	   statsuser    false    291    291    291            `           2606    18194    product_file product_file_pk 
   CONSTRAINT     Z   ALTER TABLE ONLY public.product_file
    ADD CONSTRAINT product_file_pk PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.product_file DROP CONSTRAINT product_file_pk;
       public         	   statsuser    false    291            d           2606    18196 .   product_file_variable product_file_variable_pk 
   CONSTRAINT     l   ALTER TABLE ONLY public.product_file_variable
    ADD CONSTRAINT product_file_variable_pk PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.product_file_variable DROP CONSTRAINT product_file_variable_pk;
       public         	   statsuser    false    296            g           2606    18198    product_order product_order_pk 
   CONSTRAINT     \   ALTER TABLE ONLY public.product_order
    ADD CONSTRAINT product_order_pk PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.product_order DROP CONSTRAINT product_order_pk;
       public         	   statsuser    false    299            [           2606    18200    product product_pk1 
   CONSTRAINT     Q   ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_pk1 PRIMARY KEY (id);
 =   ALTER TABLE ONLY public.product DROP CONSTRAINT product_pk1;
       public         	   statsuser    false    290            b           2606    18202 <   product_file_description product_product_file_description_pk 
   CONSTRAINT     z   ALTER TABLE ONLY public.product_file_description
    ADD CONSTRAINT product_product_file_description_pk PRIMARY KEY (id);
 f   ALTER TABLE ONLY public.product_file_description DROP CONSTRAINT product_product_file_description_pk;
       public         	   statsuser    false    292            i           2606    18204     stratification stratification_pk 
   CONSTRAINT     ^   ALTER TABLE ONLY public.stratification
    ADD CONSTRAINT stratification_pk PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.stratification DROP CONSTRAINT stratification_pk;
       public         	   statsuser    false    300            o           2606    18206 '   stratification_geom stratification_pkey 
   CONSTRAINT     e   ALTER TABLE ONLY public.stratification_geom
    ADD CONSTRAINT stratification_pkey PRIMARY KEY (id);
 Q   ALTER TABLE ONLY public.stratification_geom DROP CONSTRAINT stratification_pkey;
       public         	   statsuser    false    301            k           2606    18208     stratification stratification_un 
   CONSTRAINT     b   ALTER TABLE ONLY public.stratification
    ADD CONSTRAINT stratification_un UNIQUE (description);
 J   ALTER TABLE ONLY public.stratification DROP CONSTRAINT stratification_un;
       public         	   statsuser    false    300            q           2606    18210    wms_file wms_file_pk 
   CONSTRAINT     R   ALTER TABLE ONLY public.wms_file
    ADD CONSTRAINT wms_file_pk PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.wms_file DROP CONSTRAINT wms_file_pk;
       public         	   statsuser    false    305            s           2606    18212    wms_file wms_file_un 
   CONSTRAINT     t   ALTER TABLE ONLY public.wms_file
    ADD CONSTRAINT wms_file_un UNIQUE (product_file_id, product_file_variable_id);
 >   ALTER TABLE ONLY public.wms_file DROP CONSTRAINT wms_file_un;
       public         	   statsuser    false    305    305            u           2606    18214 #   poly_stats_per_region poly_stats_pk 
   CONSTRAINT     ^   ALTER TABLE ONLY tmp.poly_stats_per_region
    ADD CONSTRAINT poly_stats_pk PRIMARY KEY (id);
 J   ALTER TABLE ONLY tmp.poly_stats_per_region DROP CONSTRAINT poly_stats_pk;
       tmp         	   statsuser    false    307            w           2606    18216 #   poly_stats_per_region poly_stats_un 
   CONSTRAINT     �   ALTER TABLE ONLY tmp.poly_stats_per_region
    ADD CONSTRAINT poly_stats_un UNIQUE (poly_id, product_file_id, product_file_variable_id, region_id);
 J   ALTER TABLE ONLY tmp.poly_stats_per_region DROP CONSTRAINT poly_stats_un;
       tmp         	   statsuser    false    307    307    307    307            �           1259    18217    poly_stats_product_file_id_idx    INDEX        CREATE INDEX poly_stats_product_file_id_idx ON ONLY public.poly_stats USING btree (product_file_id, product_file_variable_id);
 2   DROP INDEX public.poly_stats_product_file_id_idx;
       public         	   statsuser    false    228    228            �           1259    18218 ?   poly_stats_10_1_257_product_file_id_product_file_variable_i_idx    INDEX     �   CREATE INDEX poly_stats_10_1_257_product_file_id_product_file_variable_i_idx ON public.poly_stats_10_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_10_1_257_product_file_id_product_file_variable_i_idx;
       public         	   statsuser    false    229    229    229    4770            �           1259    18219 ?   poly_stats_10_257_279_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_10_257_279_product_file_id_product_file_variable_idx ON public.poly_stats_10_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_10_257_279_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    230    230    4770    230            �           1259    18220 ?   poly_stats_10_279_285_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_10_279_285_product_file_id_product_file_variable_idx ON public.poly_stats_10_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_10_279_285_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    4770    231    231    231            �           1259    18221 ?   poly_stats_10_285_38543_product_file_id_product_file_variab_idx    INDEX     �   CREATE INDEX poly_stats_10_285_38543_product_file_id_product_file_variab_idx ON public.poly_stats_10_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_10_285_38543_product_file_id_product_file_variab_idx;
       public         	   statsuser    false    232    232    4770    232            �           1259    18222 ?   poly_stats_12_1_257_product_file_id_product_file_variable_i_idx    INDEX     �   CREATE INDEX poly_stats_12_1_257_product_file_id_product_file_variable_i_idx ON public.poly_stats_12_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_12_1_257_product_file_id_product_file_variable_i_idx;
       public         	   statsuser    false    233    4770    233    233            �           1259    18223 ?   poly_stats_12_257_279_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_12_257_279_product_file_id_product_file_variable_idx ON public.poly_stats_12_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_12_257_279_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    234    234    234    4770            �           1259    18224 ?   poly_stats_12_279_285_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_12_279_285_product_file_id_product_file_variable_idx ON public.poly_stats_12_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_12_279_285_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    4770    235    235    235            �           1259    18225 ?   poly_stats_12_285_38543_product_file_id_product_file_variab_idx    INDEX     �   CREATE INDEX poly_stats_12_285_38543_product_file_id_product_file_variab_idx ON public.poly_stats_12_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_12_285_38543_product_file_id_product_file_variab_idx;
       public         	   statsuser    false    236    236    4770    236            �           1259    18226 ?   poly_stats_14_1_257_product_file_id_product_file_variable_i_idx    INDEX     �   CREATE INDEX poly_stats_14_1_257_product_file_id_product_file_variable_i_idx ON public.poly_stats_14_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_14_1_257_product_file_id_product_file_variable_i_idx;
       public         	   statsuser    false    4770    237    237    237            �           1259    18227 ?   poly_stats_14_257_279_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_14_257_279_product_file_id_product_file_variable_idx ON public.poly_stats_14_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_14_257_279_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    238    238    238    4770            �           1259    18228 ?   poly_stats_14_279_285_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_14_279_285_product_file_id_product_file_variable_idx ON public.poly_stats_14_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_14_279_285_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    239    4770    239    239            �           1259    18229 ?   poly_stats_14_285_38543_product_file_id_product_file_variab_idx    INDEX     �   CREATE INDEX poly_stats_14_285_38543_product_file_id_product_file_variab_idx ON public.poly_stats_14_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_14_285_38543_product_file_id_product_file_variab_idx;
       public         	   statsuser    false    240    240    240    4770            �           1259    18230 ?   poly_stats_16_1_257_product_file_id_product_file_variable_i_idx    INDEX     �   CREATE INDEX poly_stats_16_1_257_product_file_id_product_file_variable_i_idx ON public.poly_stats_16_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_16_1_257_product_file_id_product_file_variable_i_idx;
       public         	   statsuser    false    4770    241    241    241            �           1259    18231 ?   poly_stats_16_257_279_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_16_257_279_product_file_id_product_file_variable_idx ON public.poly_stats_16_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_16_257_279_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    242    4770    242    242            �           1259    18232 ?   poly_stats_16_279_285_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_16_279_285_product_file_id_product_file_variable_idx ON public.poly_stats_16_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_16_279_285_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    4770    243    243    243            �           1259    18233 ?   poly_stats_16_285_38543_product_file_id_product_file_variab_idx    INDEX     �   CREATE INDEX poly_stats_16_285_38543_product_file_id_product_file_variab_idx ON public.poly_stats_16_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_16_285_38543_product_file_id_product_file_variab_idx;
       public         	   statsuser    false    4770    244    244    244            �           1259    18234 ?   poly_stats_17_1_257_product_file_id_product_file_variable_i_idx    INDEX     �   CREATE INDEX poly_stats_17_1_257_product_file_id_product_file_variable_i_idx ON public.poly_stats_17_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_17_1_257_product_file_id_product_file_variable_i_idx;
       public         	   statsuser    false    245    245    4770    245            �           1259    18235 ?   poly_stats_17_257_279_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_17_257_279_product_file_id_product_file_variable_idx ON public.poly_stats_17_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_17_257_279_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    246    246    246    4770            �           1259    18236 ?   poly_stats_17_279_285_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_17_279_285_product_file_id_product_file_variable_idx ON public.poly_stats_17_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_17_279_285_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    247    4770    247    247            �           1259    18237 ?   poly_stats_17_285_38543_product_file_id_product_file_variab_idx    INDEX     �   CREATE INDEX poly_stats_17_285_38543_product_file_id_product_file_variab_idx ON public.poly_stats_17_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_17_285_38543_product_file_id_product_file_variab_idx;
       public         	   statsuser    false    248    248    4770    248            �           1259    18238 ?   poly_stats_19_1_257_product_file_id_product_file_variable_i_idx    INDEX     �   CREATE INDEX poly_stats_19_1_257_product_file_id_product_file_variable_i_idx ON public.poly_stats_19_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_19_1_257_product_file_id_product_file_variable_i_idx;
       public         	   statsuser    false    4770    249    249    249            �           1259    18239 ?   poly_stats_19_257_279_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_19_257_279_product_file_id_product_file_variable_idx ON public.poly_stats_19_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_19_257_279_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    250    250    4770    250            �           1259    18240 ?   poly_stats_19_279_285_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_19_279_285_product_file_id_product_file_variable_idx ON public.poly_stats_19_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_19_279_285_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    251    251    4770    251            �           1259    18241 ?   poly_stats_19_285_38543_product_file_id_product_file_variab_idx    INDEX     �   CREATE INDEX poly_stats_19_285_38543_product_file_id_product_file_variab_idx ON public.poly_stats_19_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_19_285_38543_product_file_id_product_file_variab_idx;
       public         	   statsuser    false    4770    252    252    252            �           1259    18242 ?   poly_stats_1_1_257_product_file_id_product_file_variable_id_idx    INDEX     �   CREATE INDEX poly_stats_1_1_257_product_file_id_product_file_variable_id_idx ON public.poly_stats_1_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_1_1_257_product_file_id_product_file_variable_id_idx;
       public         	   statsuser    false    253    253    253    4770            �           1259    18243 ?   poly_stats_1_257_279_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_1_257_279_product_file_id_product_file_variable__idx ON public.poly_stats_1_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_1_257_279_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    254    254    4770    254            �           1259    18244 ?   poly_stats_1_279_285_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_1_279_285_product_file_id_product_file_variable__idx ON public.poly_stats_1_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_1_279_285_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    4770    255    255    255            �           1259    18245 ?   poly_stats_1_285_38543_product_file_id_product_file_variabl_idx    INDEX     �   CREATE INDEX poly_stats_1_285_38543_product_file_id_product_file_variabl_idx ON public.poly_stats_1_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_1_285_38543_product_file_id_product_file_variabl_idx;
       public         	   statsuser    false    256    256    256    4770            �           1259    18246 ?   poly_stats_21_1_257_product_file_id_product_file_variable_i_idx    INDEX     �   CREATE INDEX poly_stats_21_1_257_product_file_id_product_file_variable_i_idx ON public.poly_stats_21_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_21_1_257_product_file_id_product_file_variable_i_idx;
       public         	   statsuser    false    4770    257    257    257            �           1259    18247 ?   poly_stats_21_257_279_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_21_257_279_product_file_id_product_file_variable_idx ON public.poly_stats_21_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_21_257_279_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    258    258    4770    258            �           1259    18248 ?   poly_stats_21_279_285_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_21_279_285_product_file_id_product_file_variable_idx ON public.poly_stats_21_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_21_279_285_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    259    259    4770    259                       1259    18249 ?   poly_stats_21_285_38543_product_file_id_product_file_variab_idx    INDEX     �   CREATE INDEX poly_stats_21_285_38543_product_file_id_product_file_variab_idx ON public.poly_stats_21_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_21_285_38543_product_file_id_product_file_variab_idx;
       public         	   statsuser    false    260    260    4770    260                       1259    18250 ?   poly_stats_24_1_257_product_file_id_product_file_variable_i_idx    INDEX     �   CREATE INDEX poly_stats_24_1_257_product_file_id_product_file_variable_i_idx ON public.poly_stats_24_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_24_1_257_product_file_id_product_file_variable_i_idx;
       public         	   statsuser    false    4770    261    261    261                       1259    18251 ?   poly_stats_2_1_257_product_file_id_product_file_variable_id_idx    INDEX     �   CREATE INDEX poly_stats_2_1_257_product_file_id_product_file_variable_id_idx ON public.poly_stats_2_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_2_1_257_product_file_id_product_file_variable_id_idx;
       public         	   statsuser    false    262    262    4770    262                       1259    18252 ?   poly_stats_2_257_279_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_2_257_279_product_file_id_product_file_variable__idx ON public.poly_stats_2_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_2_257_279_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    263    263    263    4770                       1259    18253 ?   poly_stats_2_279_285_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_2_279_285_product_file_id_product_file_variable__idx ON public.poly_stats_2_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_2_279_285_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    264    4770    264    264                       1259    18254 ?   poly_stats_2_285_38543_product_file_id_product_file_variabl_idx    INDEX     �   CREATE INDEX poly_stats_2_285_38543_product_file_id_product_file_variabl_idx ON public.poly_stats_2_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_2_285_38543_product_file_id_product_file_variabl_idx;
       public         	   statsuser    false    4770    265    265    265                       1259    18255 ?   poly_stats_3_1_257_product_file_id_product_file_variable_id_idx    INDEX     �   CREATE INDEX poly_stats_3_1_257_product_file_id_product_file_variable_id_idx ON public.poly_stats_3_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_3_1_257_product_file_id_product_file_variable_id_idx;
       public         	   statsuser    false    266    266    4770    266                       1259    18256 ?   poly_stats_3_257_279_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_3_257_279_product_file_id_product_file_variable__idx ON public.poly_stats_3_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_3_257_279_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    267    267    4770    267                       1259    18257 ?   poly_stats_3_279_285_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_3_279_285_product_file_id_product_file_variable__idx ON public.poly_stats_3_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_3_279_285_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    268    4770    268    268                       1259    18258 ?   poly_stats_3_285_38543_product_file_id_product_file_variabl_idx    INDEX     �   CREATE INDEX poly_stats_3_285_38543_product_file_id_product_file_variabl_idx ON public.poly_stats_3_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_3_285_38543_product_file_id_product_file_variabl_idx;
       public         	   statsuser    false    269    269    4770    269                        1259    18259 ?   poly_stats_4_1_257_product_file_id_product_file_variable_id_idx    INDEX     �   CREATE INDEX poly_stats_4_1_257_product_file_id_product_file_variable_id_idx ON public.poly_stats_4_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_4_1_257_product_file_id_product_file_variable_id_idx;
       public         	   statsuser    false    270    270    4770    270            #           1259    18260 ?   poly_stats_4_257_279_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_4_257_279_product_file_id_product_file_variable__idx ON public.poly_stats_4_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_4_257_279_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    271    271    4770    271            &           1259    18261 ?   poly_stats_4_279_285_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_4_279_285_product_file_id_product_file_variable__idx ON public.poly_stats_4_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_4_279_285_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    4770    272    272    272            )           1259    18262 ?   poly_stats_4_285_38543_product_file_id_product_file_variabl_idx    INDEX     �   CREATE INDEX poly_stats_4_285_38543_product_file_id_product_file_variabl_idx ON public.poly_stats_4_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_4_285_38543_product_file_id_product_file_variabl_idx;
       public         	   statsuser    false    273    273    4770    273            ,           1259    18263 ?   poly_stats_5_1_257_product_file_id_product_file_variable_id_idx    INDEX     �   CREATE INDEX poly_stats_5_1_257_product_file_id_product_file_variable_id_idx ON public.poly_stats_5_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_5_1_257_product_file_id_product_file_variable_id_idx;
       public         	   statsuser    false    274    274    274    4770            /           1259    18264 ?   poly_stats_5_257_279_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_5_257_279_product_file_id_product_file_variable__idx ON public.poly_stats_5_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_5_257_279_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    275    4770    275    275            2           1259    18265 ?   poly_stats_5_279_285_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_5_279_285_product_file_id_product_file_variable__idx ON public.poly_stats_5_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_5_279_285_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    276    276    4770    276            5           1259    18266 ?   poly_stats_5_285_38543_product_file_id_product_file_variabl_idx    INDEX     �   CREATE INDEX poly_stats_5_285_38543_product_file_id_product_file_variabl_idx ON public.poly_stats_5_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_5_285_38543_product_file_id_product_file_variabl_idx;
       public         	   statsuser    false    4770    277    277    277            8           1259    18267 ?   poly_stats_6_1_257_product_file_id_product_file_variable_id_idx    INDEX     �   CREATE INDEX poly_stats_6_1_257_product_file_id_product_file_variable_id_idx ON public.poly_stats_6_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_6_1_257_product_file_id_product_file_variable_id_idx;
       public         	   statsuser    false    278    4770    278    278            ;           1259    18268 ?   poly_stats_6_257_279_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_6_257_279_product_file_id_product_file_variable__idx ON public.poly_stats_6_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_6_257_279_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    4770    279    279    279            >           1259    18269 ?   poly_stats_6_279_285_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_6_279_285_product_file_id_product_file_variable__idx ON public.poly_stats_6_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_6_279_285_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    280    4770    280    280            A           1259    18270 ?   poly_stats_6_285_38543_product_file_id_product_file_variabl_idx    INDEX     �   CREATE INDEX poly_stats_6_285_38543_product_file_id_product_file_variabl_idx ON public.poly_stats_6_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_6_285_38543_product_file_id_product_file_variabl_idx;
       public         	   statsuser    false    281    4770    281    281            D           1259    18271 ?   poly_stats_7_1_257_product_file_id_product_file_variable_id_idx    INDEX     �   CREATE INDEX poly_stats_7_1_257_product_file_id_product_file_variable_id_idx ON public.poly_stats_7_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_7_1_257_product_file_id_product_file_variable_id_idx;
       public         	   statsuser    false    4770    282    282    282            G           1259    18272 ?   poly_stats_7_257_279_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_7_257_279_product_file_id_product_file_variable__idx ON public.poly_stats_7_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_7_257_279_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    283    4770    283    283            J           1259    18273 ?   poly_stats_7_279_285_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_7_279_285_product_file_id_product_file_variable__idx ON public.poly_stats_7_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_7_279_285_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    4770    284    284    284            M           1259    18274 ?   poly_stats_7_285_38543_product_file_id_product_file_variabl_idx    INDEX     �   CREATE INDEX poly_stats_7_285_38543_product_file_id_product_file_variabl_idx ON public.poly_stats_7_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_7_285_38543_product_file_id_product_file_variabl_idx;
       public         	   statsuser    false    285    285    4770    285            P           1259    18275 ?   poly_stats_9_1_257_product_file_id_product_file_variable_id_idx    INDEX     �   CREATE INDEX poly_stats_9_1_257_product_file_id_product_file_variable_id_idx ON public.poly_stats_9_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_9_1_257_product_file_id_product_file_variable_id_idx;
       public         	   statsuser    false    4770    286    286    286            S           1259    18276 ?   poly_stats_9_257_279_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_9_257_279_product_file_id_product_file_variable__idx ON public.poly_stats_9_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_9_257_279_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    287    4770    287    287            V           1259    18277 ?   poly_stats_9_279_285_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_9_279_285_product_file_id_product_file_variable__idx ON public.poly_stats_9_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_9_279_285_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    288    4770    288    288            Y           1259    18278 ?   poly_stats_9_285_38543_product_file_id_product_file_variabl_idx    INDEX     �   CREATE INDEX poly_stats_9_285_38543_product_file_id_product_file_variabl_idx ON public.poly_stats_9_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_9_285_38543_product_file_id_product_file_variabl_idx;
       public         	   statsuser    false    289    289    289    4770            \           1259    18279    product_file_date_idx    INDEX     W   CREATE INDEX product_file_date_idx ON public.product_file USING btree (date, rt_flag);
 )   DROP INDEX public.product_file_date_idx;
       public         	   statsuser    false    291    291            e           1259    18280    product_order_email_idx    INDEX     `   CREATE INDEX product_order_email_idx ON public.product_order USING btree (email, date_created);
 +   DROP INDEX public.product_order_email_idx;
       public         	   statsuser    false    299    299            l           1259    18281    sidx_stratification_geom    INDEX     W   CREATE INDEX sidx_stratification_geom ON public.stratification_geom USING gist (geom);
 ,   DROP INDEX public.sidx_stratification_geom;
       public         	   statsuser    false    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    301            m           1259    18282    sidx_stratification_geom3857    INDEX     �   CREATE INDEX sidx_stratification_geom3857 ON public.stratification_geom USING gist (geom3857);

ALTER TABLE public.stratification_geom CLUSTER ON sidx_stratification_geom3857;
 0   DROP INDEX public.sidx_stratification_geom3857;
       public         	   statsuser    false    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    301            x           0    0    poly_stats_10_1_257_pkey    INDEX ATTACH     T   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_10_1_257_pkey;
          public       	   statsuser    false    229    4769    4772    4769    229    228            y           0    0 ?   poly_stats_10_1_257_product_file_id_product_file_variable_i_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_10_1_257_product_file_id_product_file_variable_i_idx;
          public       	   statsuser    false    4773    4770    229    228            z           0    0    poly_stats_10_257_279_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_10_257_279_pkey;
          public       	   statsuser    false    230    4775    4769    4769    230    228            {           0    0 ?   poly_stats_10_257_279_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_10_257_279_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4776    4770    230    228            |           0    0    poly_stats_10_279_285_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_10_279_285_pkey;
          public       	   statsuser    false    4769    4778    231    4769    231    228            }           0    0 ?   poly_stats_10_279_285_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_10_279_285_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4779    4770    231    228            ~           0    0    poly_stats_10_285_38543_pkey    INDEX ATTACH     X   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_10_285_38543_pkey;
          public       	   statsuser    false    4781    4769    232    4769    232    228                       0    0 ?   poly_stats_10_285_38543_product_file_id_product_file_variab_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_10_285_38543_product_file_id_product_file_variab_idx;
          public       	   statsuser    false    4782    4770    232    228            �           0    0    poly_stats_12_1_257_pkey    INDEX ATTACH     T   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_12_1_257_pkey;
          public       	   statsuser    false    233    4784    4769    4769    233    228            �           0    0 ?   poly_stats_12_1_257_product_file_id_product_file_variable_i_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_12_1_257_product_file_id_product_file_variable_i_idx;
          public       	   statsuser    false    4785    4770    233    228            �           0    0    poly_stats_12_257_279_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_12_257_279_pkey;
          public       	   statsuser    false    4769    4787    234    4769    234    228            �           0    0 ?   poly_stats_12_257_279_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_12_257_279_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4788    4770    234    228            �           0    0    poly_stats_12_279_285_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_12_279_285_pkey;
          public       	   statsuser    false    4769    235    4790    4769    235    228            �           0    0 ?   poly_stats_12_279_285_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_12_279_285_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4791    4770    235    228            �           0    0    poly_stats_12_285_38543_pkey    INDEX ATTACH     X   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_12_285_38543_pkey;
          public       	   statsuser    false    236    4769    4793    4769    236    228            �           0    0 ?   poly_stats_12_285_38543_product_file_id_product_file_variab_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_12_285_38543_product_file_id_product_file_variab_idx;
          public       	   statsuser    false    4794    4770    236    228            �           0    0    poly_stats_14_1_257_pkey    INDEX ATTACH     T   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_14_1_257_pkey;
          public       	   statsuser    false    4769    4796    237    4769    237    228            �           0    0 ?   poly_stats_14_1_257_product_file_id_product_file_variable_i_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_14_1_257_product_file_id_product_file_variable_i_idx;
          public       	   statsuser    false    4797    4770    237    228            �           0    0    poly_stats_14_257_279_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_14_257_279_pkey;
          public       	   statsuser    false    238    4769    4799    4769    238    228            �           0    0 ?   poly_stats_14_257_279_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_14_257_279_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4800    4770    238    228            �           0    0    poly_stats_14_279_285_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_14_279_285_pkey;
          public       	   statsuser    false    4802    4769    239    4769    239    228            �           0    0 ?   poly_stats_14_279_285_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_14_279_285_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4803    4770    239    228            �           0    0    poly_stats_14_285_38543_pkey    INDEX ATTACH     X   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_14_285_38543_pkey;
          public       	   statsuser    false    4805    240    4769    4769    240    228            �           0    0 ?   poly_stats_14_285_38543_product_file_id_product_file_variab_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_14_285_38543_product_file_id_product_file_variab_idx;
          public       	   statsuser    false    4806    4770    240    228            �           0    0    poly_stats_16_1_257_pkey    INDEX ATTACH     T   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_16_1_257_pkey;
          public       	   statsuser    false    241    4769    4808    4769    241    228            �           0    0 ?   poly_stats_16_1_257_product_file_id_product_file_variable_i_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_16_1_257_product_file_id_product_file_variable_i_idx;
          public       	   statsuser    false    4809    4770    241    228            �           0    0    poly_stats_16_257_279_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_16_257_279_pkey;
          public       	   statsuser    false    4811    242    4769    4769    242    228            �           0    0 ?   poly_stats_16_257_279_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_16_257_279_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4812    4770    242    228            �           0    0    poly_stats_16_279_285_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_16_279_285_pkey;
          public       	   statsuser    false    4814    243    4769    4769    243    228            �           0    0 ?   poly_stats_16_279_285_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_16_279_285_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4815    4770    243    228            �           0    0    poly_stats_16_285_38543_pkey    INDEX ATTACH     X   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_16_285_38543_pkey;
          public       	   statsuser    false    4769    4817    244    4769    244    228            �           0    0 ?   poly_stats_16_285_38543_product_file_id_product_file_variab_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_16_285_38543_product_file_id_product_file_variab_idx;
          public       	   statsuser    false    4818    4770    244    228            �           0    0    poly_stats_17_1_257_pkey    INDEX ATTACH     T   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_17_1_257_pkey;
          public       	   statsuser    false    4769    4820    245    4769    245    228            �           0    0 ?   poly_stats_17_1_257_product_file_id_product_file_variable_i_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_17_1_257_product_file_id_product_file_variable_i_idx;
          public       	   statsuser    false    4821    4770    245    228            �           0    0    poly_stats_17_257_279_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_17_257_279_pkey;
          public       	   statsuser    false    4823    246    4769    4769    246    228            �           0    0 ?   poly_stats_17_257_279_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_17_257_279_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4824    4770    246    228            �           0    0    poly_stats_17_279_285_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_17_279_285_pkey;
          public       	   statsuser    false    4826    4769    247    4769    247    228            �           0    0 ?   poly_stats_17_279_285_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_17_279_285_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4827    4770    247    228            �           0    0    poly_stats_17_285_38543_pkey    INDEX ATTACH     X   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_17_285_38543_pkey;
          public       	   statsuser    false    248    4769    4829    4769    248    228            �           0    0 ?   poly_stats_17_285_38543_product_file_id_product_file_variab_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_17_285_38543_product_file_id_product_file_variab_idx;
          public       	   statsuser    false    4830    4770    248    228            �           0    0    poly_stats_19_1_257_pkey    INDEX ATTACH     T   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_19_1_257_pkey;
          public       	   statsuser    false    4769    4832    249    4769    249    228            �           0    0 ?   poly_stats_19_1_257_product_file_id_product_file_variable_i_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_19_1_257_product_file_id_product_file_variable_i_idx;
          public       	   statsuser    false    4833    4770    249    228            �           0    0    poly_stats_19_257_279_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_19_257_279_pkey;
          public       	   statsuser    false    250    4835    4769    4769    250    228            �           0    0 ?   poly_stats_19_257_279_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_19_257_279_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4836    4770    250    228            �           0    0    poly_stats_19_279_285_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_19_279_285_pkey;
          public       	   statsuser    false    251    4769    4838    4769    251    228            �           0    0 ?   poly_stats_19_279_285_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_19_279_285_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4839    4770    251    228            �           0    0    poly_stats_19_285_38543_pkey    INDEX ATTACH     X   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_19_285_38543_pkey;
          public       	   statsuser    false    4841    4769    252    4769    252    228            �           0    0 ?   poly_stats_19_285_38543_product_file_id_product_file_variab_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_19_285_38543_product_file_id_product_file_variab_idx;
          public       	   statsuser    false    4842    4770    252    228            �           0    0    poly_stats_1_1_257_pkey    INDEX ATTACH     S   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_1_1_257_pkey;
          public       	   statsuser    false    253    4844    4769    4769    253    228            �           0    0 ?   poly_stats_1_1_257_product_file_id_product_file_variable_id_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_1_1_257_product_file_id_product_file_variable_id_idx;
          public       	   statsuser    false    4845    4770    253    228            �           0    0    poly_stats_1_257_279_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_1_257_279_pkey;
          public       	   statsuser    false    4769    254    4847    4769    254    228            �           0    0 ?   poly_stats_1_257_279_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_1_257_279_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4848    4770    254    228            �           0    0    poly_stats_1_279_285_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_1_279_285_pkey;
          public       	   statsuser    false    4850    4769    255    4769    255    228            �           0    0 ?   poly_stats_1_279_285_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_1_279_285_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4851    4770    255    228            �           0    0    poly_stats_1_285_38543_pkey    INDEX ATTACH     W   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_1_285_38543_pkey;
          public       	   statsuser    false    4853    4769    256    4769    256    228            �           0    0 ?   poly_stats_1_285_38543_product_file_id_product_file_variabl_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_1_285_38543_product_file_id_product_file_variabl_idx;
          public       	   statsuser    false    4854    4770    256    228            �           0    0    poly_stats_21_1_257_pkey    INDEX ATTACH     T   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_21_1_257_pkey;
          public       	   statsuser    false    257    4856    4769    4769    257    228            �           0    0 ?   poly_stats_21_1_257_product_file_id_product_file_variable_i_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_21_1_257_product_file_id_product_file_variable_i_idx;
          public       	   statsuser    false    4857    4770    257    228            �           0    0    poly_stats_21_257_279_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_21_257_279_pkey;
          public       	   statsuser    false    4859    4769    258    4769    258    228            �           0    0 ?   poly_stats_21_257_279_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_21_257_279_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4860    4770    258    228            �           0    0    poly_stats_21_279_285_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_21_279_285_pkey;
          public       	   statsuser    false    259    4862    4769    4769    259    228            �           0    0 ?   poly_stats_21_279_285_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_21_279_285_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4863    4770    259    228            �           0    0    poly_stats_21_285_38543_pkey    INDEX ATTACH     X   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_21_285_38543_pkey;
          public       	   statsuser    false    260    4865    4769    4769    260    228            �           0    0 ?   poly_stats_21_285_38543_product_file_id_product_file_variab_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_21_285_38543_product_file_id_product_file_variab_idx;
          public       	   statsuser    false    4866    4770    260    228            �           0    0    poly_stats_24_1_257_pkey    INDEX ATTACH     T   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_24_1_257_pkey;
          public       	   statsuser    false    4769    261    4868    4769    261    228            �           0    0 ?   poly_stats_24_1_257_product_file_id_product_file_variable_i_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_24_1_257_product_file_id_product_file_variable_i_idx;
          public       	   statsuser    false    4869    4770    261    228            �           0    0    poly_stats_2_1_257_pkey    INDEX ATTACH     S   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_2_1_257_pkey;
          public       	   statsuser    false    4769    4871    262    4769    262    228            �           0    0 ?   poly_stats_2_1_257_product_file_id_product_file_variable_id_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_2_1_257_product_file_id_product_file_variable_id_idx;
          public       	   statsuser    false    4872    4770    262    228            �           0    0    poly_stats_2_257_279_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_2_257_279_pkey;
          public       	   statsuser    false    4874    4769    263    4769    263    228            �           0    0 ?   poly_stats_2_257_279_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_2_257_279_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4875    4770    263    228            �           0    0    poly_stats_2_279_285_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_2_279_285_pkey;
          public       	   statsuser    false    4877    4769    264    4769    264    228            �           0    0 ?   poly_stats_2_279_285_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_2_279_285_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4878    4770    264    228            �           0    0    poly_stats_2_285_38543_pkey    INDEX ATTACH     W   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_2_285_38543_pkey;
          public       	   statsuser    false    4880    265    4769    4769    265    228            �           0    0 ?   poly_stats_2_285_38543_product_file_id_product_file_variabl_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_2_285_38543_product_file_id_product_file_variabl_idx;
          public       	   statsuser    false    4881    4770    265    228            �           0    0    poly_stats_3_1_257_pkey    INDEX ATTACH     S   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_3_1_257_pkey;
          public       	   statsuser    false    4883    4769    266    4769    266    228            �           0    0 ?   poly_stats_3_1_257_product_file_id_product_file_variable_id_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_3_1_257_product_file_id_product_file_variable_id_idx;
          public       	   statsuser    false    4884    4770    266    228            �           0    0    poly_stats_3_257_279_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_3_257_279_pkey;
          public       	   statsuser    false    4769    4886    267    4769    267    228            �           0    0 ?   poly_stats_3_257_279_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_3_257_279_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4887    4770    267    228            �           0    0    poly_stats_3_279_285_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_3_279_285_pkey;
          public       	   statsuser    false    268    4889    4769    4769    268    228            �           0    0 ?   poly_stats_3_279_285_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_3_279_285_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4890    4770    268    228            �           0    0    poly_stats_3_285_38543_pkey    INDEX ATTACH     W   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_3_285_38543_pkey;
          public       	   statsuser    false    269    4892    4769    4769    269    228            �           0    0 ?   poly_stats_3_285_38543_product_file_id_product_file_variabl_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_3_285_38543_product_file_id_product_file_variabl_idx;
          public       	   statsuser    false    4893    4770    269    228            �           0    0    poly_stats_4_1_257_pkey    INDEX ATTACH     S   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_4_1_257_pkey;
          public       	   statsuser    false    270    4895    4769    4769    270    228            �           0    0 ?   poly_stats_4_1_257_product_file_id_product_file_variable_id_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_4_1_257_product_file_id_product_file_variable_id_idx;
          public       	   statsuser    false    4896    4770    270    228            �           0    0    poly_stats_4_257_279_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_4_257_279_pkey;
          public       	   statsuser    false    4769    271    4898    4769    271    228            �           0    0 ?   poly_stats_4_257_279_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_4_257_279_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4899    4770    271    228            �           0    0    poly_stats_4_279_285_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_4_279_285_pkey;
          public       	   statsuser    false    272    4901    4769    4769    272    228            �           0    0 ?   poly_stats_4_279_285_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_4_279_285_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4902    4770    272    228            �           0    0    poly_stats_4_285_38543_pkey    INDEX ATTACH     W   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_4_285_38543_pkey;
          public       	   statsuser    false    4904    273    4769    4769    273    228            �           0    0 ?   poly_stats_4_285_38543_product_file_id_product_file_variabl_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_4_285_38543_product_file_id_product_file_variabl_idx;
          public       	   statsuser    false    4905    4770    273    228            �           0    0    poly_stats_5_1_257_pkey    INDEX ATTACH     S   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_5_1_257_pkey;
          public       	   statsuser    false    4907    4769    274    4769    274    228            �           0    0 ?   poly_stats_5_1_257_product_file_id_product_file_variable_id_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_5_1_257_product_file_id_product_file_variable_id_idx;
          public       	   statsuser    false    4908    4770    274    228            �           0    0    poly_stats_5_257_279_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_5_257_279_pkey;
          public       	   statsuser    false    4910    4769    275    4769    275    228            �           0    0 ?   poly_stats_5_257_279_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_5_257_279_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4911    4770    275    228            �           0    0    poly_stats_5_279_285_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_5_279_285_pkey;
          public       	   statsuser    false    276    4769    4913    4769    276    228            �           0    0 ?   poly_stats_5_279_285_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_5_279_285_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4914    4770    276    228            �           0    0    poly_stats_5_285_38543_pkey    INDEX ATTACH     W   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_5_285_38543_pkey;
          public       	   statsuser    false    277    4769    4916    4769    277    228            �           0    0 ?   poly_stats_5_285_38543_product_file_id_product_file_variabl_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_5_285_38543_product_file_id_product_file_variabl_idx;
          public       	   statsuser    false    4917    4770    277    228            �           0    0    poly_stats_6_1_257_pkey    INDEX ATTACH     S   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_6_1_257_pkey;
          public       	   statsuser    false    4919    278    4769    4769    278    228            �           0    0 ?   poly_stats_6_1_257_product_file_id_product_file_variable_id_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_6_1_257_product_file_id_product_file_variable_id_idx;
          public       	   statsuser    false    4920    4770    278    228            �           0    0    poly_stats_6_257_279_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_6_257_279_pkey;
          public       	   statsuser    false    4769    279    4922    4769    279    228            �           0    0 ?   poly_stats_6_257_279_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_6_257_279_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4923    4770    279    228            �           0    0    poly_stats_6_279_285_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_6_279_285_pkey;
          public       	   statsuser    false    280    4769    4925    4769    280    228            �           0    0 ?   poly_stats_6_279_285_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_6_279_285_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4926    4770    280    228            �           0    0    poly_stats_6_285_38543_pkey    INDEX ATTACH     W   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_6_285_38543_pkey;
          public       	   statsuser    false    4769    281    4928    4769    281    228            �           0    0 ?   poly_stats_6_285_38543_product_file_id_product_file_variabl_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_6_285_38543_product_file_id_product_file_variabl_idx;
          public       	   statsuser    false    4929    4770    281    228            �           0    0    poly_stats_7_1_257_pkey    INDEX ATTACH     S   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_7_1_257_pkey;
          public       	   statsuser    false    4769    282    4931    4769    282    228            �           0    0 ?   poly_stats_7_1_257_product_file_id_product_file_variable_id_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_7_1_257_product_file_id_product_file_variable_id_idx;
          public       	   statsuser    false    4932    4770    282    228            �           0    0    poly_stats_7_257_279_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_7_257_279_pkey;
          public       	   statsuser    false    4769    4934    283    4769    283    228            �           0    0 ?   poly_stats_7_257_279_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_7_257_279_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4935    4770    283    228            �           0    0    poly_stats_7_279_285_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_7_279_285_pkey;
          public       	   statsuser    false    284    4769    4937    4769    284    228            �           0    0 ?   poly_stats_7_279_285_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_7_279_285_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4938    4770    284    228            �           0    0    poly_stats_7_285_38543_pkey    INDEX ATTACH     W   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_7_285_38543_pkey;
          public       	   statsuser    false    285    4769    4940    4769    285    228            �           0    0 ?   poly_stats_7_285_38543_product_file_id_product_file_variabl_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_7_285_38543_product_file_id_product_file_variabl_idx;
          public       	   statsuser    false    4941    4770    285    228            �           0    0    poly_stats_9_1_257_pkey    INDEX ATTACH     S   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_9_1_257_pkey;
          public       	   statsuser    false    286    4769    4943    4769    286    228            �           0    0 ?   poly_stats_9_1_257_product_file_id_product_file_variable_id_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_9_1_257_product_file_id_product_file_variable_id_idx;
          public       	   statsuser    false    4944    4770    286    228            �           0    0    poly_stats_9_257_279_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_9_257_279_pkey;
          public       	   statsuser    false    287    4769    4946    4769    287    228            �           0    0 ?   poly_stats_9_257_279_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_9_257_279_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4947    4770    287    228            �           0    0    poly_stats_9_279_285_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_9_279_285_pkey;
          public       	   statsuser    false    4769    4949    288    4769    288    228            �           0    0 ?   poly_stats_9_279_285_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_9_279_285_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4950    4770    288    228            �           0    0    poly_stats_9_285_38543_pkey    INDEX ATTACH     W   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_9_285_38543_pkey;
          public       	   statsuser    false    4769    289    4952    4769    289    228            �           0    0 ?   poly_stats_9_285_38543_product_file_id_product_file_variabl_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_9_285_38543_product_file_id_product_file_variabl_idx;
          public       	   statsuser    false    4953    4770    289    228            �           2606    18283 0   long_term_anomaly_info long_term_anomaly_info_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.long_term_anomaly_info
    ADD CONSTRAINT long_term_anomaly_info_fk FOREIGN KEY (anomaly_product_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 Z   ALTER TABLE ONLY public.long_term_anomaly_info DROP CONSTRAINT long_term_anomaly_info_fk;
       public       	   statsuser    false    4964    225    296            �           2606    18288 2   long_term_anomaly_info long_term_anomaly_info_fk_1    FK CONSTRAINT     �   ALTER TABLE ONLY public.long_term_anomaly_info
    ADD CONSTRAINT long_term_anomaly_info_fk_1 FOREIGN KEY (mean_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 \   ALTER TABLE ONLY public.long_term_anomaly_info DROP CONSTRAINT long_term_anomaly_info_fk_1;
       public       	   statsuser    false    225    296    4964            �           2606    18293 2   long_term_anomaly_info long_term_anomaly_info_fk_2    FK CONSTRAINT     �   ALTER TABLE ONLY public.long_term_anomaly_info
    ADD CONSTRAINT long_term_anomaly_info_fk_2 FOREIGN KEY (stdev_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 \   ALTER TABLE ONLY public.long_term_anomaly_info DROP CONSTRAINT long_term_anomaly_info_fk_2;
       public       	   statsuser    false    296    4964    225            �           2606    18298 2   long_term_anomaly_info long_term_anomaly_info_fk_3    FK CONSTRAINT     �   ALTER TABLE ONLY public.long_term_anomaly_info
    ADD CONSTRAINT long_term_anomaly_info_fk_3 FOREIGN KEY (raw_product_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 \   ALTER TABLE ONLY public.long_term_anomaly_info DROP CONSTRAINT long_term_anomaly_info_fk_3;
       public       	   statsuser    false    296    225    4964            �           2606    18303 &   poly_stats poly_stats_product_file_fk_    FK CONSTRAINT     �   ALTER TABLE public.poly_stats
    ADD CONSTRAINT poly_stats_product_file_fk_ FOREIGN KEY (product_file_id) REFERENCES public.product_file(id) ON UPDATE CASCADE ON DELETE CASCADE;
 K   ALTER TABLE public.poly_stats DROP CONSTRAINT poly_stats_product_file_fk_;
       public       	   statsuser    false    228    4960    291            �           2606    18491 *   poly_stats poly_stats_product_variable_fk_    FK CONSTRAINT     �   ALTER TABLE public.poly_stats
    ADD CONSTRAINT poly_stats_product_variable_fk_ FOREIGN KEY (product_file_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 O   ALTER TABLE public.poly_stats DROP CONSTRAINT poly_stats_product_variable_fk_;
       public       	   statsuser    false    296    228    4964            �           2606    18679 -   poly_stats poly_stats_stratification_geom_fk_    FK CONSTRAINT     �   ALTER TABLE public.poly_stats
    ADD CONSTRAINT poly_stats_stratification_geom_fk_ FOREIGN KEY (poly_id) REFERENCES public.stratification_geom(id) ON UPDATE CASCADE ON DELETE CASCADE;
 R   ALTER TABLE public.poly_stats DROP CONSTRAINT poly_stats_stratification_geom_fk_;
       public       	   statsuser    false    4975    301    228            �           2606    18867 4   product_file_description product_file_description_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.product_file_description
    ADD CONSTRAINT product_file_description_fk FOREIGN KEY (product_id) REFERENCES public.product(id) ON UPDATE CASCADE ON DELETE CASCADE;
 ^   ALTER TABLE ONLY public.product_file_description DROP CONSTRAINT product_file_description_fk;
       public       	   statsuser    false    292    4955    290            �           2606    18872    product product_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_fk FOREIGN KEY (category_id) REFERENCES public.category(id) ON UPDATE CASCADE ON DELETE CASCADE;
 <   ALTER TABLE ONLY public.product DROP CONSTRAINT product_fk;
       public       	   statsuser    false    4765    290    223            �           2606    18877 *   stratification_geom stratification_geom_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.stratification_geom
    ADD CONSTRAINT stratification_geom_fk FOREIGN KEY (stratification_id) REFERENCES public.stratification(id) ON DELETE CASCADE;
 T   ALTER TABLE ONLY public.stratification_geom DROP CONSTRAINT stratification_geom_fk;
       public       	   statsuser    false    300    4969    301            �           2606    18882    wms_file wms_file_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.wms_file
    ADD CONSTRAINT wms_file_fk FOREIGN KEY (product_file_id) REFERENCES public.product_file(id) ON UPDATE CASCADE ON DELETE CASCADE;
 >   ALTER TABLE ONLY public.wms_file DROP CONSTRAINT wms_file_fk;
       public       	   statsuser    false    4960    291    305            �           2606    18887    wms_file wms_file_fk2    FK CONSTRAINT     �   ALTER TABLE ONLY public.wms_file
    ADD CONSTRAINT wms_file_fk2 FOREIGN KEY (product_file_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 ?   ALTER TABLE ONLY public.wms_file DROP CONSTRAINT wms_file_fk2;
       public       	   statsuser    false    4964    305    296            �           2606    18892 0   poly_stats_per_region poly_stats_product_file_fk    FK CONSTRAINT     �   ALTER TABLE ONLY tmp.poly_stats_per_region
    ADD CONSTRAINT poly_stats_product_file_fk FOREIGN KEY (product_file_id) REFERENCES public.product_file(id) ON UPDATE CASCADE ON DELETE CASCADE;
 W   ALTER TABLE ONLY tmp.poly_stats_per_region DROP CONSTRAINT poly_stats_product_file_fk;
       tmp       	   statsuser    false    291    4960    307            �           2606    18897 9   poly_stats_per_region poly_stats_product_file_variable_fk    FK CONSTRAINT     �   ALTER TABLE ONLY tmp.poly_stats_per_region
    ADD CONSTRAINT poly_stats_product_file_variable_fk FOREIGN KEY (product_file_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 `   ALTER TABLE ONLY tmp.poly_stats_per_region DROP CONSTRAINT poly_stats_product_file_variable_fk;
       tmp       	   statsuser    false    4964    296    307                        2606    18902 7   poly_stats_per_region poly_stats_stratification_geom_fk    FK CONSTRAINT     �   ALTER TABLE ONLY tmp.poly_stats_per_region
    ADD CONSTRAINT poly_stats_stratification_geom_fk FOREIGN KEY (poly_id) REFERENCES public.stratification_geom(id) ON UPDATE CASCADE ON DELETE CASCADE;
 ^   ALTER TABLE ONLY tmp.poly_stats_per_region DROP CONSTRAINT poly_stats_stratification_geom_fk;
       tmp       	   statsuser    false    301    4975    307           