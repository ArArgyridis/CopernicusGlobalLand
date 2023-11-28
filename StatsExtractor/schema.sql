PGDMP         #            
    {            jrcstats    15.4    15.4 X   c           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            d           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            e           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            f           1262    30125    jrcstats    DATABASE     t   CREATE DATABASE jrcstats WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.UTF-8';
    DROP DATABASE jrcstats;
                postgres    false            g           0    0    SCHEMA pg_catalog    ACL     -   GRANT ALL ON SCHEMA pg_catalog TO statsuser;
                   postgres    false    6            h           0    0    SCHEMA public    ACL     )   GRANT ALL ON SCHEMA public TO statsuser;
                   pg_database_owner    false    4                        2615    30126    tmp    SCHEMA        CREATE SCHEMA tmp;
    DROP SCHEMA tmp;
                postgres    false            i           0    0 
   SCHEMA tmp    ACL     &   GRANT ALL ON SCHEMA tmp TO statsuser;
                   postgres    false    5                        3079    30127    fuzzystrmatch 	   EXTENSION     A   CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;
    DROP EXTENSION fuzzystrmatch;
                   false            j           0    0    EXTENSION fuzzystrmatch    COMMENT     ]   COMMENT ON EXTENSION fuzzystrmatch IS 'determine similarities and distance between strings';
                        false    2                        3079    30138    postgis 	   EXTENSION     ;   CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;
    DROP EXTENSION postgis;
                   false            k           0    0    EXTENSION postgis    COMMENT     ^   COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';
                        false    3            ;           1255    31214    clms_updatepolygonstats()    FUNCTION     �  CREATE FUNCTION public.clms_updatepolygonstats() RETURNS smallint
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
       public          postgres    false            l           0    0    TABLE pg_aggregate    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_aggregate TO statsuser;
       
   pg_catalog          postgres    false    24            m           0    0    TABLE pg_am    ACL     2   GRANT ALL ON TABLE pg_catalog.pg_am TO statsuser;
       
   pg_catalog          postgres    false    25            n           0    0    TABLE pg_amop    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_amop TO statsuser;
       
   pg_catalog          postgres    false    26            o           0    0    TABLE pg_amproc    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_amproc TO statsuser;
       
   pg_catalog          postgres    false    27            p           0    0    TABLE pg_attrdef    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_attrdef TO statsuser;
       
   pg_catalog          postgres    false    28            q           0    0    TABLE pg_attribute    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_attribute TO statsuser;
       
   pg_catalog          postgres    false    13            r           0    0    TABLE pg_auth_members    ACL     <   GRANT ALL ON TABLE pg_catalog.pg_auth_members TO statsuser;
       
   pg_catalog          postgres    false    17            s           0    0    TABLE pg_authid    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_authid TO statsuser;
       
   pg_catalog          postgres    false    16            t           0    0 %   TABLE pg_available_extension_versions    ACL     L   GRANT ALL ON TABLE pg_catalog.pg_available_extension_versions TO statsuser;
       
   pg_catalog          postgres    false    91            u           0    0    TABLE pg_available_extensions    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_available_extensions TO statsuser;
       
   pg_catalog          postgres    false    90            v           0    0     TABLE pg_backend_memory_contexts    ACL     G   GRANT ALL ON TABLE pg_catalog.pg_backend_memory_contexts TO statsuser;
       
   pg_catalog          postgres    false    103            w           0    0    TABLE pg_cast    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_cast TO statsuser;
       
   pg_catalog          postgres    false    29            x           0    0    TABLE pg_class    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_class TO statsuser;
       
   pg_catalog          postgres    false    15            y           0    0    TABLE pg_collation    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_collation TO statsuser;
       
   pg_catalog          postgres    false    54            z           0    0    TABLE pg_config    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_config TO statsuser;
       
   pg_catalog          postgres    false    101            {           0    0    TABLE pg_constraint    ACL     :   GRANT ALL ON TABLE pg_catalog.pg_constraint TO statsuser;
       
   pg_catalog          postgres    false    30            |           0    0    TABLE pg_conversion    ACL     :   GRANT ALL ON TABLE pg_catalog.pg_conversion TO statsuser;
       
   pg_catalog          postgres    false    31            }           0    0    TABLE pg_cursors    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_cursors TO statsuser;
       
   pg_catalog          postgres    false    89            ~           0    0    TABLE pg_database    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_database TO statsuser;
       
   pg_catalog          postgres    false    18                       0    0    TABLE pg_db_role_setting    ACL     ?   GRANT ALL ON TABLE pg_catalog.pg_db_role_setting TO statsuser;
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
   pg_catalog          postgres    false    146            �           0    0    TABLE pg_replication_slots    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_replication_slots TO statsuser;
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
   pg_catalog          postgres    false    129            �           0    0    TABLE pg_stat_progress_analyze    ACL     E   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_analyze TO statsuser;
       
   pg_catalog          postgres    false    139            �           0    0 !   TABLE pg_stat_progress_basebackup    ACL     H   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_basebackup TO statsuser;
       
   pg_catalog          postgres    false    143            �           0    0    TABLE pg_stat_progress_cluster    ACL     E   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_cluster TO statsuser;
       
   pg_catalog          postgres    false    141            �           0    0    TABLE pg_stat_progress_copy    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_copy TO statsuser;
       
   pg_catalog          postgres    false    144            �           0    0 #   TABLE pg_stat_progress_create_index    ACL     J   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_create_index TO statsuser;
       
   pg_catalog          postgres    false    142            �           0    0    TABLE pg_stat_progress_vacuum    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_vacuum TO statsuser;
       
   pg_catalog          postgres    false    140            �           0    0    TABLE pg_stat_recovery_prefetch    ACL     F   GRANT ALL ON TABLE pg_catalog.pg_stat_recovery_prefetch TO statsuser;
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
   pg_catalog          postgres    false    147            �           0    0    TABLE pg_stat_sys_indexes    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_stat_sys_indexes TO statsuser;
       
   pg_catalog          postgres    false    114            �           0    0    TABLE pg_stat_sys_tables    ACL     ?   GRANT ALL ON TABLE pg_catalog.pg_stat_sys_tables TO statsuser;
       
   pg_catalog          postgres    false    106            �           0    0    TABLE pg_stat_user_functions    ACL     C   GRANT ALL ON TABLE pg_catalog.pg_stat_user_functions TO statsuser;
       
   pg_catalog          postgres    false    134            �           0    0    TABLE pg_stat_user_indexes    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_stat_user_indexes TO statsuser;
       
   pg_catalog          postgres    false    115            �           0    0    TABLE pg_stat_user_tables    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_stat_user_tables TO statsuser;
       
   pg_catalog          postgres    false    108            �           0    0    TABLE pg_stat_wal    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_stat_wal TO statsuser;
       
   pg_catalog          postgres    false    138            �           0    0    TABLE pg_stat_wal_receiver    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_stat_wal_receiver TO statsuser;
       
   pg_catalog          postgres    false    125            �           0    0    TABLE pg_stat_xact_all_tables    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_stat_xact_all_tables TO statsuser;
       
   pg_catalog          postgres    false    105            �           0    0    TABLE pg_stat_xact_sys_tables    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_stat_xact_sys_tables TO statsuser;
       
   pg_catalog          postgres    false    107            �           0    0 !   TABLE pg_stat_xact_user_functions    ACL     H   GRANT ALL ON TABLE pg_catalog.pg_stat_xact_user_functions TO statsuser;
       
   pg_catalog          postgres    false    135            �           0    0    TABLE pg_stat_xact_user_tables    ACL     E   GRANT ALL ON TABLE pg_catalog.pg_stat_xact_user_tables TO statsuser;
       
   pg_catalog          postgres    false    109            �           0    0    TABLE pg_statio_all_indexes    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_statio_all_indexes TO statsuser;
       
   pg_catalog          postgres    false    116            �           0    0    TABLE pg_statio_all_sequences    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_statio_all_sequences TO statsuser;
       
   pg_catalog          postgres    false    119            �           0    0    TABLE pg_statio_all_tables    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_statio_all_tables TO statsuser;
       
   pg_catalog          postgres    false    110            �           0    0    TABLE pg_statio_sys_indexes    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_statio_sys_indexes TO statsuser;
       
   pg_catalog          postgres    false    117            �           0    0    TABLE pg_statio_sys_sequences    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_statio_sys_sequences TO statsuser;
       
   pg_catalog          postgres    false    120            �           0    0    TABLE pg_statio_sys_tables    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_statio_sys_tables TO statsuser;
       
   pg_catalog          postgres    false    111            �           0    0    TABLE pg_statio_user_indexes    ACL     C   GRANT ALL ON TABLE pg_catalog.pg_statio_user_indexes TO statsuser;
       
   pg_catalog          postgres    false    118            �           0    0    TABLE pg_statio_user_sequences    ACL     E   GRANT ALL ON TABLE pg_catalog.pg_statio_user_sequences TO statsuser;
       
   pg_catalog          postgres    false    121            �           0    0    TABLE pg_statio_user_tables    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_statio_user_tables TO statsuser;
       
   pg_catalog          postgres    false    112            �           0    0    TABLE pg_statistic    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_statistic TO statsuser;
       
   pg_catalog          postgres    false    42            �           0    0    TABLE pg_statistic_ext    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_statistic_ext TO statsuser;
       
   pg_catalog          postgres    false    51            �           0    0    TABLE pg_statistic_ext_data    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_statistic_ext_data TO statsuser;
       
   pg_catalog          postgres    false    53            �           0    0    TABLE pg_stats    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_stats TO statsuser;
       
   pg_catalog          postgres    false    84            �           0    0    TABLE pg_stats_ext    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_stats_ext TO statsuser;
       
   pg_catalog          postgres    false    85            �           0    0    TABLE pg_stats_ext_exprs    ACL     ?   GRANT ALL ON TABLE pg_catalog.pg_stats_ext_exprs TO statsuser;
       
   pg_catalog          postgres    false    86            �           0    0    TABLE pg_subscription    ACL     <   GRANT ALL ON TABLE pg_catalog.pg_subscription TO statsuser;
       
   pg_catalog          postgres    false    67            �           0    0    TABLE pg_subscription_rel    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_subscription_rel TO statsuser;
       
   pg_catalog          postgres    false    68            �           0    0    TABLE pg_tables    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_tables TO statsuser;
       
   pg_catalog          postgres    false    80            �           0    0    TABLE pg_tablespace    ACL     :   GRANT ALL ON TABLE pg_catalog.pg_tablespace TO statsuser;
       
   pg_catalog          postgres    false    10            �           0    0    TABLE pg_timezone_abbrevs    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_timezone_abbrevs TO statsuser;
       
   pg_catalog          postgres    false    99            �           0    0    TABLE pg_timezone_names    ACL     >   GRANT ALL ON TABLE pg_catalog.pg_timezone_names TO statsuser;
       
   pg_catalog          postgres    false    100            �           0    0    TABLE pg_transform    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_transform TO statsuser;
       
   pg_catalog          postgres    false    58            �           0    0    TABLE pg_trigger    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_trigger TO statsuser;
       
   pg_catalog          postgres    false    43            �           0    0    TABLE pg_ts_config    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_ts_config TO statsuser;
       
   pg_catalog          postgres    false    63            �           0    0    TABLE pg_ts_config_map    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_ts_config_map TO statsuser;
       
   pg_catalog          postgres    false    64            �           0    0    TABLE pg_ts_dict    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_ts_dict TO statsuser;
       
   pg_catalog          postgres    false    61            �           0    0    TABLE pg_ts_parser    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_ts_parser TO statsuser;
       
   pg_catalog          postgres    false    62            �           0    0    TABLE pg_ts_template    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_ts_template TO statsuser;
       
   pg_catalog          postgres    false    65            �           0    0    TABLE pg_type    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_type TO statsuser;
       
   pg_catalog          postgres    false    12            �           0    0    TABLE pg_user    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_user TO statsuser;
       
   pg_catalog          postgres    false    76            �           0    0    TABLE pg_user_mapping    ACL     <   GRANT ALL ON TABLE pg_catalog.pg_user_mapping TO statsuser;
       
   pg_catalog          postgres    false    20            �           0    0    TABLE pg_user_mappings    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_user_mappings TO statsuser;
       
   pg_catalog          postgres    false    145            �           0    0    TABLE pg_views    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_views TO statsuser;
       
   pg_catalog          postgres    false    79            �            1259    31215    category    TABLE     }   CREATE TABLE public.category (
    id bigint NOT NULL,
    title text NOT NULL,
    active boolean DEFAULT false NOT NULL
);
    DROP TABLE public.category;
       public         heap 	   statsuser    false            �            1259    31221    category_id_seq    SEQUENCE     �   ALTER TABLE public.category ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.category_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   statsuser    false    222            �           0    0    TABLE geography_columns    ACL     :   GRANT ALL ON TABLE public.geography_columns TO statsuser;
          public          postgres    false    220            �           0    0    TABLE geometry_columns    ACL     9   GRANT ALL ON TABLE public.geometry_columns TO statsuser;
          public          postgres    false    221            �            1259    31222    long_term_anomaly_info    TABLE     �   CREATE TABLE public.long_term_anomaly_info (
    id bigint NOT NULL,
    anomaly_product_variable_id bigint NOT NULL,
    mean_variable_id bigint NOT NULL,
    stdev_variable_id bigint NOT NULL,
    raw_product_variable_id bigint NOT NULL
);
 *   DROP TABLE public.long_term_anomaly_info;
       public         heap 	   statsuser    false            �            1259    31225    long_term_anomaly_info_id_seq    SEQUENCE     �   CREATE SEQUENCE public.long_term_anomaly_info_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 4   DROP SEQUENCE public.long_term_anomaly_info_id_seq;
       public       	   statsuser    false    224            �           0    0    long_term_anomaly_info_id_seq    SEQUENCE OWNED BY     _   ALTER SEQUENCE public.long_term_anomaly_info_id_seq OWNED BY public.long_term_anomaly_info.id;
          public       	   statsuser    false    225            �            1259    31226    output_product_id_seq    SEQUENCE     ~   CREATE SEQUENCE public.output_product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE public.output_product_id_seq;
       public       	   statsuser    false            �            1259    31227 
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
       public         	   statsuser    false            �            1259    31233    poly_stats_10_1_257    TABLE     �  CREATE TABLE public.poly_stats_10_1_257 (
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
       public         heap 	   statsuser    false    227            �            1259    31241    poly_stats_10_257_279    TABLE     �  CREATE TABLE public.poly_stats_10_257_279 (
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
       public         heap 	   statsuser    false    227            �            1259    31249    poly_stats_10_279_285    TABLE     �  CREATE TABLE public.poly_stats_10_279_285 (
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
       public         heap 	   statsuser    false    227            �            1259    31257    poly_stats_10_285_38543    TABLE     �  CREATE TABLE public.poly_stats_10_285_38543 (
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
       public         heap 	   statsuser    false    227            �            1259    31265    poly_stats_12_1_257    TABLE     �  CREATE TABLE public.poly_stats_12_1_257 (
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
       public         heap 	   statsuser    false    227            �            1259    31273    poly_stats_12_257_279    TABLE     �  CREATE TABLE public.poly_stats_12_257_279 (
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
       public         heap 	   statsuser    false    227            �            1259    31281    poly_stats_12_279_285    TABLE     �  CREATE TABLE public.poly_stats_12_279_285 (
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
       public         heap 	   statsuser    false    227            �            1259    31289    poly_stats_12_285_38543    TABLE     �  CREATE TABLE public.poly_stats_12_285_38543 (
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
       public         heap 	   statsuser    false    227            �            1259    31297    poly_stats_14_1_257    TABLE     �  CREATE TABLE public.poly_stats_14_1_257 (
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
       public         heap 	   statsuser    false    227            �            1259    31305    poly_stats_14_257_279    TABLE     �  CREATE TABLE public.poly_stats_14_257_279 (
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
       public         heap 	   statsuser    false    227            �            1259    31313    poly_stats_14_279_285    TABLE     �  CREATE TABLE public.poly_stats_14_279_285 (
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
       public         heap 	   statsuser    false    227            �            1259    31321    poly_stats_14_285_38543    TABLE     �  CREATE TABLE public.poly_stats_14_285_38543 (
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
       public         heap 	   statsuser    false    227            �            1259    31329    poly_stats_16_1_257    TABLE     �  CREATE TABLE public.poly_stats_16_1_257 (
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
       public         heap 	   statsuser    false    227            �            1259    31337    poly_stats_16_257_279    TABLE     �  CREATE TABLE public.poly_stats_16_257_279 (
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
       public         heap 	   statsuser    false    227            �            1259    31345    poly_stats_16_279_285    TABLE     �  CREATE TABLE public.poly_stats_16_279_285 (
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
       public         heap 	   statsuser    false    227            �            1259    31353    poly_stats_16_285_38543    TABLE     �  CREATE TABLE public.poly_stats_16_285_38543 (
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
       public         heap 	   statsuser    false    227            �            1259    31361    poly_stats_17_1_257    TABLE     �  CREATE TABLE public.poly_stats_17_1_257 (
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
       public         heap 	   statsuser    false    227            �            1259    31369    poly_stats_17_257_279    TABLE     �  CREATE TABLE public.poly_stats_17_257_279 (
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
       public         heap 	   statsuser    false    227            �            1259    31377    poly_stats_17_279_285    TABLE     �  CREATE TABLE public.poly_stats_17_279_285 (
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
       public         heap 	   statsuser    false    227            �            1259    31385    poly_stats_17_285_38543    TABLE     �  CREATE TABLE public.poly_stats_17_285_38543 (
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
       public         heap 	   statsuser    false    227            �            1259    31393    poly_stats_19_1_257    TABLE     �  CREATE TABLE public.poly_stats_19_1_257 (
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
       public         heap 	   statsuser    false    227            �            1259    31401    poly_stats_19_257_279    TABLE     �  CREATE TABLE public.poly_stats_19_257_279 (
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
       public         heap 	   statsuser    false    227            �            1259    31409    poly_stats_19_279_285    TABLE     �  CREATE TABLE public.poly_stats_19_279_285 (
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
       public         heap 	   statsuser    false    227            �            1259    31417    poly_stats_19_285_38543    TABLE     �  CREATE TABLE public.poly_stats_19_285_38543 (
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
       public         heap 	   statsuser    false    227            �            1259    31425    poly_stats_1_1_257    TABLE     �  CREATE TABLE public.poly_stats_1_1_257 (
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
       public         heap 	   statsuser    false    227            �            1259    31433    poly_stats_1_257_279    TABLE     �  CREATE TABLE public.poly_stats_1_257_279 (
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
       public         heap 	   statsuser    false    227            �            1259    31441    poly_stats_1_279_285    TABLE     �  CREATE TABLE public.poly_stats_1_279_285 (
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
       public         heap 	   statsuser    false    227            �            1259    31449    poly_stats_1_285_38543    TABLE     �  CREATE TABLE public.poly_stats_1_285_38543 (
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
       public         heap 	   statsuser    false    227                        1259    31457    poly_stats_21_1_257    TABLE     �  CREATE TABLE public.poly_stats_21_1_257 (
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
       public         heap 	   statsuser    false    227                       1259    31465    poly_stats_21_257_279    TABLE     �  CREATE TABLE public.poly_stats_21_257_279 (
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
       public         heap 	   statsuser    false    227                       1259    31473    poly_stats_21_279_285    TABLE     �  CREATE TABLE public.poly_stats_21_279_285 (
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
       public         heap 	   statsuser    false    227                       1259    31481    poly_stats_21_285_38543    TABLE     �  CREATE TABLE public.poly_stats_21_285_38543 (
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
       public         heap 	   statsuser    false    227            3           1259    34806    poly_stats_24_1_257    TABLE     �  CREATE TABLE public.poly_stats_24_1_257 (
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
       public         heap 	   statsuser    false    227                       1259    31489    poly_stats_2_1_257    TABLE     �  CREATE TABLE public.poly_stats_2_1_257 (
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
       public         heap 	   statsuser    false    227                       1259    31497    poly_stats_2_257_279    TABLE     �  CREATE TABLE public.poly_stats_2_257_279 (
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
       public         heap 	   statsuser    false    227                       1259    31505    poly_stats_2_279_285    TABLE     �  CREATE TABLE public.poly_stats_2_279_285 (
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
       public         heap 	   statsuser    false    227                       1259    31513    poly_stats_2_285_38543    TABLE     �  CREATE TABLE public.poly_stats_2_285_38543 (
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
       public         heap 	   statsuser    false    227                       1259    31521    poly_stats_3_1_257    TABLE     �  CREATE TABLE public.poly_stats_3_1_257 (
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
       public         heap 	   statsuser    false    227            	           1259    31529    poly_stats_3_257_279    TABLE     �  CREATE TABLE public.poly_stats_3_257_279 (
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
       public         heap 	   statsuser    false    227            
           1259    31537    poly_stats_3_279_285    TABLE     �  CREATE TABLE public.poly_stats_3_279_285 (
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
       public         heap 	   statsuser    false    227                       1259    31545    poly_stats_3_285_38543    TABLE     �  CREATE TABLE public.poly_stats_3_285_38543 (
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
       public         heap 	   statsuser    false    227                       1259    31553    poly_stats_4_1_257    TABLE     �  CREATE TABLE public.poly_stats_4_1_257 (
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
       public         heap 	   statsuser    false    227                       1259    31561    poly_stats_4_257_279    TABLE     �  CREATE TABLE public.poly_stats_4_257_279 (
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
       public         heap 	   statsuser    false    227                       1259    31569    poly_stats_4_279_285    TABLE     �  CREATE TABLE public.poly_stats_4_279_285 (
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
       public         heap 	   statsuser    false    227                       1259    31577    poly_stats_4_285_38543    TABLE     �  CREATE TABLE public.poly_stats_4_285_38543 (
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
       public         heap 	   statsuser    false    227                       1259    31585    poly_stats_5_1_257    TABLE     �  CREATE TABLE public.poly_stats_5_1_257 (
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
       public         heap 	   statsuser    false    227                       1259    31593    poly_stats_5_257_279    TABLE     �  CREATE TABLE public.poly_stats_5_257_279 (
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
       public         heap 	   statsuser    false    227                       1259    31601    poly_stats_5_279_285    TABLE     �  CREATE TABLE public.poly_stats_5_279_285 (
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
       public         heap 	   statsuser    false    227                       1259    31609    poly_stats_5_285_38543    TABLE     �  CREATE TABLE public.poly_stats_5_285_38543 (
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
       public         heap 	   statsuser    false    227                       1259    31617    poly_stats_6_1_257    TABLE     �  CREATE TABLE public.poly_stats_6_1_257 (
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
       public         heap 	   statsuser    false    227                       1259    31625    poly_stats_6_257_279    TABLE     �  CREATE TABLE public.poly_stats_6_257_279 (
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
       public         heap 	   statsuser    false    227                       1259    31633    poly_stats_6_279_285    TABLE     �  CREATE TABLE public.poly_stats_6_279_285 (
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
       public         heap 	   statsuser    false    227                       1259    31641    poly_stats_6_285_38543    TABLE     �  CREATE TABLE public.poly_stats_6_285_38543 (
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
       public         heap 	   statsuser    false    227                       1259    31649    poly_stats_7_1_257    TABLE     �  CREATE TABLE public.poly_stats_7_1_257 (
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
       public         heap 	   statsuser    false    227                       1259    31657    poly_stats_7_257_279    TABLE     �  CREATE TABLE public.poly_stats_7_257_279 (
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
       public         heap 	   statsuser    false    227                       1259    31665    poly_stats_7_279_285    TABLE     �  CREATE TABLE public.poly_stats_7_279_285 (
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
       public         heap 	   statsuser    false    227                       1259    31673    poly_stats_7_285_38543    TABLE     �  CREATE TABLE public.poly_stats_7_285_38543 (
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
       public         heap 	   statsuser    false    227                       1259    31681    poly_stats_9_1_257    TABLE     �  CREATE TABLE public.poly_stats_9_1_257 (
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
       public         heap 	   statsuser    false    227                       1259    31689    poly_stats_9_257_279    TABLE     �  CREATE TABLE public.poly_stats_9_257_279 (
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
       public         heap 	   statsuser    false    227                       1259    31697    poly_stats_9_279_285    TABLE     �  CREATE TABLE public.poly_stats_9_279_285 (
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
       public         heap 	   statsuser    false    227                       1259    31705    poly_stats_9_285_38543    TABLE     �  CREATE TABLE public.poly_stats_9_285_38543 (
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
       public         heap 	   statsuser    false    227                        1259    31713    product    TABLE     �   CREATE TABLE public.product (
    id bigint NOT NULL,
    name text[] NOT NULL,
    type text DEFAULT 'raw'::text NOT NULL,
    category_id bigint,
    description text
);
    DROP TABLE public.product;
       public         heap 	   statsuser    false            !           1259    31719    product_file    TABLE     +  CREATE TABLE public.product_file (
    id bigint NOT NULL,
    product_file_description_id bigint NOT NULL,
    rel_file_path text NOT NULL,
    rt_flag smallint,
    date timestamp without time zone NOT NULL,
    date_created timestamp without time zone DEFAULT (now() AT TIME ZONE 'UTC'::text)
);
     DROP TABLE public.product_file;
       public         heap 	   statsuser    false            "           1259    31725    product_file_description    TABLE     �   CREATE TABLE public.product_file_description (
    id bigint NOT NULL,
    product_id bigint,
    pattern text NOT NULL,
    types text NOT NULL,
    create_date text NOT NULL,
    file_name_creation_pattern text,
    rt_flag_pattern text
);
 ,   DROP TABLE public.product_file_description;
       public         heap 	   statsuser    false            #           1259    31730    product_file_description_id_seq    SEQUENCE     �   CREATE SEQUENCE public.product_file_description_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 6   DROP SEQUENCE public.product_file_description_id_seq;
       public       	   statsuser    false    290            �           0    0    product_file_description_id_seq    SEQUENCE OWNED BY     c   ALTER SEQUENCE public.product_file_description_id_seq OWNED BY public.product_file_description.id;
          public       	   statsuser    false    291            $           1259    31731    product_file_id_seq    SEQUENCE     |   CREATE SEQUENCE public.product_file_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.product_file_id_seq;
       public       	   statsuser    false            %           1259    31732    product_file_id_seq1    SEQUENCE     }   CREATE SEQUENCE public.product_file_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.product_file_id_seq1;
       public       	   statsuser    false    289            �           0    0    product_file_id_seq1    SEQUENCE OWNED BY     L   ALTER SEQUENCE public.product_file_id_seq1 OWNED BY public.product_file.id;
          public       	   statsuser    false    293            &           1259    31733    product_file_variable    TABLE     <  CREATE TABLE public.product_file_variable (
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
       public         heap 	   statsuser    false            '           1259    31739    product_file_variable_id_seq    SEQUENCE     �   CREATE SEQUENCE public.product_file_variable_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 3   DROP SEQUENCE public.product_file_variable_id_seq;
       public       	   statsuser    false    294            �           0    0    product_file_variable_id_seq    SEQUENCE OWNED BY     ]   ALTER SEQUENCE public.product_file_variable_id_seq OWNED BY public.product_file_variable.id;
          public       	   statsuser    false    295            (           1259    31740    product_id_seq    SEQUENCE     w   CREATE SEQUENCE public.product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public.product_id_seq;
       public       	   statsuser    false    288            �           0    0    product_id_seq    SEQUENCE OWNED BY     A   ALTER SEQUENCE public.product_id_seq OWNED BY public.product.id;
          public       	   statsuser    false    296            2           1259    33053    product_order    TABLE     /  CREATE TABLE public.product_order (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    email text,
    aoi public.geometry(MultiPolygon,3857),
    request_data jsonb,
    date_created timestamp without time zone DEFAULT (now() AT TIME ZONE 'UTC'::text),
    processed boolean DEFAULT false NOT NULL
);
 !   DROP TABLE public.product_order;
       public         heap 	   statsuser    false    3    3    3    3    3    3    3    3            �           0    0    TABLE spatial_ref_sys    ACL     8   GRANT ALL ON TABLE public.spatial_ref_sys TO statsuser;
          public          postgres    false    218            )           1259    31741    stratification    TABLE     m   CREATE TABLE public.stratification (
    id bigint NOT NULL,
    description text,
    tilelayer_url text
);
 "   DROP TABLE public.stratification;
       public         heap 	   statsuser    false            *           1259    31746    stratification_geom    TABLE     �   CREATE TABLE public.stratification_geom (
    id bigint NOT NULL,
    stratification_id bigint NOT NULL,
    geom public.geometry(MultiPolygon,4326),
    geom3857 public.geometry(MultiPolygon,3857),
    description text
);
 '   DROP TABLE public.stratification_geom;
       public         heap 	   statsuser    false    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3            +           1259    31751    stratification_geom_id_seq    SEQUENCE     �   CREATE SEQUENCE public.stratification_geom_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE public.stratification_geom_id_seq;
       public       	   statsuser    false    298            �           0    0    stratification_geom_id_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE public.stratification_geom_id_seq OWNED BY public.stratification_geom.id;
          public       	   statsuser    false    299            ,           1259    31752    stratification_id_seq    SEQUENCE     ~   CREATE SEQUENCE public.stratification_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE public.stratification_id_seq;
       public       	   statsuser    false    297                        0    0    stratification_id_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE public.stratification_id_seq OWNED BY public.stratification.id;
          public       	   statsuser    false    300            -           1259    31753    tmp    TABLE     6   CREATE TABLE public.tmp (
    json_object_agg json
);
    DROP TABLE public.tmp;
       public         heap 	   statsuser    false            .           1259    31758    wms_file    TABLE     �   CREATE TABLE public.wms_file (
    id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint,
    rel_file_path text
);
    DROP TABLE public.wms_file;
       public         heap 	   statsuser    false            /           1259    31763    wms_file_id_seq    SEQUENCE     x   CREATE SEQUENCE public.wms_file_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.wms_file_id_seq;
       public       	   statsuser    false    302                       0    0    wms_file_id_seq    SEQUENCE OWNED BY     C   ALTER SEQUENCE public.wms_file_id_seq OWNED BY public.wms_file.id;
          public       	   statsuser    false    303            0           1259    31764    poly_stats_per_region    TABLE     �  CREATE TABLE tmp.poly_stats_per_region (
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
       tmp         heap 	   statsuser    false    5            1           1259    31772    poly_stats_per_region_id_seq    SEQUENCE     �   CREATE SEQUENCE tmp.poly_stats_per_region_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE tmp.poly_stats_per_region_id_seq;
       tmp       	   statsuser    false    304    5                       0    0    poly_stats_per_region_id_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE tmp.poly_stats_per_region_id_seq OWNED BY tmp.poly_stats_per_region.id;
          tmp       	   statsuser    false    305            \           0    0    poly_stats_10_1_257    TABLE ATTACH     }   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_10_1_257 FOR VALUES FROM ('10', '1') TO ('10', '257');
          public       	   statsuser    false    228    227            ]           0    0    poly_stats_10_257_279    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_10_257_279 FOR VALUES FROM ('10', '257') TO ('10', '279');
          public       	   statsuser    false    229    227            ^           0    0    poly_stats_10_279_285    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_10_279_285 FOR VALUES FROM ('10', '279') TO ('10', '285');
          public       	   statsuser    false    230    227            _           0    0    poly_stats_10_285_38543    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_10_285_38543 FOR VALUES FROM ('10', '285') TO ('10', '38543');
          public       	   statsuser    false    231    227            `           0    0    poly_stats_12_1_257    TABLE ATTACH     }   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_12_1_257 FOR VALUES FROM ('12', '1') TO ('12', '257');
          public       	   statsuser    false    232    227            a           0    0    poly_stats_12_257_279    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_12_257_279 FOR VALUES FROM ('12', '257') TO ('12', '279');
          public       	   statsuser    false    233    227            b           0    0    poly_stats_12_279_285    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_12_279_285 FOR VALUES FROM ('12', '279') TO ('12', '285');
          public       	   statsuser    false    234    227            c           0    0    poly_stats_12_285_38543    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_12_285_38543 FOR VALUES FROM ('12', '285') TO ('12', '38543');
          public       	   statsuser    false    235    227            d           0    0    poly_stats_14_1_257    TABLE ATTACH     }   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_14_1_257 FOR VALUES FROM ('14', '1') TO ('14', '257');
          public       	   statsuser    false    236    227            e           0    0    poly_stats_14_257_279    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_14_257_279 FOR VALUES FROM ('14', '257') TO ('14', '279');
          public       	   statsuser    false    237    227            f           0    0    poly_stats_14_279_285    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_14_279_285 FOR VALUES FROM ('14', '279') TO ('14', '285');
          public       	   statsuser    false    238    227            g           0    0    poly_stats_14_285_38543    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_14_285_38543 FOR VALUES FROM ('14', '285') TO ('14', '38543');
          public       	   statsuser    false    239    227            h           0    0    poly_stats_16_1_257    TABLE ATTACH     }   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_16_1_257 FOR VALUES FROM ('16', '1') TO ('16', '257');
          public       	   statsuser    false    240    227            i           0    0    poly_stats_16_257_279    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_16_257_279 FOR VALUES FROM ('16', '257') TO ('16', '279');
          public       	   statsuser    false    241    227            j           0    0    poly_stats_16_279_285    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_16_279_285 FOR VALUES FROM ('16', '279') TO ('16', '285');
          public       	   statsuser    false    242    227            k           0    0    poly_stats_16_285_38543    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_16_285_38543 FOR VALUES FROM ('16', '285') TO ('16', '38543');
          public       	   statsuser    false    243    227            l           0    0    poly_stats_17_1_257    TABLE ATTACH     }   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_17_1_257 FOR VALUES FROM ('17', '1') TO ('17', '257');
          public       	   statsuser    false    244    227            m           0    0    poly_stats_17_257_279    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_17_257_279 FOR VALUES FROM ('17', '257') TO ('17', '279');
          public       	   statsuser    false    245    227            n           0    0    poly_stats_17_279_285    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_17_279_285 FOR VALUES FROM ('17', '279') TO ('17', '285');
          public       	   statsuser    false    246    227            o           0    0    poly_stats_17_285_38543    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_17_285_38543 FOR VALUES FROM ('17', '285') TO ('17', '38543');
          public       	   statsuser    false    247    227            p           0    0    poly_stats_19_1_257    TABLE ATTACH     }   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_19_1_257 FOR VALUES FROM ('19', '1') TO ('19', '257');
          public       	   statsuser    false    248    227            q           0    0    poly_stats_19_257_279    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_19_257_279 FOR VALUES FROM ('19', '257') TO ('19', '279');
          public       	   statsuser    false    249    227            r           0    0    poly_stats_19_279_285    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_19_279_285 FOR VALUES FROM ('19', '279') TO ('19', '285');
          public       	   statsuser    false    250    227            s           0    0    poly_stats_19_285_38543    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_19_285_38543 FOR VALUES FROM ('19', '285') TO ('19', '38543');
          public       	   statsuser    false    251    227            t           0    0    poly_stats_1_1_257    TABLE ATTACH     z   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_1_1_257 FOR VALUES FROM ('1', '1') TO ('1', '257');
          public       	   statsuser    false    252    227            u           0    0    poly_stats_1_257_279    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_1_257_279 FOR VALUES FROM ('1', '257') TO ('1', '279');
          public       	   statsuser    false    253    227            v           0    0    poly_stats_1_279_285    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_1_279_285 FOR VALUES FROM ('1', '279') TO ('1', '285');
          public       	   statsuser    false    254    227            w           0    0    poly_stats_1_285_38543    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_1_285_38543 FOR VALUES FROM ('1', '285') TO ('1', '38543');
          public       	   statsuser    false    255    227            x           0    0    poly_stats_21_1_257    TABLE ATTACH     }   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_21_1_257 FOR VALUES FROM ('21', '1') TO ('21', '257');
          public       	   statsuser    false    256    227            y           0    0    poly_stats_21_257_279    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_21_257_279 FOR VALUES FROM ('21', '257') TO ('21', '279');
          public       	   statsuser    false    257    227            z           0    0    poly_stats_21_279_285    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_21_279_285 FOR VALUES FROM ('21', '279') TO ('21', '285');
          public       	   statsuser    false    258    227            {           0    0    poly_stats_21_285_38543    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_21_285_38543 FOR VALUES FROM ('21', '285') TO ('21', '38543');
          public       	   statsuser    false    259    227            �           0    0    poly_stats_24_1_257    TABLE ATTACH     }   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_24_1_257 FOR VALUES FROM ('24', '1') TO ('24', '257');
          public       	   statsuser    false    307    227            |           0    0    poly_stats_2_1_257    TABLE ATTACH     z   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_2_1_257 FOR VALUES FROM ('2', '1') TO ('2', '257');
          public       	   statsuser    false    260    227            }           0    0    poly_stats_2_257_279    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_2_257_279 FOR VALUES FROM ('2', '257') TO ('2', '279');
          public       	   statsuser    false    261    227            ~           0    0    poly_stats_2_279_285    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_2_279_285 FOR VALUES FROM ('2', '279') TO ('2', '285');
          public       	   statsuser    false    262    227                       0    0    poly_stats_2_285_38543    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_2_285_38543 FOR VALUES FROM ('2', '285') TO ('2', '38543');
          public       	   statsuser    false    263    227            �           0    0    poly_stats_3_1_257    TABLE ATTACH     z   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_3_1_257 FOR VALUES FROM ('3', '1') TO ('3', '257');
          public       	   statsuser    false    264    227            �           0    0    poly_stats_3_257_279    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_3_257_279 FOR VALUES FROM ('3', '257') TO ('3', '279');
          public       	   statsuser    false    265    227            �           0    0    poly_stats_3_279_285    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_3_279_285 FOR VALUES FROM ('3', '279') TO ('3', '285');
          public       	   statsuser    false    266    227            �           0    0    poly_stats_3_285_38543    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_3_285_38543 FOR VALUES FROM ('3', '285') TO ('3', '38543');
          public       	   statsuser    false    267    227            �           0    0    poly_stats_4_1_257    TABLE ATTACH     z   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_4_1_257 FOR VALUES FROM ('4', '1') TO ('4', '257');
          public       	   statsuser    false    268    227            �           0    0    poly_stats_4_257_279    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_4_257_279 FOR VALUES FROM ('4', '257') TO ('4', '279');
          public       	   statsuser    false    269    227            �           0    0    poly_stats_4_279_285    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_4_279_285 FOR VALUES FROM ('4', '279') TO ('4', '285');
          public       	   statsuser    false    270    227            �           0    0    poly_stats_4_285_38543    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_4_285_38543 FOR VALUES FROM ('4', '285') TO ('4', '38543');
          public       	   statsuser    false    271    227            �           0    0    poly_stats_5_1_257    TABLE ATTACH     z   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_5_1_257 FOR VALUES FROM ('5', '1') TO ('5', '257');
          public       	   statsuser    false    272    227            �           0    0    poly_stats_5_257_279    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_5_257_279 FOR VALUES FROM ('5', '257') TO ('5', '279');
          public       	   statsuser    false    273    227            �           0    0    poly_stats_5_279_285    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_5_279_285 FOR VALUES FROM ('5', '279') TO ('5', '285');
          public       	   statsuser    false    274    227            �           0    0    poly_stats_5_285_38543    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_5_285_38543 FOR VALUES FROM ('5', '285') TO ('5', '38543');
          public       	   statsuser    false    275    227            �           0    0    poly_stats_6_1_257    TABLE ATTACH     z   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_6_1_257 FOR VALUES FROM ('6', '1') TO ('6', '257');
          public       	   statsuser    false    276    227            �           0    0    poly_stats_6_257_279    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_6_257_279 FOR VALUES FROM ('6', '257') TO ('6', '279');
          public       	   statsuser    false    277    227            �           0    0    poly_stats_6_279_285    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_6_279_285 FOR VALUES FROM ('6', '279') TO ('6', '285');
          public       	   statsuser    false    278    227            �           0    0    poly_stats_6_285_38543    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_6_285_38543 FOR VALUES FROM ('6', '285') TO ('6', '38543');
          public       	   statsuser    false    279    227            �           0    0    poly_stats_7_1_257    TABLE ATTACH     z   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_7_1_257 FOR VALUES FROM ('7', '1') TO ('7', '257');
          public       	   statsuser    false    280    227            �           0    0    poly_stats_7_257_279    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_7_257_279 FOR VALUES FROM ('7', '257') TO ('7', '279');
          public       	   statsuser    false    281    227            �           0    0    poly_stats_7_279_285    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_7_279_285 FOR VALUES FROM ('7', '279') TO ('7', '285');
          public       	   statsuser    false    282    227            �           0    0    poly_stats_7_285_38543    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_7_285_38543 FOR VALUES FROM ('7', '285') TO ('7', '38543');
          public       	   statsuser    false    283    227            �           0    0    poly_stats_9_1_257    TABLE ATTACH     z   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_9_1_257 FOR VALUES FROM ('9', '1') TO ('9', '257');
          public       	   statsuser    false    284    227            �           0    0    poly_stats_9_257_279    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_9_257_279 FOR VALUES FROM ('9', '257') TO ('9', '279');
          public       	   statsuser    false    285    227            �           0    0    poly_stats_9_279_285    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_9_279_285 FOR VALUES FROM ('9', '279') TO ('9', '285');
          public       	   statsuser    false    286    227            �           0    0    poly_stats_9_285_38543    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_9_285_38543 FOR VALUES FROM ('9', '285') TO ('9', '38543');
          public       	   statsuser    false    287    227            �           2604    31773    long_term_anomaly_info id    DEFAULT     �   ALTER TABLE ONLY public.long_term_anomaly_info ALTER COLUMN id SET DEFAULT nextval('public.long_term_anomaly_info_id_seq'::regclass);
 H   ALTER TABLE public.long_term_anomaly_info ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    225    224            R           2604    31774 
   product id    DEFAULT     h   ALTER TABLE ONLY public.product ALTER COLUMN id SET DEFAULT nextval('public.product_id_seq'::regclass);
 9   ALTER TABLE public.product ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    296    288            T           2604    31775    product_file id    DEFAULT     s   ALTER TABLE ONLY public.product_file ALTER COLUMN id SET DEFAULT nextval('public.product_file_id_seq1'::regclass);
 >   ALTER TABLE public.product_file ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    293    289            V           2604    31776    product_file_description id    DEFAULT     �   ALTER TABLE ONLY public.product_file_description ALTER COLUMN id SET DEFAULT nextval('public.product_file_description_id_seq'::regclass);
 J   ALTER TABLE public.product_file_description ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    291    290            W           2604    31777    product_file_variable id    DEFAULT     �   ALTER TABLE ONLY public.product_file_variable ALTER COLUMN id SET DEFAULT nextval('public.product_file_variable_id_seq'::regclass);
 G   ALTER TABLE public.product_file_variable ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    295    294            Y           2604    31778    stratification id    DEFAULT     v   ALTER TABLE ONLY public.stratification ALTER COLUMN id SET DEFAULT nextval('public.stratification_id_seq'::regclass);
 @   ALTER TABLE public.stratification ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    300    297            Z           2604    31779    stratification_geom id    DEFAULT     �   ALTER TABLE ONLY public.stratification_geom ALTER COLUMN id SET DEFAULT nextval('public.stratification_geom_id_seq'::regclass);
 E   ALTER TABLE public.stratification_geom ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    299    298            [           2604    31780    wms_file id    DEFAULT     j   ALTER TABLE ONLY public.wms_file ALTER COLUMN id SET DEFAULT nextval('public.wms_file_id_seq'::regclass);
 :   ALTER TABLE public.wms_file ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    303    302            \           2604    31781    poly_stats_per_region id    DEFAULT     ~   ALTER TABLE ONLY tmp.poly_stats_per_region ALTER COLUMN id SET DEFAULT nextval('tmp.poly_stats_per_region_id_seq'::regclass);
 D   ALTER TABLE tmp.poly_stats_per_region ALTER COLUMN id DROP DEFAULT;
       tmp       	   statsuser    false    305    304            l           2606    31783 0   long_term_anomaly_info long_term_anomaly_info_pk 
   CONSTRAINT     n   ALTER TABLE ONLY public.long_term_anomaly_info
    ADD CONSTRAINT long_term_anomaly_info_pk PRIMARY KEY (id);
 Z   ALTER TABLE ONLY public.long_term_anomaly_info DROP CONSTRAINT long_term_anomaly_info_pk;
       public         	   statsuser    false    224            j           2606    31785    category newtable_pk 
   CONSTRAINT     R   ALTER TABLE ONLY public.category
    ADD CONSTRAINT newtable_pk PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.category DROP CONSTRAINT newtable_pk;
       public         	   statsuser    false    222            n           2606    31787    poly_stats poly_stats_pk_ 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats
    ADD CONSTRAINT poly_stats_pk_ PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 C   ALTER TABLE ONLY public.poly_stats DROP CONSTRAINT poly_stats_pk_;
       public         	   statsuser    false    227    227    227            q           2606    31789 ,   poly_stats_10_1_257 poly_stats_10_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_10_1_257
    ADD CONSTRAINT poly_stats_10_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 V   ALTER TABLE ONLY public.poly_stats_10_1_257 DROP CONSTRAINT poly_stats_10_1_257_pkey;
       public         	   statsuser    false    228    228    228    4718    228            t           2606    31791 0   poly_stats_10_257_279 poly_stats_10_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_10_257_279
    ADD CONSTRAINT poly_stats_10_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_10_257_279 DROP CONSTRAINT poly_stats_10_257_279_pkey;
       public         	   statsuser    false    229    4718    229    229    229            w           2606    31793 0   poly_stats_10_279_285 poly_stats_10_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_10_279_285
    ADD CONSTRAINT poly_stats_10_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_10_279_285 DROP CONSTRAINT poly_stats_10_279_285_pkey;
       public         	   statsuser    false    230    230    230    230    4718            z           2606    31795 4   poly_stats_10_285_38543 poly_stats_10_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_10_285_38543
    ADD CONSTRAINT poly_stats_10_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 ^   ALTER TABLE ONLY public.poly_stats_10_285_38543 DROP CONSTRAINT poly_stats_10_285_38543_pkey;
       public         	   statsuser    false    4718    231    231    231    231            }           2606    31797 ,   poly_stats_12_1_257 poly_stats_12_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_12_1_257
    ADD CONSTRAINT poly_stats_12_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 V   ALTER TABLE ONLY public.poly_stats_12_1_257 DROP CONSTRAINT poly_stats_12_1_257_pkey;
       public         	   statsuser    false    232    232    232    232    4718            �           2606    31799 0   poly_stats_12_257_279 poly_stats_12_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_12_257_279
    ADD CONSTRAINT poly_stats_12_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_12_257_279 DROP CONSTRAINT poly_stats_12_257_279_pkey;
       public         	   statsuser    false    233    4718    233    233    233            �           2606    31801 0   poly_stats_12_279_285 poly_stats_12_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_12_279_285
    ADD CONSTRAINT poly_stats_12_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_12_279_285 DROP CONSTRAINT poly_stats_12_279_285_pkey;
       public         	   statsuser    false    4718    234    234    234    234            �           2606    31803 4   poly_stats_12_285_38543 poly_stats_12_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_12_285_38543
    ADD CONSTRAINT poly_stats_12_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 ^   ALTER TABLE ONLY public.poly_stats_12_285_38543 DROP CONSTRAINT poly_stats_12_285_38543_pkey;
       public         	   statsuser    false    235    235    4718    235    235            �           2606    31805 ,   poly_stats_14_1_257 poly_stats_14_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_14_1_257
    ADD CONSTRAINT poly_stats_14_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 V   ALTER TABLE ONLY public.poly_stats_14_1_257 DROP CONSTRAINT poly_stats_14_1_257_pkey;
       public         	   statsuser    false    4718    236    236    236    236            �           2606    31807 0   poly_stats_14_257_279 poly_stats_14_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_14_257_279
    ADD CONSTRAINT poly_stats_14_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_14_257_279 DROP CONSTRAINT poly_stats_14_257_279_pkey;
       public         	   statsuser    false    237    237    237    237    4718            �           2606    31809 0   poly_stats_14_279_285 poly_stats_14_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_14_279_285
    ADD CONSTRAINT poly_stats_14_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_14_279_285 DROP CONSTRAINT poly_stats_14_279_285_pkey;
       public         	   statsuser    false    238    238    238    4718    238            �           2606    31811 4   poly_stats_14_285_38543 poly_stats_14_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_14_285_38543
    ADD CONSTRAINT poly_stats_14_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 ^   ALTER TABLE ONLY public.poly_stats_14_285_38543 DROP CONSTRAINT poly_stats_14_285_38543_pkey;
       public         	   statsuser    false    239    4718    239    239    239            �           2606    31813 ,   poly_stats_16_1_257 poly_stats_16_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_16_1_257
    ADD CONSTRAINT poly_stats_16_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 V   ALTER TABLE ONLY public.poly_stats_16_1_257 DROP CONSTRAINT poly_stats_16_1_257_pkey;
       public         	   statsuser    false    240    240    240    4718    240            �           2606    31815 0   poly_stats_16_257_279 poly_stats_16_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_16_257_279
    ADD CONSTRAINT poly_stats_16_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_16_257_279 DROP CONSTRAINT poly_stats_16_257_279_pkey;
       public         	   statsuser    false    241    241    241    4718    241            �           2606    31817 0   poly_stats_16_279_285 poly_stats_16_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_16_279_285
    ADD CONSTRAINT poly_stats_16_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_16_279_285 DROP CONSTRAINT poly_stats_16_279_285_pkey;
       public         	   statsuser    false    242    242    242    242    4718            �           2606    31819 4   poly_stats_16_285_38543 poly_stats_16_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_16_285_38543
    ADD CONSTRAINT poly_stats_16_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 ^   ALTER TABLE ONLY public.poly_stats_16_285_38543 DROP CONSTRAINT poly_stats_16_285_38543_pkey;
       public         	   statsuser    false    243    243    4718    243    243            �           2606    31821 ,   poly_stats_17_1_257 poly_stats_17_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_17_1_257
    ADD CONSTRAINT poly_stats_17_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 V   ALTER TABLE ONLY public.poly_stats_17_1_257 DROP CONSTRAINT poly_stats_17_1_257_pkey;
       public         	   statsuser    false    4718    244    244    244    244            �           2606    31823 0   poly_stats_17_257_279 poly_stats_17_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_17_257_279
    ADD CONSTRAINT poly_stats_17_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_17_257_279 DROP CONSTRAINT poly_stats_17_257_279_pkey;
       public         	   statsuser    false    245    4718    245    245    245            �           2606    31825 0   poly_stats_17_279_285 poly_stats_17_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_17_279_285
    ADD CONSTRAINT poly_stats_17_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_17_279_285 DROP CONSTRAINT poly_stats_17_279_285_pkey;
       public         	   statsuser    false    246    4718    246    246    246            �           2606    31827 4   poly_stats_17_285_38543 poly_stats_17_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_17_285_38543
    ADD CONSTRAINT poly_stats_17_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 ^   ALTER TABLE ONLY public.poly_stats_17_285_38543 DROP CONSTRAINT poly_stats_17_285_38543_pkey;
       public         	   statsuser    false    4718    247    247    247    247            �           2606    31829 ,   poly_stats_19_1_257 poly_stats_19_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_19_1_257
    ADD CONSTRAINT poly_stats_19_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 V   ALTER TABLE ONLY public.poly_stats_19_1_257 DROP CONSTRAINT poly_stats_19_1_257_pkey;
       public         	   statsuser    false    248    4718    248    248    248            �           2606    31831 0   poly_stats_19_257_279 poly_stats_19_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_19_257_279
    ADD CONSTRAINT poly_stats_19_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_19_257_279 DROP CONSTRAINT poly_stats_19_257_279_pkey;
       public         	   statsuser    false    249    4718    249    249    249            �           2606    31833 0   poly_stats_19_279_285 poly_stats_19_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_19_279_285
    ADD CONSTRAINT poly_stats_19_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_19_279_285 DROP CONSTRAINT poly_stats_19_279_285_pkey;
       public         	   statsuser    false    4718    250    250    250    250            �           2606    31835 4   poly_stats_19_285_38543 poly_stats_19_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_19_285_38543
    ADD CONSTRAINT poly_stats_19_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 ^   ALTER TABLE ONLY public.poly_stats_19_285_38543 DROP CONSTRAINT poly_stats_19_285_38543_pkey;
       public         	   statsuser    false    251    251    4718    251    251            �           2606    31837 *   poly_stats_1_1_257 poly_stats_1_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_1_1_257
    ADD CONSTRAINT poly_stats_1_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 T   ALTER TABLE ONLY public.poly_stats_1_1_257 DROP CONSTRAINT poly_stats_1_1_257_pkey;
       public         	   statsuser    false    252    252    4718    252    252            �           2606    31839 .   poly_stats_1_257_279 poly_stats_1_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_1_257_279
    ADD CONSTRAINT poly_stats_1_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_1_257_279 DROP CONSTRAINT poly_stats_1_257_279_pkey;
       public         	   statsuser    false    253    253    253    253    4718            �           2606    31841 .   poly_stats_1_279_285 poly_stats_1_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_1_279_285
    ADD CONSTRAINT poly_stats_1_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_1_279_285 DROP CONSTRAINT poly_stats_1_279_285_pkey;
       public         	   statsuser    false    254    4718    254    254    254            �           2606    31843 2   poly_stats_1_285_38543 poly_stats_1_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_1_285_38543
    ADD CONSTRAINT poly_stats_1_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 \   ALTER TABLE ONLY public.poly_stats_1_285_38543 DROP CONSTRAINT poly_stats_1_285_38543_pkey;
       public         	   statsuser    false    255    4718    255    255    255            �           2606    31845 ,   poly_stats_21_1_257 poly_stats_21_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_21_1_257
    ADD CONSTRAINT poly_stats_21_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 V   ALTER TABLE ONLY public.poly_stats_21_1_257 DROP CONSTRAINT poly_stats_21_1_257_pkey;
       public         	   statsuser    false    4718    256    256    256    256            �           2606    31847 0   poly_stats_21_257_279 poly_stats_21_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_21_257_279
    ADD CONSTRAINT poly_stats_21_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_21_257_279 DROP CONSTRAINT poly_stats_21_257_279_pkey;
       public         	   statsuser    false    257    257    257    4718    257            �           2606    31849 0   poly_stats_21_279_285 poly_stats_21_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_21_279_285
    ADD CONSTRAINT poly_stats_21_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_21_279_285 DROP CONSTRAINT poly_stats_21_279_285_pkey;
       public         	   statsuser    false    4718    258    258    258    258            �           2606    31851 4   poly_stats_21_285_38543 poly_stats_21_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_21_285_38543
    ADD CONSTRAINT poly_stats_21_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 ^   ALTER TABLE ONLY public.poly_stats_21_285_38543 DROP CONSTRAINT poly_stats_21_285_38543_pkey;
       public         	   statsuser    false    259    259    259    4718    259            C           2606    34813 ,   poly_stats_24_1_257 poly_stats_24_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_24_1_257
    ADD CONSTRAINT poly_stats_24_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 V   ALTER TABLE ONLY public.poly_stats_24_1_257 DROP CONSTRAINT poly_stats_24_1_257_pkey;
       public         	   statsuser    false    307    307    4718    307    307            �           2606    31853 *   poly_stats_2_1_257 poly_stats_2_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_2_1_257
    ADD CONSTRAINT poly_stats_2_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 T   ALTER TABLE ONLY public.poly_stats_2_1_257 DROP CONSTRAINT poly_stats_2_1_257_pkey;
       public         	   statsuser    false    260    260    260    260    4718            �           2606    31855 .   poly_stats_2_257_279 poly_stats_2_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_2_257_279
    ADD CONSTRAINT poly_stats_2_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_2_257_279 DROP CONSTRAINT poly_stats_2_257_279_pkey;
       public         	   statsuser    false    261    261    261    4718    261            �           2606    31857 .   poly_stats_2_279_285 poly_stats_2_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_2_279_285
    ADD CONSTRAINT poly_stats_2_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_2_279_285 DROP CONSTRAINT poly_stats_2_279_285_pkey;
       public         	   statsuser    false    262    262    4718    262    262            �           2606    31859 2   poly_stats_2_285_38543 poly_stats_2_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_2_285_38543
    ADD CONSTRAINT poly_stats_2_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 \   ALTER TABLE ONLY public.poly_stats_2_285_38543 DROP CONSTRAINT poly_stats_2_285_38543_pkey;
       public         	   statsuser    false    4718    263    263    263    263            �           2606    31861 *   poly_stats_3_1_257 poly_stats_3_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_3_1_257
    ADD CONSTRAINT poly_stats_3_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 T   ALTER TABLE ONLY public.poly_stats_3_1_257 DROP CONSTRAINT poly_stats_3_1_257_pkey;
       public         	   statsuser    false    4718    264    264    264    264            �           2606    31863 .   poly_stats_3_257_279 poly_stats_3_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_3_257_279
    ADD CONSTRAINT poly_stats_3_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_3_257_279 DROP CONSTRAINT poly_stats_3_257_279_pkey;
       public         	   statsuser    false    265    265    265    4718    265            �           2606    31865 .   poly_stats_3_279_285 poly_stats_3_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_3_279_285
    ADD CONSTRAINT poly_stats_3_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_3_279_285 DROP CONSTRAINT poly_stats_3_279_285_pkey;
       public         	   statsuser    false    266    266    266    266    4718            �           2606    31867 2   poly_stats_3_285_38543 poly_stats_3_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_3_285_38543
    ADD CONSTRAINT poly_stats_3_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 \   ALTER TABLE ONLY public.poly_stats_3_285_38543 DROP CONSTRAINT poly_stats_3_285_38543_pkey;
       public         	   statsuser    false    4718    267    267    267    267            �           2606    31869 *   poly_stats_4_1_257 poly_stats_4_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_4_1_257
    ADD CONSTRAINT poly_stats_4_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 T   ALTER TABLE ONLY public.poly_stats_4_1_257 DROP CONSTRAINT poly_stats_4_1_257_pkey;
       public         	   statsuser    false    268    4718    268    268    268            �           2606    31871 .   poly_stats_4_257_279 poly_stats_4_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_4_257_279
    ADD CONSTRAINT poly_stats_4_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_4_257_279 DROP CONSTRAINT poly_stats_4_257_279_pkey;
       public         	   statsuser    false    269    269    4718    269    269            �           2606    31873 .   poly_stats_4_279_285 poly_stats_4_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_4_279_285
    ADD CONSTRAINT poly_stats_4_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_4_279_285 DROP CONSTRAINT poly_stats_4_279_285_pkey;
       public         	   statsuser    false    270    270    270    270    4718            �           2606    31875 2   poly_stats_4_285_38543 poly_stats_4_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_4_285_38543
    ADD CONSTRAINT poly_stats_4_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 \   ALTER TABLE ONLY public.poly_stats_4_285_38543 DROP CONSTRAINT poly_stats_4_285_38543_pkey;
       public         	   statsuser    false    271    271    271    271    4718            �           2606    31877 *   poly_stats_5_1_257 poly_stats_5_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_5_1_257
    ADD CONSTRAINT poly_stats_5_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 T   ALTER TABLE ONLY public.poly_stats_5_1_257 DROP CONSTRAINT poly_stats_5_1_257_pkey;
       public         	   statsuser    false    272    272    4718    272    272            �           2606    31879 .   poly_stats_5_257_279 poly_stats_5_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_5_257_279
    ADD CONSTRAINT poly_stats_5_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_5_257_279 DROP CONSTRAINT poly_stats_5_257_279_pkey;
       public         	   statsuser    false    273    273    273    273    4718            �           2606    31881 .   poly_stats_5_279_285 poly_stats_5_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_5_279_285
    ADD CONSTRAINT poly_stats_5_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_5_279_285 DROP CONSTRAINT poly_stats_5_279_285_pkey;
       public         	   statsuser    false    274    274    274    4718    274            �           2606    31883 2   poly_stats_5_285_38543 poly_stats_5_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_5_285_38543
    ADD CONSTRAINT poly_stats_5_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 \   ALTER TABLE ONLY public.poly_stats_5_285_38543 DROP CONSTRAINT poly_stats_5_285_38543_pkey;
       public         	   statsuser    false    275    275    275    4718    275                       2606    31885 *   poly_stats_6_1_257 poly_stats_6_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_6_1_257
    ADD CONSTRAINT poly_stats_6_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 T   ALTER TABLE ONLY public.poly_stats_6_1_257 DROP CONSTRAINT poly_stats_6_1_257_pkey;
       public         	   statsuser    false    4718    276    276    276    276                       2606    31887 .   poly_stats_6_257_279 poly_stats_6_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_6_257_279
    ADD CONSTRAINT poly_stats_6_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_6_257_279 DROP CONSTRAINT poly_stats_6_257_279_pkey;
       public         	   statsuser    false    277    277    277    277    4718                       2606    31889 .   poly_stats_6_279_285 poly_stats_6_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_6_279_285
    ADD CONSTRAINT poly_stats_6_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_6_279_285 DROP CONSTRAINT poly_stats_6_279_285_pkey;
       public         	   statsuser    false    278    278    4718    278    278            
           2606    31891 2   poly_stats_6_285_38543 poly_stats_6_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_6_285_38543
    ADD CONSTRAINT poly_stats_6_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 \   ALTER TABLE ONLY public.poly_stats_6_285_38543 DROP CONSTRAINT poly_stats_6_285_38543_pkey;
       public         	   statsuser    false    279    279    279    4718    279                       2606    31893 *   poly_stats_7_1_257 poly_stats_7_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_7_1_257
    ADD CONSTRAINT poly_stats_7_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 T   ALTER TABLE ONLY public.poly_stats_7_1_257 DROP CONSTRAINT poly_stats_7_1_257_pkey;
       public         	   statsuser    false    4718    280    280    280    280                       2606    31895 .   poly_stats_7_257_279 poly_stats_7_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_7_257_279
    ADD CONSTRAINT poly_stats_7_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_7_257_279 DROP CONSTRAINT poly_stats_7_257_279_pkey;
       public         	   statsuser    false    281    4718    281    281    281                       2606    31897 .   poly_stats_7_279_285 poly_stats_7_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_7_279_285
    ADD CONSTRAINT poly_stats_7_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_7_279_285 DROP CONSTRAINT poly_stats_7_279_285_pkey;
       public         	   statsuser    false    282    282    282    4718    282                       2606    31899 2   poly_stats_7_285_38543 poly_stats_7_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_7_285_38543
    ADD CONSTRAINT poly_stats_7_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 \   ALTER TABLE ONLY public.poly_stats_7_285_38543 DROP CONSTRAINT poly_stats_7_285_38543_pkey;
       public         	   statsuser    false    283    283    4718    283    283                       2606    31901 *   poly_stats_9_1_257 poly_stats_9_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_9_1_257
    ADD CONSTRAINT poly_stats_9_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 T   ALTER TABLE ONLY public.poly_stats_9_1_257 DROP CONSTRAINT poly_stats_9_1_257_pkey;
       public         	   statsuser    false    4718    284    284    284    284                       2606    31903 .   poly_stats_9_257_279 poly_stats_9_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_9_257_279
    ADD CONSTRAINT poly_stats_9_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_9_257_279 DROP CONSTRAINT poly_stats_9_257_279_pkey;
       public         	   statsuser    false    4718    285    285    285    285                       2606    31905 .   poly_stats_9_279_285 poly_stats_9_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_9_279_285
    ADD CONSTRAINT poly_stats_9_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_9_279_285 DROP CONSTRAINT poly_stats_9_279_285_pkey;
       public         	   statsuser    false    286    286    4718    286    286            "           2606    31907 2   poly_stats_9_285_38543 poly_stats_9_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_9_285_38543
    ADD CONSTRAINT poly_stats_9_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 \   ALTER TABLE ONLY public.poly_stats_9_285_38543 DROP CONSTRAINT poly_stats_9_285_38543_pkey;
       public         	   statsuser    false    287    287    287    287    4718            (           2606    31909 6   product_file product_file_date_product_description_idx 
   CONSTRAINT     �   ALTER TABLE ONLY public.product_file
    ADD CONSTRAINT product_file_date_product_description_idx UNIQUE (product_file_description_id, date, rt_flag);
 `   ALTER TABLE ONLY public.product_file DROP CONSTRAINT product_file_date_product_description_idx;
       public         	   statsuser    false    289    289    289            *           2606    31911    product_file product_file_pk 
   CONSTRAINT     Z   ALTER TABLE ONLY public.product_file
    ADD CONSTRAINT product_file_pk PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.product_file DROP CONSTRAINT product_file_pk;
       public         	   statsuser    false    289            .           2606    31913 .   product_file_variable product_file_variable_pk 
   CONSTRAINT     l   ALTER TABLE ONLY public.product_file_variable
    ADD CONSTRAINT product_file_variable_pk PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.product_file_variable DROP CONSTRAINT product_file_variable_pk;
       public         	   statsuser    false    294            A           2606    33061    product_order product_order_pk 
   CONSTRAINT     \   ALTER TABLE ONLY public.product_order
    ADD CONSTRAINT product_order_pk PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.product_order DROP CONSTRAINT product_order_pk;
       public         	   statsuser    false    306            %           2606    31915    product product_pk1 
   CONSTRAINT     Q   ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_pk1 PRIMARY KEY (id);
 =   ALTER TABLE ONLY public.product DROP CONSTRAINT product_pk1;
       public         	   statsuser    false    288            ,           2606    31917 <   product_file_description product_product_file_description_pk 
   CONSTRAINT     z   ALTER TABLE ONLY public.product_file_description
    ADD CONSTRAINT product_product_file_description_pk PRIMARY KEY (id);
 f   ALTER TABLE ONLY public.product_file_description DROP CONSTRAINT product_product_file_description_pk;
       public         	   statsuser    false    290            0           2606    31919     stratification stratification_pk 
   CONSTRAINT     ^   ALTER TABLE ONLY public.stratification
    ADD CONSTRAINT stratification_pk PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.stratification DROP CONSTRAINT stratification_pk;
       public         	   statsuser    false    297            6           2606    31921 '   stratification_geom stratification_pkey 
   CONSTRAINT     e   ALTER TABLE ONLY public.stratification_geom
    ADD CONSTRAINT stratification_pkey PRIMARY KEY (id);
 Q   ALTER TABLE ONLY public.stratification_geom DROP CONSTRAINT stratification_pkey;
       public         	   statsuser    false    298            2           2606    31923     stratification stratification_un 
   CONSTRAINT     b   ALTER TABLE ONLY public.stratification
    ADD CONSTRAINT stratification_un UNIQUE (description);
 J   ALTER TABLE ONLY public.stratification DROP CONSTRAINT stratification_un;
       public         	   statsuser    false    297            8           2606    31925    wms_file wms_file_pk 
   CONSTRAINT     R   ALTER TABLE ONLY public.wms_file
    ADD CONSTRAINT wms_file_pk PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.wms_file DROP CONSTRAINT wms_file_pk;
       public         	   statsuser    false    302            :           2606    31927    wms_file wms_file_un 
   CONSTRAINT     t   ALTER TABLE ONLY public.wms_file
    ADD CONSTRAINT wms_file_un UNIQUE (product_file_id, product_file_variable_id);
 >   ALTER TABLE ONLY public.wms_file DROP CONSTRAINT wms_file_un;
       public         	   statsuser    false    302    302            <           2606    31929 #   poly_stats_per_region poly_stats_pk 
   CONSTRAINT     ^   ALTER TABLE ONLY tmp.poly_stats_per_region
    ADD CONSTRAINT poly_stats_pk PRIMARY KEY (id);
 J   ALTER TABLE ONLY tmp.poly_stats_per_region DROP CONSTRAINT poly_stats_pk;
       tmp         	   statsuser    false    304            >           2606    31931 #   poly_stats_per_region poly_stats_un 
   CONSTRAINT     �   ALTER TABLE ONLY tmp.poly_stats_per_region
    ADD CONSTRAINT poly_stats_un UNIQUE (poly_id, product_file_id, product_file_variable_id, region_id);
 J   ALTER TABLE ONLY tmp.poly_stats_per_region DROP CONSTRAINT poly_stats_un;
       tmp         	   statsuser    false    304    304    304    304            o           1259    31932    poly_stats_product_file_id_idx    INDEX        CREATE INDEX poly_stats_product_file_id_idx ON ONLY public.poly_stats USING btree (product_file_id, product_file_variable_id);
 2   DROP INDEX public.poly_stats_product_file_id_idx;
       public         	   statsuser    false    227    227            r           1259    31933 ?   poly_stats_10_1_257_product_file_id_product_file_variable_i_idx    INDEX     �   CREATE INDEX poly_stats_10_1_257_product_file_id_product_file_variable_i_idx ON public.poly_stats_10_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_10_1_257_product_file_id_product_file_variable_i_idx;
       public         	   statsuser    false    228    4719    228    228            u           1259    31934 ?   poly_stats_10_257_279_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_10_257_279_product_file_id_product_file_variable_idx ON public.poly_stats_10_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_10_257_279_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    4719    229    229    229            x           1259    31935 ?   poly_stats_10_279_285_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_10_279_285_product_file_id_product_file_variable_idx ON public.poly_stats_10_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_10_279_285_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    230    230    230    4719            {           1259    31936 ?   poly_stats_10_285_38543_product_file_id_product_file_variab_idx    INDEX     �   CREATE INDEX poly_stats_10_285_38543_product_file_id_product_file_variab_idx ON public.poly_stats_10_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_10_285_38543_product_file_id_product_file_variab_idx;
       public         	   statsuser    false    231    4719    231    231            ~           1259    31937 ?   poly_stats_12_1_257_product_file_id_product_file_variable_i_idx    INDEX     �   CREATE INDEX poly_stats_12_1_257_product_file_id_product_file_variable_i_idx ON public.poly_stats_12_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_12_1_257_product_file_id_product_file_variable_i_idx;
       public         	   statsuser    false    232    4719    232    232            �           1259    31938 ?   poly_stats_12_257_279_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_12_257_279_product_file_id_product_file_variable_idx ON public.poly_stats_12_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_12_257_279_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    233    233    233    4719            �           1259    31939 ?   poly_stats_12_279_285_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_12_279_285_product_file_id_product_file_variable_idx ON public.poly_stats_12_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_12_279_285_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    234    4719    234    234            �           1259    31940 ?   poly_stats_12_285_38543_product_file_id_product_file_variab_idx    INDEX     �   CREATE INDEX poly_stats_12_285_38543_product_file_id_product_file_variab_idx ON public.poly_stats_12_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_12_285_38543_product_file_id_product_file_variab_idx;
       public         	   statsuser    false    235    4719    235    235            �           1259    31941 ?   poly_stats_14_1_257_product_file_id_product_file_variable_i_idx    INDEX     �   CREATE INDEX poly_stats_14_1_257_product_file_id_product_file_variable_i_idx ON public.poly_stats_14_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_14_1_257_product_file_id_product_file_variable_i_idx;
       public         	   statsuser    false    236    4719    236    236            �           1259    31942 ?   poly_stats_14_257_279_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_14_257_279_product_file_id_product_file_variable_idx ON public.poly_stats_14_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_14_257_279_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    237    237    237    4719            �           1259    31943 ?   poly_stats_14_279_285_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_14_279_285_product_file_id_product_file_variable_idx ON public.poly_stats_14_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_14_279_285_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    238    238    4719    238            �           1259    31944 ?   poly_stats_14_285_38543_product_file_id_product_file_variab_idx    INDEX     �   CREATE INDEX poly_stats_14_285_38543_product_file_id_product_file_variab_idx ON public.poly_stats_14_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_14_285_38543_product_file_id_product_file_variab_idx;
       public         	   statsuser    false    4719    239    239    239            �           1259    31945 ?   poly_stats_16_1_257_product_file_id_product_file_variable_i_idx    INDEX     �   CREATE INDEX poly_stats_16_1_257_product_file_id_product_file_variable_i_idx ON public.poly_stats_16_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_16_1_257_product_file_id_product_file_variable_i_idx;
       public         	   statsuser    false    240    240    240    4719            �           1259    31946 ?   poly_stats_16_257_279_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_16_257_279_product_file_id_product_file_variable_idx ON public.poly_stats_16_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_16_257_279_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    241    241    4719    241            �           1259    31947 ?   poly_stats_16_279_285_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_16_279_285_product_file_id_product_file_variable_idx ON public.poly_stats_16_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_16_279_285_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    242    242    242    4719            �           1259    31948 ?   poly_stats_16_285_38543_product_file_id_product_file_variab_idx    INDEX     �   CREATE INDEX poly_stats_16_285_38543_product_file_id_product_file_variab_idx ON public.poly_stats_16_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_16_285_38543_product_file_id_product_file_variab_idx;
       public         	   statsuser    false    243    243    4719    243            �           1259    31949 ?   poly_stats_17_1_257_product_file_id_product_file_variable_i_idx    INDEX     �   CREATE INDEX poly_stats_17_1_257_product_file_id_product_file_variable_i_idx ON public.poly_stats_17_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_17_1_257_product_file_id_product_file_variable_i_idx;
       public         	   statsuser    false    244    244    4719    244            �           1259    31950 ?   poly_stats_17_257_279_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_17_257_279_product_file_id_product_file_variable_idx ON public.poly_stats_17_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_17_257_279_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    245    4719    245    245            �           1259    31951 ?   poly_stats_17_279_285_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_17_279_285_product_file_id_product_file_variable_idx ON public.poly_stats_17_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_17_279_285_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    4719    246    246    246            �           1259    31952 ?   poly_stats_17_285_38543_product_file_id_product_file_variab_idx    INDEX     �   CREATE INDEX poly_stats_17_285_38543_product_file_id_product_file_variab_idx ON public.poly_stats_17_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_17_285_38543_product_file_id_product_file_variab_idx;
       public         	   statsuser    false    247    247    247    4719            �           1259    31953 ?   poly_stats_19_1_257_product_file_id_product_file_variable_i_idx    INDEX     �   CREATE INDEX poly_stats_19_1_257_product_file_id_product_file_variable_i_idx ON public.poly_stats_19_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_19_1_257_product_file_id_product_file_variable_i_idx;
       public         	   statsuser    false    248    248    248    4719            �           1259    31954 ?   poly_stats_19_257_279_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_19_257_279_product_file_id_product_file_variable_idx ON public.poly_stats_19_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_19_257_279_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    249    249    249    4719            �           1259    31955 ?   poly_stats_19_279_285_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_19_279_285_product_file_id_product_file_variable_idx ON public.poly_stats_19_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_19_279_285_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    250    250    4719    250            �           1259    31956 ?   poly_stats_19_285_38543_product_file_id_product_file_variab_idx    INDEX     �   CREATE INDEX poly_stats_19_285_38543_product_file_id_product_file_variab_idx ON public.poly_stats_19_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_19_285_38543_product_file_id_product_file_variab_idx;
       public         	   statsuser    false    4719    251    251    251            �           1259    31957 ?   poly_stats_1_1_257_product_file_id_product_file_variable_id_idx    INDEX     �   CREATE INDEX poly_stats_1_1_257_product_file_id_product_file_variable_id_idx ON public.poly_stats_1_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_1_1_257_product_file_id_product_file_variable_id_idx;
       public         	   statsuser    false    252    4719    252    252            �           1259    31958 ?   poly_stats_1_257_279_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_1_257_279_product_file_id_product_file_variable__idx ON public.poly_stats_1_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_1_257_279_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    4719    253    253    253            �           1259    31959 ?   poly_stats_1_279_285_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_1_279_285_product_file_id_product_file_variable__idx ON public.poly_stats_1_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_1_279_285_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    254    254    254    4719            �           1259    31960 ?   poly_stats_1_285_38543_product_file_id_product_file_variabl_idx    INDEX     �   CREATE INDEX poly_stats_1_285_38543_product_file_id_product_file_variabl_idx ON public.poly_stats_1_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_1_285_38543_product_file_id_product_file_variabl_idx;
       public         	   statsuser    false    4719    255    255    255            �           1259    31961 ?   poly_stats_21_1_257_product_file_id_product_file_variable_i_idx    INDEX     �   CREATE INDEX poly_stats_21_1_257_product_file_id_product_file_variable_i_idx ON public.poly_stats_21_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_21_1_257_product_file_id_product_file_variable_i_idx;
       public         	   statsuser    false    256    4719    256    256            �           1259    31962 ?   poly_stats_21_257_279_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_21_257_279_product_file_id_product_file_variable_idx ON public.poly_stats_21_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_21_257_279_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    4719    257    257    257            �           1259    31963 ?   poly_stats_21_279_285_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_21_279_285_product_file_id_product_file_variable_idx ON public.poly_stats_21_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_21_279_285_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    258    258    4719    258            �           1259    31964 ?   poly_stats_21_285_38543_product_file_id_product_file_variab_idx    INDEX     �   CREATE INDEX poly_stats_21_285_38543_product_file_id_product_file_variab_idx ON public.poly_stats_21_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_21_285_38543_product_file_id_product_file_variab_idx;
       public         	   statsuser    false    4719    259    259    259            D           1259    34814 ?   poly_stats_24_1_257_product_file_id_product_file_variable_i_idx    INDEX     �   CREATE INDEX poly_stats_24_1_257_product_file_id_product_file_variable_i_idx ON public.poly_stats_24_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_24_1_257_product_file_id_product_file_variable_i_idx;
       public         	   statsuser    false    4719    307    307    307            �           1259    31965 ?   poly_stats_2_1_257_product_file_id_product_file_variable_id_idx    INDEX     �   CREATE INDEX poly_stats_2_1_257_product_file_id_product_file_variable_id_idx ON public.poly_stats_2_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_2_1_257_product_file_id_product_file_variable_id_idx;
       public         	   statsuser    false    260    260    260    4719            �           1259    31966 ?   poly_stats_2_257_279_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_2_257_279_product_file_id_product_file_variable__idx ON public.poly_stats_2_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_2_257_279_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    261    261    261    4719            �           1259    31967 ?   poly_stats_2_279_285_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_2_279_285_product_file_id_product_file_variable__idx ON public.poly_stats_2_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_2_279_285_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    262    262    4719    262            �           1259    31968 ?   poly_stats_2_285_38543_product_file_id_product_file_variabl_idx    INDEX     �   CREATE INDEX poly_stats_2_285_38543_product_file_id_product_file_variabl_idx ON public.poly_stats_2_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_2_285_38543_product_file_id_product_file_variabl_idx;
       public         	   statsuser    false    263    4719    263    263            �           1259    31969 ?   poly_stats_3_1_257_product_file_id_product_file_variable_id_idx    INDEX     �   CREATE INDEX poly_stats_3_1_257_product_file_id_product_file_variable_id_idx ON public.poly_stats_3_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_3_1_257_product_file_id_product_file_variable_id_idx;
       public         	   statsuser    false    264    264    264    4719            �           1259    31970 ?   poly_stats_3_257_279_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_3_257_279_product_file_id_product_file_variable__idx ON public.poly_stats_3_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_3_257_279_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    265    265    4719    265            �           1259    31971 ?   poly_stats_3_279_285_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_3_279_285_product_file_id_product_file_variable__idx ON public.poly_stats_3_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_3_279_285_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    266    266    4719    266            �           1259    31972 ?   poly_stats_3_285_38543_product_file_id_product_file_variabl_idx    INDEX     �   CREATE INDEX poly_stats_3_285_38543_product_file_id_product_file_variabl_idx ON public.poly_stats_3_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_3_285_38543_product_file_id_product_file_variabl_idx;
       public         	   statsuser    false    4719    267    267    267            �           1259    31973 ?   poly_stats_4_1_257_product_file_id_product_file_variable_id_idx    INDEX     �   CREATE INDEX poly_stats_4_1_257_product_file_id_product_file_variable_id_idx ON public.poly_stats_4_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_4_1_257_product_file_id_product_file_variable_id_idx;
       public         	   statsuser    false    268    268    268    4719            �           1259    31974 ?   poly_stats_4_257_279_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_4_257_279_product_file_id_product_file_variable__idx ON public.poly_stats_4_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_4_257_279_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    269    269    4719    269            �           1259    31975 ?   poly_stats_4_279_285_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_4_279_285_product_file_id_product_file_variable__idx ON public.poly_stats_4_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_4_279_285_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    4719    270    270    270            �           1259    31976 ?   poly_stats_4_285_38543_product_file_id_product_file_variabl_idx    INDEX     �   CREATE INDEX poly_stats_4_285_38543_product_file_id_product_file_variabl_idx ON public.poly_stats_4_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_4_285_38543_product_file_id_product_file_variabl_idx;
       public         	   statsuser    false    271    271    4719    271            �           1259    31977 ?   poly_stats_5_1_257_product_file_id_product_file_variable_id_idx    INDEX     �   CREATE INDEX poly_stats_5_1_257_product_file_id_product_file_variable_id_idx ON public.poly_stats_5_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_5_1_257_product_file_id_product_file_variable_id_idx;
       public         	   statsuser    false    4719    272    272    272            �           1259    31978 ?   poly_stats_5_257_279_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_5_257_279_product_file_id_product_file_variable__idx ON public.poly_stats_5_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_5_257_279_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    273    273    273    4719            �           1259    31979 ?   poly_stats_5_279_285_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_5_279_285_product_file_id_product_file_variable__idx ON public.poly_stats_5_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_5_279_285_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    274    274    274    4719            �           1259    31980 ?   poly_stats_5_285_38543_product_file_id_product_file_variabl_idx    INDEX     �   CREATE INDEX poly_stats_5_285_38543_product_file_id_product_file_variabl_idx ON public.poly_stats_5_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_5_285_38543_product_file_id_product_file_variabl_idx;
       public         	   statsuser    false    275    275    4719    275                       1259    31981 ?   poly_stats_6_1_257_product_file_id_product_file_variable_id_idx    INDEX     �   CREATE INDEX poly_stats_6_1_257_product_file_id_product_file_variable_id_idx ON public.poly_stats_6_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_6_1_257_product_file_id_product_file_variable_id_idx;
       public         	   statsuser    false    276    276    276    4719                       1259    31982 ?   poly_stats_6_257_279_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_6_257_279_product_file_id_product_file_variable__idx ON public.poly_stats_6_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_6_257_279_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    277    277    277    4719                       1259    31983 ?   poly_stats_6_279_285_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_6_279_285_product_file_id_product_file_variable__idx ON public.poly_stats_6_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_6_279_285_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    278    278    278    4719                       1259    31984 ?   poly_stats_6_285_38543_product_file_id_product_file_variabl_idx    INDEX     �   CREATE INDEX poly_stats_6_285_38543_product_file_id_product_file_variabl_idx ON public.poly_stats_6_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_6_285_38543_product_file_id_product_file_variabl_idx;
       public         	   statsuser    false    4719    279    279    279                       1259    31985 ?   poly_stats_7_1_257_product_file_id_product_file_variable_id_idx    INDEX     �   CREATE INDEX poly_stats_7_1_257_product_file_id_product_file_variable_id_idx ON public.poly_stats_7_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_7_1_257_product_file_id_product_file_variable_id_idx;
       public         	   statsuser    false    4719    280    280    280                       1259    31986 ?   poly_stats_7_257_279_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_7_257_279_product_file_id_product_file_variable__idx ON public.poly_stats_7_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_7_257_279_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    281    281    281    4719                       1259    31987 ?   poly_stats_7_279_285_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_7_279_285_product_file_id_product_file_variable__idx ON public.poly_stats_7_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_7_279_285_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    282    282    282    4719                       1259    31988 ?   poly_stats_7_285_38543_product_file_id_product_file_variabl_idx    INDEX     �   CREATE INDEX poly_stats_7_285_38543_product_file_id_product_file_variabl_idx ON public.poly_stats_7_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_7_285_38543_product_file_id_product_file_variabl_idx;
       public         	   statsuser    false    283    4719    283    283                       1259    31989 ?   poly_stats_9_1_257_product_file_id_product_file_variable_id_idx    INDEX     �   CREATE INDEX poly_stats_9_1_257_product_file_id_product_file_variable_id_idx ON public.poly_stats_9_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_9_1_257_product_file_id_product_file_variable_id_idx;
       public         	   statsuser    false    284    284    284    4719                       1259    31990 ?   poly_stats_9_257_279_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_9_257_279_product_file_id_product_file_variable__idx ON public.poly_stats_9_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_9_257_279_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    285    285    285    4719                        1259    31991 ?   poly_stats_9_279_285_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_9_279_285_product_file_id_product_file_variable__idx ON public.poly_stats_9_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_9_279_285_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    286    286    4719    286            #           1259    31992 ?   poly_stats_9_285_38543_product_file_id_product_file_variabl_idx    INDEX     �   CREATE INDEX poly_stats_9_285_38543_product_file_id_product_file_variabl_idx ON public.poly_stats_9_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_9_285_38543_product_file_id_product_file_variabl_idx;
       public         	   statsuser    false    287    287    287    4719            &           1259    31993    product_file_date_idx    INDEX     W   CREATE INDEX product_file_date_idx ON public.product_file USING btree (date, rt_flag);
 )   DROP INDEX public.product_file_date_idx;
       public         	   statsuser    false    289    289            ?           1259    33062    product_order_email_idx    INDEX     `   CREATE INDEX product_order_email_idx ON public.product_order USING btree (email, date_created);
 +   DROP INDEX public.product_order_email_idx;
       public         	   statsuser    false    306    306            3           1259    31994    sidx_stratification_geom    INDEX     W   CREATE INDEX sidx_stratification_geom ON public.stratification_geom USING gist (geom);
 ,   DROP INDEX public.sidx_stratification_geom;
       public         	   statsuser    false    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    298            4           1259    31995    sidx_stratification_geom3857    INDEX     �   CREATE INDEX sidx_stratification_geom3857 ON public.stratification_geom USING gist (geom3857);

ALTER TABLE public.stratification_geom CLUSTER ON sidx_stratification_geom3857;
 0   DROP INDEX public.sidx_stratification_geom3857;
       public         	   statsuser    false    298    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3            E           0    0    poly_stats_10_1_257_pkey    INDEX ATTACH     T   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_10_1_257_pkey;
          public       	   statsuser    false    4721    4718    228    4718    228    227            F           0    0 ?   poly_stats_10_1_257_product_file_id_product_file_variable_i_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_10_1_257_product_file_id_product_file_variable_i_idx;
          public       	   statsuser    false    4722    4719    228    227            G           0    0    poly_stats_10_257_279_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_10_257_279_pkey;
          public       	   statsuser    false    229    4724    4718    4718    229    227            H           0    0 ?   poly_stats_10_257_279_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_10_257_279_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4725    4719    229    227            I           0    0    poly_stats_10_279_285_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_10_279_285_pkey;
          public       	   statsuser    false    4718    230    4727    4718    230    227            J           0    0 ?   poly_stats_10_279_285_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_10_279_285_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4728    4719    230    227            K           0    0    poly_stats_10_285_38543_pkey    INDEX ATTACH     X   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_10_285_38543_pkey;
          public       	   statsuser    false    4730    231    4718    4718    231    227            L           0    0 ?   poly_stats_10_285_38543_product_file_id_product_file_variab_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_10_285_38543_product_file_id_product_file_variab_idx;
          public       	   statsuser    false    4731    4719    231    227            M           0    0    poly_stats_12_1_257_pkey    INDEX ATTACH     T   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_12_1_257_pkey;
          public       	   statsuser    false    4718    4733    232    4718    232    227            N           0    0 ?   poly_stats_12_1_257_product_file_id_product_file_variable_i_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_12_1_257_product_file_id_product_file_variable_i_idx;
          public       	   statsuser    false    4734    4719    232    227            O           0    0    poly_stats_12_257_279_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_12_257_279_pkey;
          public       	   statsuser    false    4718    4736    233    4718    233    227            P           0    0 ?   poly_stats_12_257_279_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_12_257_279_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4737    4719    233    227            Q           0    0    poly_stats_12_279_285_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_12_279_285_pkey;
          public       	   statsuser    false    4739    4718    234    4718    234    227            R           0    0 ?   poly_stats_12_279_285_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_12_279_285_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4740    4719    234    227            S           0    0    poly_stats_12_285_38543_pkey    INDEX ATTACH     X   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_12_285_38543_pkey;
          public       	   statsuser    false    4742    235    4718    4718    235    227            T           0    0 ?   poly_stats_12_285_38543_product_file_id_product_file_variab_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_12_285_38543_product_file_id_product_file_variab_idx;
          public       	   statsuser    false    4743    4719    235    227            U           0    0    poly_stats_14_1_257_pkey    INDEX ATTACH     T   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_14_1_257_pkey;
          public       	   statsuser    false    4745    4718    236    4718    236    227            V           0    0 ?   poly_stats_14_1_257_product_file_id_product_file_variable_i_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_14_1_257_product_file_id_product_file_variable_i_idx;
          public       	   statsuser    false    4746    4719    236    227            W           0    0    poly_stats_14_257_279_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_14_257_279_pkey;
          public       	   statsuser    false    237    4718    4748    4718    237    227            X           0    0 ?   poly_stats_14_257_279_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_14_257_279_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4749    4719    237    227            Y           0    0    poly_stats_14_279_285_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_14_279_285_pkey;
          public       	   statsuser    false    4751    4718    238    4718    238    227            Z           0    0 ?   poly_stats_14_279_285_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_14_279_285_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4752    4719    238    227            [           0    0    poly_stats_14_285_38543_pkey    INDEX ATTACH     X   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_14_285_38543_pkey;
          public       	   statsuser    false    4718    4754    239    4718    239    227            \           0    0 ?   poly_stats_14_285_38543_product_file_id_product_file_variab_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_14_285_38543_product_file_id_product_file_variab_idx;
          public       	   statsuser    false    4755    4719    239    227            ]           0    0    poly_stats_16_1_257_pkey    INDEX ATTACH     T   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_16_1_257_pkey;
          public       	   statsuser    false    4757    4718    240    4718    240    227            ^           0    0 ?   poly_stats_16_1_257_product_file_id_product_file_variable_i_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_16_1_257_product_file_id_product_file_variable_i_idx;
          public       	   statsuser    false    4758    4719    240    227            _           0    0    poly_stats_16_257_279_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_16_257_279_pkey;
          public       	   statsuser    false    4718    4760    241    4718    241    227            `           0    0 ?   poly_stats_16_257_279_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_16_257_279_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4761    4719    241    227            a           0    0    poly_stats_16_279_285_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_16_279_285_pkey;
          public       	   statsuser    false    4718    242    4763    4718    242    227            b           0    0 ?   poly_stats_16_279_285_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_16_279_285_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4764    4719    242    227            c           0    0    poly_stats_16_285_38543_pkey    INDEX ATTACH     X   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_16_285_38543_pkey;
          public       	   statsuser    false    4718    4766    243    4718    243    227            d           0    0 ?   poly_stats_16_285_38543_product_file_id_product_file_variab_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_16_285_38543_product_file_id_product_file_variab_idx;
          public       	   statsuser    false    4767    4719    243    227            e           0    0    poly_stats_17_1_257_pkey    INDEX ATTACH     T   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_17_1_257_pkey;
          public       	   statsuser    false    244    4769    4718    4718    244    227            f           0    0 ?   poly_stats_17_1_257_product_file_id_product_file_variable_i_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_17_1_257_product_file_id_product_file_variable_i_idx;
          public       	   statsuser    false    4770    4719    244    227            g           0    0    poly_stats_17_257_279_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_17_257_279_pkey;
          public       	   statsuser    false    4772    245    4718    4718    245    227            h           0    0 ?   poly_stats_17_257_279_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_17_257_279_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4773    4719    245    227            i           0    0    poly_stats_17_279_285_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_17_279_285_pkey;
          public       	   statsuser    false    246    4718    4775    4718    246    227            j           0    0 ?   poly_stats_17_279_285_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_17_279_285_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4776    4719    246    227            k           0    0    poly_stats_17_285_38543_pkey    INDEX ATTACH     X   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_17_285_38543_pkey;
          public       	   statsuser    false    4718    4778    247    4718    247    227            l           0    0 ?   poly_stats_17_285_38543_product_file_id_product_file_variab_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_17_285_38543_product_file_id_product_file_variab_idx;
          public       	   statsuser    false    4779    4719    247    227            m           0    0    poly_stats_19_1_257_pkey    INDEX ATTACH     T   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_19_1_257_pkey;
          public       	   statsuser    false    248    4718    4781    4718    248    227            n           0    0 ?   poly_stats_19_1_257_product_file_id_product_file_variable_i_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_19_1_257_product_file_id_product_file_variable_i_idx;
          public       	   statsuser    false    4782    4719    248    227            o           0    0    poly_stats_19_257_279_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_19_257_279_pkey;
          public       	   statsuser    false    249    4784    4718    4718    249    227            p           0    0 ?   poly_stats_19_257_279_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_19_257_279_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4785    4719    249    227            q           0    0    poly_stats_19_279_285_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_19_279_285_pkey;
          public       	   statsuser    false    4718    250    4787    4718    250    227            r           0    0 ?   poly_stats_19_279_285_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_19_279_285_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4788    4719    250    227            s           0    0    poly_stats_19_285_38543_pkey    INDEX ATTACH     X   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_19_285_38543_pkey;
          public       	   statsuser    false    251    4790    4718    4718    251    227            t           0    0 ?   poly_stats_19_285_38543_product_file_id_product_file_variab_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_19_285_38543_product_file_id_product_file_variab_idx;
          public       	   statsuser    false    4791    4719    251    227            u           0    0    poly_stats_1_1_257_pkey    INDEX ATTACH     S   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_1_1_257_pkey;
          public       	   statsuser    false    4718    4793    252    4718    252    227            v           0    0 ?   poly_stats_1_1_257_product_file_id_product_file_variable_id_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_1_1_257_product_file_id_product_file_variable_id_idx;
          public       	   statsuser    false    4794    4719    252    227            w           0    0    poly_stats_1_257_279_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_1_257_279_pkey;
          public       	   statsuser    false    4796    4718    253    4718    253    227            x           0    0 ?   poly_stats_1_257_279_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_1_257_279_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4797    4719    253    227            y           0    0    poly_stats_1_279_285_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_1_279_285_pkey;
          public       	   statsuser    false    254    4718    4799    4718    254    227            z           0    0 ?   poly_stats_1_279_285_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_1_279_285_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4800    4719    254    227            {           0    0    poly_stats_1_285_38543_pkey    INDEX ATTACH     W   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_1_285_38543_pkey;
          public       	   statsuser    false    4802    255    4718    4718    255    227            |           0    0 ?   poly_stats_1_285_38543_product_file_id_product_file_variabl_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_1_285_38543_product_file_id_product_file_variabl_idx;
          public       	   statsuser    false    4803    4719    255    227            }           0    0    poly_stats_21_1_257_pkey    INDEX ATTACH     T   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_21_1_257_pkey;
          public       	   statsuser    false    4805    256    4718    4718    256    227            ~           0    0 ?   poly_stats_21_1_257_product_file_id_product_file_variable_i_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_21_1_257_product_file_id_product_file_variable_i_idx;
          public       	   statsuser    false    4806    4719    256    227                       0    0    poly_stats_21_257_279_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_21_257_279_pkey;
          public       	   statsuser    false    4808    257    4718    4718    257    227            �           0    0 ?   poly_stats_21_257_279_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_21_257_279_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4809    4719    257    227            �           0    0    poly_stats_21_279_285_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_21_279_285_pkey;
          public       	   statsuser    false    4718    258    4811    4718    258    227            �           0    0 ?   poly_stats_21_279_285_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_21_279_285_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4812    4719    258    227            �           0    0    poly_stats_21_285_38543_pkey    INDEX ATTACH     X   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_21_285_38543_pkey;
          public       	   statsuser    false    4814    259    4718    4718    259    227            �           0    0 ?   poly_stats_21_285_38543_product_file_id_product_file_variab_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_21_285_38543_product_file_id_product_file_variab_idx;
          public       	   statsuser    false    4815    4719    259    227            �           0    0    poly_stats_24_1_257_pkey    INDEX ATTACH     T   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_24_1_257_pkey;
          public       	   statsuser    false    4718    4931    307    4718    307    227            �           0    0 ?   poly_stats_24_1_257_product_file_id_product_file_variable_i_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_24_1_257_product_file_id_product_file_variable_i_idx;
          public       	   statsuser    false    4932    4719    307    227            �           0    0    poly_stats_2_1_257_pkey    INDEX ATTACH     S   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_2_1_257_pkey;
          public       	   statsuser    false    4718    260    4817    4718    260    227            �           0    0 ?   poly_stats_2_1_257_product_file_id_product_file_variable_id_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_2_1_257_product_file_id_product_file_variable_id_idx;
          public       	   statsuser    false    4818    4719    260    227            �           0    0    poly_stats_2_257_279_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_2_257_279_pkey;
          public       	   statsuser    false    261    4718    4820    4718    261    227            �           0    0 ?   poly_stats_2_257_279_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_2_257_279_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4821    4719    261    227            �           0    0    poly_stats_2_279_285_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_2_279_285_pkey;
          public       	   statsuser    false    4718    262    4823    4718    262    227            �           0    0 ?   poly_stats_2_279_285_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_2_279_285_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4824    4719    262    227            �           0    0    poly_stats_2_285_38543_pkey    INDEX ATTACH     W   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_2_285_38543_pkey;
          public       	   statsuser    false    263    4826    4718    4718    263    227            �           0    0 ?   poly_stats_2_285_38543_product_file_id_product_file_variabl_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_2_285_38543_product_file_id_product_file_variabl_idx;
          public       	   statsuser    false    4827    4719    263    227            �           0    0    poly_stats_3_1_257_pkey    INDEX ATTACH     S   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_3_1_257_pkey;
          public       	   statsuser    false    264    4718    4829    4718    264    227            �           0    0 ?   poly_stats_3_1_257_product_file_id_product_file_variable_id_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_3_1_257_product_file_id_product_file_variable_id_idx;
          public       	   statsuser    false    4830    4719    264    227            �           0    0    poly_stats_3_257_279_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_3_257_279_pkey;
          public       	   statsuser    false    4832    265    4718    4718    265    227            �           0    0 ?   poly_stats_3_257_279_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_3_257_279_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4833    4719    265    227            �           0    0    poly_stats_3_279_285_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_3_279_285_pkey;
          public       	   statsuser    false    4835    266    4718    4718    266    227            �           0    0 ?   poly_stats_3_279_285_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_3_279_285_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4836    4719    266    227            �           0    0    poly_stats_3_285_38543_pkey    INDEX ATTACH     W   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_3_285_38543_pkey;
          public       	   statsuser    false    4838    267    4718    4718    267    227            �           0    0 ?   poly_stats_3_285_38543_product_file_id_product_file_variabl_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_3_285_38543_product_file_id_product_file_variabl_idx;
          public       	   statsuser    false    4839    4719    267    227            �           0    0    poly_stats_4_1_257_pkey    INDEX ATTACH     S   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_4_1_257_pkey;
          public       	   statsuser    false    4718    268    4841    4718    268    227            �           0    0 ?   poly_stats_4_1_257_product_file_id_product_file_variable_id_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_4_1_257_product_file_id_product_file_variable_id_idx;
          public       	   statsuser    false    4842    4719    268    227            �           0    0    poly_stats_4_257_279_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_4_257_279_pkey;
          public       	   statsuser    false    4718    4844    269    4718    269    227            �           0    0 ?   poly_stats_4_257_279_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_4_257_279_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4845    4719    269    227            �           0    0    poly_stats_4_279_285_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_4_279_285_pkey;
          public       	   statsuser    false    4718    270    4847    4718    270    227            �           0    0 ?   poly_stats_4_279_285_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_4_279_285_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4848    4719    270    227            �           0    0    poly_stats_4_285_38543_pkey    INDEX ATTACH     W   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_4_285_38543_pkey;
          public       	   statsuser    false    4850    271    4718    4718    271    227            �           0    0 ?   poly_stats_4_285_38543_product_file_id_product_file_variabl_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_4_285_38543_product_file_id_product_file_variabl_idx;
          public       	   statsuser    false    4851    4719    271    227            �           0    0    poly_stats_5_1_257_pkey    INDEX ATTACH     S   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_5_1_257_pkey;
          public       	   statsuser    false    272    4853    4718    4718    272    227            �           0    0 ?   poly_stats_5_1_257_product_file_id_product_file_variable_id_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_5_1_257_product_file_id_product_file_variable_id_idx;
          public       	   statsuser    false    4854    4719    272    227            �           0    0    poly_stats_5_257_279_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_5_257_279_pkey;
          public       	   statsuser    false    4856    273    4718    4718    273    227            �           0    0 ?   poly_stats_5_257_279_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_5_257_279_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4857    4719    273    227            �           0    0    poly_stats_5_279_285_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_5_279_285_pkey;
          public       	   statsuser    false    4718    4859    274    4718    274    227            �           0    0 ?   poly_stats_5_279_285_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_5_279_285_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4860    4719    274    227            �           0    0    poly_stats_5_285_38543_pkey    INDEX ATTACH     W   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_5_285_38543_pkey;
          public       	   statsuser    false    4862    275    4718    4718    275    227            �           0    0 ?   poly_stats_5_285_38543_product_file_id_product_file_variabl_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_5_285_38543_product_file_id_product_file_variabl_idx;
          public       	   statsuser    false    4863    4719    275    227            �           0    0    poly_stats_6_1_257_pkey    INDEX ATTACH     S   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_6_1_257_pkey;
          public       	   statsuser    false    4865    4718    276    4718    276    227            �           0    0 ?   poly_stats_6_1_257_product_file_id_product_file_variable_id_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_6_1_257_product_file_id_product_file_variable_id_idx;
          public       	   statsuser    false    4866    4719    276    227            �           0    0    poly_stats_6_257_279_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_6_257_279_pkey;
          public       	   statsuser    false    4718    277    4868    4718    277    227            �           0    0 ?   poly_stats_6_257_279_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_6_257_279_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4869    4719    277    227            �           0    0    poly_stats_6_279_285_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_6_279_285_pkey;
          public       	   statsuser    false    4718    278    4871    4718    278    227            �           0    0 ?   poly_stats_6_279_285_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_6_279_285_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4872    4719    278    227            �           0    0    poly_stats_6_285_38543_pkey    INDEX ATTACH     W   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_6_285_38543_pkey;
          public       	   statsuser    false    279    4718    4874    4718    279    227            �           0    0 ?   poly_stats_6_285_38543_product_file_id_product_file_variabl_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_6_285_38543_product_file_id_product_file_variabl_idx;
          public       	   statsuser    false    4875    4719    279    227            �           0    0    poly_stats_7_1_257_pkey    INDEX ATTACH     S   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_7_1_257_pkey;
          public       	   statsuser    false    4718    4877    280    4718    280    227            �           0    0 ?   poly_stats_7_1_257_product_file_id_product_file_variable_id_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_7_1_257_product_file_id_product_file_variable_id_idx;
          public       	   statsuser    false    4878    4719    280    227            �           0    0    poly_stats_7_257_279_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_7_257_279_pkey;
          public       	   statsuser    false    4880    4718    281    4718    281    227            �           0    0 ?   poly_stats_7_257_279_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_7_257_279_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4881    4719    281    227            �           0    0    poly_stats_7_279_285_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_7_279_285_pkey;
          public       	   statsuser    false    282    4883    4718    4718    282    227            �           0    0 ?   poly_stats_7_279_285_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_7_279_285_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4884    4719    282    227            �           0    0    poly_stats_7_285_38543_pkey    INDEX ATTACH     W   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_7_285_38543_pkey;
          public       	   statsuser    false    283    4886    4718    4718    283    227            �           0    0 ?   poly_stats_7_285_38543_product_file_id_product_file_variabl_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_7_285_38543_product_file_id_product_file_variabl_idx;
          public       	   statsuser    false    4887    4719    283    227            �           0    0    poly_stats_9_1_257_pkey    INDEX ATTACH     S   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_9_1_257_pkey;
          public       	   statsuser    false    4889    284    4718    4718    284    227            �           0    0 ?   poly_stats_9_1_257_product_file_id_product_file_variable_id_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_9_1_257_product_file_id_product_file_variable_id_idx;
          public       	   statsuser    false    4890    4719    284    227            �           0    0    poly_stats_9_257_279_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_9_257_279_pkey;
          public       	   statsuser    false    4718    285    4892    4718    285    227            �           0    0 ?   poly_stats_9_257_279_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_9_257_279_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4893    4719    285    227            �           0    0    poly_stats_9_279_285_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_9_279_285_pkey;
          public       	   statsuser    false    286    4895    4718    4718    286    227            �           0    0 ?   poly_stats_9_279_285_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_9_279_285_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4896    4719    286    227            �           0    0    poly_stats_9_285_38543_pkey    INDEX ATTACH     W   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_9_285_38543_pkey;
          public       	   statsuser    false    4898    4718    287    4718    287    227            �           0    0 ?   poly_stats_9_285_38543_product_file_id_product_file_variabl_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_9_285_38543_product_file_id_product_file_variabl_idx;
          public       	   statsuser    false    4899    4719    287    227            �           2606    31996 0   long_term_anomaly_info long_term_anomaly_info_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.long_term_anomaly_info
    ADD CONSTRAINT long_term_anomaly_info_fk FOREIGN KEY (anomaly_product_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 Z   ALTER TABLE ONLY public.long_term_anomaly_info DROP CONSTRAINT long_term_anomaly_info_fk;
       public       	   statsuser    false    4910    224    294            �           2606    32001 2   long_term_anomaly_info long_term_anomaly_info_fk_1    FK CONSTRAINT     �   ALTER TABLE ONLY public.long_term_anomaly_info
    ADD CONSTRAINT long_term_anomaly_info_fk_1 FOREIGN KEY (mean_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 \   ALTER TABLE ONLY public.long_term_anomaly_info DROP CONSTRAINT long_term_anomaly_info_fk_1;
       public       	   statsuser    false    224    4910    294            �           2606    32006 2   long_term_anomaly_info long_term_anomaly_info_fk_2    FK CONSTRAINT     �   ALTER TABLE ONLY public.long_term_anomaly_info
    ADD CONSTRAINT long_term_anomaly_info_fk_2 FOREIGN KEY (stdev_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 \   ALTER TABLE ONLY public.long_term_anomaly_info DROP CONSTRAINT long_term_anomaly_info_fk_2;
       public       	   statsuser    false    4910    224    294            �           2606    32011 2   long_term_anomaly_info long_term_anomaly_info_fk_3    FK CONSTRAINT     �   ALTER TABLE ONLY public.long_term_anomaly_info
    ADD CONSTRAINT long_term_anomaly_info_fk_3 FOREIGN KEY (raw_product_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 \   ALTER TABLE ONLY public.long_term_anomaly_info DROP CONSTRAINT long_term_anomaly_info_fk_3;
       public       	   statsuser    false    294    4910    224            �           2606    32016 &   poly_stats poly_stats_product_file_fk_    FK CONSTRAINT     �   ALTER TABLE public.poly_stats
    ADD CONSTRAINT poly_stats_product_file_fk_ FOREIGN KEY (product_file_id) REFERENCES public.product_file(id) ON UPDATE CASCADE ON DELETE CASCADE;
 K   ALTER TABLE public.poly_stats DROP CONSTRAINT poly_stats_product_file_fk_;
       public       	   statsuser    false    4906    289    227            �           2606    32201 *   poly_stats poly_stats_product_variable_fk_    FK CONSTRAINT     �   ALTER TABLE public.poly_stats
    ADD CONSTRAINT poly_stats_product_variable_fk_ FOREIGN KEY (product_file_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 O   ALTER TABLE public.poly_stats DROP CONSTRAINT poly_stats_product_variable_fk_;
       public       	   statsuser    false    227    4910    294            �           2606    32386 -   poly_stats poly_stats_stratification_geom_fk_    FK CONSTRAINT     �   ALTER TABLE public.poly_stats
    ADD CONSTRAINT poly_stats_stratification_geom_fk_ FOREIGN KEY (poly_id) REFERENCES public.stratification_geom(id) ON UPDATE CASCADE ON DELETE CASCADE;
 R   ALTER TABLE public.poly_stats DROP CONSTRAINT poly_stats_stratification_geom_fk_;
       public       	   statsuser    false    4918    298    227            �           2606    32571 4   product_file_description product_file_description_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.product_file_description
    ADD CONSTRAINT product_file_description_fk FOREIGN KEY (product_id) REFERENCES public.product(id) ON UPDATE CASCADE ON DELETE CASCADE;
 ^   ALTER TABLE ONLY public.product_file_description DROP CONSTRAINT product_file_description_fk;
       public       	   statsuser    false    290    4901    288            �           2606    32576    product product_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_fk FOREIGN KEY (category_id) REFERENCES public.category(id) ON UPDATE CASCADE ON DELETE CASCADE;
 <   ALTER TABLE ONLY public.product DROP CONSTRAINT product_fk;
       public       	   statsuser    false    288    4714    222            �           2606    32581 *   stratification_geom stratification_geom_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.stratification_geom
    ADD CONSTRAINT stratification_geom_fk FOREIGN KEY (stratification_id) REFERENCES public.stratification(id) ON DELETE CASCADE;
 T   ALTER TABLE ONLY public.stratification_geom DROP CONSTRAINT stratification_geom_fk;
       public       	   statsuser    false    298    4912    297            �           2606    32586    wms_file wms_file_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.wms_file
    ADD CONSTRAINT wms_file_fk FOREIGN KEY (product_file_id) REFERENCES public.product_file(id) ON UPDATE CASCADE ON DELETE CASCADE;
 >   ALTER TABLE ONLY public.wms_file DROP CONSTRAINT wms_file_fk;
       public       	   statsuser    false    302    289    4906            �           2606    32591    wms_file wms_file_fk2    FK CONSTRAINT     �   ALTER TABLE ONLY public.wms_file
    ADD CONSTRAINT wms_file_fk2 FOREIGN KEY (product_file_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 ?   ALTER TABLE ONLY public.wms_file DROP CONSTRAINT wms_file_fk2;
       public       	   statsuser    false    4910    302    294            �           2606    32596 0   poly_stats_per_region poly_stats_product_file_fk    FK CONSTRAINT     �   ALTER TABLE ONLY tmp.poly_stats_per_region
    ADD CONSTRAINT poly_stats_product_file_fk FOREIGN KEY (product_file_id) REFERENCES public.product_file(id) ON UPDATE CASCADE ON DELETE CASCADE;
 W   ALTER TABLE ONLY tmp.poly_stats_per_region DROP CONSTRAINT poly_stats_product_file_fk;
       tmp       	   statsuser    false    304    4906    289            �           2606    32601 9   poly_stats_per_region poly_stats_product_file_variable_fk    FK CONSTRAINT     �   ALTER TABLE ONLY tmp.poly_stats_per_region
    ADD CONSTRAINT poly_stats_product_file_variable_fk FOREIGN KEY (product_file_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 `   ALTER TABLE ONLY tmp.poly_stats_per_region DROP CONSTRAINT poly_stats_product_file_variable_fk;
       tmp       	   statsuser    false    304    294    4910            �           2606    32606 7   poly_stats_per_region poly_stats_stratification_geom_fk    FK CONSTRAINT     �   ALTER TABLE ONLY tmp.poly_stats_per_region
    ADD CONSTRAINT poly_stats_stratification_geom_fk FOREIGN KEY (poly_id) REFERENCES public.stratification_geom(id) ON UPDATE CASCADE ON DELETE CASCADE;
 ^   ALTER TABLE ONLY tmp.poly_stats_per_region DROP CONSTRAINT poly_stats_stratification_geom_fk;
       tmp       	   statsuser    false    304    298    4918           