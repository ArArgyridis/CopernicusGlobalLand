PGDMP  (        
        
    |            jrcstats    16.3    16.3 �    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            �           1262    67380    jrcstats    DATABASE     p   CREATE DATABASE jrcstats WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'C.UTF-8';
    DROP DATABASE jrcstats;
                postgres    false            �           0    0    SCHEMA pg_catalog    ACL     -   GRANT ALL ON SCHEMA pg_catalog TO statsuser;
                   postgres    false    5            �           0    0    SCHEMA public    ACL     )   GRANT ALL ON SCHEMA public TO statsuser;
                   pg_database_owner    false    8                        2615    67381    tmp    SCHEMA        CREATE SCHEMA tmp;
    DROP SCHEMA tmp;
                postgres    false            �           0    0 
   SCHEMA tmp    ACL     &   GRANT ALL ON SCHEMA tmp TO statsuser;
                   postgres    false    4                        3079    67382    fuzzystrmatch 	   EXTENSION     A   CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;
    DROP EXTENSION fuzzystrmatch;
                   false            �           0    0    EXTENSION fuzzystrmatch    COMMENT     ]   COMMENT ON EXTENSION fuzzystrmatch IS 'determine similarities and distance between strings';
                        false    2                        3079    67394    postgis 	   EXTENSION     ;   CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;
    DROP EXTENSION postgis;
                   false            �           0    0    EXTENSION postgis    COMMENT     ^   COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';
                        false    3            �           1255    68470    clms_updatepolygonstats()    FUNCTION     �  CREATE FUNCTION public.clms_updatepolygonstats() RETURNS smallint
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
       public          postgres    false            �           0    0    TABLE pg_aggregate    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_aggregate TO statsuser;
       
   pg_catalog          postgres    false    24            �           0    0    TABLE pg_am    ACL     2   GRANT ALL ON TABLE pg_catalog.pg_am TO statsuser;
       
   pg_catalog          postgres    false    25            �           0    0    TABLE pg_amop    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_amop TO statsuser;
       
   pg_catalog          postgres    false    26            �           0    0    TABLE pg_amproc    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_amproc TO statsuser;
       
   pg_catalog          postgres    false    27            �           0    0    TABLE pg_attrdef    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_attrdef TO statsuser;
       
   pg_catalog          postgres    false    28            �           0    0    TABLE pg_attribute    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_attribute TO statsuser;
       
   pg_catalog          postgres    false    13            �           0    0    TABLE pg_auth_members    ACL     <   GRANT ALL ON TABLE pg_catalog.pg_auth_members TO statsuser;
       
   pg_catalog          postgres    false    17            �           0    0    TABLE pg_authid    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_authid TO statsuser;
       
   pg_catalog          postgres    false    16            �           0    0 %   TABLE pg_available_extension_versions    ACL     L   GRANT ALL ON TABLE pg_catalog.pg_available_extension_versions TO statsuser;
       
   pg_catalog          postgres    false    91            �           0    0    TABLE pg_available_extensions    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_available_extensions TO statsuser;
       
   pg_catalog          postgres    false    90            �           0    0     TABLE pg_backend_memory_contexts    ACL     G   GRANT ALL ON TABLE pg_catalog.pg_backend_memory_contexts TO statsuser;
       
   pg_catalog          postgres    false    103            �           0    0    TABLE pg_cast    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_cast TO statsuser;
       
   pg_catalog          postgres    false    29            �           0    0    TABLE pg_class    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_class TO statsuser;
       
   pg_catalog          postgres    false    15            �           0    0    TABLE pg_collation    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_collation TO statsuser;
       
   pg_catalog          postgres    false    54            �           0    0    TABLE pg_config    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_config TO statsuser;
       
   pg_catalog          postgres    false    101            �           0    0    TABLE pg_constraint    ACL     :   GRANT ALL ON TABLE pg_catalog.pg_constraint TO statsuser;
       
   pg_catalog          postgres    false    30            �           0    0    TABLE pg_conversion    ACL     :   GRANT ALL ON TABLE pg_catalog.pg_conversion TO statsuser;
       
   pg_catalog          postgres    false    31            �           0    0    TABLE pg_cursors    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_cursors TO statsuser;
       
   pg_catalog          postgres    false    89            �           0    0    TABLE pg_database    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_database TO statsuser;
       
   pg_catalog          postgres    false    18            �           0    0    TABLE pg_db_role_setting    ACL     ?   GRANT ALL ON TABLE pg_catalog.pg_db_role_setting TO statsuser;
       
   pg_catalog          postgres    false    45            �           0    0    TABLE pg_default_acl    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_default_acl TO statsuser;
       
   pg_catalog          postgres    false    9            �           0    0    TABLE pg_depend    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_depend TO statsuser;
       
   pg_catalog          postgres    false    32            �           0    0    TABLE pg_description    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_description TO statsuser;
       
   pg_catalog          postgres    false    33            �           0    0    TABLE pg_enum    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_enum TO statsuser;
       
   pg_catalog          postgres    false    56            �           0    0    TABLE pg_event_trigger    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_event_trigger TO statsuser;
       
   pg_catalog          postgres    false    55            �           0    0    TABLE pg_extension    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_extension TO statsuser;
       
   pg_catalog          postgres    false    47            �           0    0    TABLE pg_file_settings    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_file_settings TO statsuser;
       
   pg_catalog          postgres    false    96            �           0    0    TABLE pg_foreign_data_wrapper    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_foreign_data_wrapper TO statsuser;
       
   pg_catalog          postgres    false    22            �           0    0    TABLE pg_foreign_server    ACL     >   GRANT ALL ON TABLE pg_catalog.pg_foreign_server TO statsuser;
       
   pg_catalog          postgres    false    19            �           0    0    TABLE pg_foreign_table    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_foreign_table TO statsuser;
       
   pg_catalog          postgres    false    48            �           0    0    TABLE pg_group    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_group TO statsuser;
       
   pg_catalog          postgres    false    75            �           0    0    TABLE pg_hba_file_rules    ACL     >   GRANT ALL ON TABLE pg_catalog.pg_hba_file_rules TO statsuser;
       
   pg_catalog          postgres    false    97            �           0    0    TABLE pg_ident_file_mappings    ACL     C   GRANT ALL ON TABLE pg_catalog.pg_ident_file_mappings TO statsuser;
       
   pg_catalog          postgres    false    98            �           0    0    TABLE pg_index    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_index TO statsuser;
       
   pg_catalog          postgres    false    34            �           0    0    TABLE pg_indexes    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_indexes TO statsuser;
       
   pg_catalog          postgres    false    82            �           0    0    TABLE pg_inherits    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_inherits TO statsuser;
       
   pg_catalog          postgres    false    35            �           0    0    TABLE pg_init_privs    ACL     :   GRANT ALL ON TABLE pg_catalog.pg_init_privs TO statsuser;
       
   pg_catalog          postgres    false    52            �           0    0    TABLE pg_language    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_language TO statsuser;
       
   pg_catalog          postgres    false    36            �           0    0    TABLE pg_largeobject    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_largeobject TO statsuser;
       
   pg_catalog          postgres    false    37            �           0    0    TABLE pg_largeobject_metadata    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_largeobject_metadata TO statsuser;
       
   pg_catalog          postgres    false    46            �           0    0    TABLE pg_locks    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_locks TO statsuser;
       
   pg_catalog          postgres    false    88            �           0    0    TABLE pg_matviews    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_matviews TO statsuser;
       
   pg_catalog          postgres    false    81            �           0    0    TABLE pg_namespace    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_namespace TO statsuser;
       
   pg_catalog          postgres    false    38            �           0    0    TABLE pg_opclass    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_opclass TO statsuser;
       
   pg_catalog          postgres    false    39            �           0    0    TABLE pg_operator    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_operator TO statsuser;
       
   pg_catalog          postgres    false    40            �           0    0    TABLE pg_opfamily    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_opfamily TO statsuser;
       
   pg_catalog          postgres    false    44            �           0    0    TABLE pg_parameter_acl    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_parameter_acl TO statsuser;
       
   pg_catalog          postgres    false    72            �           0    0    TABLE pg_partitioned_table    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_partitioned_table TO statsuser;
       
   pg_catalog          postgres    false    50            �           0    0    TABLE pg_policies    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_policies TO statsuser;
       
   pg_catalog          postgres    false    77            �           0    0    TABLE pg_policy    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_policy TO statsuser;
       
   pg_catalog          postgres    false    49            �           0    0    TABLE pg_prepared_statements    ACL     C   GRANT ALL ON TABLE pg_catalog.pg_prepared_statements TO statsuser;
       
   pg_catalog          postgres    false    93            �           0    0    TABLE pg_prepared_xacts    ACL     >   GRANT ALL ON TABLE pg_catalog.pg_prepared_xacts TO statsuser;
       
   pg_catalog          postgres    false    92            �           0    0    TABLE pg_proc    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_proc TO statsuser;
       
   pg_catalog          postgres    false    14            �           0    0    TABLE pg_publication    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_publication TO statsuser;
       
   pg_catalog          postgres    false    69            �           0    0    TABLE pg_publication_namespace    ACL     E   GRANT ALL ON TABLE pg_catalog.pg_publication_namespace TO statsuser;
       
   pg_catalog          postgres    false    71            �           0    0    TABLE pg_publication_rel    ACL     ?   GRANT ALL ON TABLE pg_catalog.pg_publication_rel TO statsuser;
       
   pg_catalog          postgres    false    70            �           0    0    TABLE pg_publication_tables    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_publication_tables TO statsuser;
       
   pg_catalog          postgres    false    87            �           0    0    TABLE pg_range    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_range TO statsuser;
       
   pg_catalog          postgres    false    57            �           0    0    TABLE pg_replication_origin    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_replication_origin TO statsuser;
       
   pg_catalog          postgres    false    66            �           0    0 "   TABLE pg_replication_origin_status    ACL     I   GRANT ALL ON TABLE pg_catalog.pg_replication_origin_status TO statsuser;
       
   pg_catalog          postgres    false    147            �           0    0    TABLE pg_replication_slots    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_replication_slots TO statsuser;
       
   pg_catalog          postgres    false    130            �           0    0    TABLE pg_rewrite    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_rewrite TO statsuser;
       
   pg_catalog          postgres    false    41            �           0    0    TABLE pg_roles    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_roles TO statsuser;
       
   pg_catalog          postgres    false    73            �           0    0    TABLE pg_rules    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_rules TO statsuser;
       
   pg_catalog          postgres    false    78            �           0    0    TABLE pg_seclabel    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_seclabel TO statsuser;
       
   pg_catalog          postgres    false    60            �           0    0    TABLE pg_seclabels    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_seclabels TO statsuser;
       
   pg_catalog          postgres    false    94            �           0    0    TABLE pg_sequence    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_sequence TO statsuser;
       
   pg_catalog          postgres    false    21            �           0    0    TABLE pg_sequences    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_sequences TO statsuser;
       
   pg_catalog          postgres    false    83            �           0    0    TABLE pg_settings    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_settings TO statsuser;
       
   pg_catalog          postgres    false    95            �           0    0    TABLE pg_shadow    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_shadow TO statsuser;
       
   pg_catalog          postgres    false    74            �           0    0    TABLE pg_shdepend    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_shdepend TO statsuser;
       
   pg_catalog          postgres    false    11            �           0    0    TABLE pg_shdescription    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_shdescription TO statsuser;
       
   pg_catalog          postgres    false    23            �           0    0    TABLE pg_shmem_allocations    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_shmem_allocations TO statsuser;
       
   pg_catalog          postgres    false    102            �           0    0    TABLE pg_shseclabel    ACL     :   GRANT ALL ON TABLE pg_catalog.pg_shseclabel TO statsuser;
       
   pg_catalog          postgres    false    59            �           0    0    TABLE pg_stat_activity    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_stat_activity TO statsuser;
       
   pg_catalog          postgres    false    122            �           0    0    TABLE pg_stat_all_indexes    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_stat_all_indexes TO statsuser;
       
   pg_catalog          postgres    false    113            �           0    0    TABLE pg_stat_all_tables    ACL     ?   GRANT ALL ON TABLE pg_catalog.pg_stat_all_tables TO statsuser;
       
   pg_catalog          postgres    false    104            �           0    0    TABLE pg_stat_archiver    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_stat_archiver TO statsuser;
       
   pg_catalog          postgres    false    136            �           0    0    TABLE pg_stat_bgwriter    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_stat_bgwriter TO statsuser;
       
   pg_catalog          postgres    false    137            �           0    0    TABLE pg_stat_database    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_stat_database TO statsuser;
       
   pg_catalog          postgres    false    132            �           0    0     TABLE pg_stat_database_conflicts    ACL     G   GRANT ALL ON TABLE pg_catalog.pg_stat_database_conflicts TO statsuser;
       
   pg_catalog          postgres    false    133            �           0    0    TABLE pg_stat_gssapi    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_stat_gssapi TO statsuser;
       
   pg_catalog          postgres    false    129            �           0    0    TABLE pg_stat_io    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_stat_io TO statsuser;
       
   pg_catalog          postgres    false    138            �           0    0    TABLE pg_stat_progress_analyze    ACL     E   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_analyze TO statsuser;
       
   pg_catalog          postgres    false    140            �           0    0 !   TABLE pg_stat_progress_basebackup    ACL     H   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_basebackup TO statsuser;
       
   pg_catalog          postgres    false    144            �           0    0    TABLE pg_stat_progress_cluster    ACL     E   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_cluster TO statsuser;
       
   pg_catalog          postgres    false    142            �           0    0    TABLE pg_stat_progress_copy    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_copy TO statsuser;
       
   pg_catalog          postgres    false    145            �           0    0 #   TABLE pg_stat_progress_create_index    ACL     J   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_create_index TO statsuser;
       
   pg_catalog          postgres    false    143            �           0    0    TABLE pg_stat_progress_vacuum    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_vacuum TO statsuser;
       
   pg_catalog          postgres    false    141            �           0    0    TABLE pg_stat_recovery_prefetch    ACL     F   GRANT ALL ON TABLE pg_catalog.pg_stat_recovery_prefetch TO statsuser;
       
   pg_catalog          postgres    false    126            �           0    0    TABLE pg_stat_replication    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_stat_replication TO statsuser;
       
   pg_catalog          postgres    false    123            �           0    0    TABLE pg_stat_replication_slots    ACL     F   GRANT ALL ON TABLE pg_catalog.pg_stat_replication_slots TO statsuser;
       
   pg_catalog          postgres    false    131            �           0    0    TABLE pg_stat_slru    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_stat_slru TO statsuser;
       
   pg_catalog          postgres    false    124            �           0    0    TABLE pg_stat_ssl    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_stat_ssl TO statsuser;
       
   pg_catalog          postgres    false    128            �           0    0    TABLE pg_stat_subscription    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_stat_subscription TO statsuser;
       
   pg_catalog          postgres    false    127            �           0    0     TABLE pg_stat_subscription_stats    ACL     G   GRANT ALL ON TABLE pg_catalog.pg_stat_subscription_stats TO statsuser;
       
   pg_catalog          postgres    false    148            �           0    0    TABLE pg_stat_sys_indexes    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_stat_sys_indexes TO statsuser;
       
   pg_catalog          postgres    false    114            �           0    0    TABLE pg_stat_sys_tables    ACL     ?   GRANT ALL ON TABLE pg_catalog.pg_stat_sys_tables TO statsuser;
       
   pg_catalog          postgres    false    106            �           0    0    TABLE pg_stat_user_functions    ACL     C   GRANT ALL ON TABLE pg_catalog.pg_stat_user_functions TO statsuser;
       
   pg_catalog          postgres    false    134            �           0    0    TABLE pg_stat_user_indexes    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_stat_user_indexes TO statsuser;
       
   pg_catalog          postgres    false    115            �           0    0    TABLE pg_stat_user_tables    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_stat_user_tables TO statsuser;
       
   pg_catalog          postgres    false    108            �           0    0    TABLE pg_stat_wal    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_stat_wal TO statsuser;
       
   pg_catalog          postgres    false    139            �           0    0    TABLE pg_stat_wal_receiver    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_stat_wal_receiver TO statsuser;
       
   pg_catalog          postgres    false    125            �           0    0    TABLE pg_stat_xact_all_tables    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_stat_xact_all_tables TO statsuser;
       
   pg_catalog          postgres    false    105            �           0    0    TABLE pg_stat_xact_sys_tables    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_stat_xact_sys_tables TO statsuser;
       
   pg_catalog          postgres    false    107            �           0    0 !   TABLE pg_stat_xact_user_functions    ACL     H   GRANT ALL ON TABLE pg_catalog.pg_stat_xact_user_functions TO statsuser;
       
   pg_catalog          postgres    false    135            �           0    0    TABLE pg_stat_xact_user_tables    ACL     E   GRANT ALL ON TABLE pg_catalog.pg_stat_xact_user_tables TO statsuser;
       
   pg_catalog          postgres    false    109            �           0    0    TABLE pg_statio_all_indexes    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_statio_all_indexes TO statsuser;
       
   pg_catalog          postgres    false    116            �           0    0    TABLE pg_statio_all_sequences    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_statio_all_sequences TO statsuser;
       
   pg_catalog          postgres    false    119            �           0    0    TABLE pg_statio_all_tables    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_statio_all_tables TO statsuser;
       
   pg_catalog          postgres    false    110            �           0    0    TABLE pg_statio_sys_indexes    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_statio_sys_indexes TO statsuser;
       
   pg_catalog          postgres    false    117            �           0    0    TABLE pg_statio_sys_sequences    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_statio_sys_sequences TO statsuser;
       
   pg_catalog          postgres    false    120            �           0    0    TABLE pg_statio_sys_tables    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_statio_sys_tables TO statsuser;
       
   pg_catalog          postgres    false    111            �           0    0    TABLE pg_statio_user_indexes    ACL     C   GRANT ALL ON TABLE pg_catalog.pg_statio_user_indexes TO statsuser;
       
   pg_catalog          postgres    false    118            �           0    0    TABLE pg_statio_user_sequences    ACL     E   GRANT ALL ON TABLE pg_catalog.pg_statio_user_sequences TO statsuser;
       
   pg_catalog          postgres    false    121                        0    0    TABLE pg_statio_user_tables    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_statio_user_tables TO statsuser;
       
   pg_catalog          postgres    false    112                       0    0    TABLE pg_statistic    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_statistic TO statsuser;
       
   pg_catalog          postgres    false    42                       0    0    TABLE pg_statistic_ext    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_statistic_ext TO statsuser;
       
   pg_catalog          postgres    false    51                       0    0    TABLE pg_statistic_ext_data    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_statistic_ext_data TO statsuser;
       
   pg_catalog          postgres    false    53                       0    0    TABLE pg_stats    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_stats TO statsuser;
       
   pg_catalog          postgres    false    84                       0    0    TABLE pg_stats_ext    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_stats_ext TO statsuser;
       
   pg_catalog          postgres    false    85                       0    0    TABLE pg_stats_ext_exprs    ACL     ?   GRANT ALL ON TABLE pg_catalog.pg_stats_ext_exprs TO statsuser;
       
   pg_catalog          postgres    false    86                       0    0    TABLE pg_subscription    ACL     <   GRANT ALL ON TABLE pg_catalog.pg_subscription TO statsuser;
       
   pg_catalog          postgres    false    67                       0    0    TABLE pg_subscription_rel    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_subscription_rel TO statsuser;
       
   pg_catalog          postgres    false    68            	           0    0    TABLE pg_tables    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_tables TO statsuser;
       
   pg_catalog          postgres    false    80            
           0    0    TABLE pg_tablespace    ACL     :   GRANT ALL ON TABLE pg_catalog.pg_tablespace TO statsuser;
       
   pg_catalog          postgres    false    10                       0    0    TABLE pg_timezone_abbrevs    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_timezone_abbrevs TO statsuser;
       
   pg_catalog          postgres    false    99                       0    0    TABLE pg_timezone_names    ACL     >   GRANT ALL ON TABLE pg_catalog.pg_timezone_names TO statsuser;
       
   pg_catalog          postgres    false    100                       0    0    TABLE pg_transform    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_transform TO statsuser;
       
   pg_catalog          postgres    false    58                       0    0    TABLE pg_trigger    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_trigger TO statsuser;
       
   pg_catalog          postgres    false    43                       0    0    TABLE pg_ts_config    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_ts_config TO statsuser;
       
   pg_catalog          postgres    false    63                       0    0    TABLE pg_ts_config_map    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_ts_config_map TO statsuser;
       
   pg_catalog          postgres    false    64                       0    0    TABLE pg_ts_dict    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_ts_dict TO statsuser;
       
   pg_catalog          postgres    false    61                       0    0    TABLE pg_ts_parser    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_ts_parser TO statsuser;
       
   pg_catalog          postgres    false    62                       0    0    TABLE pg_ts_template    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_ts_template TO statsuser;
       
   pg_catalog          postgres    false    65                       0    0    TABLE pg_type    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_type TO statsuser;
       
   pg_catalog          postgres    false    12                       0    0    TABLE pg_user    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_user TO statsuser;
       
   pg_catalog          postgres    false    76                       0    0    TABLE pg_user_mapping    ACL     <   GRANT ALL ON TABLE pg_catalog.pg_user_mapping TO statsuser;
       
   pg_catalog          postgres    false    20                       0    0    TABLE pg_user_mappings    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_user_mappings TO statsuser;
       
   pg_catalog          postgres    false    146                       0    0    TABLE pg_views    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_views TO statsuser;
       
   pg_catalog          postgres    false    79            �            1259    68471    category    TABLE     }   CREATE TABLE public.category (
    id bigint NOT NULL,
    title text NOT NULL,
    active boolean DEFAULT false NOT NULL
);
    DROP TABLE public.category;
       public         heap 	   statsuser    false            �            1259    68477    category_id_seq    SEQUENCE     �   ALTER TABLE public.category ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.category_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   statsuser    false    223                       0    0    TABLE geography_columns    ACL     :   GRANT ALL ON TABLE public.geography_columns TO statsuser;
          public          postgres    false    221                       0    0    TABLE geometry_columns    ACL     9   GRANT ALL ON TABLE public.geometry_columns TO statsuser;
          public          postgres    false    222            �            1259    68478    global_land_cover_2019    TABLE     �   CREATE TABLE public.global_land_cover_2019 (
    id integer NOT NULL,
    geom public.geometry(Polygon,4326),
    fid bigint,
    "DN" integer
);
 *   DROP TABLE public.global_land_cover_2019;
       public         heap 	   statsuser    false    3    3    3    3    3    3    3    3            �            1259    68483    global_land_cover_2019_id_seq    SEQUENCE     �   CREATE SEQUENCE public.global_land_cover_2019_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 4   DROP SEQUENCE public.global_land_cover_2019_id_seq;
       public       	   statsuser    false    225                       0    0    global_land_cover_2019_id_seq    SEQUENCE OWNED BY     _   ALTER SEQUENCE public.global_land_cover_2019_id_seq OWNED BY public.global_land_cover_2019.id;
          public       	   statsuser    false    226            �            1259    68484    long_term_anomaly_info    TABLE     �   CREATE TABLE public.long_term_anomaly_info (
    id bigint NOT NULL,
    anomaly_product_variable_id bigint NOT NULL,
    mean_variable_id bigint NOT NULL,
    stdev_variable_id bigint NOT NULL,
    raw_product_variable_id bigint NOT NULL
);
 *   DROP TABLE public.long_term_anomaly_info;
       public         heap 	   statsuser    false            �            1259    68487    long_term_anomaly_info_id_seq    SEQUENCE     �   CREATE SEQUENCE public.long_term_anomaly_info_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 4   DROP SEQUENCE public.long_term_anomaly_info_id_seq;
       public       	   statsuser    false    227                       0    0    long_term_anomaly_info_id_seq    SEQUENCE OWNED BY     _   ALTER SEQUENCE public.long_term_anomaly_info_id_seq OWNED BY public.long_term_anomaly_info.id;
          public       	   statsuser    false    228            �            1259    68488    output_product_id_seq    SEQUENCE     ~   CREATE SEQUENCE public.output_product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE public.output_product_id_seq;
       public       	   statsuser    false            �            1259    68489 
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
       public         	   statsuser    false            �            1259    68495    product    TABLE     �   CREATE TABLE public.product (
    id bigint NOT NULL,
    name text[] NOT NULL,
    type text DEFAULT 'raw'::text NOT NULL,
    category_id bigint,
    description text
);
    DROP TABLE public.product;
       public         heap 	   statsuser    false            �            1259    68501    product_file    TABLE     +  CREATE TABLE public.product_file (
    id bigint NOT NULL,
    product_file_description_id bigint NOT NULL,
    rel_file_path text NOT NULL,
    rt_flag smallint,
    date timestamp without time zone NOT NULL,
    date_created timestamp without time zone DEFAULT (now() AT TIME ZONE 'UTC'::text)
);
     DROP TABLE public.product_file;
       public         heap 	   statsuser    false            �            1259    68759    product_file_description    TABLE       CREATE TABLE public.product_file_description (
    id bigint NOT NULL,
    product_id bigint,
    pattern text[] NOT NULL,
    types text NOT NULL,
    create_date text NOT NULL,
    file_name_creation_pattern text,
    rt_flag_pattern text,
    satellite_system_pattern text
);
 ,   DROP TABLE public.product_file_description;
       public         heap 	   statsuser    false            �            1259    68758    product_file_description_id_seq    SEQUENCE     �   CREATE SEQUENCE public.product_file_description_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 6   DROP SEQUENCE public.product_file_description_id_seq;
       public       	   statsuser    false    248                       0    0    product_file_description_id_seq    SEQUENCE OWNED BY     c   ALTER SEQUENCE public.product_file_description_id_seq OWNED BY public.product_file_description.id;
          public       	   statsuser    false    247            �            1259    68513    product_file_id_seq    SEQUENCE     |   CREATE SEQUENCE public.product_file_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.product_file_id_seq;
       public       	   statsuser    false            �            1259    68514    product_file_id_seq1    SEQUENCE     }   CREATE SEQUENCE public.product_file_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.product_file_id_seq1;
       public       	   statsuser    false    232                       0    0    product_file_id_seq1    SEQUENCE OWNED BY     L   ALTER SEQUENCE public.product_file_id_seq1 OWNED BY public.product_file.id;
          public       	   statsuser    false    234            �            1259    68515    product_file_variable    TABLE     <  CREATE TABLE public.product_file_variable (
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
       public         heap 	   statsuser    false            �            1259    68521    product_file_variable_id_seq    SEQUENCE     �   CREATE SEQUENCE public.product_file_variable_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 3   DROP SEQUENCE public.product_file_variable_id_seq;
       public       	   statsuser    false    235                       0    0    product_file_variable_id_seq    SEQUENCE OWNED BY     ]   ALTER SEQUENCE public.product_file_variable_id_seq OWNED BY public.product_file_variable.id;
          public       	   statsuser    false    236            �            1259    68522    product_id_seq    SEQUENCE     w   CREATE SEQUENCE public.product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public.product_id_seq;
       public       	   statsuser    false    231                        0    0    product_id_seq    SEQUENCE OWNED BY     A   ALTER SEQUENCE public.product_id_seq OWNED BY public.product.id;
          public       	   statsuser    false    237            �            1259    68523    product_order    TABLE     /  CREATE TABLE public.product_order (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    email text,
    aoi public.geometry(MultiPolygon,3857),
    request_data jsonb,
    date_created timestamp without time zone DEFAULT (now() AT TIME ZONE 'UTC'::text),
    processed boolean DEFAULT false NOT NULL
);
 !   DROP TABLE public.product_order;
       public         heap 	   statsuser    false    3    3    3    3    3    3    3    3            !           0    0    TABLE spatial_ref_sys    ACL     8   GRANT ALL ON TABLE public.spatial_ref_sys TO statsuser;
          public          postgres    false    219            �            1259    68531    stratification    TABLE     m   CREATE TABLE public.stratification (
    id bigint NOT NULL,
    description text,
    tilelayer_url text
);
 "   DROP TABLE public.stratification;
       public         heap 	   statsuser    false            �            1259    68536    stratification_geom    TABLE     �   CREATE TABLE public.stratification_geom (
    id bigint NOT NULL,
    stratification_id bigint NOT NULL,
    geom public.geometry(MultiPolygon,4326),
    geom3857 public.geometry(MultiPolygon,3857),
    description text
);
 '   DROP TABLE public.stratification_geom;
       public         heap 	   statsuser    false    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3            �            1259    68541    stratification_geom_id_seq    SEQUENCE     �   CREATE SEQUENCE public.stratification_geom_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE public.stratification_geom_id_seq;
       public       	   statsuser    false    240            "           0    0    stratification_geom_id_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE public.stratification_geom_id_seq OWNED BY public.stratification_geom.id;
          public       	   statsuser    false    241            �            1259    68542    stratification_id_seq    SEQUENCE     ~   CREATE SEQUENCE public.stratification_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE public.stratification_id_seq;
       public       	   statsuser    false    239            #           0    0    stratification_id_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE public.stratification_id_seq OWNED BY public.stratification.id;
          public       	   statsuser    false    242            �            1259    68548    wms_file    TABLE     �   CREATE TABLE public.wms_file (
    id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint,
    rel_file_path text
);
    DROP TABLE public.wms_file;
       public         heap 	   statsuser    false            �            1259    68553    wms_file_id_seq    SEQUENCE     x   CREATE SEQUENCE public.wms_file_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.wms_file_id_seq;
       public       	   statsuser    false    243            $           0    0    wms_file_id_seq    SEQUENCE OWNED BY     C   ALTER SEQUENCE public.wms_file_id_seq OWNED BY public.wms_file.id;
          public       	   statsuser    false    244            �            1259    68554    poly_stats_per_region    TABLE     �  CREATE TABLE tmp.poly_stats_per_region (
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
       tmp         heap 	   statsuser    false    4            �            1259    68562    poly_stats_per_region_id_seq    SEQUENCE     �   CREATE SEQUENCE tmp.poly_stats_per_region_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE tmp.poly_stats_per_region_id_seq;
       tmp       	   statsuser    false    4    245            %           0    0    poly_stats_per_region_id_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE tmp.poly_stats_per_region_id_seq OWNED BY tmp.poly_stats_per_region.id;
          tmp       	   statsuser    false    246            �           2604    68563    global_land_cover_2019 id    DEFAULT     �   ALTER TABLE ONLY public.global_land_cover_2019 ALTER COLUMN id SET DEFAULT nextval('public.global_land_cover_2019_id_seq'::regclass);
 H   ALTER TABLE public.global_land_cover_2019 ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    226    225            �           2604    68564    long_term_anomaly_info id    DEFAULT     �   ALTER TABLE ONLY public.long_term_anomaly_info ALTER COLUMN id SET DEFAULT nextval('public.long_term_anomaly_info_id_seq'::regclass);
 H   ALTER TABLE public.long_term_anomaly_info ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    228    227            �           2604    68565 
   product id    DEFAULT     h   ALTER TABLE ONLY public.product ALTER COLUMN id SET DEFAULT nextval('public.product_id_seq'::regclass);
 9   ALTER TABLE public.product ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    237    231            �           2604    68566    product_file id    DEFAULT     s   ALTER TABLE ONLY public.product_file ALTER COLUMN id SET DEFAULT nextval('public.product_file_id_seq1'::regclass);
 >   ALTER TABLE public.product_file ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    234    232            �           2604    68762    product_file_description id    DEFAULT     �   ALTER TABLE ONLY public.product_file_description ALTER COLUMN id SET DEFAULT nextval('public.product_file_description_id_seq'::regclass);
 J   ALTER TABLE public.product_file_description ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    247    248    248            �           2604    68568    product_file_variable id    DEFAULT     �   ALTER TABLE ONLY public.product_file_variable ALTER COLUMN id SET DEFAULT nextval('public.product_file_variable_id_seq'::regclass);
 G   ALTER TABLE public.product_file_variable ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    236    235            �           2604    68569    stratification id    DEFAULT     v   ALTER TABLE ONLY public.stratification ALTER COLUMN id SET DEFAULT nextval('public.stratification_id_seq'::regclass);
 @   ALTER TABLE public.stratification ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    242    239            �           2604    68570    stratification_geom id    DEFAULT     �   ALTER TABLE ONLY public.stratification_geom ALTER COLUMN id SET DEFAULT nextval('public.stratification_geom_id_seq'::regclass);
 E   ALTER TABLE public.stratification_geom ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    241    240            �           2604    68571    wms_file id    DEFAULT     j   ALTER TABLE ONLY public.wms_file ALTER COLUMN id SET DEFAULT nextval('public.wms_file_id_seq'::regclass);
 :   ALTER TABLE public.wms_file ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    244    243            �           2604    68572    poly_stats_per_region id    DEFAULT     ~   ALTER TABLE ONLY tmp.poly_stats_per_region ALTER COLUMN id SET DEFAULT nextval('tmp.poly_stats_per_region_id_seq'::regclass);
 D   ALTER TABLE tmp.poly_stats_per_region ALTER COLUMN id DROP DEFAULT;
       tmp       	   statsuser    false    246    245            �           2606    68574 2   global_land_cover_2019 global_land_cover_2019_pkey 
   CONSTRAINT     p   ALTER TABLE ONLY public.global_land_cover_2019
    ADD CONSTRAINT global_land_cover_2019_pkey PRIMARY KEY (id);
 \   ALTER TABLE ONLY public.global_land_cover_2019 DROP CONSTRAINT global_land_cover_2019_pkey;
       public         	   statsuser    false    225            �           2606    68576 0   long_term_anomaly_info long_term_anomaly_info_pk 
   CONSTRAINT     n   ALTER TABLE ONLY public.long_term_anomaly_info
    ADD CONSTRAINT long_term_anomaly_info_pk PRIMARY KEY (id);
 Z   ALTER TABLE ONLY public.long_term_anomaly_info DROP CONSTRAINT long_term_anomaly_info_pk;
       public         	   statsuser    false    227            �           2606    68578    category newtable_pk 
   CONSTRAINT     R   ALTER TABLE ONLY public.category
    ADD CONSTRAINT newtable_pk PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.category DROP CONSTRAINT newtable_pk;
       public         	   statsuser    false    223            �           2606    68580    poly_stats poly_stats_pk_ 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats
    ADD CONSTRAINT poly_stats_pk_ PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 C   ALTER TABLE ONLY public.poly_stats DROP CONSTRAINT poly_stats_pk_;
       public         	   statsuser    false    230    230    230            �           2606    68582 6   product_file product_file_date_product_description_idx 
   CONSTRAINT     �   ALTER TABLE ONLY public.product_file
    ADD CONSTRAINT product_file_date_product_description_idx UNIQUE (product_file_description_id, date, rt_flag);
 `   ALTER TABLE ONLY public.product_file DROP CONSTRAINT product_file_date_product_description_idx;
       public         	   statsuser    false    232    232    232            �           2606    68584    product_file product_file_pk 
   CONSTRAINT     Z   ALTER TABLE ONLY public.product_file
    ADD CONSTRAINT product_file_pk PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.product_file DROP CONSTRAINT product_file_pk;
       public         	   statsuser    false    232            �           2606    68586 .   product_file_variable product_file_variable_pk 
   CONSTRAINT     l   ALTER TABLE ONLY public.product_file_variable
    ADD CONSTRAINT product_file_variable_pk PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.product_file_variable DROP CONSTRAINT product_file_variable_pk;
       public         	   statsuser    false    235            �           2606    68588    product_order product_order_pk 
   CONSTRAINT     \   ALTER TABLE ONLY public.product_order
    ADD CONSTRAINT product_order_pk PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.product_order DROP CONSTRAINT product_order_pk;
       public         	   statsuser    false    238            �           2606    68590    product product_pk1 
   CONSTRAINT     Q   ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_pk1 PRIMARY KEY (id);
 =   ALTER TABLE ONLY public.product DROP CONSTRAINT product_pk1;
       public         	   statsuser    false    231            �           2606    68766 <   product_file_description product_product_file_description_pk 
   CONSTRAINT     z   ALTER TABLE ONLY public.product_file_description
    ADD CONSTRAINT product_product_file_description_pk PRIMARY KEY (id);
 f   ALTER TABLE ONLY public.product_file_description DROP CONSTRAINT product_product_file_description_pk;
       public         	   statsuser    false    248            �           2606    68594     stratification stratification_pk 
   CONSTRAINT     ^   ALTER TABLE ONLY public.stratification
    ADD CONSTRAINT stratification_pk PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.stratification DROP CONSTRAINT stratification_pk;
       public         	   statsuser    false    239            �           2606    68596 '   stratification_geom stratification_pkey 
   CONSTRAINT     e   ALTER TABLE ONLY public.stratification_geom
    ADD CONSTRAINT stratification_pkey PRIMARY KEY (id);
 Q   ALTER TABLE ONLY public.stratification_geom DROP CONSTRAINT stratification_pkey;
       public         	   statsuser    false    240            �           2606    68598     stratification stratification_un 
   CONSTRAINT     b   ALTER TABLE ONLY public.stratification
    ADD CONSTRAINT stratification_un UNIQUE (description);
 J   ALTER TABLE ONLY public.stratification DROP CONSTRAINT stratification_un;
       public         	   statsuser    false    239            �           2606    68600    wms_file wms_file_pk 
   CONSTRAINT     R   ALTER TABLE ONLY public.wms_file
    ADD CONSTRAINT wms_file_pk PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.wms_file DROP CONSTRAINT wms_file_pk;
       public         	   statsuser    false    243            �           2606    68602    wms_file wms_file_un 
   CONSTRAINT     t   ALTER TABLE ONLY public.wms_file
    ADD CONSTRAINT wms_file_un UNIQUE (product_file_id, product_file_variable_id);
 >   ALTER TABLE ONLY public.wms_file DROP CONSTRAINT wms_file_un;
       public         	   statsuser    false    243    243            �           2606    68604 #   poly_stats_per_region poly_stats_pk 
   CONSTRAINT     ^   ALTER TABLE ONLY tmp.poly_stats_per_region
    ADD CONSTRAINT poly_stats_pk PRIMARY KEY (id);
 J   ALTER TABLE ONLY tmp.poly_stats_per_region DROP CONSTRAINT poly_stats_pk;
       tmp         	   statsuser    false    245            �           2606    68606 #   poly_stats_per_region poly_stats_un 
   CONSTRAINT     �   ALTER TABLE ONLY tmp.poly_stats_per_region
    ADD CONSTRAINT poly_stats_un UNIQUE (poly_id, product_file_id, product_file_variable_id, region_id);
 J   ALTER TABLE ONLY tmp.poly_stats_per_region DROP CONSTRAINT poly_stats_un;
       tmp         	   statsuser    false    245    245    245    245            �           1259    68607    poly_stats_product_file_id_idx    INDEX        CREATE INDEX poly_stats_product_file_id_idx ON ONLY public.poly_stats USING btree (product_file_id, product_file_variable_id);
 2   DROP INDEX public.poly_stats_product_file_id_idx;
       public         	   statsuser    false    230    230            �           1259    68608    poly_stats_valid_pixels_idx    INDEX     _   CREATE INDEX poly_stats_valid_pixels_idx ON ONLY public.poly_stats USING btree (valid_pixels);
 /   DROP INDEX public.poly_stats_valid_pixels_idx;
       public         	   statsuser    false    230            �           1259    68609    product_file_date_idx    INDEX     W   CREATE INDEX product_file_date_idx ON public.product_file USING btree (date, rt_flag);
 )   DROP INDEX public.product_file_date_idx;
       public         	   statsuser    false    232    232            �           1259    68610    product_order_email_idx    INDEX     `   CREATE INDEX product_order_email_idx ON public.product_order USING btree (email, date_created);
 +   DROP INDEX public.product_order_email_idx;
       public         	   statsuser    false    238    238            �           1259    68611    sidx_stratification_geom    INDEX     W   CREATE INDEX sidx_stratification_geom ON public.stratification_geom USING gist (geom);
 ,   DROP INDEX public.sidx_stratification_geom;
       public         	   statsuser    false    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    240            �           1259    68612    sidx_stratification_geom3857    INDEX     �   CREATE INDEX sidx_stratification_geom3857 ON public.stratification_geom USING gist (geom3857);

ALTER TABLE public.stratification_geom CLUSTER ON sidx_stratification_geom3857;
 0   DROP INDEX public.sidx_stratification_geom3857;
       public         	   statsuser    false    240    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3            �           2606    68613 0   long_term_anomaly_info long_term_anomaly_info_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.long_term_anomaly_info
    ADD CONSTRAINT long_term_anomaly_info_fk FOREIGN KEY (anomaly_product_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 Z   ALTER TABLE ONLY public.long_term_anomaly_info DROP CONSTRAINT long_term_anomaly_info_fk;
       public       	   statsuser    false    235    4296    227            �           2606    68618 2   long_term_anomaly_info long_term_anomaly_info_fk_1    FK CONSTRAINT     �   ALTER TABLE ONLY public.long_term_anomaly_info
    ADD CONSTRAINT long_term_anomaly_info_fk_1 FOREIGN KEY (mean_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 \   ALTER TABLE ONLY public.long_term_anomaly_info DROP CONSTRAINT long_term_anomaly_info_fk_1;
       public       	   statsuser    false    4296    235    227            �           2606    68623 2   long_term_anomaly_info long_term_anomaly_info_fk_2    FK CONSTRAINT     �   ALTER TABLE ONLY public.long_term_anomaly_info
    ADD CONSTRAINT long_term_anomaly_info_fk_2 FOREIGN KEY (stdev_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 \   ALTER TABLE ONLY public.long_term_anomaly_info DROP CONSTRAINT long_term_anomaly_info_fk_2;
       public       	   statsuser    false    4296    227    235            �           2606    68628 2   long_term_anomaly_info long_term_anomaly_info_fk_3    FK CONSTRAINT     �   ALTER TABLE ONLY public.long_term_anomaly_info
    ADD CONSTRAINT long_term_anomaly_info_fk_3 FOREIGN KEY (raw_product_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 \   ALTER TABLE ONLY public.long_term_anomaly_info DROP CONSTRAINT long_term_anomaly_info_fk_3;
       public       	   statsuser    false    4296    235    227            �           2606    68633 &   poly_stats poly_stats_product_file_fk_    FK CONSTRAINT     �   ALTER TABLE public.poly_stats
    ADD CONSTRAINT poly_stats_product_file_fk_ FOREIGN KEY (product_file_id) REFERENCES public.product_file(id) ON UPDATE CASCADE ON DELETE CASCADE;
 K   ALTER TABLE public.poly_stats DROP CONSTRAINT poly_stats_product_file_fk_;
       public       	   statsuser    false    232    4294    230            �           2606    68638 *   poly_stats poly_stats_product_variable_fk_    FK CONSTRAINT     �   ALTER TABLE public.poly_stats
    ADD CONSTRAINT poly_stats_product_variable_fk_ FOREIGN KEY (product_file_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 O   ALTER TABLE public.poly_stats DROP CONSTRAINT poly_stats_product_variable_fk_;
       public       	   statsuser    false    235    4296    230            �           2606    68643 -   poly_stats poly_stats_stratification_geom_fk_    FK CONSTRAINT     �   ALTER TABLE public.poly_stats
    ADD CONSTRAINT poly_stats_stratification_geom_fk_ FOREIGN KEY (poly_id) REFERENCES public.stratification_geom(id) ON UPDATE CASCADE ON DELETE CASCADE;
 R   ALTER TABLE public.poly_stats DROP CONSTRAINT poly_stats_stratification_geom_fk_;
       public       	   statsuser    false    230    240    4307            �           2606    68767 4   product_file_description product_file_description_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.product_file_description
    ADD CONSTRAINT product_file_description_fk FOREIGN KEY (product_id) REFERENCES public.product(id) ON UPDATE CASCADE ON DELETE CASCADE;
 ^   ALTER TABLE ONLY public.product_file_description DROP CONSTRAINT product_file_description_fk;
       public       	   statsuser    false    248    231    4289            �           2606    68772 5   product_file product_file_product_file_description_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.product_file
    ADD CONSTRAINT product_file_product_file_description_fk FOREIGN KEY (product_file_description_id) REFERENCES public.product_file_description(id) ON UPDATE CASCADE ON DELETE CASCADE;
 _   ALTER TABLE ONLY public.product_file DROP CONSTRAINT product_file_product_file_description_fk;
       public       	   statsuser    false    232    4317    248            �           2606    68658    product product_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_fk FOREIGN KEY (category_id) REFERENCES public.category(id) ON UPDATE CASCADE ON DELETE CASCADE;
 <   ALTER TABLE ONLY public.product DROP CONSTRAINT product_fk;
       public       	   statsuser    false    231    223    4279            �           2606    68663 *   stratification_geom stratification_geom_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.stratification_geom
    ADD CONSTRAINT stratification_geom_fk FOREIGN KEY (stratification_id) REFERENCES public.stratification(id) ON DELETE CASCADE;
 T   ALTER TABLE ONLY public.stratification_geom DROP CONSTRAINT stratification_geom_fk;
       public       	   statsuser    false    4301    239    240            �           2606    68668    wms_file wms_file_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.wms_file
    ADD CONSTRAINT wms_file_fk FOREIGN KEY (product_file_id) REFERENCES public.product_file(id) ON UPDATE CASCADE ON DELETE CASCADE;
 >   ALTER TABLE ONLY public.wms_file DROP CONSTRAINT wms_file_fk;
       public       	   statsuser    false    243    232    4294            �           2606    68673    wms_file wms_file_fk2    FK CONSTRAINT     �   ALTER TABLE ONLY public.wms_file
    ADD CONSTRAINT wms_file_fk2 FOREIGN KEY (product_file_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 ?   ALTER TABLE ONLY public.wms_file DROP CONSTRAINT wms_file_fk2;
       public       	   statsuser    false    243    4296    235            �           2606    68678 0   poly_stats_per_region poly_stats_product_file_fk    FK CONSTRAINT     �   ALTER TABLE ONLY tmp.poly_stats_per_region
    ADD CONSTRAINT poly_stats_product_file_fk FOREIGN KEY (product_file_id) REFERENCES public.product_file(id) ON UPDATE CASCADE ON DELETE CASCADE;
 W   ALTER TABLE ONLY tmp.poly_stats_per_region DROP CONSTRAINT poly_stats_product_file_fk;
       tmp       	   statsuser    false    4294    232    245            �           2606    68683 9   poly_stats_per_region poly_stats_product_file_variable_fk    FK CONSTRAINT     �   ALTER TABLE ONLY tmp.poly_stats_per_region
    ADD CONSTRAINT poly_stats_product_file_variable_fk FOREIGN KEY (product_file_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 `   ALTER TABLE ONLY tmp.poly_stats_per_region DROP CONSTRAINT poly_stats_product_file_variable_fk;
       tmp       	   statsuser    false    245    235    4296            �           2606    68688 7   poly_stats_per_region poly_stats_stratification_geom_fk    FK CONSTRAINT     �   ALTER TABLE ONLY tmp.poly_stats_per_region
    ADD CONSTRAINT poly_stats_stratification_geom_fk FOREIGN KEY (poly_id) REFERENCES public.stratification_geom(id) ON UPDATE CASCADE ON DELETE CASCADE;
 ^   ALTER TABLE ONLY tmp.poly_stats_per_region DROP CONSTRAINT poly_stats_stratification_geom_fk;
       tmp       	   statsuser    false    240    245    4307            �    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            �           1262    67380    jrcstats    DATABASE     p   CREATE DATABASE jrcstats WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'C.UTF-8';
    DROP DATABASE jrcstats;
                postgres    false            �           0    0    SCHEMA pg_catalog    ACL     -   GRANT ALL ON SCHEMA pg_catalog TO statsuser;
                   postgres    false    5            �           0    0    SCHEMA public    ACL     )   GRANT ALL ON SCHEMA public TO statsuser;
                   pg_database_owner    false    8                        2615    67381    tmp    SCHEMA        CREATE SCHEMA tmp;
    DROP SCHEMA tmp;
                postgres    false            �           0    0 
   SCHEMA tmp    ACL     &   GRANT ALL ON SCHEMA tmp TO statsuser;
                   postgres    false    4                        3079    67382    fuzzystrmatch 	   EXTENSION     A   CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;
    DROP EXTENSION fuzzystrmatch;
                   false            �           0    0    EXTENSION fuzzystrmatch    COMMENT     ]   COMMENT ON EXTENSION fuzzystrmatch IS 'determine similarities and distance between strings';
                        false    2                        3079    67394    postgis 	   EXTENSION     ;   CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;
    DROP EXTENSION postgis;
                   false            �           0    0    EXTENSION postgis    COMMENT     ^   COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';
                        false    3            �           1255    68470    clms_updatepolygonstats()    FUNCTION     �  CREATE FUNCTION public.clms_updatepolygonstats() RETURNS smallint
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
       public          postgres    false            �           0    0    TABLE pg_aggregate    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_aggregate TO statsuser;
       
   pg_catalog          postgres    false    24            �           0    0    TABLE pg_am    ACL     2   GRANT ALL ON TABLE pg_catalog.pg_am TO statsuser;
       
   pg_catalog          postgres    false    25            �           0    0    TABLE pg_amop    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_amop TO statsuser;
       
   pg_catalog          postgres    false    26            �           0    0    TABLE pg_amproc    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_amproc TO statsuser;
       
   pg_catalog          postgres    false    27            �           0    0    TABLE pg_attrdef    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_attrdef TO statsuser;
       
   pg_catalog          postgres    false    28            �           0    0    TABLE pg_attribute    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_attribute TO statsuser;
       
   pg_catalog          postgres    false    13            �           0    0    TABLE pg_auth_members    ACL     <   GRANT ALL ON TABLE pg_catalog.pg_auth_members TO statsuser;
       
   pg_catalog          postgres    false    17            �           0    0    TABLE pg_authid    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_authid TO statsuser;
       
   pg_catalog          postgres    false    16            �           0    0 %   TABLE pg_available_extension_versions    ACL     L   GRANT ALL ON TABLE pg_catalog.pg_available_extension_versions TO statsuser;
       
   pg_catalog          postgres    false    91            �           0    0    TABLE pg_available_extensions    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_available_extensions TO statsuser;
       
   pg_catalog          postgres    false    90            �           0    0     TABLE pg_backend_memory_contexts    ACL     G   GRANT ALL ON TABLE pg_catalog.pg_backend_memory_contexts TO statsuser;
       
   pg_catalog          postgres    false    103            �           0    0    TABLE pg_cast    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_cast TO statsuser;
       
   pg_catalog          postgres    false    29            �           0    0    TABLE pg_class    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_class TO statsuser;
       
   pg_catalog          postgres    false    15            �           0    0    TABLE pg_collation    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_collation TO statsuser;
       
   pg_catalog          postgres    false    54            �           0    0    TABLE pg_config    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_config TO statsuser;
       
   pg_catalog          postgres    false    101            �           0    0    TABLE pg_constraint    ACL     :   GRANT ALL ON TABLE pg_catalog.pg_constraint TO statsuser;
       
   pg_catalog          postgres    false    30            �           0    0    TABLE pg_conversion    ACL     :   GRANT ALL ON TABLE pg_catalog.pg_conversion TO statsuser;
       
   pg_catalog          postgres    false    31            �           0    0    TABLE pg_cursors    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_cursors TO statsuser;
       
   pg_catalog          postgres    false    89            �           0    0    TABLE pg_database    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_database TO statsuser;
       
   pg_catalog          postgres    false    18            �           0    0    TABLE pg_db_role_setting    ACL     ?   GRANT ALL ON TABLE pg_catalog.pg_db_role_setting TO statsuser;
       
   pg_catalog          postgres    false    45            �           0    0    TABLE pg_default_acl    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_default_acl TO statsuser;
       
   pg_catalog          postgres    false    9            �           0    0    TABLE pg_depend    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_depend TO statsuser;
       
   pg_catalog          postgres    false    32            �           0    0    TABLE pg_description    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_description TO statsuser;
       
   pg_catalog          postgres    false    33            �           0    0    TABLE pg_enum    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_enum TO statsuser;
       
   pg_catalog          postgres    false    56            �           0    0    TABLE pg_event_trigger    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_event_trigger TO statsuser;
       
   pg_catalog          postgres    false    55            �           0    0    TABLE pg_extension    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_extension TO statsuser;
       
   pg_catalog          postgres    false    47            �           0    0    TABLE pg_file_settings    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_file_settings TO statsuser;
       
   pg_catalog          postgres    false    96            �           0    0    TABLE pg_foreign_data_wrapper    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_foreign_data_wrapper TO statsuser;
       
   pg_catalog          postgres    false    22            �           0    0    TABLE pg_foreign_server    ACL     >   GRANT ALL ON TABLE pg_catalog.pg_foreign_server TO statsuser;
       
   pg_catalog          postgres    false    19            �           0    0    TABLE pg_foreign_table    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_foreign_table TO statsuser;
       
   pg_catalog          postgres    false    48            �           0    0    TABLE pg_group    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_group TO statsuser;
       
   pg_catalog          postgres    false    75            �           0    0    TABLE pg_hba_file_rules    ACL     >   GRANT ALL ON TABLE pg_catalog.pg_hba_file_rules TO statsuser;
       
   pg_catalog          postgres    false    97            �           0    0    TABLE pg_ident_file_mappings    ACL     C   GRANT ALL ON TABLE pg_catalog.pg_ident_file_mappings TO statsuser;
       
   pg_catalog          postgres    false    98            �           0    0    TABLE pg_index    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_index TO statsuser;
       
   pg_catalog          postgres    false    34            �           0    0    TABLE pg_indexes    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_indexes TO statsuser;
       
   pg_catalog          postgres    false    82            �           0    0    TABLE pg_inherits    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_inherits TO statsuser;
       
   pg_catalog          postgres    false    35            �           0    0    TABLE pg_init_privs    ACL     :   GRANT ALL ON TABLE pg_catalog.pg_init_privs TO statsuser;
       
   pg_catalog          postgres    false    52            �           0    0    TABLE pg_language    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_language TO statsuser;
       
   pg_catalog          postgres    false    36            �           0    0    TABLE pg_largeobject    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_largeobject TO statsuser;
       
   pg_catalog          postgres    false    37            �           0    0    TABLE pg_largeobject_metadata    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_largeobject_metadata TO statsuser;
       
   pg_catalog          postgres    false    46            �           0    0    TABLE pg_locks    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_locks TO statsuser;
       
   pg_catalog          postgres    false    88            �           0    0    TABLE pg_matviews    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_matviews TO statsuser;
       
   pg_catalog          postgres    false    81            �           0    0    TABLE pg_namespace    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_namespace TO statsuser;
       
   pg_catalog          postgres    false    38            �           0    0    TABLE pg_opclass    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_opclass TO statsuser;
       
   pg_catalog          postgres    false    39            �           0    0    TABLE pg_operator    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_operator TO statsuser;
       
   pg_catalog          postgres    false    40            �           0    0    TABLE pg_opfamily    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_opfamily TO statsuser;
       
   pg_catalog          postgres    false    44            �           0    0    TABLE pg_parameter_acl    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_parameter_acl TO statsuser;
       
   pg_catalog          postgres    false    72            �           0    0    TABLE pg_partitioned_table    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_partitioned_table TO statsuser;
       
   pg_catalog          postgres    false    50            �           0    0    TABLE pg_policies    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_policies TO statsuser;
       
   pg_catalog          postgres    false    77            �           0    0    TABLE pg_policy    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_policy TO statsuser;
       
   pg_catalog          postgres    false    49            �           0    0    TABLE pg_prepared_statements    ACL     C   GRANT ALL ON TABLE pg_catalog.pg_prepared_statements TO statsuser;
       
   pg_catalog          postgres    false    93            �           0    0    TABLE pg_prepared_xacts    ACL     >   GRANT ALL ON TABLE pg_catalog.pg_prepared_xacts TO statsuser;
       
   pg_catalog          postgres    false    92            �           0    0    TABLE pg_proc    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_proc TO statsuser;
       
   pg_catalog          postgres    false    14            �           0    0    TABLE pg_publication    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_publication TO statsuser;
       
   pg_catalog          postgres    false    69            �           0    0    TABLE pg_publication_namespace    ACL     E   GRANT ALL ON TABLE pg_catalog.pg_publication_namespace TO statsuser;
       
   pg_catalog          postgres    false    71            �           0    0    TABLE pg_publication_rel    ACL     ?   GRANT ALL ON TABLE pg_catalog.pg_publication_rel TO statsuser;
       
   pg_catalog          postgres    false    70            �           0    0    TABLE pg_publication_tables    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_publication_tables TO statsuser;
       
   pg_catalog          postgres    false    87            �           0    0    TABLE pg_range    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_range TO statsuser;
       
   pg_catalog          postgres    false    57            �           0    0    TABLE pg_replication_origin    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_replication_origin TO statsuser;
       
   pg_catalog          postgres    false    66            �           0    0 "   TABLE pg_replication_origin_status    ACL     I   GRANT ALL ON TABLE pg_catalog.pg_replication_origin_status TO statsuser;
       
   pg_catalog          postgres    false    147            �           0    0    TABLE pg_replication_slots    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_replication_slots TO statsuser;
       
   pg_catalog          postgres    false    130            �           0    0    TABLE pg_rewrite    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_rewrite TO statsuser;
       
   pg_catalog          postgres    false    41            �           0    0    TABLE pg_roles    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_roles TO statsuser;
       
   pg_catalog          postgres    false    73            �           0    0    TABLE pg_rules    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_rules TO statsuser;
       
   pg_catalog          postgres    false    78            �           0    0    TABLE pg_seclabel    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_seclabel TO statsuser;
       
   pg_catalog          postgres    false    60            �           0    0    TABLE pg_seclabels    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_seclabels TO statsuser;
       
   pg_catalog          postgres    false    94            �           0    0    TABLE pg_sequence    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_sequence TO statsuser;
       
   pg_catalog          postgres    false    21            �           0    0    TABLE pg_sequences    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_sequences TO statsuser;
       
   pg_catalog          postgres    false    83            �           0    0    TABLE pg_settings    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_settings TO statsuser;
       
   pg_catalog          postgres    false    95            �           0    0    TABLE pg_shadow    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_shadow TO statsuser;
       
   pg_catalog          postgres    false    74            �           0    0    TABLE pg_shdepend    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_shdepend TO statsuser;
       
   pg_catalog          postgres    false    11            �           0    0    TABLE pg_shdescription    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_shdescription TO statsuser;
       
   pg_catalog          postgres    false    23            �           0    0    TABLE pg_shmem_allocations    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_shmem_allocations TO statsuser;
       
   pg_catalog          postgres    false    102            �           0    0    TABLE pg_shseclabel    ACL     :   GRANT ALL ON TABLE pg_catalog.pg_shseclabel TO statsuser;
       
   pg_catalog          postgres    false    59            �           0    0    TABLE pg_stat_activity    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_stat_activity TO statsuser;
       
   pg_catalog          postgres    false    122            �           0    0    TABLE pg_stat_all_indexes    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_stat_all_indexes TO statsuser;
       
   pg_catalog          postgres    false    113            �           0    0    TABLE pg_stat_all_tables    ACL     ?   GRANT ALL ON TABLE pg_catalog.pg_stat_all_tables TO statsuser;
       
   pg_catalog          postgres    false    104            �           0    0    TABLE pg_stat_archiver    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_stat_archiver TO statsuser;
       
   pg_catalog          postgres    false    136            �           0    0    TABLE pg_stat_bgwriter    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_stat_bgwriter TO statsuser;
       
   pg_catalog          postgres    false    137            �           0    0    TABLE pg_stat_database    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_stat_database TO statsuser;
       
   pg_catalog          postgres    false    132            �           0    0     TABLE pg_stat_database_conflicts    ACL     G   GRANT ALL ON TABLE pg_catalog.pg_stat_database_conflicts TO statsuser;
       
   pg_catalog          postgres    false    133            �           0    0    TABLE pg_stat_gssapi    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_stat_gssapi TO statsuser;
       
   pg_catalog          postgres    false    129            �           0    0    TABLE pg_stat_io    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_stat_io TO statsuser;
       
   pg_catalog          postgres    false    138            �           0    0    TABLE pg_stat_progress_analyze    ACL     E   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_analyze TO statsuser;
       
   pg_catalog          postgres    false    140            �           0    0 !   TABLE pg_stat_progress_basebackup    ACL     H   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_basebackup TO statsuser;
       
   pg_catalog          postgres    false    144            �           0    0    TABLE pg_stat_progress_cluster    ACL     E   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_cluster TO statsuser;
       
   pg_catalog          postgres    false    142            �           0    0    TABLE pg_stat_progress_copy    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_copy TO statsuser;
       
   pg_catalog          postgres    false    145            �           0    0 #   TABLE pg_stat_progress_create_index    ACL     J   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_create_index TO statsuser;
       
   pg_catalog          postgres    false    143            �           0    0    TABLE pg_stat_progress_vacuum    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_vacuum TO statsuser;
       
   pg_catalog          postgres    false    141            �           0    0    TABLE pg_stat_recovery_prefetch    ACL     F   GRANT ALL ON TABLE pg_catalog.pg_stat_recovery_prefetch TO statsuser;
       
   pg_catalog          postgres    false    126            �           0    0    TABLE pg_stat_replication    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_stat_replication TO statsuser;
       
   pg_catalog          postgres    false    123            �           0    0    TABLE pg_stat_replication_slots    ACL     F   GRANT ALL ON TABLE pg_catalog.pg_stat_replication_slots TO statsuser;
       
   pg_catalog          postgres    false    131            �           0    0    TABLE pg_stat_slru    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_stat_slru TO statsuser;
       
   pg_catalog          postgres    false    124            �           0    0    TABLE pg_stat_ssl    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_stat_ssl TO statsuser;
       
   pg_catalog          postgres    false    128            �           0    0    TABLE pg_stat_subscription    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_stat_subscription TO statsuser;
       
   pg_catalog          postgres    false    127            �           0    0     TABLE pg_stat_subscription_stats    ACL     G   GRANT ALL ON TABLE pg_catalog.pg_stat_subscription_stats TO statsuser;
       
   pg_catalog          postgres    false    148            �           0    0    TABLE pg_stat_sys_indexes    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_stat_sys_indexes TO statsuser;
       
   pg_catalog          postgres    false    114            �           0    0    TABLE pg_stat_sys_tables    ACL     ?   GRANT ALL ON TABLE pg_catalog.pg_stat_sys_tables TO statsuser;
       
   pg_catalog          postgres    false    106            �           0    0    TABLE pg_stat_user_functions    ACL     C   GRANT ALL ON TABLE pg_catalog.pg_stat_user_functions TO statsuser;
       
   pg_catalog          postgres    false    134            �           0    0    TABLE pg_stat_user_indexes    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_stat_user_indexes TO statsuser;
       
   pg_catalog          postgres    false    115            �           0    0    TABLE pg_stat_user_tables    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_stat_user_tables TO statsuser;
       
   pg_catalog          postgres    false    108            �           0    0    TABLE pg_stat_wal    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_stat_wal TO statsuser;
       
   pg_catalog          postgres    false    139            �           0    0    TABLE pg_stat_wal_receiver    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_stat_wal_receiver TO statsuser;
       
   pg_catalog          postgres    false    125            �           0    0    TABLE pg_stat_xact_all_tables    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_stat_xact_all_tables TO statsuser;
       
   pg_catalog          postgres    false    105            �           0    0    TABLE pg_stat_xact_sys_tables    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_stat_xact_sys_tables TO statsuser;
       
   pg_catalog          postgres    false    107            �           0    0 !   TABLE pg_stat_xact_user_functions    ACL     H   GRANT ALL ON TABLE pg_catalog.pg_stat_xact_user_functions TO statsuser;
       
   pg_catalog          postgres    false    135            �           0    0    TABLE pg_stat_xact_user_tables    ACL     E   GRANT ALL ON TABLE pg_catalog.pg_stat_xact_user_tables TO statsuser;
       
   pg_catalog          postgres    false    109            �           0    0    TABLE pg_statio_all_indexes    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_statio_all_indexes TO statsuser;
       
   pg_catalog          postgres    false    116            �           0    0    TABLE pg_statio_all_sequences    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_statio_all_sequences TO statsuser;
       
   pg_catalog          postgres    false    119            �           0    0    TABLE pg_statio_all_tables    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_statio_all_tables TO statsuser;
       
   pg_catalog          postgres    false    110            �           0    0    TABLE pg_statio_sys_indexes    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_statio_sys_indexes TO statsuser;
       
   pg_catalog          postgres    false    117            �           0    0    TABLE pg_statio_sys_sequences    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_statio_sys_sequences TO statsuser;
       
   pg_catalog          postgres    false    120            �           0    0    TABLE pg_statio_sys_tables    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_statio_sys_tables TO statsuser;
       
   pg_catalog          postgres    false    111            �           0    0    TABLE pg_statio_user_indexes    ACL     C   GRANT ALL ON TABLE pg_catalog.pg_statio_user_indexes TO statsuser;
       
   pg_catalog          postgres    false    118            �           0    0    TABLE pg_statio_user_sequences    ACL     E   GRANT ALL ON TABLE pg_catalog.pg_statio_user_sequences TO statsuser;
       
   pg_catalog          postgres    false    121                        0    0    TABLE pg_statio_user_tables    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_statio_user_tables TO statsuser;
       
   pg_catalog          postgres    false    112                       0    0    TABLE pg_statistic    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_statistic TO statsuser;
       
   pg_catalog          postgres    false    42                       0    0    TABLE pg_statistic_ext    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_statistic_ext TO statsuser;
       
   pg_catalog          postgres    false    51                       0    0    TABLE pg_statistic_ext_data    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_statistic_ext_data TO statsuser;
       
   pg_catalog          postgres    false    53                       0    0    TABLE pg_stats    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_stats TO statsuser;
       
   pg_catalog          postgres    false    84                       0    0    TABLE pg_stats_ext    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_stats_ext TO statsuser;
       
   pg_catalog          postgres    false    85                       0    0    TABLE pg_stats_ext_exprs    ACL     ?   GRANT ALL ON TABLE pg_catalog.pg_stats_ext_exprs TO statsuser;
       
   pg_catalog          postgres    false    86                       0    0    TABLE pg_subscription    ACL     <   GRANT ALL ON TABLE pg_catalog.pg_subscription TO statsuser;
       
   pg_catalog          postgres    false    67                       0    0    TABLE pg_subscription_rel    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_subscription_rel TO statsuser;
       
   pg_catalog          postgres    false    68            	           0    0    TABLE pg_tables    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_tables TO statsuser;
       
   pg_catalog          postgres    false    80            
           0    0    TABLE pg_tablespace    ACL     :   GRANT ALL ON TABLE pg_catalog.pg_tablespace TO statsuser;
       
   pg_catalog          postgres    false    10                       0    0    TABLE pg_timezone_abbrevs    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_timezone_abbrevs TO statsuser;
       
   pg_catalog          postgres    false    99                       0    0    TABLE pg_timezone_names    ACL     >   GRANT ALL ON TABLE pg_catalog.pg_timezone_names TO statsuser;
       
   pg_catalog          postgres    false    100                       0    0    TABLE pg_transform    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_transform TO statsuser;
       
   pg_catalog          postgres    false    58                       0    0    TABLE pg_trigger    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_trigger TO statsuser;
       
   pg_catalog          postgres    false    43                       0    0    TABLE pg_ts_config    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_ts_config TO statsuser;
       
   pg_catalog          postgres    false    63                       0    0    TABLE pg_ts_config_map    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_ts_config_map TO statsuser;
       
   pg_catalog          postgres    false    64                       0    0    TABLE pg_ts_dict    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_ts_dict TO statsuser;
       
   pg_catalog          postgres    false    61                       0    0    TABLE pg_ts_parser    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_ts_parser TO statsuser;
       
   pg_catalog          postgres    false    62                       0    0    TABLE pg_ts_template    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_ts_template TO statsuser;
       
   pg_catalog          postgres    false    65                       0    0    TABLE pg_type    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_type TO statsuser;
       
   pg_catalog          postgres    false    12                       0    0    TABLE pg_user    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_user TO statsuser;
       
   pg_catalog          postgres    false    76                       0    0    TABLE pg_user_mapping    ACL     <   GRANT ALL ON TABLE pg_catalog.pg_user_mapping TO statsuser;
       
   pg_catalog          postgres    false    20                       0    0    TABLE pg_user_mappings    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_user_mappings TO statsuser;
       
   pg_catalog          postgres    false    146                       0    0    TABLE pg_views    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_views TO statsuser;
       
   pg_catalog          postgres    false    79            �            1259    68471    category    TABLE     }   CREATE TABLE public.category (
    id bigint NOT NULL,
    title text NOT NULL,
    active boolean DEFAULT false NOT NULL
);
    DROP TABLE public.category;
       public         heap 	   statsuser    false            �            1259    68477    category_id_seq    SEQUENCE     �   ALTER TABLE public.category ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.category_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   statsuser    false    223                       0    0    TABLE geography_columns    ACL     :   GRANT ALL ON TABLE public.geography_columns TO statsuser;
          public          postgres    false    221                       0    0    TABLE geometry_columns    ACL     9   GRANT ALL ON TABLE public.geometry_columns TO statsuser;
          public          postgres    false    222            �            1259    68478    global_land_cover_2019    TABLE     �   CREATE TABLE public.global_land_cover_2019 (
    id integer NOT NULL,
    geom public.geometry(Polygon,4326),
    fid bigint,
    "DN" integer
);
 *   DROP TABLE public.global_land_cover_2019;
       public         heap 	   statsuser    false    3    3    3    3    3    3    3    3            �            1259    68483    global_land_cover_2019_id_seq    SEQUENCE     �   CREATE SEQUENCE public.global_land_cover_2019_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 4   DROP SEQUENCE public.global_land_cover_2019_id_seq;
       public       	   statsuser    false    225                       0    0    global_land_cover_2019_id_seq    SEQUENCE OWNED BY     _   ALTER SEQUENCE public.global_land_cover_2019_id_seq OWNED BY public.global_land_cover_2019.id;
          public       	   statsuser    false    226            �            1259    68484    long_term_anomaly_info    TABLE     �   CREATE TABLE public.long_term_anomaly_info (
    id bigint NOT NULL,
    anomaly_product_variable_id bigint NOT NULL,
    mean_variable_id bigint NOT NULL,
    stdev_variable_id bigint NOT NULL,
    raw_product_variable_id bigint NOT NULL
);
 *   DROP TABLE public.long_term_anomaly_info;
       public         heap 	   statsuser    false            �            1259    68487    long_term_anomaly_info_id_seq    SEQUENCE     �   CREATE SEQUENCE public.long_term_anomaly_info_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 4   DROP SEQUENCE public.long_term_anomaly_info_id_seq;
       public       	   statsuser    false    227                       0    0    long_term_anomaly_info_id_seq    SEQUENCE OWNED BY     _   ALTER SEQUENCE public.long_term_anomaly_info_id_seq OWNED BY public.long_term_anomaly_info.id;
          public       	   statsuser    false    228            �            1259    68488    output_product_id_seq    SEQUENCE     ~   CREATE SEQUENCE public.output_product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE public.output_product_id_seq;
       public       	   statsuser    false            �            1259    68489 
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
       public         	   statsuser    false            �            1259    68495    product    TABLE     �   CREATE TABLE public.product (
    id bigint NOT NULL,
    name text[] NOT NULL,
    type text DEFAULT 'raw'::text NOT NULL,
    category_id bigint,
    description text
);
    DROP TABLE public.product;
       public         heap 	   statsuser    false            �            1259    68501    product_file    TABLE     +  CREATE TABLE public.product_file (
    id bigint NOT NULL,
    product_file_description_id bigint NOT NULL,
    rel_file_path text NOT NULL,
    rt_flag smallint,
    date timestamp without time zone NOT NULL,
    date_created timestamp without time zone DEFAULT (now() AT TIME ZONE 'UTC'::text)
);
     DROP TABLE public.product_file;
       public         heap 	   statsuser    false            �            1259    68759    product_file_description    TABLE       CREATE TABLE public.product_file_description (
    id bigint NOT NULL,
    product_id bigint,
    pattern text[] NOT NULL,
    types text NOT NULL,
    create_date text NOT NULL,
    file_name_creation_pattern text,
    rt_flag_pattern text,
    satellite_system_pattern text
);
 ,   DROP TABLE public.product_file_description;
       public         heap 	   statsuser    false            �            1259    68758    product_file_description_id_seq    SEQUENCE     �   CREATE SEQUENCE public.product_file_description_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 6   DROP SEQUENCE public.product_file_description_id_seq;
       public       	   statsuser    false    248                       0    0    product_file_description_id_seq    SEQUENCE OWNED BY     c   ALTER SEQUENCE public.product_file_description_id_seq OWNED BY public.product_file_description.id;
          public       	   statsuser    false    247            �            1259    68513    product_file_id_seq    SEQUENCE     |   CREATE SEQUENCE public.product_file_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.product_file_id_seq;
       public       	   statsuser    false            �            1259    68514    product_file_id_seq1    SEQUENCE     }   CREATE SEQUENCE public.product_file_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.product_file_id_seq1;
       public       	   statsuser    false    232                       0    0    product_file_id_seq1    SEQUENCE OWNED BY     L   ALTER SEQUENCE public.product_file_id_seq1 OWNED BY public.product_file.id;
          public       	   statsuser    false    234            �            1259    68515    product_file_variable    TABLE     <  CREATE TABLE public.product_file_variable (
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
       public         heap 	   statsuser    false            �            1259    68521    product_file_variable_id_seq    SEQUENCE     �   CREATE SEQUENCE public.product_file_variable_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 3   DROP SEQUENCE public.product_file_variable_id_seq;
       public       	   statsuser    false    235                       0    0    product_file_variable_id_seq    SEQUENCE OWNED BY     ]   ALTER SEQUENCE public.product_file_variable_id_seq OWNED BY public.product_file_variable.id;
          public       	   statsuser    false    236            �            1259    68522    product_id_seq    SEQUENCE     w   CREATE SEQUENCE public.product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public.product_id_seq;
       public       	   statsuser    false    231                        0    0    product_id_seq    SEQUENCE OWNED BY     A   ALTER SEQUENCE public.product_id_seq OWNED BY public.product.id;
          public       	   statsuser    false    237            �            1259    68523    product_order    TABLE     /  CREATE TABLE public.product_order (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    email text,
    aoi public.geometry(MultiPolygon,3857),
    request_data jsonb,
    date_created timestamp without time zone DEFAULT (now() AT TIME ZONE 'UTC'::text),
    processed boolean DEFAULT false NOT NULL
);
 !   DROP TABLE public.product_order;
       public         heap 	   statsuser    false    3    3    3    3    3    3    3    3            !           0    0    TABLE spatial_ref_sys    ACL     8   GRANT ALL ON TABLE public.spatial_ref_sys TO statsuser;
          public          postgres    false    219            �            1259    68531    stratification    TABLE     m   CREATE TABLE public.stratification (
    id bigint NOT NULL,
    description text,
    tilelayer_url text
);
 "   DROP TABLE public.stratification;
       public         heap 	   statsuser    false            �            1259    68536    stratification_geom    TABLE     �   CREATE TABLE public.stratification_geom (
    id bigint NOT NULL,
    stratification_id bigint NOT NULL,
    geom public.geometry(MultiPolygon,4326),
    geom3857 public.geometry(MultiPolygon,3857),
    description text
);
 '   DROP TABLE public.stratification_geom;
       public         heap 	   statsuser    false    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3            �            1259    68541    stratification_geom_id_seq    SEQUENCE     �   CREATE SEQUENCE public.stratification_geom_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE public.stratification_geom_id_seq;
       public       	   statsuser    false    240            "           0    0    stratification_geom_id_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE public.stratification_geom_id_seq OWNED BY public.stratification_geom.id;
          public       	   statsuser    false    241            �            1259    68542    stratification_id_seq    SEQUENCE     ~   CREATE SEQUENCE public.stratification_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE public.stratification_id_seq;
       public       	   statsuser    false    239            #           0    0    stratification_id_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE public.stratification_id_seq OWNED BY public.stratification.id;
          public       	   statsuser    false    242            �            1259    68548    wms_file    TABLE     �   CREATE TABLE public.wms_file (
    id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint,
    rel_file_path text
);
    DROP TABLE public.wms_file;
       public         heap 	   statsuser    false            �            1259    68553    wms_file_id_seq    SEQUENCE     x   CREATE SEQUENCE public.wms_file_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.wms_file_id_seq;
       public       	   statsuser    false    243            $           0    0    wms_file_id_seq    SEQUENCE OWNED BY     C   ALTER SEQUENCE public.wms_file_id_seq OWNED BY public.wms_file.id;
          public       	   statsuser    false    244            �            1259    68554    poly_stats_per_region    TABLE     �  CREATE TABLE tmp.poly_stats_per_region (
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
       tmp         heap 	   statsuser    false    4            �            1259    68562    poly_stats_per_region_id_seq    SEQUENCE     �   CREATE SEQUENCE tmp.poly_stats_per_region_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE tmp.poly_stats_per_region_id_seq;
       tmp       	   statsuser    false    4    245            %           0    0    poly_stats_per_region_id_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE tmp.poly_stats_per_region_id_seq OWNED BY tmp.poly_stats_per_region.id;
          tmp       	   statsuser    false    246            �           2604    68563    global_land_cover_2019 id    DEFAULT     �   ALTER TABLE ONLY public.global_land_cover_2019 ALTER COLUMN id SET DEFAULT nextval('public.global_land_cover_2019_id_seq'::regclass);
 H   ALTER TABLE public.global_land_cover_2019 ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    226    225            �           2604    68564    long_term_anomaly_info id    DEFAULT     �   ALTER TABLE ONLY public.long_term_anomaly_info ALTER COLUMN id SET DEFAULT nextval('public.long_term_anomaly_info_id_seq'::regclass);
 H   ALTER TABLE public.long_term_anomaly_info ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    228    227            �           2604    68565 
   product id    DEFAULT     h   ALTER TABLE ONLY public.product ALTER COLUMN id SET DEFAULT nextval('public.product_id_seq'::regclass);
 9   ALTER TABLE public.product ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    237    231            �           2604    68566    product_file id    DEFAULT     s   ALTER TABLE ONLY public.product_file ALTER COLUMN id SET DEFAULT nextval('public.product_file_id_seq1'::regclass);
 >   ALTER TABLE public.product_file ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    234    232            �           2604    68762    product_file_description id    DEFAULT     �   ALTER TABLE ONLY public.product_file_description ALTER COLUMN id SET DEFAULT nextval('public.product_file_description_id_seq'::regclass);
 J   ALTER TABLE public.product_file_description ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    247    248    248            �           2604    68568    product_file_variable id    DEFAULT     �   ALTER TABLE ONLY public.product_file_variable ALTER COLUMN id SET DEFAULT nextval('public.product_file_variable_id_seq'::regclass);
 G   ALTER TABLE public.product_file_variable ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    236    235            �           2604    68569    stratification id    DEFAULT     v   ALTER TABLE ONLY public.stratification ALTER COLUMN id SET DEFAULT nextval('public.stratification_id_seq'::regclass);
 @   ALTER TABLE public.stratification ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    242    239            �           2604    68570    stratification_geom id    DEFAULT     �   ALTER TABLE ONLY public.stratification_geom ALTER COLUMN id SET DEFAULT nextval('public.stratification_geom_id_seq'::regclass);
 E   ALTER TABLE public.stratification_geom ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    241    240            �           2604    68571    wms_file id    DEFAULT     j   ALTER TABLE ONLY public.wms_file ALTER COLUMN id SET DEFAULT nextval('public.wms_file_id_seq'::regclass);
 :   ALTER TABLE public.wms_file ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    244    243            �           2604    68572    poly_stats_per_region id    DEFAULT     ~   ALTER TABLE ONLY tmp.poly_stats_per_region ALTER COLUMN id SET DEFAULT nextval('tmp.poly_stats_per_region_id_seq'::regclass);
 D   ALTER TABLE tmp.poly_stats_per_region ALTER COLUMN id DROP DEFAULT;
       tmp       	   statsuser    false    246    245            �           2606    68574 2   global_land_cover_2019 global_land_cover_2019_pkey 
   CONSTRAINT     p   ALTER TABLE ONLY public.global_land_cover_2019
    ADD CONSTRAINT global_land_cover_2019_pkey PRIMARY KEY (id);
 \   ALTER TABLE ONLY public.global_land_cover_2019 DROP CONSTRAINT global_land_cover_2019_pkey;
       public         	   statsuser    false    225            �           2606    68576 0   long_term_anomaly_info long_term_anomaly_info_pk 
   CONSTRAINT     n   ALTER TABLE ONLY public.long_term_anomaly_info
    ADD CONSTRAINT long_term_anomaly_info_pk PRIMARY KEY (id);
 Z   ALTER TABLE ONLY public.long_term_anomaly_info DROP CONSTRAINT long_term_anomaly_info_pk;
       public         	   statsuser    false    227            �           2606    68578    category newtable_pk 
   CONSTRAINT     R   ALTER TABLE ONLY public.category
    ADD CONSTRAINT newtable_pk PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.category DROP CONSTRAINT newtable_pk;
       public         	   statsuser    false    223            �           2606    68580    poly_stats poly_stats_pk_ 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats
    ADD CONSTRAINT poly_stats_pk_ PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 C   ALTER TABLE ONLY public.poly_stats DROP CONSTRAINT poly_stats_pk_;
       public         	   statsuser    false    230    230    230            �           2606    68582 6   product_file product_file_date_product_description_idx 
   CONSTRAINT     �   ALTER TABLE ONLY public.product_file
    ADD CONSTRAINT product_file_date_product_description_idx UNIQUE (product_file_description_id, date, rt_flag);
 `   ALTER TABLE ONLY public.product_file DROP CONSTRAINT product_file_date_product_description_idx;
       public         	   statsuser    false    232    232    232            �           2606    68584    product_file product_file_pk 
   CONSTRAINT     Z   ALTER TABLE ONLY public.product_file
    ADD CONSTRAINT product_file_pk PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.product_file DROP CONSTRAINT product_file_pk;
       public         	   statsuser    false    232            �           2606    68586 .   product_file_variable product_file_variable_pk 
   CONSTRAINT     l   ALTER TABLE ONLY public.product_file_variable
    ADD CONSTRAINT product_file_variable_pk PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.product_file_variable DROP CONSTRAINT product_file_variable_pk;
       public         	   statsuser    false    235            �           2606    68588    product_order product_order_pk 
   CONSTRAINT     \   ALTER TABLE ONLY public.product_order
    ADD CONSTRAINT product_order_pk PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.product_order DROP CONSTRAINT product_order_pk;
       public         	   statsuser    false    238            �           2606    68590    product product_pk1 
   CONSTRAINT     Q   ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_pk1 PRIMARY KEY (id);
 =   ALTER TABLE ONLY public.product DROP CONSTRAINT product_pk1;
       public         	   statsuser    false    231            �           2606    68766 <   product_file_description product_product_file_description_pk 
   CONSTRAINT     z   ALTER TABLE ONLY public.product_file_description
    ADD CONSTRAINT product_product_file_description_pk PRIMARY KEY (id);
 f   ALTER TABLE ONLY public.product_file_description DROP CONSTRAINT product_product_file_description_pk;
       public         	   statsuser    false    248            �           2606    68594     stratification stratification_pk 
   CONSTRAINT     ^   ALTER TABLE ONLY public.stratification
    ADD CONSTRAINT stratification_pk PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.stratification DROP CONSTRAINT stratification_pk;
       public         	   statsuser    false    239            �           2606    68596 '   stratification_geom stratification_pkey 
   CONSTRAINT     e   ALTER TABLE ONLY public.stratification_geom
    ADD CONSTRAINT stratification_pkey PRIMARY KEY (id);
 Q   ALTER TABLE ONLY public.stratification_geom DROP CONSTRAINT stratification_pkey;
       public         	   statsuser    false    240            �           2606    68598     stratification stratification_un 
   CONSTRAINT     b   ALTER TABLE ONLY public.stratification
    ADD CONSTRAINT stratification_un UNIQUE (description);
 J   ALTER TABLE ONLY public.stratification DROP CONSTRAINT stratification_un;
       public         	   statsuser    false    239            �           2606    68600    wms_file wms_file_pk 
   CONSTRAINT     R   ALTER TABLE ONLY public.wms_file
    ADD CONSTRAINT wms_file_pk PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.wms_file DROP CONSTRAINT wms_file_pk;
       public         	   statsuser    false    243            �           2606    68602    wms_file wms_file_un 
   CONSTRAINT     t   ALTER TABLE ONLY public.wms_file
    ADD CONSTRAINT wms_file_un UNIQUE (product_file_id, product_file_variable_id);
 >   ALTER TABLE ONLY public.wms_file DROP CONSTRAINT wms_file_un;
       public         	   statsuser    false    243    243            �           2606    68604 #   poly_stats_per_region poly_stats_pk 
   CONSTRAINT     ^   ALTER TABLE ONLY tmp.poly_stats_per_region
    ADD CONSTRAINT poly_stats_pk PRIMARY KEY (id);
 J   ALTER TABLE ONLY tmp.poly_stats_per_region DROP CONSTRAINT poly_stats_pk;
       tmp         	   statsuser    false    245            �           2606    68606 #   poly_stats_per_region poly_stats_un 
   CONSTRAINT     �   ALTER TABLE ONLY tmp.poly_stats_per_region
    ADD CONSTRAINT poly_stats_un UNIQUE (poly_id, product_file_id, product_file_variable_id, region_id);
 J   ALTER TABLE ONLY tmp.poly_stats_per_region DROP CONSTRAINT poly_stats_un;
       tmp         	   statsuser    false    245    245    245    245            �           1259    68607    poly_stats_product_file_id_idx    INDEX        CREATE INDEX poly_stats_product_file_id_idx ON ONLY public.poly_stats USING btree (product_file_id, product_file_variable_id);
 2   DROP INDEX public.poly_stats_product_file_id_idx;
       public         	   statsuser    false    230    230            �           1259    68608    poly_stats_valid_pixels_idx    INDEX     _   CREATE INDEX poly_stats_valid_pixels_idx ON ONLY public.poly_stats USING btree (valid_pixels);
 /   DROP INDEX public.poly_stats_valid_pixels_idx;
       public         	   statsuser    false    230            �           1259    68609    product_file_date_idx    INDEX     W   CREATE INDEX product_file_date_idx ON public.product_file USING btree (date, rt_flag);
 )   DROP INDEX public.product_file_date_idx;
       public         	   statsuser    false    232    232            �           1259    68610    product_order_email_idx    INDEX     `   CREATE INDEX product_order_email_idx ON public.product_order USING btree (email, date_created);
 +   DROP INDEX public.product_order_email_idx;
       public         	   statsuser    false    238    238            �           1259    68611    sidx_stratification_geom    INDEX     W   CREATE INDEX sidx_stratification_geom ON public.stratification_geom USING gist (geom);
 ,   DROP INDEX public.sidx_stratification_geom;
       public         	   statsuser    false    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    240            �           1259    68612    sidx_stratification_geom3857    INDEX     �   CREATE INDEX sidx_stratification_geom3857 ON public.stratification_geom USING gist (geom3857);

ALTER TABLE public.stratification_geom CLUSTER ON sidx_stratification_geom3857;
 0   DROP INDEX public.sidx_stratification_geom3857;
       public         	   statsuser    false    240    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3            �           2606    68613 0   long_term_anomaly_info long_term_anomaly_info_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.long_term_anomaly_info
    ADD CONSTRAINT long_term_anomaly_info_fk FOREIGN KEY (anomaly_product_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 Z   ALTER TABLE ONLY public.long_term_anomaly_info DROP CONSTRAINT long_term_anomaly_info_fk;
       public       	   statsuser    false    235    4296    227            �           2606    68618 2   long_term_anomaly_info long_term_anomaly_info_fk_1    FK CONSTRAINT     �   ALTER TABLE ONLY public.long_term_anomaly_info
    ADD CONSTRAINT long_term_anomaly_info_fk_1 FOREIGN KEY (mean_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 \   ALTER TABLE ONLY public.long_term_anomaly_info DROP CONSTRAINT long_term_anomaly_info_fk_1;
       public       	   statsuser    false    4296    235    227            �           2606    68623 2   long_term_anomaly_info long_term_anomaly_info_fk_2    FK CONSTRAINT     �   ALTER TABLE ONLY public.long_term_anomaly_info
    ADD CONSTRAINT long_term_anomaly_info_fk_2 FOREIGN KEY (stdev_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 \   ALTER TABLE ONLY public.long_term_anomaly_info DROP CONSTRAINT long_term_anomaly_info_fk_2;
       public       	   statsuser    false    4296    227    235            �           2606    68628 2   long_term_anomaly_info long_term_anomaly_info_fk_3    FK CONSTRAINT     �   ALTER TABLE ONLY public.long_term_anomaly_info
    ADD CONSTRAINT long_term_anomaly_info_fk_3 FOREIGN KEY (raw_product_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 \   ALTER TABLE ONLY public.long_term_anomaly_info DROP CONSTRAINT long_term_anomaly_info_fk_3;
       public       	   statsuser    false    4296    235    227            �           2606    68633 &   poly_stats poly_stats_product_file_fk_    FK CONSTRAINT     �   ALTER TABLE public.poly_stats
    ADD CONSTRAINT poly_stats_product_file_fk_ FOREIGN KEY (product_file_id) REFERENCES public.product_file(id) ON UPDATE CASCADE ON DELETE CASCADE;
 K   ALTER TABLE public.poly_stats DROP CONSTRAINT poly_stats_product_file_fk_;
       public       	   statsuser    false    232    4294    230            �           2606    68638 *   poly_stats poly_stats_product_variable_fk_    FK CONSTRAINT     �   ALTER TABLE public.poly_stats
    ADD CONSTRAINT poly_stats_product_variable_fk_ FOREIGN KEY (product_file_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 O   ALTER TABLE public.poly_stats DROP CONSTRAINT poly_stats_product_variable_fk_;
       public       	   statsuser    false    235    4296    230            �           2606    68643 -   poly_stats poly_stats_stratification_geom_fk_    FK CONSTRAINT     �   ALTER TABLE public.poly_stats
    ADD CONSTRAINT poly_stats_stratification_geom_fk_ FOREIGN KEY (poly_id) REFERENCES public.stratification_geom(id) ON UPDATE CASCADE ON DELETE CASCADE;
 R   ALTER TABLE public.poly_stats DROP CONSTRAINT poly_stats_stratification_geom_fk_;
       public       	   statsuser    false    230    240    4307            �           2606    68767 4   product_file_description product_file_description_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.product_file_description
    ADD CONSTRAINT product_file_description_fk FOREIGN KEY (product_id) REFERENCES public.product(id) ON UPDATE CASCADE ON DELETE CASCADE;
 ^   ALTER TABLE ONLY public.product_file_description DROP CONSTRAINT product_file_description_fk;
       public       	   statsuser    false    248    231    4289            �           2606    68772 5   product_file product_file_product_file_description_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.product_file
    ADD CONSTRAINT product_file_product_file_description_fk FOREIGN KEY (product_file_description_id) REFERENCES public.product_file_description(id) ON UPDATE CASCADE ON DELETE CASCADE;
 _   ALTER TABLE ONLY public.product_file DROP CONSTRAINT product_file_product_file_description_fk;
       public       	   statsuser    false    232    4317    248            �           2606    68658    product product_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_fk FOREIGN KEY (category_id) REFERENCES public.category(id) ON UPDATE CASCADE ON DELETE CASCADE;
 <   ALTER TABLE ONLY public.product DROP CONSTRAINT product_fk;
       public       	   statsuser    false    231    223    4279            �           2606    68663 *   stratification_geom stratification_geom_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.stratification_geom
    ADD CONSTRAINT stratification_geom_fk FOREIGN KEY (stratification_id) REFERENCES public.stratification(id) ON DELETE CASCADE;
 T   ALTER TABLE ONLY public.stratification_geom DROP CONSTRAINT stratification_geom_fk;
       public       	   statsuser    false    4301    239    240            �           2606    68668    wms_file wms_file_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.wms_file
    ADD CONSTRAINT wms_file_fk FOREIGN KEY (product_file_id) REFERENCES public.product_file(id) ON UPDATE CASCADE ON DELETE CASCADE;
 >   ALTER TABLE ONLY public.wms_file DROP CONSTRAINT wms_file_fk;
       public       	   statsuser    false    243    232    4294            �           2606    68673    wms_file wms_file_fk2    FK CONSTRAINT     �   ALTER TABLE ONLY public.wms_file
    ADD CONSTRAINT wms_file_fk2 FOREIGN KEY (product_file_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 ?   ALTER TABLE ONLY public.wms_file DROP CONSTRAINT wms_file_fk2;
       public       	   statsuser    false    243    4296    235            �           2606    68678 0   poly_stats_per_region poly_stats_product_file_fk    FK CONSTRAINT     �   ALTER TABLE ONLY tmp.poly_stats_per_region
    ADD CONSTRAINT poly_stats_product_file_fk FOREIGN KEY (product_file_id) REFERENCES public.product_file(id) ON UPDATE CASCADE ON DELETE CASCADE;
 W   ALTER TABLE ONLY tmp.poly_stats_per_region DROP CONSTRAINT poly_stats_product_file_fk;
       tmp       	   statsuser    false    4294    232    245            �           2606    68683 9   poly_stats_per_region poly_stats_product_file_variable_fk    FK CONSTRAINT     �   ALTER TABLE ONLY tmp.poly_stats_per_region
    ADD CONSTRAINT poly_stats_product_file_variable_fk FOREIGN KEY (product_file_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 `   ALTER TABLE ONLY tmp.poly_stats_per_region DROP CONSTRAINT poly_stats_product_file_variable_fk;
       tmp       	   statsuser    false    245    235    4296            �           2606    68688 7   poly_stats_per_region poly_stats_stratification_geom_fk    FK CONSTRAINT     �   ALTER TABLE ONLY tmp.poly_stats_per_region
    ADD CONSTRAINT poly_stats_stratification_geom_fk FOREIGN KEY (poly_id) REFERENCES public.stratification_geom(id) ON UPDATE CASCADE ON DELETE CASCADE;
 ^   ALTER TABLE ONLY tmp.poly_stats_per_region DROP CONSTRAINT poly_stats_stratification_geom_fk;
       tmp       	   statsuser    false    240    245    4307           