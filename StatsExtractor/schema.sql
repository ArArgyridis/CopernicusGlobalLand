PGDMP          
    	        |           jrcstats    16.2    16.2 �   9           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            :           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            ;           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            <           1262    16388    jrcstats    DATABASE     p   CREATE DATABASE jrcstats WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'C.UTF-8';
    DROP DATABASE jrcstats;
             	   statsuser    false            =           0    0    SCHEMA pg_catalog    ACL     -   GRANT ALL ON SCHEMA pg_catalog TO statsuser;
                   postgres    false    5            >           0    0    SCHEMA public    ACL     )   GRANT ALL ON SCHEMA public TO statsuser;
                   pg_database_owner    false    8                        2615    16390    tmp    SCHEMA        CREATE SCHEMA tmp;
    DROP SCHEMA tmp;
                postgres    false            ?           0    0 
   SCHEMA tmp    ACL     &   GRANT ALL ON SCHEMA tmp TO statsuser;
                   postgres    false    4                        3079    16391    fuzzystrmatch 	   EXTENSION     A   CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;
    DROP EXTENSION fuzzystrmatch;
                   false            @           0    0    EXTENSION fuzzystrmatch    COMMENT     ]   COMMENT ON EXTENSION fuzzystrmatch IS 'determine similarities and distance between strings';
                        false    2                        3079    16403    postgis 	   EXTENSION     ;   CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;
    DROP EXTENSION postgis;
                   false            A           0    0    EXTENSION postgis    COMMENT     ^   COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';
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
       public          postgres    false            B           0    0    TABLE pg_aggregate    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_aggregate TO statsuser;
       
   pg_catalog          postgres    false    24            C           0    0    TABLE pg_am    ACL     2   GRANT ALL ON TABLE pg_catalog.pg_am TO statsuser;
       
   pg_catalog          postgres    false    25            D           0    0    TABLE pg_amop    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_amop TO statsuser;
       
   pg_catalog          postgres    false    26            E           0    0    TABLE pg_amproc    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_amproc TO statsuser;
       
   pg_catalog          postgres    false    27            F           0    0    TABLE pg_attrdef    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_attrdef TO statsuser;
       
   pg_catalog          postgres    false    28            G           0    0    TABLE pg_attribute    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_attribute TO statsuser;
       
   pg_catalog          postgres    false    13            H           0    0    TABLE pg_auth_members    ACL     <   GRANT ALL ON TABLE pg_catalog.pg_auth_members TO statsuser;
       
   pg_catalog          postgres    false    17            I           0    0    TABLE pg_authid    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_authid TO statsuser;
       
   pg_catalog          postgres    false    16            J           0    0 %   TABLE pg_available_extension_versions    ACL     L   GRANT ALL ON TABLE pg_catalog.pg_available_extension_versions TO statsuser;
       
   pg_catalog          postgres    false    91            K           0    0    TABLE pg_available_extensions    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_available_extensions TO statsuser;
       
   pg_catalog          postgres    false    90            L           0    0     TABLE pg_backend_memory_contexts    ACL     G   GRANT ALL ON TABLE pg_catalog.pg_backend_memory_contexts TO statsuser;
       
   pg_catalog          postgres    false    103            M           0    0    TABLE pg_cast    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_cast TO statsuser;
       
   pg_catalog          postgres    false    29            N           0    0    TABLE pg_class    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_class TO statsuser;
       
   pg_catalog          postgres    false    15            O           0    0    TABLE pg_collation    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_collation TO statsuser;
       
   pg_catalog          postgres    false    54            P           0    0    TABLE pg_config    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_config TO statsuser;
       
   pg_catalog          postgres    false    101            Q           0    0    TABLE pg_constraint    ACL     :   GRANT ALL ON TABLE pg_catalog.pg_constraint TO statsuser;
       
   pg_catalog          postgres    false    30            R           0    0    TABLE pg_conversion    ACL     :   GRANT ALL ON TABLE pg_catalog.pg_conversion TO statsuser;
       
   pg_catalog          postgres    false    31            S           0    0    TABLE pg_cursors    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_cursors TO statsuser;
       
   pg_catalog          postgres    false    89            T           0    0    TABLE pg_database    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_database TO statsuser;
       
   pg_catalog          postgres    false    18            U           0    0    TABLE pg_db_role_setting    ACL     ?   GRANT ALL ON TABLE pg_catalog.pg_db_role_setting TO statsuser;
       
   pg_catalog          postgres    false    45            V           0    0    TABLE pg_default_acl    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_default_acl TO statsuser;
       
   pg_catalog          postgres    false    9            W           0    0    TABLE pg_depend    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_depend TO statsuser;
       
   pg_catalog          postgres    false    32            X           0    0    TABLE pg_description    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_description TO statsuser;
       
   pg_catalog          postgres    false    33            Y           0    0    TABLE pg_enum    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_enum TO statsuser;
       
   pg_catalog          postgres    false    56            Z           0    0    TABLE pg_event_trigger    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_event_trigger TO statsuser;
       
   pg_catalog          postgres    false    55            [           0    0    TABLE pg_extension    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_extension TO statsuser;
       
   pg_catalog          postgres    false    47            \           0    0    TABLE pg_file_settings    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_file_settings TO statsuser;
       
   pg_catalog          postgres    false    96            ]           0    0    TABLE pg_foreign_data_wrapper    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_foreign_data_wrapper TO statsuser;
       
   pg_catalog          postgres    false    22            ^           0    0    TABLE pg_foreign_server    ACL     >   GRANT ALL ON TABLE pg_catalog.pg_foreign_server TO statsuser;
       
   pg_catalog          postgres    false    19            _           0    0    TABLE pg_foreign_table    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_foreign_table TO statsuser;
       
   pg_catalog          postgres    false    48            `           0    0    TABLE pg_group    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_group TO statsuser;
       
   pg_catalog          postgres    false    75            a           0    0    TABLE pg_hba_file_rules    ACL     >   GRANT ALL ON TABLE pg_catalog.pg_hba_file_rules TO statsuser;
       
   pg_catalog          postgres    false    97            b           0    0    TABLE pg_ident_file_mappings    ACL     C   GRANT ALL ON TABLE pg_catalog.pg_ident_file_mappings TO statsuser;
       
   pg_catalog          postgres    false    98            c           0    0    TABLE pg_index    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_index TO statsuser;
       
   pg_catalog          postgres    false    34            d           0    0    TABLE pg_indexes    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_indexes TO statsuser;
       
   pg_catalog          postgres    false    82            e           0    0    TABLE pg_inherits    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_inherits TO statsuser;
       
   pg_catalog          postgres    false    35            f           0    0    TABLE pg_init_privs    ACL     :   GRANT ALL ON TABLE pg_catalog.pg_init_privs TO statsuser;
       
   pg_catalog          postgres    false    52            g           0    0    TABLE pg_language    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_language TO statsuser;
       
   pg_catalog          postgres    false    36            h           0    0    TABLE pg_largeobject    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_largeobject TO statsuser;
       
   pg_catalog          postgres    false    37            i           0    0    TABLE pg_largeobject_metadata    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_largeobject_metadata TO statsuser;
       
   pg_catalog          postgres    false    46            j           0    0    TABLE pg_locks    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_locks TO statsuser;
       
   pg_catalog          postgres    false    88            k           0    0    TABLE pg_matviews    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_matviews TO statsuser;
       
   pg_catalog          postgres    false    81            l           0    0    TABLE pg_namespace    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_namespace TO statsuser;
       
   pg_catalog          postgres    false    38            m           0    0    TABLE pg_opclass    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_opclass TO statsuser;
       
   pg_catalog          postgres    false    39            n           0    0    TABLE pg_operator    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_operator TO statsuser;
       
   pg_catalog          postgres    false    40            o           0    0    TABLE pg_opfamily    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_opfamily TO statsuser;
       
   pg_catalog          postgres    false    44            p           0    0    TABLE pg_parameter_acl    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_parameter_acl TO statsuser;
       
   pg_catalog          postgres    false    72            q           0    0    TABLE pg_partitioned_table    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_partitioned_table TO statsuser;
       
   pg_catalog          postgres    false    50            r           0    0    TABLE pg_policies    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_policies TO statsuser;
       
   pg_catalog          postgres    false    77            s           0    0    TABLE pg_policy    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_policy TO statsuser;
       
   pg_catalog          postgres    false    49            t           0    0    TABLE pg_prepared_statements    ACL     C   GRANT ALL ON TABLE pg_catalog.pg_prepared_statements TO statsuser;
       
   pg_catalog          postgres    false    93            u           0    0    TABLE pg_prepared_xacts    ACL     >   GRANT ALL ON TABLE pg_catalog.pg_prepared_xacts TO statsuser;
       
   pg_catalog          postgres    false    92            v           0    0    TABLE pg_proc    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_proc TO statsuser;
       
   pg_catalog          postgres    false    14            w           0    0    TABLE pg_publication    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_publication TO statsuser;
       
   pg_catalog          postgres    false    69            x           0    0    TABLE pg_publication_namespace    ACL     E   GRANT ALL ON TABLE pg_catalog.pg_publication_namespace TO statsuser;
       
   pg_catalog          postgres    false    71            y           0    0    TABLE pg_publication_rel    ACL     ?   GRANT ALL ON TABLE pg_catalog.pg_publication_rel TO statsuser;
       
   pg_catalog          postgres    false    70            z           0    0    TABLE pg_publication_tables    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_publication_tables TO statsuser;
       
   pg_catalog          postgres    false    87            {           0    0    TABLE pg_range    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_range TO statsuser;
       
   pg_catalog          postgres    false    57            |           0    0    TABLE pg_replication_origin    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_replication_origin TO statsuser;
       
   pg_catalog          postgres    false    66            }           0    0 "   TABLE pg_replication_origin_status    ACL     I   GRANT ALL ON TABLE pg_catalog.pg_replication_origin_status TO statsuser;
       
   pg_catalog          postgres    false    147            ~           0    0    TABLE pg_replication_slots    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_replication_slots TO statsuser;
       
   pg_catalog          postgres    false    130                       0    0    TABLE pg_rewrite    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_rewrite TO statsuser;
       
   pg_catalog          postgres    false    41            �           0    0    TABLE pg_roles    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_roles TO statsuser;
       
   pg_catalog          postgres    false    73            �           0    0    TABLE pg_rules    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_rules TO statsuser;
       
   pg_catalog          postgres    false    78            �           0    0    TABLE pg_seclabel    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_seclabel TO statsuser;
       
   pg_catalog          postgres    false    60            �           0    0    TABLE pg_seclabels    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_seclabels TO statsuser;
       
   pg_catalog          postgres    false    94            �           0    0    TABLE pg_sequence    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_sequence TO statsuser;
       
   pg_catalog          postgres    false    21            �           0    0    TABLE pg_sequences    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_sequences TO statsuser;
       
   pg_catalog          postgres    false    83            �           0    0    TABLE pg_settings    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_settings TO statsuser;
       
   pg_catalog          postgres    false    95            �           0    0    TABLE pg_shadow    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_shadow TO statsuser;
       
   pg_catalog          postgres    false    74            �           0    0    TABLE pg_shdepend    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_shdepend TO statsuser;
       
   pg_catalog          postgres    false    11            �           0    0    TABLE pg_shdescription    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_shdescription TO statsuser;
       
   pg_catalog          postgres    false    23            �           0    0    TABLE pg_shmem_allocations    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_shmem_allocations TO statsuser;
       
   pg_catalog          postgres    false    102            �           0    0    TABLE pg_shseclabel    ACL     :   GRANT ALL ON TABLE pg_catalog.pg_shseclabel TO statsuser;
       
   pg_catalog          postgres    false    59            �           0    0    TABLE pg_stat_activity    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_stat_activity TO statsuser;
       
   pg_catalog          postgres    false    122            �           0    0    TABLE pg_stat_all_indexes    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_stat_all_indexes TO statsuser;
       
   pg_catalog          postgres    false    113            �           0    0    TABLE pg_stat_all_tables    ACL     ?   GRANT ALL ON TABLE pg_catalog.pg_stat_all_tables TO statsuser;
       
   pg_catalog          postgres    false    104            �           0    0    TABLE pg_stat_archiver    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_stat_archiver TO statsuser;
       
   pg_catalog          postgres    false    136            �           0    0    TABLE pg_stat_bgwriter    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_stat_bgwriter TO statsuser;
       
   pg_catalog          postgres    false    137            �           0    0    TABLE pg_stat_database    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_stat_database TO statsuser;
       
   pg_catalog          postgres    false    132            �           0    0     TABLE pg_stat_database_conflicts    ACL     G   GRANT ALL ON TABLE pg_catalog.pg_stat_database_conflicts TO statsuser;
       
   pg_catalog          postgres    false    133            �           0    0    TABLE pg_stat_gssapi    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_stat_gssapi TO statsuser;
       
   pg_catalog          postgres    false    129            �           0    0    TABLE pg_stat_io    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_stat_io TO statsuser;
       
   pg_catalog          postgres    false    138            �           0    0    TABLE pg_stat_progress_analyze    ACL     E   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_analyze TO statsuser;
       
   pg_catalog          postgres    false    140            �           0    0 !   TABLE pg_stat_progress_basebackup    ACL     H   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_basebackup TO statsuser;
       
   pg_catalog          postgres    false    144            �           0    0    TABLE pg_stat_progress_cluster    ACL     E   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_cluster TO statsuser;
       
   pg_catalog          postgres    false    142            �           0    0    TABLE pg_stat_progress_copy    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_copy TO statsuser;
       
   pg_catalog          postgres    false    145            �           0    0 #   TABLE pg_stat_progress_create_index    ACL     J   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_create_index TO statsuser;
       
   pg_catalog          postgres    false    143            �           0    0    TABLE pg_stat_progress_vacuum    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_vacuum TO statsuser;
       
   pg_catalog          postgres    false    141            �           0    0    TABLE pg_stat_recovery_prefetch    ACL     F   GRANT ALL ON TABLE pg_catalog.pg_stat_recovery_prefetch TO statsuser;
       
   pg_catalog          postgres    false    126            �           0    0    TABLE pg_stat_replication    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_stat_replication TO statsuser;
       
   pg_catalog          postgres    false    123            �           0    0    TABLE pg_stat_replication_slots    ACL     F   GRANT ALL ON TABLE pg_catalog.pg_stat_replication_slots TO statsuser;
       
   pg_catalog          postgres    false    131            �           0    0    TABLE pg_stat_slru    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_stat_slru TO statsuser;
       
   pg_catalog          postgres    false    124            �           0    0    TABLE pg_stat_ssl    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_stat_ssl TO statsuser;
       
   pg_catalog          postgres    false    128            �           0    0    TABLE pg_stat_subscription    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_stat_subscription TO statsuser;
       
   pg_catalog          postgres    false    127            �           0    0     TABLE pg_stat_subscription_stats    ACL     G   GRANT ALL ON TABLE pg_catalog.pg_stat_subscription_stats TO statsuser;
       
   pg_catalog          postgres    false    148            �           0    0    TABLE pg_stat_sys_indexes    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_stat_sys_indexes TO statsuser;
       
   pg_catalog          postgres    false    114            �           0    0    TABLE pg_stat_sys_tables    ACL     ?   GRANT ALL ON TABLE pg_catalog.pg_stat_sys_tables TO statsuser;
       
   pg_catalog          postgres    false    106            �           0    0    TABLE pg_stat_user_functions    ACL     C   GRANT ALL ON TABLE pg_catalog.pg_stat_user_functions TO statsuser;
       
   pg_catalog          postgres    false    134            �           0    0    TABLE pg_stat_user_indexes    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_stat_user_indexes TO statsuser;
       
   pg_catalog          postgres    false    115            �           0    0    TABLE pg_stat_user_tables    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_stat_user_tables TO statsuser;
       
   pg_catalog          postgres    false    108            �           0    0    TABLE pg_stat_wal    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_stat_wal TO statsuser;
       
   pg_catalog          postgres    false    139            �           0    0    TABLE pg_stat_wal_receiver    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_stat_wal_receiver TO statsuser;
       
   pg_catalog          postgres    false    125            �           0    0    TABLE pg_stat_xact_all_tables    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_stat_xact_all_tables TO statsuser;
       
   pg_catalog          postgres    false    105            �           0    0    TABLE pg_stat_xact_sys_tables    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_stat_xact_sys_tables TO statsuser;
       
   pg_catalog          postgres    false    107            �           0    0 !   TABLE pg_stat_xact_user_functions    ACL     H   GRANT ALL ON TABLE pg_catalog.pg_stat_xact_user_functions TO statsuser;
       
   pg_catalog          postgres    false    135            �           0    0    TABLE pg_stat_xact_user_tables    ACL     E   GRANT ALL ON TABLE pg_catalog.pg_stat_xact_user_tables TO statsuser;
       
   pg_catalog          postgres    false    109            �           0    0    TABLE pg_statio_all_indexes    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_statio_all_indexes TO statsuser;
       
   pg_catalog          postgres    false    116            �           0    0    TABLE pg_statio_all_sequences    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_statio_all_sequences TO statsuser;
       
   pg_catalog          postgres    false    119            �           0    0    TABLE pg_statio_all_tables    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_statio_all_tables TO statsuser;
       
   pg_catalog          postgres    false    110            �           0    0    TABLE pg_statio_sys_indexes    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_statio_sys_indexes TO statsuser;
       
   pg_catalog          postgres    false    117            �           0    0    TABLE pg_statio_sys_sequences    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_statio_sys_sequences TO statsuser;
       
   pg_catalog          postgres    false    120            �           0    0    TABLE pg_statio_sys_tables    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_statio_sys_tables TO statsuser;
       
   pg_catalog          postgres    false    111            �           0    0    TABLE pg_statio_user_indexes    ACL     C   GRANT ALL ON TABLE pg_catalog.pg_statio_user_indexes TO statsuser;
       
   pg_catalog          postgres    false    118            �           0    0    TABLE pg_statio_user_sequences    ACL     E   GRANT ALL ON TABLE pg_catalog.pg_statio_user_sequences TO statsuser;
       
   pg_catalog          postgres    false    121            �           0    0    TABLE pg_statio_user_tables    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_statio_user_tables TO statsuser;
       
   pg_catalog          postgres    false    112            �           0    0    TABLE pg_statistic    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_statistic TO statsuser;
       
   pg_catalog          postgres    false    42            �           0    0    TABLE pg_statistic_ext    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_statistic_ext TO statsuser;
       
   pg_catalog          postgres    false    51            �           0    0    TABLE pg_statistic_ext_data    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_statistic_ext_data TO statsuser;
       
   pg_catalog          postgres    false    53            �           0    0    TABLE pg_stats    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_stats TO statsuser;
       
   pg_catalog          postgres    false    84            �           0    0    TABLE pg_stats_ext    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_stats_ext TO statsuser;
       
   pg_catalog          postgres    false    85            �           0    0    TABLE pg_stats_ext_exprs    ACL     ?   GRANT ALL ON TABLE pg_catalog.pg_stats_ext_exprs TO statsuser;
       
   pg_catalog          postgres    false    86            �           0    0    TABLE pg_subscription    ACL     <   GRANT ALL ON TABLE pg_catalog.pg_subscription TO statsuser;
       
   pg_catalog          postgres    false    67            �           0    0    TABLE pg_subscription_rel    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_subscription_rel TO statsuser;
       
   pg_catalog          postgres    false    68            �           0    0    TABLE pg_tables    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_tables TO statsuser;
       
   pg_catalog          postgres    false    80            �           0    0    TABLE pg_tablespace    ACL     :   GRANT ALL ON TABLE pg_catalog.pg_tablespace TO statsuser;
       
   pg_catalog          postgres    false    10            �           0    0    TABLE pg_timezone_abbrevs    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_timezone_abbrevs TO statsuser;
       
   pg_catalog          postgres    false    99            �           0    0    TABLE pg_timezone_names    ACL     >   GRANT ALL ON TABLE pg_catalog.pg_timezone_names TO statsuser;
       
   pg_catalog          postgres    false    100            �           0    0    TABLE pg_transform    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_transform TO statsuser;
       
   pg_catalog          postgres    false    58            �           0    0    TABLE pg_trigger    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_trigger TO statsuser;
       
   pg_catalog          postgres    false    43            �           0    0    TABLE pg_ts_config    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_ts_config TO statsuser;
       
   pg_catalog          postgres    false    63            �           0    0    TABLE pg_ts_config_map    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_ts_config_map TO statsuser;
       
   pg_catalog          postgres    false    64            �           0    0    TABLE pg_ts_dict    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_ts_dict TO statsuser;
       
   pg_catalog          postgres    false    61            �           0    0    TABLE pg_ts_parser    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_ts_parser TO statsuser;
       
   pg_catalog          postgres    false    62            �           0    0    TABLE pg_ts_template    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_ts_template TO statsuser;
       
   pg_catalog          postgres    false    65            �           0    0    TABLE pg_type    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_type TO statsuser;
       
   pg_catalog          postgres    false    12            �           0    0    TABLE pg_user    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_user TO statsuser;
       
   pg_catalog          postgres    false    76            �           0    0    TABLE pg_user_mapping    ACL     <   GRANT ALL ON TABLE pg_catalog.pg_user_mapping TO statsuser;
       
   pg_catalog          postgres    false    20            �           0    0    TABLE pg_user_mappings    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_user_mappings TO statsuser;
       
   pg_catalog          postgres    false    146            �           0    0    TABLE pg_views    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_views TO statsuser;
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
            public       	   statsuser    false    223            �           0    0    TABLE geography_columns    ACL     :   GRANT ALL ON TABLE public.geography_columns TO statsuser;
          public          postgres    false    221            �           0    0    TABLE geometry_columns    ACL     9   GRANT ALL ON TABLE public.geometry_columns TO statsuser;
          public          postgres    false    222            8           1259    25410    global_land_cover_2019    TABLE     �   CREATE TABLE public.global_land_cover_2019 (
    id integer NOT NULL,
    geom public.geometry(Polygon,4326),
    fid bigint,
    "DN" integer
);
 *   DROP TABLE public.global_land_cover_2019;
       public         heap 	   statsuser    false    3    3    3    3    3    3    3    3            7           1259    25409    global_land_cover_2019_id_seq    SEQUENCE     �   CREATE SEQUENCE public.global_land_cover_2019_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 4   DROP SEQUENCE public.global_land_cover_2019_id_seq;
       public       	   statsuser    false    312            �           0    0    global_land_cover_2019_id_seq    SEQUENCE OWNED BY     _   ALTER SEQUENCE public.global_land_cover_2019_id_seq OWNED BY public.global_land_cover_2019.id;
          public       	   statsuser    false    311            �            1259    17487    long_term_anomaly_info    TABLE     �   CREATE TABLE public.long_term_anomaly_info (
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
       public       	   statsuser    false    225            �           0    0    long_term_anomaly_info_id_seq    SEQUENCE OWNED BY     _   ALTER SEQUENCE public.long_term_anomaly_info_id_seq OWNED BY public.long_term_anomaly_info.id;
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
       public         heap 	   statsuser    false    228            5           1259    23018    poly_stats_25_1_2    TABLE     �  CREATE TABLE public.poly_stats_25_1_2 (
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
 %   DROP TABLE public.poly_stats_25_1_2;
       public         heap 	   statsuser    false    228            6           1259    23111    poly_stats_25_2_257    TABLE     �  CREATE TABLE public.poly_stats_25_2_257 (
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
 '   DROP TABLE public.poly_stats_25_2_257;
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
       public       	   statsuser    false    292            �           0    0    product_file_description_id_seq    SEQUENCE OWNED BY     c   ALTER SEQUENCE public.product_file_description_id_seq OWNED BY public.product_file_description.id;
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
       public       	   statsuser    false    291            �           0    0    product_file_id_seq1    SEQUENCE OWNED BY     L   ALTER SEQUENCE public.product_file_id_seq1 OWNED BY public.product_file.id;
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
       public       	   statsuser    false    296            �           0    0    product_file_variable_id_seq    SEQUENCE OWNED BY     ]   ALTER SEQUENCE public.product_file_variable_id_seq OWNED BY public.product_file_variable.id;
          public       	   statsuser    false    297            *           1259    18013    product_id_seq    SEQUENCE     w   CREATE SEQUENCE public.product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public.product_id_seq;
       public       	   statsuser    false    290            �           0    0    product_id_seq    SEQUENCE OWNED BY     A   ALTER SEQUENCE public.product_id_seq OWNED BY public.product.id;
          public       	   statsuser    false    298            +           1259    18014    product_order    TABLE     /  CREATE TABLE public.product_order (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    email text,
    aoi public.geometry(MultiPolygon,3857),
    request_data jsonb,
    date_created timestamp without time zone DEFAULT (now() AT TIME ZONE 'UTC'::text),
    processed boolean DEFAULT false NOT NULL
);
 !   DROP TABLE public.product_order;
       public         heap 	   statsuser    false    3    3    3    3    3    3    3    3            �           0    0    TABLE spatial_ref_sys    ACL     8   GRANT ALL ON TABLE public.spatial_ref_sys TO statsuser;
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
       public       	   statsuser    false    301            �           0    0    stratification_geom_id_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE public.stratification_geom_id_seq OWNED BY public.stratification_geom.id;
          public       	   statsuser    false    302            /           1259    18033    stratification_id_seq    SEQUENCE     ~   CREATE SEQUENCE public.stratification_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE public.stratification_id_seq;
       public       	   statsuser    false    300            �           0    0    stratification_id_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE public.stratification_id_seq OWNED BY public.stratification.id;
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
       public       	   statsuser    false    305            �           0    0    wms_file_id_seq    SEQUENCE OWNED BY     C   ALTER SEQUENCE public.wms_file_id_seq OWNED BY public.wms_file.id;
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
       tmp       	   statsuser    false    4    307            �           0    0    poly_stats_per_region_id_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE tmp.poly_stats_per_region_id_seq OWNED BY tmp.poly_stats_per_region.id;
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
          public       	   statsuser    false    261    228            �           0    0    poly_stats_25_1_2    TABLE ATTACH     y   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_25_1_2 FOR VALUES FROM ('25', '1') TO ('25', '2');
          public       	   statsuser    false    309    228            �           0    0    poly_stats_25_2_257    TABLE ATTACH     }   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_25_2_257 FOR VALUES FROM ('25', '2') TO ('25', '257');
          public       	   statsuser    false    310    228            �           0    0    poly_stats_2_1_257    TABLE ATTACH     z   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_2_1_257 FOR VALUES FROM ('2', '1') TO ('2', '257');
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
          public       	   statsuser    false    289    228            �           2604    25413    global_land_cover_2019 id    DEFAULT     �   ALTER TABLE ONLY public.global_land_cover_2019 ALTER COLUMN id SET DEFAULT nextval('public.global_land_cover_2019_id_seq'::regclass);
 H   ALTER TABLE public.global_land_cover_2019 ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    311    312    312            �           2604    18054    long_term_anomaly_info id    DEFAULT     �   ALTER TABLE ONLY public.long_term_anomaly_info ALTER COLUMN id SET DEFAULT nextval('public.long_term_anomaly_info_id_seq'::regclass);
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
       tmp       	   statsuser    false    308    307            �           2606    25415 2   global_land_cover_2019 global_land_cover_2019_pkey 
   CONSTRAINT     p   ALTER TABLE ONLY public.global_land_cover_2019
    ADD CONSTRAINT global_land_cover_2019_pkey PRIMARY KEY (id);
 \   ALTER TABLE ONLY public.global_land_cover_2019 DROP CONSTRAINT global_land_cover_2019_pkey;
       public         	   statsuser    false    312            �           2606    18064 0   long_term_anomaly_info long_term_anomaly_info_pk 
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
       public         	   statsuser    false    229    4791    229    229    229            �           2606    18072 0   poly_stats_10_257_279 poly_stats_10_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_10_257_279
    ADD CONSTRAINT poly_stats_10_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_10_257_279 DROP CONSTRAINT poly_stats_10_257_279_pkey;
       public         	   statsuser    false    4791    230    230    230    230            �           2606    18074 0   poly_stats_10_279_285 poly_stats_10_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_10_279_285
    ADD CONSTRAINT poly_stats_10_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_10_279_285 DROP CONSTRAINT poly_stats_10_279_285_pkey;
       public         	   statsuser    false    231    4791    231    231    231            �           2606    18076 4   poly_stats_10_285_38543 poly_stats_10_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_10_285_38543
    ADD CONSTRAINT poly_stats_10_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 ^   ALTER TABLE ONLY public.poly_stats_10_285_38543 DROP CONSTRAINT poly_stats_10_285_38543_pkey;
       public         	   statsuser    false    232    232    232    4791    232            �           2606    18078 ,   poly_stats_12_1_257 poly_stats_12_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_12_1_257
    ADD CONSTRAINT poly_stats_12_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 V   ALTER TABLE ONLY public.poly_stats_12_1_257 DROP CONSTRAINT poly_stats_12_1_257_pkey;
       public         	   statsuser    false    233    233    4791    233    233            �           2606    18080 0   poly_stats_12_257_279 poly_stats_12_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_12_257_279
    ADD CONSTRAINT poly_stats_12_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_12_257_279 DROP CONSTRAINT poly_stats_12_257_279_pkey;
       public         	   statsuser    false    234    234    234    4791    234            �           2606    18082 0   poly_stats_12_279_285 poly_stats_12_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_12_279_285
    ADD CONSTRAINT poly_stats_12_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_12_279_285 DROP CONSTRAINT poly_stats_12_279_285_pkey;
       public         	   statsuser    false    235    235    4791    235    235            �           2606    18084 4   poly_stats_12_285_38543 poly_stats_12_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_12_285_38543
    ADD CONSTRAINT poly_stats_12_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 ^   ALTER TABLE ONLY public.poly_stats_12_285_38543 DROP CONSTRAINT poly_stats_12_285_38543_pkey;
       public         	   statsuser    false    4791    236    236    236    236            �           2606    18086 ,   poly_stats_14_1_257 poly_stats_14_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_14_1_257
    ADD CONSTRAINT poly_stats_14_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 V   ALTER TABLE ONLY public.poly_stats_14_1_257 DROP CONSTRAINT poly_stats_14_1_257_pkey;
       public         	   statsuser    false    237    4791    237    237    237            �           2606    18088 0   poly_stats_14_257_279 poly_stats_14_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_14_257_279
    ADD CONSTRAINT poly_stats_14_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_14_257_279 DROP CONSTRAINT poly_stats_14_257_279_pkey;
       public         	   statsuser    false    238    4791    238    238    238            �           2606    18090 0   poly_stats_14_279_285 poly_stats_14_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_14_279_285
    ADD CONSTRAINT poly_stats_14_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_14_279_285 DROP CONSTRAINT poly_stats_14_279_285_pkey;
       public         	   statsuser    false    239    4791    239    239    239            �           2606    18092 4   poly_stats_14_285_38543 poly_stats_14_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_14_285_38543
    ADD CONSTRAINT poly_stats_14_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 ^   ALTER TABLE ONLY public.poly_stats_14_285_38543 DROP CONSTRAINT poly_stats_14_285_38543_pkey;
       public         	   statsuser    false    240    240    240    4791    240            �           2606    18094 ,   poly_stats_16_1_257 poly_stats_16_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_16_1_257
    ADD CONSTRAINT poly_stats_16_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 V   ALTER TABLE ONLY public.poly_stats_16_1_257 DROP CONSTRAINT poly_stats_16_1_257_pkey;
       public         	   statsuser    false    241    241    241    4791    241            �           2606    18096 0   poly_stats_16_257_279 poly_stats_16_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_16_257_279
    ADD CONSTRAINT poly_stats_16_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_16_257_279 DROP CONSTRAINT poly_stats_16_257_279_pkey;
       public         	   statsuser    false    242    242    242    242    4791            �           2606    18098 0   poly_stats_16_279_285 poly_stats_16_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_16_279_285
    ADD CONSTRAINT poly_stats_16_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_16_279_285 DROP CONSTRAINT poly_stats_16_279_285_pkey;
       public         	   statsuser    false    243    243    243    4791    243            �           2606    18100 4   poly_stats_16_285_38543 poly_stats_16_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_16_285_38543
    ADD CONSTRAINT poly_stats_16_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 ^   ALTER TABLE ONLY public.poly_stats_16_285_38543 DROP CONSTRAINT poly_stats_16_285_38543_pkey;
       public         	   statsuser    false    244    244    244    4791    244            �           2606    18102 ,   poly_stats_17_1_257 poly_stats_17_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_17_1_257
    ADD CONSTRAINT poly_stats_17_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 V   ALTER TABLE ONLY public.poly_stats_17_1_257 DROP CONSTRAINT poly_stats_17_1_257_pkey;
       public         	   statsuser    false    245    245    245    245    4791            �           2606    18104 0   poly_stats_17_257_279 poly_stats_17_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_17_257_279
    ADD CONSTRAINT poly_stats_17_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_17_257_279 DROP CONSTRAINT poly_stats_17_257_279_pkey;
       public         	   statsuser    false    246    4791    246    246    246                       2606    18106 0   poly_stats_17_279_285 poly_stats_17_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_17_279_285
    ADD CONSTRAINT poly_stats_17_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_17_279_285 DROP CONSTRAINT poly_stats_17_279_285_pkey;
       public         	   statsuser    false    247    247    247    4791    247                       2606    18108 4   poly_stats_17_285_38543 poly_stats_17_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_17_285_38543
    ADD CONSTRAINT poly_stats_17_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 ^   ALTER TABLE ONLY public.poly_stats_17_285_38543 DROP CONSTRAINT poly_stats_17_285_38543_pkey;
       public         	   statsuser    false    248    248    248    4791    248                       2606    18110 ,   poly_stats_19_1_257 poly_stats_19_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_19_1_257
    ADD CONSTRAINT poly_stats_19_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 V   ALTER TABLE ONLY public.poly_stats_19_1_257 DROP CONSTRAINT poly_stats_19_1_257_pkey;
       public         	   statsuser    false    249    249    249    4791    249                       2606    18112 0   poly_stats_19_257_279 poly_stats_19_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_19_257_279
    ADD CONSTRAINT poly_stats_19_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_19_257_279 DROP CONSTRAINT poly_stats_19_257_279_pkey;
       public         	   statsuser    false    250    250    250    4791    250                       2606    18114 0   poly_stats_19_279_285 poly_stats_19_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_19_279_285
    ADD CONSTRAINT poly_stats_19_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_19_279_285 DROP CONSTRAINT poly_stats_19_279_285_pkey;
       public         	   statsuser    false    251    251    251    251    4791                       2606    18116 4   poly_stats_19_285_38543 poly_stats_19_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_19_285_38543
    ADD CONSTRAINT poly_stats_19_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 ^   ALTER TABLE ONLY public.poly_stats_19_285_38543 DROP CONSTRAINT poly_stats_19_285_38543_pkey;
       public         	   statsuser    false    252    4791    252    252    252                       2606    18118 *   poly_stats_1_1_257 poly_stats_1_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_1_1_257
    ADD CONSTRAINT poly_stats_1_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 T   ALTER TABLE ONLY public.poly_stats_1_1_257 DROP CONSTRAINT poly_stats_1_1_257_pkey;
       public         	   statsuser    false    253    253    253    253    4791                       2606    18120 .   poly_stats_1_257_279 poly_stats_1_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_1_257_279
    ADD CONSTRAINT poly_stats_1_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_1_257_279 DROP CONSTRAINT poly_stats_1_257_279_pkey;
       public         	   statsuser    false    254    254    254    254    4791            #           2606    18122 .   poly_stats_1_279_285 poly_stats_1_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_1_279_285
    ADD CONSTRAINT poly_stats_1_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_1_279_285 DROP CONSTRAINT poly_stats_1_279_285_pkey;
       public         	   statsuser    false    255    255    4791    255    255            '           2606    18124 2   poly_stats_1_285_38543 poly_stats_1_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_1_285_38543
    ADD CONSTRAINT poly_stats_1_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 \   ALTER TABLE ONLY public.poly_stats_1_285_38543 DROP CONSTRAINT poly_stats_1_285_38543_pkey;
       public         	   statsuser    false    256    256    256    256    4791            +           2606    18126 ,   poly_stats_21_1_257 poly_stats_21_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_21_1_257
    ADD CONSTRAINT poly_stats_21_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 V   ALTER TABLE ONLY public.poly_stats_21_1_257 DROP CONSTRAINT poly_stats_21_1_257_pkey;
       public         	   statsuser    false    257    257    257    4791    257            /           2606    18128 0   poly_stats_21_257_279 poly_stats_21_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_21_257_279
    ADD CONSTRAINT poly_stats_21_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_21_257_279 DROP CONSTRAINT poly_stats_21_257_279_pkey;
       public         	   statsuser    false    258    4791    258    258    258            3           2606    18130 0   poly_stats_21_279_285 poly_stats_21_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_21_279_285
    ADD CONSTRAINT poly_stats_21_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_21_279_285 DROP CONSTRAINT poly_stats_21_279_285_pkey;
       public         	   statsuser    false    259    4791    259    259    259            7           2606    18132 4   poly_stats_21_285_38543 poly_stats_21_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_21_285_38543
    ADD CONSTRAINT poly_stats_21_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 ^   ALTER TABLE ONLY public.poly_stats_21_285_38543 DROP CONSTRAINT poly_stats_21_285_38543_pkey;
       public         	   statsuser    false    260    4791    260    260    260            ;           2606    18134 ,   poly_stats_24_1_257 poly_stats_24_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_24_1_257
    ADD CONSTRAINT poly_stats_24_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 V   ALTER TABLE ONLY public.poly_stats_24_1_257 DROP CONSTRAINT poly_stats_24_1_257_pkey;
       public         	   statsuser    false    261    261    261    4791    261            �           2606    23025 (   poly_stats_25_1_2 poly_stats_25_1_2_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_25_1_2
    ADD CONSTRAINT poly_stats_25_1_2_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 R   ALTER TABLE ONLY public.poly_stats_25_1_2 DROP CONSTRAINT poly_stats_25_1_2_pkey;
       public         	   statsuser    false    309    309    309    4791    309            �           2606    23118 ,   poly_stats_25_2_257 poly_stats_25_2_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_25_2_257
    ADD CONSTRAINT poly_stats_25_2_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 V   ALTER TABLE ONLY public.poly_stats_25_2_257 DROP CONSTRAINT poly_stats_25_2_257_pkey;
       public         	   statsuser    false    4791    310    310    310    310            ?           2606    18136 *   poly_stats_2_1_257 poly_stats_2_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_2_1_257
    ADD CONSTRAINT poly_stats_2_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 T   ALTER TABLE ONLY public.poly_stats_2_1_257 DROP CONSTRAINT poly_stats_2_1_257_pkey;
       public         	   statsuser    false    262    4791    262    262    262            C           2606    18138 .   poly_stats_2_257_279 poly_stats_2_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_2_257_279
    ADD CONSTRAINT poly_stats_2_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_2_257_279 DROP CONSTRAINT poly_stats_2_257_279_pkey;
       public         	   statsuser    false    4791    263    263    263    263            G           2606    18140 .   poly_stats_2_279_285 poly_stats_2_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_2_279_285
    ADD CONSTRAINT poly_stats_2_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_2_279_285 DROP CONSTRAINT poly_stats_2_279_285_pkey;
       public         	   statsuser    false    264    264    264    4791    264            K           2606    18142 2   poly_stats_2_285_38543 poly_stats_2_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_2_285_38543
    ADD CONSTRAINT poly_stats_2_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 \   ALTER TABLE ONLY public.poly_stats_2_285_38543 DROP CONSTRAINT poly_stats_2_285_38543_pkey;
       public         	   statsuser    false    4791    265    265    265    265            O           2606    18144 *   poly_stats_3_1_257 poly_stats_3_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_3_1_257
    ADD CONSTRAINT poly_stats_3_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 T   ALTER TABLE ONLY public.poly_stats_3_1_257 DROP CONSTRAINT poly_stats_3_1_257_pkey;
       public         	   statsuser    false    266    4791    266    266    266            S           2606    18146 .   poly_stats_3_257_279 poly_stats_3_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_3_257_279
    ADD CONSTRAINT poly_stats_3_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_3_257_279 DROP CONSTRAINT poly_stats_3_257_279_pkey;
       public         	   statsuser    false    267    267    4791    267    267            W           2606    18148 .   poly_stats_3_279_285 poly_stats_3_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_3_279_285
    ADD CONSTRAINT poly_stats_3_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_3_279_285 DROP CONSTRAINT poly_stats_3_279_285_pkey;
       public         	   statsuser    false    268    4791    268    268    268            [           2606    18150 2   poly_stats_3_285_38543 poly_stats_3_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_3_285_38543
    ADD CONSTRAINT poly_stats_3_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 \   ALTER TABLE ONLY public.poly_stats_3_285_38543 DROP CONSTRAINT poly_stats_3_285_38543_pkey;
       public         	   statsuser    false    269    4791    269    269    269            _           2606    18152 *   poly_stats_4_1_257 poly_stats_4_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_4_1_257
    ADD CONSTRAINT poly_stats_4_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 T   ALTER TABLE ONLY public.poly_stats_4_1_257 DROP CONSTRAINT poly_stats_4_1_257_pkey;
       public         	   statsuser    false    270    270    270    4791    270            c           2606    18154 .   poly_stats_4_257_279 poly_stats_4_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_4_257_279
    ADD CONSTRAINT poly_stats_4_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_4_257_279 DROP CONSTRAINT poly_stats_4_257_279_pkey;
       public         	   statsuser    false    4791    271    271    271    271            g           2606    18156 .   poly_stats_4_279_285 poly_stats_4_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_4_279_285
    ADD CONSTRAINT poly_stats_4_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_4_279_285 DROP CONSTRAINT poly_stats_4_279_285_pkey;
       public         	   statsuser    false    4791    272    272    272    272            k           2606    18158 2   poly_stats_4_285_38543 poly_stats_4_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_4_285_38543
    ADD CONSTRAINT poly_stats_4_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 \   ALTER TABLE ONLY public.poly_stats_4_285_38543 DROP CONSTRAINT poly_stats_4_285_38543_pkey;
       public         	   statsuser    false    273    273    273    4791    273            o           2606    18160 *   poly_stats_5_1_257 poly_stats_5_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_5_1_257
    ADD CONSTRAINT poly_stats_5_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 T   ALTER TABLE ONLY public.poly_stats_5_1_257 DROP CONSTRAINT poly_stats_5_1_257_pkey;
       public         	   statsuser    false    274    4791    274    274    274            s           2606    18162 .   poly_stats_5_257_279 poly_stats_5_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_5_257_279
    ADD CONSTRAINT poly_stats_5_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_5_257_279 DROP CONSTRAINT poly_stats_5_257_279_pkey;
       public         	   statsuser    false    275    275    4791    275    275            w           2606    18164 .   poly_stats_5_279_285 poly_stats_5_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_5_279_285
    ADD CONSTRAINT poly_stats_5_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_5_279_285 DROP CONSTRAINT poly_stats_5_279_285_pkey;
       public         	   statsuser    false    276    276    4791    276    276            {           2606    18166 2   poly_stats_5_285_38543 poly_stats_5_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_5_285_38543
    ADD CONSTRAINT poly_stats_5_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 \   ALTER TABLE ONLY public.poly_stats_5_285_38543 DROP CONSTRAINT poly_stats_5_285_38543_pkey;
       public         	   statsuser    false    277    4791    277    277    277                       2606    18168 *   poly_stats_6_1_257 poly_stats_6_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_6_1_257
    ADD CONSTRAINT poly_stats_6_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 T   ALTER TABLE ONLY public.poly_stats_6_1_257 DROP CONSTRAINT poly_stats_6_1_257_pkey;
       public         	   statsuser    false    4791    278    278    278    278            �           2606    18170 .   poly_stats_6_257_279 poly_stats_6_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_6_257_279
    ADD CONSTRAINT poly_stats_6_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_6_257_279 DROP CONSTRAINT poly_stats_6_257_279_pkey;
       public         	   statsuser    false    279    4791    279    279    279            �           2606    18172 .   poly_stats_6_279_285 poly_stats_6_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_6_279_285
    ADD CONSTRAINT poly_stats_6_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_6_279_285 DROP CONSTRAINT poly_stats_6_279_285_pkey;
       public         	   statsuser    false    280    280    280    4791    280            �           2606    18174 2   poly_stats_6_285_38543 poly_stats_6_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_6_285_38543
    ADD CONSTRAINT poly_stats_6_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 \   ALTER TABLE ONLY public.poly_stats_6_285_38543 DROP CONSTRAINT poly_stats_6_285_38543_pkey;
       public         	   statsuser    false    281    281    281    4791    281            �           2606    18176 *   poly_stats_7_1_257 poly_stats_7_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_7_1_257
    ADD CONSTRAINT poly_stats_7_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 T   ALTER TABLE ONLY public.poly_stats_7_1_257 DROP CONSTRAINT poly_stats_7_1_257_pkey;
       public         	   statsuser    false    282    4791    282    282    282            �           2606    18178 .   poly_stats_7_257_279 poly_stats_7_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_7_257_279
    ADD CONSTRAINT poly_stats_7_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_7_257_279 DROP CONSTRAINT poly_stats_7_257_279_pkey;
       public         	   statsuser    false    283    4791    283    283    283            �           2606    18180 .   poly_stats_7_279_285 poly_stats_7_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_7_279_285
    ADD CONSTRAINT poly_stats_7_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_7_279_285 DROP CONSTRAINT poly_stats_7_279_285_pkey;
       public         	   statsuser    false    284    4791    284    284    284            �           2606    18182 2   poly_stats_7_285_38543 poly_stats_7_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_7_285_38543
    ADD CONSTRAINT poly_stats_7_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 \   ALTER TABLE ONLY public.poly_stats_7_285_38543 DROP CONSTRAINT poly_stats_7_285_38543_pkey;
       public         	   statsuser    false    285    4791    285    285    285            �           2606    18184 *   poly_stats_9_1_257 poly_stats_9_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_9_1_257
    ADD CONSTRAINT poly_stats_9_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 T   ALTER TABLE ONLY public.poly_stats_9_1_257 DROP CONSTRAINT poly_stats_9_1_257_pkey;
       public         	   statsuser    false    286    286    4791    286    286            �           2606    18186 .   poly_stats_9_257_279 poly_stats_9_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_9_257_279
    ADD CONSTRAINT poly_stats_9_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_9_257_279 DROP CONSTRAINT poly_stats_9_257_279_pkey;
       public         	   statsuser    false    287    287    287    4791    287            �           2606    18188 .   poly_stats_9_279_285 poly_stats_9_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_9_279_285
    ADD CONSTRAINT poly_stats_9_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_9_279_285 DROP CONSTRAINT poly_stats_9_279_285_pkey;
       public         	   statsuser    false    288    4791    288    288    288            �           2606    18190 2   poly_stats_9_285_38543 poly_stats_9_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_9_285_38543
    ADD CONSTRAINT poly_stats_9_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 \   ALTER TABLE ONLY public.poly_stats_9_285_38543 DROP CONSTRAINT poly_stats_9_285_38543_pkey;
       public         	   statsuser    false    289    289    4791    289    289            �           2606    18192 6   product_file product_file_date_product_description_idx 
   CONSTRAINT     �   ALTER TABLE ONLY public.product_file
    ADD CONSTRAINT product_file_date_product_description_idx UNIQUE (product_file_description_id, date, rt_flag);
 `   ALTER TABLE ONLY public.product_file DROP CONSTRAINT product_file_date_product_description_idx;
       public         	   statsuser    false    291    291    291            �           2606    18194    product_file product_file_pk 
   CONSTRAINT     Z   ALTER TABLE ONLY public.product_file
    ADD CONSTRAINT product_file_pk PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.product_file DROP CONSTRAINT product_file_pk;
       public         	   statsuser    false    291            �           2606    18196 .   product_file_variable product_file_variable_pk 
   CONSTRAINT     l   ALTER TABLE ONLY public.product_file_variable
    ADD CONSTRAINT product_file_variable_pk PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.product_file_variable DROP CONSTRAINT product_file_variable_pk;
       public         	   statsuser    false    296            �           2606    18198    product_order product_order_pk 
   CONSTRAINT     \   ALTER TABLE ONLY public.product_order
    ADD CONSTRAINT product_order_pk PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.product_order DROP CONSTRAINT product_order_pk;
       public         	   statsuser    false    299            �           2606    18200    product product_pk1 
   CONSTRAINT     Q   ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_pk1 PRIMARY KEY (id);
 =   ALTER TABLE ONLY public.product DROP CONSTRAINT product_pk1;
       public         	   statsuser    false    290            �           2606    18202 <   product_file_description product_product_file_description_pk 
   CONSTRAINT     z   ALTER TABLE ONLY public.product_file_description
    ADD CONSTRAINT product_product_file_description_pk PRIMARY KEY (id);
 f   ALTER TABLE ONLY public.product_file_description DROP CONSTRAINT product_product_file_description_pk;
       public         	   statsuser    false    292            �           2606    18204     stratification stratification_pk 
   CONSTRAINT     ^   ALTER TABLE ONLY public.stratification
    ADD CONSTRAINT stratification_pk PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.stratification DROP CONSTRAINT stratification_pk;
       public         	   statsuser    false    300            �           2606    18206 '   stratification_geom stratification_pkey 
   CONSTRAINT     e   ALTER TABLE ONLY public.stratification_geom
    ADD CONSTRAINT stratification_pkey PRIMARY KEY (id);
 Q   ALTER TABLE ONLY public.stratification_geom DROP CONSTRAINT stratification_pkey;
       public         	   statsuser    false    301            �           2606    18208     stratification stratification_un 
   CONSTRAINT     b   ALTER TABLE ONLY public.stratification
    ADD CONSTRAINT stratification_un UNIQUE (description);
 J   ALTER TABLE ONLY public.stratification DROP CONSTRAINT stratification_un;
       public         	   statsuser    false    300            �           2606    18210    wms_file wms_file_pk 
   CONSTRAINT     R   ALTER TABLE ONLY public.wms_file
    ADD CONSTRAINT wms_file_pk PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.wms_file DROP CONSTRAINT wms_file_pk;
       public         	   statsuser    false    305            �           2606    18212    wms_file wms_file_un 
   CONSTRAINT     t   ALTER TABLE ONLY public.wms_file
    ADD CONSTRAINT wms_file_un UNIQUE (product_file_id, product_file_variable_id);
 >   ALTER TABLE ONLY public.wms_file DROP CONSTRAINT wms_file_un;
       public         	   statsuser    false    305    305            �           2606    18214 #   poly_stats_per_region poly_stats_pk 
   CONSTRAINT     ^   ALTER TABLE ONLY tmp.poly_stats_per_region
    ADD CONSTRAINT poly_stats_pk PRIMARY KEY (id);
 J   ALTER TABLE ONLY tmp.poly_stats_per_region DROP CONSTRAINT poly_stats_pk;
       tmp         	   statsuser    false    307            �           2606    18216 #   poly_stats_per_region poly_stats_un 
   CONSTRAINT     �   ALTER TABLE ONLY tmp.poly_stats_per_region
    ADD CONSTRAINT poly_stats_un UNIQUE (poly_id, product_file_id, product_file_variable_id, region_id);
 J   ALTER TABLE ONLY tmp.poly_stats_per_region DROP CONSTRAINT poly_stats_un;
       tmp         	   statsuser    false    307    307    307    307            �           1259    18217    poly_stats_product_file_id_idx    INDEX        CREATE INDEX poly_stats_product_file_id_idx ON ONLY public.poly_stats USING btree (product_file_id, product_file_variable_id);
 2   DROP INDEX public.poly_stats_product_file_id_idx;
       public         	   statsuser    false    228    228            �           1259    18218 ?   poly_stats_10_1_257_product_file_id_product_file_variable_i_idx    INDEX     �   CREATE INDEX poly_stats_10_1_257_product_file_id_product_file_variable_i_idx ON public.poly_stats_10_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_10_1_257_product_file_id_product_file_variable_i_idx;
       public         	   statsuser    false    4792    229    229    229            �           1259    25266    poly_stats_valid_pixels_idx    INDEX     _   CREATE INDEX poly_stats_valid_pixels_idx ON ONLY public.poly_stats USING btree (valid_pixels);
 /   DROP INDEX public.poly_stats_valid_pixels_idx;
       public         	   statsuser    false    228            �           1259    25299 $   poly_stats_10_1_257_valid_pixels_idx    INDEX     l   CREATE INDEX poly_stats_10_1_257_valid_pixels_idx ON public.poly_stats_10_1_257 USING btree (valid_pixels);
 8   DROP INDEX public.poly_stats_10_1_257_valid_pixels_idx;
       public         	   statsuser    false    229    229    4793            �           1259    18219 ?   poly_stats_10_257_279_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_10_257_279_product_file_id_product_file_variable_idx ON public.poly_stats_10_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_10_257_279_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    230    230    230    4792            �           1259    25300 &   poly_stats_10_257_279_valid_pixels_idx    INDEX     p   CREATE INDEX poly_stats_10_257_279_valid_pixels_idx ON public.poly_stats_10_257_279 USING btree (valid_pixels);
 :   DROP INDEX public.poly_stats_10_257_279_valid_pixels_idx;
       public         	   statsuser    false    230    230    4793            �           1259    18220 ?   poly_stats_10_279_285_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_10_279_285_product_file_id_product_file_variable_idx ON public.poly_stats_10_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_10_279_285_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    231    4792    231    231            �           1259    25301 &   poly_stats_10_279_285_valid_pixels_idx    INDEX     p   CREATE INDEX poly_stats_10_279_285_valid_pixels_idx ON public.poly_stats_10_279_285 USING btree (valid_pixels);
 :   DROP INDEX public.poly_stats_10_279_285_valid_pixels_idx;
       public         	   statsuser    false    231    231    4793            �           1259    18221 ?   poly_stats_10_285_38543_product_file_id_product_file_variab_idx    INDEX     �   CREATE INDEX poly_stats_10_285_38543_product_file_id_product_file_variab_idx ON public.poly_stats_10_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_10_285_38543_product_file_id_product_file_variab_idx;
       public         	   statsuser    false    232    232    4792    232            �           1259    25302 (   poly_stats_10_285_38543_valid_pixels_idx    INDEX     t   CREATE INDEX poly_stats_10_285_38543_valid_pixels_idx ON public.poly_stats_10_285_38543 USING btree (valid_pixels);
 <   DROP INDEX public.poly_stats_10_285_38543_valid_pixels_idx;
       public         	   statsuser    false    232    4793    232            �           1259    18222 ?   poly_stats_12_1_257_product_file_id_product_file_variable_i_idx    INDEX     �   CREATE INDEX poly_stats_12_1_257_product_file_id_product_file_variable_i_idx ON public.poly_stats_12_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_12_1_257_product_file_id_product_file_variable_i_idx;
       public         	   statsuser    false    233    233    233    4792            �           1259    25303 $   poly_stats_12_1_257_valid_pixels_idx    INDEX     l   CREATE INDEX poly_stats_12_1_257_valid_pixels_idx ON public.poly_stats_12_1_257 USING btree (valid_pixels);
 8   DROP INDEX public.poly_stats_12_1_257_valid_pixels_idx;
       public         	   statsuser    false    4793    233    233            �           1259    18223 ?   poly_stats_12_257_279_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_12_257_279_product_file_id_product_file_variable_idx ON public.poly_stats_12_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_12_257_279_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    234    234    4792    234            �           1259    25304 &   poly_stats_12_257_279_valid_pixels_idx    INDEX     p   CREATE INDEX poly_stats_12_257_279_valid_pixels_idx ON public.poly_stats_12_257_279 USING btree (valid_pixels);
 :   DROP INDEX public.poly_stats_12_257_279_valid_pixels_idx;
       public         	   statsuser    false    234    4793    234            �           1259    18224 ?   poly_stats_12_279_285_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_12_279_285_product_file_id_product_file_variable_idx ON public.poly_stats_12_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_12_279_285_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    235    235    4792    235            �           1259    25305 &   poly_stats_12_279_285_valid_pixels_idx    INDEX     p   CREATE INDEX poly_stats_12_279_285_valid_pixels_idx ON public.poly_stats_12_279_285 USING btree (valid_pixels);
 :   DROP INDEX public.poly_stats_12_279_285_valid_pixels_idx;
       public         	   statsuser    false    235    4793    235            �           1259    18225 ?   poly_stats_12_285_38543_product_file_id_product_file_variab_idx    INDEX     �   CREATE INDEX poly_stats_12_285_38543_product_file_id_product_file_variab_idx ON public.poly_stats_12_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_12_285_38543_product_file_id_product_file_variab_idx;
       public         	   statsuser    false    236    236    236    4792            �           1259    25306 (   poly_stats_12_285_38543_valid_pixels_idx    INDEX     t   CREATE INDEX poly_stats_12_285_38543_valid_pixels_idx ON public.poly_stats_12_285_38543 USING btree (valid_pixels);
 <   DROP INDEX public.poly_stats_12_285_38543_valid_pixels_idx;
       public         	   statsuser    false    236    236    4793            �           1259    18226 ?   poly_stats_14_1_257_product_file_id_product_file_variable_i_idx    INDEX     �   CREATE INDEX poly_stats_14_1_257_product_file_id_product_file_variable_i_idx ON public.poly_stats_14_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_14_1_257_product_file_id_product_file_variable_i_idx;
       public         	   statsuser    false    4792    237    237    237            �           1259    25307 $   poly_stats_14_1_257_valid_pixels_idx    INDEX     l   CREATE INDEX poly_stats_14_1_257_valid_pixels_idx ON public.poly_stats_14_1_257 USING btree (valid_pixels);
 8   DROP INDEX public.poly_stats_14_1_257_valid_pixels_idx;
       public         	   statsuser    false    4793    237    237            �           1259    18227 ?   poly_stats_14_257_279_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_14_257_279_product_file_id_product_file_variable_idx ON public.poly_stats_14_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_14_257_279_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    4792    238    238    238            �           1259    25308 &   poly_stats_14_257_279_valid_pixels_idx    INDEX     p   CREATE INDEX poly_stats_14_257_279_valid_pixels_idx ON public.poly_stats_14_257_279 USING btree (valid_pixels);
 :   DROP INDEX public.poly_stats_14_257_279_valid_pixels_idx;
       public         	   statsuser    false    238    4793    238            �           1259    18228 ?   poly_stats_14_279_285_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_14_279_285_product_file_id_product_file_variable_idx ON public.poly_stats_14_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_14_279_285_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    239    4792    239    239            �           1259    25309 &   poly_stats_14_279_285_valid_pixels_idx    INDEX     p   CREATE INDEX poly_stats_14_279_285_valid_pixels_idx ON public.poly_stats_14_279_285 USING btree (valid_pixels);
 :   DROP INDEX public.poly_stats_14_279_285_valid_pixels_idx;
       public         	   statsuser    false    239    4793    239            �           1259    18229 ?   poly_stats_14_285_38543_product_file_id_product_file_variab_idx    INDEX     �   CREATE INDEX poly_stats_14_285_38543_product_file_id_product_file_variab_idx ON public.poly_stats_14_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_14_285_38543_product_file_id_product_file_variab_idx;
       public         	   statsuser    false    240    240    4792    240            �           1259    25310 (   poly_stats_14_285_38543_valid_pixels_idx    INDEX     t   CREATE INDEX poly_stats_14_285_38543_valid_pixels_idx ON public.poly_stats_14_285_38543 USING btree (valid_pixels);
 <   DROP INDEX public.poly_stats_14_285_38543_valid_pixels_idx;
       public         	   statsuser    false    240    240    4793            �           1259    18230 ?   poly_stats_16_1_257_product_file_id_product_file_variable_i_idx    INDEX     �   CREATE INDEX poly_stats_16_1_257_product_file_id_product_file_variable_i_idx ON public.poly_stats_16_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_16_1_257_product_file_id_product_file_variable_i_idx;
       public         	   statsuser    false    241    241    4792    241            �           1259    25311 $   poly_stats_16_1_257_valid_pixels_idx    INDEX     l   CREATE INDEX poly_stats_16_1_257_valid_pixels_idx ON public.poly_stats_16_1_257 USING btree (valid_pixels);
 8   DROP INDEX public.poly_stats_16_1_257_valid_pixels_idx;
       public         	   statsuser    false    4793    241    241            �           1259    18231 ?   poly_stats_16_257_279_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_16_257_279_product_file_id_product_file_variable_idx ON public.poly_stats_16_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_16_257_279_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    242    4792    242    242            �           1259    25312 &   poly_stats_16_257_279_valid_pixels_idx    INDEX     p   CREATE INDEX poly_stats_16_257_279_valid_pixels_idx ON public.poly_stats_16_257_279 USING btree (valid_pixels);
 :   DROP INDEX public.poly_stats_16_257_279_valid_pixels_idx;
       public         	   statsuser    false    242    242    4793            �           1259    18232 ?   poly_stats_16_279_285_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_16_279_285_product_file_id_product_file_variable_idx ON public.poly_stats_16_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_16_279_285_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    243    243    243    4792            �           1259    25313 &   poly_stats_16_279_285_valid_pixels_idx    INDEX     p   CREATE INDEX poly_stats_16_279_285_valid_pixels_idx ON public.poly_stats_16_279_285 USING btree (valid_pixels);
 :   DROP INDEX public.poly_stats_16_279_285_valid_pixels_idx;
       public         	   statsuser    false    243    4793    243            �           1259    18233 ?   poly_stats_16_285_38543_product_file_id_product_file_variab_idx    INDEX     �   CREATE INDEX poly_stats_16_285_38543_product_file_id_product_file_variab_idx ON public.poly_stats_16_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_16_285_38543_product_file_id_product_file_variab_idx;
       public         	   statsuser    false    244    244    4792    244            �           1259    25314 (   poly_stats_16_285_38543_valid_pixels_idx    INDEX     t   CREATE INDEX poly_stats_16_285_38543_valid_pixels_idx ON public.poly_stats_16_285_38543 USING btree (valid_pixels);
 <   DROP INDEX public.poly_stats_16_285_38543_valid_pixels_idx;
       public         	   statsuser    false    244    4793    244            �           1259    18234 ?   poly_stats_17_1_257_product_file_id_product_file_variable_i_idx    INDEX     �   CREATE INDEX poly_stats_17_1_257_product_file_id_product_file_variable_i_idx ON public.poly_stats_17_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_17_1_257_product_file_id_product_file_variable_i_idx;
       public         	   statsuser    false    245    245    245    4792            �           1259    25315 $   poly_stats_17_1_257_valid_pixels_idx    INDEX     l   CREATE INDEX poly_stats_17_1_257_valid_pixels_idx ON public.poly_stats_17_1_257 USING btree (valid_pixels);
 8   DROP INDEX public.poly_stats_17_1_257_valid_pixels_idx;
       public         	   statsuser    false    245    4793    245                        1259    18235 ?   poly_stats_17_257_279_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_17_257_279_product_file_id_product_file_variable_idx ON public.poly_stats_17_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_17_257_279_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    246    246    4792    246                       1259    25316 &   poly_stats_17_257_279_valid_pixels_idx    INDEX     p   CREATE INDEX poly_stats_17_257_279_valid_pixels_idx ON public.poly_stats_17_257_279 USING btree (valid_pixels);
 :   DROP INDEX public.poly_stats_17_257_279_valid_pixels_idx;
       public         	   statsuser    false    246    4793    246                       1259    18236 ?   poly_stats_17_279_285_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_17_279_285_product_file_id_product_file_variable_idx ON public.poly_stats_17_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_17_279_285_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    4792    247    247    247                       1259    25317 &   poly_stats_17_279_285_valid_pixels_idx    INDEX     p   CREATE INDEX poly_stats_17_279_285_valid_pixels_idx ON public.poly_stats_17_279_285 USING btree (valid_pixels);
 :   DROP INDEX public.poly_stats_17_279_285_valid_pixels_idx;
       public         	   statsuser    false    247    247    4793                       1259    18237 ?   poly_stats_17_285_38543_product_file_id_product_file_variab_idx    INDEX     �   CREATE INDEX poly_stats_17_285_38543_product_file_id_product_file_variab_idx ON public.poly_stats_17_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_17_285_38543_product_file_id_product_file_variab_idx;
       public         	   statsuser    false    248    248    248    4792            	           1259    25318 (   poly_stats_17_285_38543_valid_pixels_idx    INDEX     t   CREATE INDEX poly_stats_17_285_38543_valid_pixels_idx ON public.poly_stats_17_285_38543 USING btree (valid_pixels);
 <   DROP INDEX public.poly_stats_17_285_38543_valid_pixels_idx;
       public         	   statsuser    false    4793    248    248                       1259    18238 ?   poly_stats_19_1_257_product_file_id_product_file_variable_i_idx    INDEX     �   CREATE INDEX poly_stats_19_1_257_product_file_id_product_file_variable_i_idx ON public.poly_stats_19_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_19_1_257_product_file_id_product_file_variable_i_idx;
       public         	   statsuser    false    249    249    249    4792                       1259    25319 $   poly_stats_19_1_257_valid_pixels_idx    INDEX     l   CREATE INDEX poly_stats_19_1_257_valid_pixels_idx ON public.poly_stats_19_1_257 USING btree (valid_pixels);
 8   DROP INDEX public.poly_stats_19_1_257_valid_pixels_idx;
       public         	   statsuser    false    249    249    4793                       1259    18239 ?   poly_stats_19_257_279_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_19_257_279_product_file_id_product_file_variable_idx ON public.poly_stats_19_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_19_257_279_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    250    250    4792    250                       1259    25320 &   poly_stats_19_257_279_valid_pixels_idx    INDEX     p   CREATE INDEX poly_stats_19_257_279_valid_pixels_idx ON public.poly_stats_19_257_279 USING btree (valid_pixels);
 :   DROP INDEX public.poly_stats_19_257_279_valid_pixels_idx;
       public         	   statsuser    false    250    250    4793                       1259    18240 ?   poly_stats_19_279_285_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_19_279_285_product_file_id_product_file_variable_idx ON public.poly_stats_19_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_19_279_285_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    251    251    251    4792                       1259    25321 &   poly_stats_19_279_285_valid_pixels_idx    INDEX     p   CREATE INDEX poly_stats_19_279_285_valid_pixels_idx ON public.poly_stats_19_279_285 USING btree (valid_pixels);
 :   DROP INDEX public.poly_stats_19_279_285_valid_pixels_idx;
       public         	   statsuser    false    4793    251    251                       1259    18241 ?   poly_stats_19_285_38543_product_file_id_product_file_variab_idx    INDEX     �   CREATE INDEX poly_stats_19_285_38543_product_file_id_product_file_variab_idx ON public.poly_stats_19_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_19_285_38543_product_file_id_product_file_variab_idx;
       public         	   statsuser    false    252    252    252    4792                       1259    25322 (   poly_stats_19_285_38543_valid_pixels_idx    INDEX     t   CREATE INDEX poly_stats_19_285_38543_valid_pixels_idx ON public.poly_stats_19_285_38543 USING btree (valid_pixels);
 <   DROP INDEX public.poly_stats_19_285_38543_valid_pixels_idx;
       public         	   statsuser    false    4793    252    252                       1259    18242 ?   poly_stats_1_1_257_product_file_id_product_file_variable_id_idx    INDEX     �   CREATE INDEX poly_stats_1_1_257_product_file_id_product_file_variable_id_idx ON public.poly_stats_1_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_1_1_257_product_file_id_product_file_variable_id_idx;
       public         	   statsuser    false    4792    253    253    253                       1259    25267 #   poly_stats_1_1_257_valid_pixels_idx    INDEX     j   CREATE INDEX poly_stats_1_1_257_valid_pixels_idx ON public.poly_stats_1_1_257 USING btree (valid_pixels);
 7   DROP INDEX public.poly_stats_1_1_257_valid_pixels_idx;
       public         	   statsuser    false    4793    253    253                        1259    18243 ?   poly_stats_1_257_279_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_1_257_279_product_file_id_product_file_variable__idx ON public.poly_stats_1_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_1_257_279_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    254    4792    254    254            !           1259    25268 %   poly_stats_1_257_279_valid_pixels_idx    INDEX     n   CREATE INDEX poly_stats_1_257_279_valid_pixels_idx ON public.poly_stats_1_257_279 USING btree (valid_pixels);
 9   DROP INDEX public.poly_stats_1_257_279_valid_pixels_idx;
       public         	   statsuser    false    254    254    4793            $           1259    18244 ?   poly_stats_1_279_285_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_1_279_285_product_file_id_product_file_variable__idx ON public.poly_stats_1_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_1_279_285_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    255    255    4792    255            %           1259    25269 %   poly_stats_1_279_285_valid_pixels_idx    INDEX     n   CREATE INDEX poly_stats_1_279_285_valid_pixels_idx ON public.poly_stats_1_279_285 USING btree (valid_pixels);
 9   DROP INDEX public.poly_stats_1_279_285_valid_pixels_idx;
       public         	   statsuser    false    4793    255    255            (           1259    18245 ?   poly_stats_1_285_38543_product_file_id_product_file_variabl_idx    INDEX     �   CREATE INDEX poly_stats_1_285_38543_product_file_id_product_file_variabl_idx ON public.poly_stats_1_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_1_285_38543_product_file_id_product_file_variabl_idx;
       public         	   statsuser    false    256    256    256    4792            )           1259    25270 '   poly_stats_1_285_38543_valid_pixels_idx    INDEX     r   CREATE INDEX poly_stats_1_285_38543_valid_pixels_idx ON public.poly_stats_1_285_38543 USING btree (valid_pixels);
 ;   DROP INDEX public.poly_stats_1_285_38543_valid_pixels_idx;
       public         	   statsuser    false    256    256    4793            ,           1259    18246 ?   poly_stats_21_1_257_product_file_id_product_file_variable_i_idx    INDEX     �   CREATE INDEX poly_stats_21_1_257_product_file_id_product_file_variable_i_idx ON public.poly_stats_21_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_21_1_257_product_file_id_product_file_variable_i_idx;
       public         	   statsuser    false    257    257    4792    257            -           1259    25323 $   poly_stats_21_1_257_valid_pixels_idx    INDEX     l   CREATE INDEX poly_stats_21_1_257_valid_pixels_idx ON public.poly_stats_21_1_257 USING btree (valid_pixels);
 8   DROP INDEX public.poly_stats_21_1_257_valid_pixels_idx;
       public         	   statsuser    false    4793    257    257            0           1259    18247 ?   poly_stats_21_257_279_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_21_257_279_product_file_id_product_file_variable_idx ON public.poly_stats_21_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_21_257_279_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    258    258    4792    258            1           1259    25324 &   poly_stats_21_257_279_valid_pixels_idx    INDEX     p   CREATE INDEX poly_stats_21_257_279_valid_pixels_idx ON public.poly_stats_21_257_279 USING btree (valid_pixels);
 :   DROP INDEX public.poly_stats_21_257_279_valid_pixels_idx;
       public         	   statsuser    false    4793    258    258            4           1259    18248 ?   poly_stats_21_279_285_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_21_279_285_product_file_id_product_file_variable_idx ON public.poly_stats_21_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_21_279_285_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    259    259    4792    259            5           1259    25325 &   poly_stats_21_279_285_valid_pixels_idx    INDEX     p   CREATE INDEX poly_stats_21_279_285_valid_pixels_idx ON public.poly_stats_21_279_285 USING btree (valid_pixels);
 :   DROP INDEX public.poly_stats_21_279_285_valid_pixels_idx;
       public         	   statsuser    false    259    259    4793            8           1259    18249 ?   poly_stats_21_285_38543_product_file_id_product_file_variab_idx    INDEX     �   CREATE INDEX poly_stats_21_285_38543_product_file_id_product_file_variab_idx ON public.poly_stats_21_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_21_285_38543_product_file_id_product_file_variab_idx;
       public         	   statsuser    false    4792    260    260    260            9           1259    25326 (   poly_stats_21_285_38543_valid_pixels_idx    INDEX     t   CREATE INDEX poly_stats_21_285_38543_valid_pixels_idx ON public.poly_stats_21_285_38543 USING btree (valid_pixels);
 <   DROP INDEX public.poly_stats_21_285_38543_valid_pixels_idx;
       public         	   statsuser    false    4793    260    260            <           1259    18250 ?   poly_stats_24_1_257_product_file_id_product_file_variable_i_idx    INDEX     �   CREATE INDEX poly_stats_24_1_257_product_file_id_product_file_variable_i_idx ON public.poly_stats_24_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_24_1_257_product_file_id_product_file_variable_i_idx;
       public         	   statsuser    false    261    4792    261    261            =           1259    25327 $   poly_stats_24_1_257_valid_pixels_idx    INDEX     l   CREATE INDEX poly_stats_24_1_257_valid_pixels_idx ON public.poly_stats_24_1_257 USING btree (valid_pixels);
 8   DROP INDEX public.poly_stats_24_1_257_valid_pixels_idx;
       public         	   statsuser    false    4793    261    261            �           1259    23026 >   poly_stats_25_1_2_product_file_id_product_file_variable_id_idx    INDEX     �   CREATE INDEX poly_stats_25_1_2_product_file_id_product_file_variable_id_idx ON public.poly_stats_25_1_2 USING btree (product_file_id, product_file_variable_id);
 R   DROP INDEX public.poly_stats_25_1_2_product_file_id_product_file_variable_id_idx;
       public         	   statsuser    false    4792    309    309    309            �           1259    25328 "   poly_stats_25_1_2_valid_pixels_idx    INDEX     h   CREATE INDEX poly_stats_25_1_2_valid_pixels_idx ON public.poly_stats_25_1_2 USING btree (valid_pixels);
 6   DROP INDEX public.poly_stats_25_1_2_valid_pixels_idx;
       public         	   statsuser    false    309    309    4793            �           1259    23119 ?   poly_stats_25_2_257_product_file_id_product_file_variable_i_idx    INDEX     �   CREATE INDEX poly_stats_25_2_257_product_file_id_product_file_variable_i_idx ON public.poly_stats_25_2_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_25_2_257_product_file_id_product_file_variable_i_idx;
       public         	   statsuser    false    310    310    310    4792            �           1259    25329 $   poly_stats_25_2_257_valid_pixels_idx    INDEX     l   CREATE INDEX poly_stats_25_2_257_valid_pixels_idx ON public.poly_stats_25_2_257 USING btree (valid_pixels);
 8   DROP INDEX public.poly_stats_25_2_257_valid_pixels_idx;
       public         	   statsuser    false    310    4793    310            @           1259    18251 ?   poly_stats_2_1_257_product_file_id_product_file_variable_id_idx    INDEX     �   CREATE INDEX poly_stats_2_1_257_product_file_id_product_file_variable_id_idx ON public.poly_stats_2_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_2_1_257_product_file_id_product_file_variable_id_idx;
       public         	   statsuser    false    262    262    262    4792            A           1259    25271 #   poly_stats_2_1_257_valid_pixels_idx    INDEX     j   CREATE INDEX poly_stats_2_1_257_valid_pixels_idx ON public.poly_stats_2_1_257 USING btree (valid_pixels);
 7   DROP INDEX public.poly_stats_2_1_257_valid_pixels_idx;
       public         	   statsuser    false    262    4793    262            D           1259    18252 ?   poly_stats_2_257_279_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_2_257_279_product_file_id_product_file_variable__idx ON public.poly_stats_2_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_2_257_279_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    4792    263    263    263            E           1259    25272 %   poly_stats_2_257_279_valid_pixels_idx    INDEX     n   CREATE INDEX poly_stats_2_257_279_valid_pixels_idx ON public.poly_stats_2_257_279 USING btree (valid_pixels);
 9   DROP INDEX public.poly_stats_2_257_279_valid_pixels_idx;
       public         	   statsuser    false    4793    263    263            H           1259    18253 ?   poly_stats_2_279_285_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_2_279_285_product_file_id_product_file_variable__idx ON public.poly_stats_2_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_2_279_285_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    264    4792    264    264            I           1259    25273 %   poly_stats_2_279_285_valid_pixels_idx    INDEX     n   CREATE INDEX poly_stats_2_279_285_valid_pixels_idx ON public.poly_stats_2_279_285 USING btree (valid_pixels);
 9   DROP INDEX public.poly_stats_2_279_285_valid_pixels_idx;
       public         	   statsuser    false    264    4793    264            L           1259    18254 ?   poly_stats_2_285_38543_product_file_id_product_file_variabl_idx    INDEX     �   CREATE INDEX poly_stats_2_285_38543_product_file_id_product_file_variabl_idx ON public.poly_stats_2_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_2_285_38543_product_file_id_product_file_variabl_idx;
       public         	   statsuser    false    265    265    265    4792            M           1259    25274 '   poly_stats_2_285_38543_valid_pixels_idx    INDEX     r   CREATE INDEX poly_stats_2_285_38543_valid_pixels_idx ON public.poly_stats_2_285_38543 USING btree (valid_pixels);
 ;   DROP INDEX public.poly_stats_2_285_38543_valid_pixels_idx;
       public         	   statsuser    false    265    265    4793            P           1259    18255 ?   poly_stats_3_1_257_product_file_id_product_file_variable_id_idx    INDEX     �   CREATE INDEX poly_stats_3_1_257_product_file_id_product_file_variable_id_idx ON public.poly_stats_3_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_3_1_257_product_file_id_product_file_variable_id_idx;
       public         	   statsuser    false    266    4792    266    266            Q           1259    25275 #   poly_stats_3_1_257_valid_pixels_idx    INDEX     j   CREATE INDEX poly_stats_3_1_257_valid_pixels_idx ON public.poly_stats_3_1_257 USING btree (valid_pixels);
 7   DROP INDEX public.poly_stats_3_1_257_valid_pixels_idx;
       public         	   statsuser    false    266    4793    266            T           1259    18256 ?   poly_stats_3_257_279_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_3_257_279_product_file_id_product_file_variable__idx ON public.poly_stats_3_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_3_257_279_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    267    4792    267    267            U           1259    25276 %   poly_stats_3_257_279_valid_pixels_idx    INDEX     n   CREATE INDEX poly_stats_3_257_279_valid_pixels_idx ON public.poly_stats_3_257_279 USING btree (valid_pixels);
 9   DROP INDEX public.poly_stats_3_257_279_valid_pixels_idx;
       public         	   statsuser    false    267    267    4793            X           1259    18257 ?   poly_stats_3_279_285_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_3_279_285_product_file_id_product_file_variable__idx ON public.poly_stats_3_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_3_279_285_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    4792    268    268    268            Y           1259    25277 %   poly_stats_3_279_285_valid_pixels_idx    INDEX     n   CREATE INDEX poly_stats_3_279_285_valid_pixels_idx ON public.poly_stats_3_279_285 USING btree (valid_pixels);
 9   DROP INDEX public.poly_stats_3_279_285_valid_pixels_idx;
       public         	   statsuser    false    268    4793    268            \           1259    18258 ?   poly_stats_3_285_38543_product_file_id_product_file_variabl_idx    INDEX     �   CREATE INDEX poly_stats_3_285_38543_product_file_id_product_file_variabl_idx ON public.poly_stats_3_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_3_285_38543_product_file_id_product_file_variabl_idx;
       public         	   statsuser    false    269    4792    269    269            ]           1259    25278 '   poly_stats_3_285_38543_valid_pixels_idx    INDEX     r   CREATE INDEX poly_stats_3_285_38543_valid_pixels_idx ON public.poly_stats_3_285_38543 USING btree (valid_pixels);
 ;   DROP INDEX public.poly_stats_3_285_38543_valid_pixels_idx;
       public         	   statsuser    false    269    4793    269            `           1259    18259 ?   poly_stats_4_1_257_product_file_id_product_file_variable_id_idx    INDEX     �   CREATE INDEX poly_stats_4_1_257_product_file_id_product_file_variable_id_idx ON public.poly_stats_4_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_4_1_257_product_file_id_product_file_variable_id_idx;
       public         	   statsuser    false    270    270    4792    270            a           1259    25279 #   poly_stats_4_1_257_valid_pixels_idx    INDEX     j   CREATE INDEX poly_stats_4_1_257_valid_pixels_idx ON public.poly_stats_4_1_257 USING btree (valid_pixels);
 7   DROP INDEX public.poly_stats_4_1_257_valid_pixels_idx;
       public         	   statsuser    false    270    270    4793            d           1259    18260 ?   poly_stats_4_257_279_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_4_257_279_product_file_id_product_file_variable__idx ON public.poly_stats_4_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_4_257_279_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    271    271    4792    271            e           1259    25280 %   poly_stats_4_257_279_valid_pixels_idx    INDEX     n   CREATE INDEX poly_stats_4_257_279_valid_pixels_idx ON public.poly_stats_4_257_279 USING btree (valid_pixels);
 9   DROP INDEX public.poly_stats_4_257_279_valid_pixels_idx;
       public         	   statsuser    false    4793    271    271            h           1259    18261 ?   poly_stats_4_279_285_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_4_279_285_product_file_id_product_file_variable__idx ON public.poly_stats_4_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_4_279_285_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    272    4792    272    272            i           1259    25281 %   poly_stats_4_279_285_valid_pixels_idx    INDEX     n   CREATE INDEX poly_stats_4_279_285_valid_pixels_idx ON public.poly_stats_4_279_285 USING btree (valid_pixels);
 9   DROP INDEX public.poly_stats_4_279_285_valid_pixels_idx;
       public         	   statsuser    false    4793    272    272            l           1259    18262 ?   poly_stats_4_285_38543_product_file_id_product_file_variabl_idx    INDEX     �   CREATE INDEX poly_stats_4_285_38543_product_file_id_product_file_variabl_idx ON public.poly_stats_4_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_4_285_38543_product_file_id_product_file_variabl_idx;
       public         	   statsuser    false    273    273    4792    273            m           1259    25282 '   poly_stats_4_285_38543_valid_pixels_idx    INDEX     r   CREATE INDEX poly_stats_4_285_38543_valid_pixels_idx ON public.poly_stats_4_285_38543 USING btree (valid_pixels);
 ;   DROP INDEX public.poly_stats_4_285_38543_valid_pixels_idx;
       public         	   statsuser    false    273    4793    273            p           1259    18263 ?   poly_stats_5_1_257_product_file_id_product_file_variable_id_idx    INDEX     �   CREATE INDEX poly_stats_5_1_257_product_file_id_product_file_variable_id_idx ON public.poly_stats_5_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_5_1_257_product_file_id_product_file_variable_id_idx;
       public         	   statsuser    false    274    274    274    4792            q           1259    25283 #   poly_stats_5_1_257_valid_pixels_idx    INDEX     j   CREATE INDEX poly_stats_5_1_257_valid_pixels_idx ON public.poly_stats_5_1_257 USING btree (valid_pixels);
 7   DROP INDEX public.poly_stats_5_1_257_valid_pixels_idx;
       public         	   statsuser    false    274    4793    274            t           1259    18264 ?   poly_stats_5_257_279_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_5_257_279_product_file_id_product_file_variable__idx ON public.poly_stats_5_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_5_257_279_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    275    275    275    4792            u           1259    25284 %   poly_stats_5_257_279_valid_pixels_idx    INDEX     n   CREATE INDEX poly_stats_5_257_279_valid_pixels_idx ON public.poly_stats_5_257_279 USING btree (valid_pixels);
 9   DROP INDEX public.poly_stats_5_257_279_valid_pixels_idx;
       public         	   statsuser    false    275    275    4793            x           1259    18265 ?   poly_stats_5_279_285_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_5_279_285_product_file_id_product_file_variable__idx ON public.poly_stats_5_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_5_279_285_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    276    276    276    4792            y           1259    25285 %   poly_stats_5_279_285_valid_pixels_idx    INDEX     n   CREATE INDEX poly_stats_5_279_285_valid_pixels_idx ON public.poly_stats_5_279_285 USING btree (valid_pixels);
 9   DROP INDEX public.poly_stats_5_279_285_valid_pixels_idx;
       public         	   statsuser    false    276    276    4793            |           1259    18266 ?   poly_stats_5_285_38543_product_file_id_product_file_variabl_idx    INDEX     �   CREATE INDEX poly_stats_5_285_38543_product_file_id_product_file_variabl_idx ON public.poly_stats_5_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_5_285_38543_product_file_id_product_file_variabl_idx;
       public         	   statsuser    false    277    4792    277    277            }           1259    25286 '   poly_stats_5_285_38543_valid_pixels_idx    INDEX     r   CREATE INDEX poly_stats_5_285_38543_valid_pixels_idx ON public.poly_stats_5_285_38543 USING btree (valid_pixels);
 ;   DROP INDEX public.poly_stats_5_285_38543_valid_pixels_idx;
       public         	   statsuser    false    277    277    4793            �           1259    18267 ?   poly_stats_6_1_257_product_file_id_product_file_variable_id_idx    INDEX     �   CREATE INDEX poly_stats_6_1_257_product_file_id_product_file_variable_id_idx ON public.poly_stats_6_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_6_1_257_product_file_id_product_file_variable_id_idx;
       public         	   statsuser    false    278    278    4792    278            �           1259    25287 #   poly_stats_6_1_257_valid_pixels_idx    INDEX     j   CREATE INDEX poly_stats_6_1_257_valid_pixels_idx ON public.poly_stats_6_1_257 USING btree (valid_pixels);
 7   DROP INDEX public.poly_stats_6_1_257_valid_pixels_idx;
       public         	   statsuser    false    278    4793    278            �           1259    18268 ?   poly_stats_6_257_279_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_6_257_279_product_file_id_product_file_variable__idx ON public.poly_stats_6_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_6_257_279_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    279    4792    279    279            �           1259    25288 %   poly_stats_6_257_279_valid_pixels_idx    INDEX     n   CREATE INDEX poly_stats_6_257_279_valid_pixels_idx ON public.poly_stats_6_257_279 USING btree (valid_pixels);
 9   DROP INDEX public.poly_stats_6_257_279_valid_pixels_idx;
       public         	   statsuser    false    279    4793    279            �           1259    18269 ?   poly_stats_6_279_285_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_6_279_285_product_file_id_product_file_variable__idx ON public.poly_stats_6_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_6_279_285_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    280    280    280    4792            �           1259    25289 %   poly_stats_6_279_285_valid_pixels_idx    INDEX     n   CREATE INDEX poly_stats_6_279_285_valid_pixels_idx ON public.poly_stats_6_279_285 USING btree (valid_pixels);
 9   DROP INDEX public.poly_stats_6_279_285_valid_pixels_idx;
       public         	   statsuser    false    280    4793    280            �           1259    18270 ?   poly_stats_6_285_38543_product_file_id_product_file_variabl_idx    INDEX     �   CREATE INDEX poly_stats_6_285_38543_product_file_id_product_file_variabl_idx ON public.poly_stats_6_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_6_285_38543_product_file_id_product_file_variabl_idx;
       public         	   statsuser    false    281    281    4792    281            �           1259    25290 '   poly_stats_6_285_38543_valid_pixels_idx    INDEX     r   CREATE INDEX poly_stats_6_285_38543_valid_pixels_idx ON public.poly_stats_6_285_38543 USING btree (valid_pixels);
 ;   DROP INDEX public.poly_stats_6_285_38543_valid_pixels_idx;
       public         	   statsuser    false    281    4793    281            �           1259    18271 ?   poly_stats_7_1_257_product_file_id_product_file_variable_id_idx    INDEX     �   CREATE INDEX poly_stats_7_1_257_product_file_id_product_file_variable_id_idx ON public.poly_stats_7_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_7_1_257_product_file_id_product_file_variable_id_idx;
       public         	   statsuser    false    282    4792    282    282            �           1259    25291 #   poly_stats_7_1_257_valid_pixels_idx    INDEX     j   CREATE INDEX poly_stats_7_1_257_valid_pixels_idx ON public.poly_stats_7_1_257 USING btree (valid_pixels);
 7   DROP INDEX public.poly_stats_7_1_257_valid_pixels_idx;
       public         	   statsuser    false    282    4793    282            �           1259    18272 ?   poly_stats_7_257_279_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_7_257_279_product_file_id_product_file_variable__idx ON public.poly_stats_7_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_7_257_279_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    283    283    283    4792            �           1259    25292 %   poly_stats_7_257_279_valid_pixels_idx    INDEX     n   CREATE INDEX poly_stats_7_257_279_valid_pixels_idx ON public.poly_stats_7_257_279 USING btree (valid_pixels);
 9   DROP INDEX public.poly_stats_7_257_279_valid_pixels_idx;
       public         	   statsuser    false    283    4793    283            �           1259    18273 ?   poly_stats_7_279_285_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_7_279_285_product_file_id_product_file_variable__idx ON public.poly_stats_7_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_7_279_285_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    4792    284    284    284            �           1259    25293 %   poly_stats_7_279_285_valid_pixels_idx    INDEX     n   CREATE INDEX poly_stats_7_279_285_valid_pixels_idx ON public.poly_stats_7_279_285 USING btree (valid_pixels);
 9   DROP INDEX public.poly_stats_7_279_285_valid_pixels_idx;
       public         	   statsuser    false    284    4793    284            �           1259    18274 ?   poly_stats_7_285_38543_product_file_id_product_file_variabl_idx    INDEX     �   CREATE INDEX poly_stats_7_285_38543_product_file_id_product_file_variabl_idx ON public.poly_stats_7_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_7_285_38543_product_file_id_product_file_variabl_idx;
       public         	   statsuser    false    285    285    4792    285            �           1259    25294 '   poly_stats_7_285_38543_valid_pixels_idx    INDEX     r   CREATE INDEX poly_stats_7_285_38543_valid_pixels_idx ON public.poly_stats_7_285_38543 USING btree (valid_pixels);
 ;   DROP INDEX public.poly_stats_7_285_38543_valid_pixels_idx;
       public         	   statsuser    false    285    4793    285            �           1259    18275 ?   poly_stats_9_1_257_product_file_id_product_file_variable_id_idx    INDEX     �   CREATE INDEX poly_stats_9_1_257_product_file_id_product_file_variable_id_idx ON public.poly_stats_9_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_9_1_257_product_file_id_product_file_variable_id_idx;
       public         	   statsuser    false    286    286    286    4792            �           1259    25295 #   poly_stats_9_1_257_valid_pixels_idx    INDEX     j   CREATE INDEX poly_stats_9_1_257_valid_pixels_idx ON public.poly_stats_9_1_257 USING btree (valid_pixels);
 7   DROP INDEX public.poly_stats_9_1_257_valid_pixels_idx;
       public         	   statsuser    false    286    4793    286            �           1259    18276 ?   poly_stats_9_257_279_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_9_257_279_product_file_id_product_file_variable__idx ON public.poly_stats_9_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_9_257_279_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    287    4792    287    287            �           1259    25296 %   poly_stats_9_257_279_valid_pixels_idx    INDEX     n   CREATE INDEX poly_stats_9_257_279_valid_pixels_idx ON public.poly_stats_9_257_279 USING btree (valid_pixels);
 9   DROP INDEX public.poly_stats_9_257_279_valid_pixels_idx;
       public         	   statsuser    false    287    287    4793            �           1259    18277 ?   poly_stats_9_279_285_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_9_279_285_product_file_id_product_file_variable__idx ON public.poly_stats_9_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_9_279_285_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    288    288    4792    288            �           1259    25297 %   poly_stats_9_279_285_valid_pixels_idx    INDEX     n   CREATE INDEX poly_stats_9_279_285_valid_pixels_idx ON public.poly_stats_9_279_285 USING btree (valid_pixels);
 9   DROP INDEX public.poly_stats_9_279_285_valid_pixels_idx;
       public         	   statsuser    false    288    288    4793            �           1259    18278 ?   poly_stats_9_285_38543_product_file_id_product_file_variabl_idx    INDEX     �   CREATE INDEX poly_stats_9_285_38543_product_file_id_product_file_variabl_idx ON public.poly_stats_9_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_9_285_38543_product_file_id_product_file_variabl_idx;
       public         	   statsuser    false    289    289    289    4792            �           1259    25298 '   poly_stats_9_285_38543_valid_pixels_idx    INDEX     r   CREATE INDEX poly_stats_9_285_38543_valid_pixels_idx ON public.poly_stats_9_285_38543 USING btree (valid_pixels);
 ;   DROP INDEX public.poly_stats_9_285_38543_valid_pixels_idx;
       public         	   statsuser    false    289    289    4793            �           1259    18279    product_file_date_idx    INDEX     W   CREATE INDEX product_file_date_idx ON public.product_file USING btree (date, rt_flag);
 )   DROP INDEX public.product_file_date_idx;
       public         	   statsuser    false    291    291            �           1259    18280    product_order_email_idx    INDEX     `   CREATE INDEX product_order_email_idx ON public.product_order USING btree (email, date_created);
 +   DROP INDEX public.product_order_email_idx;
       public         	   statsuser    false    299    299            �           1259    18281    sidx_stratification_geom    INDEX     W   CREATE INDEX sidx_stratification_geom ON public.stratification_geom USING gist (geom);
 ,   DROP INDEX public.sidx_stratification_geom;
       public         	   statsuser    false    301    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3            �           1259    18282    sidx_stratification_geom3857    INDEX     �   CREATE INDEX sidx_stratification_geom3857 ON public.stratification_geom USING gist (geom3857);

ALTER TABLE public.stratification_geom CLUSTER ON sidx_stratification_geom3857;
 0   DROP INDEX public.sidx_stratification_geom3857;
       public         	   statsuser    false    301    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3            �           0    0    poly_stats_10_1_257_pkey    INDEX ATTACH     T   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_10_1_257_pkey;
          public       	   statsuser    false    229    4795    4791    4791    229    228            �           0    0 ?   poly_stats_10_1_257_product_file_id_product_file_variable_i_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_10_1_257_product_file_id_product_file_variable_i_idx;
          public       	   statsuser    false    4796    4792    229    228            �           0    0 $   poly_stats_10_1_257_valid_pixels_idx    INDEX ATTACH     m   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_10_1_257_valid_pixels_idx;
          public       	   statsuser    false    4797    4793    229    228            �           0    0    poly_stats_10_257_279_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_10_257_279_pkey;
          public       	   statsuser    false    230    4799    4791    4791    230    228            �           0    0 ?   poly_stats_10_257_279_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_10_257_279_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4800    4792    230    228            �           0    0 &   poly_stats_10_257_279_valid_pixels_idx    INDEX ATTACH     o   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_10_257_279_valid_pixels_idx;
          public       	   statsuser    false    4801    4793    230    228            �           0    0    poly_stats_10_279_285_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_10_279_285_pkey;
          public       	   statsuser    false    4803    231    4791    4791    231    228            �           0    0 ?   poly_stats_10_279_285_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_10_279_285_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4804    4792    231    228            �           0    0 &   poly_stats_10_279_285_valid_pixels_idx    INDEX ATTACH     o   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_10_279_285_valid_pixels_idx;
          public       	   statsuser    false    4805    4793    231    228            �           0    0    poly_stats_10_285_38543_pkey    INDEX ATTACH     X   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_10_285_38543_pkey;
          public       	   statsuser    false    4791    232    4807    4791    232    228            �           0    0 ?   poly_stats_10_285_38543_product_file_id_product_file_variab_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_10_285_38543_product_file_id_product_file_variab_idx;
          public       	   statsuser    false    4808    4792    232    228            �           0    0 (   poly_stats_10_285_38543_valid_pixels_idx    INDEX ATTACH     q   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_10_285_38543_valid_pixels_idx;
          public       	   statsuser    false    4809    4793    232    228            �           0    0    poly_stats_12_1_257_pkey    INDEX ATTACH     T   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_12_1_257_pkey;
          public       	   statsuser    false    4791    4811    233    4791    233    228            �           0    0 ?   poly_stats_12_1_257_product_file_id_product_file_variable_i_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_12_1_257_product_file_id_product_file_variable_i_idx;
          public       	   statsuser    false    4812    4792    233    228            �           0    0 $   poly_stats_12_1_257_valid_pixels_idx    INDEX ATTACH     m   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_12_1_257_valid_pixels_idx;
          public       	   statsuser    false    4813    4793    233    228            �           0    0    poly_stats_12_257_279_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_12_257_279_pkey;
          public       	   statsuser    false    4815    234    4791    4791    234    228            �           0    0 ?   poly_stats_12_257_279_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_12_257_279_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4816    4792    234    228            �           0    0 &   poly_stats_12_257_279_valid_pixels_idx    INDEX ATTACH     o   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_12_257_279_valid_pixels_idx;
          public       	   statsuser    false    4817    4793    234    228            �           0    0    poly_stats_12_279_285_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_12_279_285_pkey;
          public       	   statsuser    false    235    4819    4791    4791    235    228            �           0    0 ?   poly_stats_12_279_285_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_12_279_285_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4820    4792    235    228            �           0    0 &   poly_stats_12_279_285_valid_pixels_idx    INDEX ATTACH     o   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_12_279_285_valid_pixels_idx;
          public       	   statsuser    false    4821    4793    235    228            �           0    0    poly_stats_12_285_38543_pkey    INDEX ATTACH     X   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_12_285_38543_pkey;
          public       	   statsuser    false    4791    236    4823    4791    236    228            �           0    0 ?   poly_stats_12_285_38543_product_file_id_product_file_variab_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_12_285_38543_product_file_id_product_file_variab_idx;
          public       	   statsuser    false    4824    4792    236    228            �           0    0 (   poly_stats_12_285_38543_valid_pixels_idx    INDEX ATTACH     q   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_12_285_38543_valid_pixels_idx;
          public       	   statsuser    false    4825    4793    236    228            �           0    0    poly_stats_14_1_257_pkey    INDEX ATTACH     T   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_14_1_257_pkey;
          public       	   statsuser    false    237    4791    4827    4791    237    228            �           0    0 ?   poly_stats_14_1_257_product_file_id_product_file_variable_i_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_14_1_257_product_file_id_product_file_variable_i_idx;
          public       	   statsuser    false    4828    4792    237    228            �           0    0 $   poly_stats_14_1_257_valid_pixels_idx    INDEX ATTACH     m   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_14_1_257_valid_pixels_idx;
          public       	   statsuser    false    4829    4793    237    228            �           0    0    poly_stats_14_257_279_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_14_257_279_pkey;
          public       	   statsuser    false    4831    238    4791    4791    238    228            �           0    0 ?   poly_stats_14_257_279_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_14_257_279_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4832    4792    238    228            �           0    0 &   poly_stats_14_257_279_valid_pixels_idx    INDEX ATTACH     o   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_14_257_279_valid_pixels_idx;
          public       	   statsuser    false    4833    4793    238    228            �           0    0    poly_stats_14_279_285_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_14_279_285_pkey;
          public       	   statsuser    false    4791    239    4835    4791    239    228            �           0    0 ?   poly_stats_14_279_285_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_14_279_285_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4836    4792    239    228            �           0    0 &   poly_stats_14_279_285_valid_pixels_idx    INDEX ATTACH     o   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_14_279_285_valid_pixels_idx;
          public       	   statsuser    false    4837    4793    239    228            �           0    0    poly_stats_14_285_38543_pkey    INDEX ATTACH     X   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_14_285_38543_pkey;
          public       	   statsuser    false    240    4791    4839    4791    240    228            �           0    0 ?   poly_stats_14_285_38543_product_file_id_product_file_variab_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_14_285_38543_product_file_id_product_file_variab_idx;
          public       	   statsuser    false    4840    4792    240    228            �           0    0 (   poly_stats_14_285_38543_valid_pixels_idx    INDEX ATTACH     q   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_14_285_38543_valid_pixels_idx;
          public       	   statsuser    false    4841    4793    240    228            �           0    0    poly_stats_16_1_257_pkey    INDEX ATTACH     T   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_16_1_257_pkey;
          public       	   statsuser    false    241    4843    4791    4791    241    228            �           0    0 ?   poly_stats_16_1_257_product_file_id_product_file_variable_i_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_16_1_257_product_file_id_product_file_variable_i_idx;
          public       	   statsuser    false    4844    4792    241    228            �           0    0 $   poly_stats_16_1_257_valid_pixels_idx    INDEX ATTACH     m   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_16_1_257_valid_pixels_idx;
          public       	   statsuser    false    4845    4793    241    228            �           0    0    poly_stats_16_257_279_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_16_257_279_pkey;
          public       	   statsuser    false    4791    242    4847    4791    242    228            �           0    0 ?   poly_stats_16_257_279_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_16_257_279_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4848    4792    242    228            �           0    0 &   poly_stats_16_257_279_valid_pixels_idx    INDEX ATTACH     o   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_16_257_279_valid_pixels_idx;
          public       	   statsuser    false    4849    4793    242    228                        0    0    poly_stats_16_279_285_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_16_279_285_pkey;
          public       	   statsuser    false    243    4851    4791    4791    243    228                       0    0 ?   poly_stats_16_279_285_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_16_279_285_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4852    4792    243    228                       0    0 &   poly_stats_16_279_285_valid_pixels_idx    INDEX ATTACH     o   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_16_279_285_valid_pixels_idx;
          public       	   statsuser    false    4853    4793    243    228                       0    0    poly_stats_16_285_38543_pkey    INDEX ATTACH     X   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_16_285_38543_pkey;
          public       	   statsuser    false    244    4855    4791    4791    244    228                       0    0 ?   poly_stats_16_285_38543_product_file_id_product_file_variab_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_16_285_38543_product_file_id_product_file_variab_idx;
          public       	   statsuser    false    4856    4792    244    228                       0    0 (   poly_stats_16_285_38543_valid_pixels_idx    INDEX ATTACH     q   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_16_285_38543_valid_pixels_idx;
          public       	   statsuser    false    4857    4793    244    228                       0    0    poly_stats_17_1_257_pkey    INDEX ATTACH     T   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_17_1_257_pkey;
          public       	   statsuser    false    245    4859    4791    4791    245    228                       0    0 ?   poly_stats_17_1_257_product_file_id_product_file_variable_i_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_17_1_257_product_file_id_product_file_variable_i_idx;
          public       	   statsuser    false    4860    4792    245    228                       0    0 $   poly_stats_17_1_257_valid_pixels_idx    INDEX ATTACH     m   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_17_1_257_valid_pixels_idx;
          public       	   statsuser    false    4861    4793    245    228            	           0    0    poly_stats_17_257_279_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_17_257_279_pkey;
          public       	   statsuser    false    4791    4863    246    4791    246    228            
           0    0 ?   poly_stats_17_257_279_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_17_257_279_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4864    4792    246    228                       0    0 &   poly_stats_17_257_279_valid_pixels_idx    INDEX ATTACH     o   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_17_257_279_valid_pixels_idx;
          public       	   statsuser    false    4865    4793    246    228                       0    0    poly_stats_17_279_285_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_17_279_285_pkey;
          public       	   statsuser    false    4867    247    4791    4791    247    228                       0    0 ?   poly_stats_17_279_285_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_17_279_285_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4868    4792    247    228                       0    0 &   poly_stats_17_279_285_valid_pixels_idx    INDEX ATTACH     o   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_17_279_285_valid_pixels_idx;
          public       	   statsuser    false    4869    4793    247    228                       0    0    poly_stats_17_285_38543_pkey    INDEX ATTACH     X   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_17_285_38543_pkey;
          public       	   statsuser    false    4871    248    4791    4791    248    228                       0    0 ?   poly_stats_17_285_38543_product_file_id_product_file_variab_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_17_285_38543_product_file_id_product_file_variab_idx;
          public       	   statsuser    false    4872    4792    248    228                       0    0 (   poly_stats_17_285_38543_valid_pixels_idx    INDEX ATTACH     q   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_17_285_38543_valid_pixels_idx;
          public       	   statsuser    false    4873    4793    248    228                       0    0    poly_stats_19_1_257_pkey    INDEX ATTACH     T   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_19_1_257_pkey;
          public       	   statsuser    false    4791    249    4875    4791    249    228                       0    0 ?   poly_stats_19_1_257_product_file_id_product_file_variable_i_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_19_1_257_product_file_id_product_file_variable_i_idx;
          public       	   statsuser    false    4876    4792    249    228                       0    0 $   poly_stats_19_1_257_valid_pixels_idx    INDEX ATTACH     m   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_19_1_257_valid_pixels_idx;
          public       	   statsuser    false    4877    4793    249    228                       0    0    poly_stats_19_257_279_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_19_257_279_pkey;
          public       	   statsuser    false    4791    250    4879    4791    250    228                       0    0 ?   poly_stats_19_257_279_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_19_257_279_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4880    4792    250    228                       0    0 &   poly_stats_19_257_279_valid_pixels_idx    INDEX ATTACH     o   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_19_257_279_valid_pixels_idx;
          public       	   statsuser    false    4881    4793    250    228                       0    0    poly_stats_19_279_285_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_19_279_285_pkey;
          public       	   statsuser    false    4883    251    4791    4791    251    228                       0    0 ?   poly_stats_19_279_285_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_19_279_285_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4884    4792    251    228                       0    0 &   poly_stats_19_279_285_valid_pixels_idx    INDEX ATTACH     o   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_19_279_285_valid_pixels_idx;
          public       	   statsuser    false    4885    4793    251    228                       0    0    poly_stats_19_285_38543_pkey    INDEX ATTACH     X   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_19_285_38543_pkey;
          public       	   statsuser    false    4887    4791    252    4791    252    228                       0    0 ?   poly_stats_19_285_38543_product_file_id_product_file_variab_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_19_285_38543_product_file_id_product_file_variab_idx;
          public       	   statsuser    false    4888    4792    252    228                       0    0 (   poly_stats_19_285_38543_valid_pixels_idx    INDEX ATTACH     q   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_19_285_38543_valid_pixels_idx;
          public       	   statsuser    false    4889    4793    252    228                       0    0    poly_stats_1_1_257_pkey    INDEX ATTACH     S   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_1_1_257_pkey;
          public       	   statsuser    false    4891    4791    253    4791    253    228                       0    0 ?   poly_stats_1_1_257_product_file_id_product_file_variable_id_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_1_1_257_product_file_id_product_file_variable_id_idx;
          public       	   statsuser    false    4892    4792    253    228                        0    0 #   poly_stats_1_1_257_valid_pixels_idx    INDEX ATTACH     l   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_1_1_257_valid_pixels_idx;
          public       	   statsuser    false    4893    4793    253    228            !           0    0    poly_stats_1_257_279_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_1_257_279_pkey;
          public       	   statsuser    false    4895    4791    254    4791    254    228            "           0    0 ?   poly_stats_1_257_279_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_1_257_279_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4896    4792    254    228            #           0    0 %   poly_stats_1_257_279_valid_pixels_idx    INDEX ATTACH     n   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_1_257_279_valid_pixels_idx;
          public       	   statsuser    false    4897    4793    254    228            $           0    0    poly_stats_1_279_285_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_1_279_285_pkey;
          public       	   statsuser    false    4791    4899    255    4791    255    228            %           0    0 ?   poly_stats_1_279_285_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_1_279_285_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4900    4792    255    228            &           0    0 %   poly_stats_1_279_285_valid_pixels_idx    INDEX ATTACH     n   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_1_279_285_valid_pixels_idx;
          public       	   statsuser    false    4901    4793    255    228            '           0    0    poly_stats_1_285_38543_pkey    INDEX ATTACH     W   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_1_285_38543_pkey;
          public       	   statsuser    false    256    4791    4903    4791    256    228            (           0    0 ?   poly_stats_1_285_38543_product_file_id_product_file_variabl_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_1_285_38543_product_file_id_product_file_variabl_idx;
          public       	   statsuser    false    4904    4792    256    228            )           0    0 '   poly_stats_1_285_38543_valid_pixels_idx    INDEX ATTACH     p   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_1_285_38543_valid_pixels_idx;
          public       	   statsuser    false    4905    4793    256    228            *           0    0    poly_stats_21_1_257_pkey    INDEX ATTACH     T   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_21_1_257_pkey;
          public       	   statsuser    false    4907    257    4791    4791    257    228            +           0    0 ?   poly_stats_21_1_257_product_file_id_product_file_variable_i_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_21_1_257_product_file_id_product_file_variable_i_idx;
          public       	   statsuser    false    4908    4792    257    228            ,           0    0 $   poly_stats_21_1_257_valid_pixels_idx    INDEX ATTACH     m   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_21_1_257_valid_pixels_idx;
          public       	   statsuser    false    4909    4793    257    228            -           0    0    poly_stats_21_257_279_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_21_257_279_pkey;
          public       	   statsuser    false    258    4791    4911    4791    258    228            .           0    0 ?   poly_stats_21_257_279_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_21_257_279_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4912    4792    258    228            /           0    0 &   poly_stats_21_257_279_valid_pixels_idx    INDEX ATTACH     o   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_21_257_279_valid_pixels_idx;
          public       	   statsuser    false    4913    4793    258    228            0           0    0    poly_stats_21_279_285_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_21_279_285_pkey;
          public       	   statsuser    false    4791    259    4915    4791    259    228            1           0    0 ?   poly_stats_21_279_285_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_21_279_285_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4916    4792    259    228            2           0    0 &   poly_stats_21_279_285_valid_pixels_idx    INDEX ATTACH     o   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_21_279_285_valid_pixels_idx;
          public       	   statsuser    false    4917    4793    259    228            3           0    0    poly_stats_21_285_38543_pkey    INDEX ATTACH     X   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_21_285_38543_pkey;
          public       	   statsuser    false    260    4791    4919    4791    260    228            4           0    0 ?   poly_stats_21_285_38543_product_file_id_product_file_variab_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_21_285_38543_product_file_id_product_file_variab_idx;
          public       	   statsuser    false    4920    4792    260    228            5           0    0 (   poly_stats_21_285_38543_valid_pixels_idx    INDEX ATTACH     q   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_21_285_38543_valid_pixels_idx;
          public       	   statsuser    false    4921    4793    260    228            6           0    0    poly_stats_24_1_257_pkey    INDEX ATTACH     T   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_24_1_257_pkey;
          public       	   statsuser    false    4923    4791    261    4791    261    228            7           0    0 ?   poly_stats_24_1_257_product_file_id_product_file_variable_i_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_24_1_257_product_file_id_product_file_variable_i_idx;
          public       	   statsuser    false    4924    4792    261    228            8           0    0 $   poly_stats_24_1_257_valid_pixels_idx    INDEX ATTACH     m   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_24_1_257_valid_pixels_idx;
          public       	   statsuser    false    4925    4793    261    228            �           0    0    poly_stats_25_1_2_pkey    INDEX ATTACH     R   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_25_1_2_pkey;
          public       	   statsuser    false    5069    4791    309    4791    309    228            �           0    0 >   poly_stats_25_1_2_product_file_id_product_file_variable_id_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_25_1_2_product_file_id_product_file_variable_id_idx;
          public       	   statsuser    false    5070    4792    309    228            �           0    0 "   poly_stats_25_1_2_valid_pixels_idx    INDEX ATTACH     k   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_25_1_2_valid_pixels_idx;
          public       	   statsuser    false    5071    4793    309    228            �           0    0    poly_stats_25_2_257_pkey    INDEX ATTACH     T   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_25_2_257_pkey;
          public       	   statsuser    false    310    5073    4791    4791    310    228            �           0    0 ?   poly_stats_25_2_257_product_file_id_product_file_variable_i_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_25_2_257_product_file_id_product_file_variable_i_idx;
          public       	   statsuser    false    5074    4792    310    228            �           0    0 $   poly_stats_25_2_257_valid_pixels_idx    INDEX ATTACH     m   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_25_2_257_valid_pixels_idx;
          public       	   statsuser    false    5075    4793    310    228            9           0    0    poly_stats_2_1_257_pkey    INDEX ATTACH     S   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_2_1_257_pkey;
          public       	   statsuser    false    4927    262    4791    4791    262    228            :           0    0 ?   poly_stats_2_1_257_product_file_id_product_file_variable_id_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_2_1_257_product_file_id_product_file_variable_id_idx;
          public       	   statsuser    false    4928    4792    262    228            ;           0    0 #   poly_stats_2_1_257_valid_pixels_idx    INDEX ATTACH     l   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_2_1_257_valid_pixels_idx;
          public       	   statsuser    false    4929    4793    262    228            <           0    0    poly_stats_2_257_279_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_2_257_279_pkey;
          public       	   statsuser    false    4931    263    4791    4791    263    228            =           0    0 ?   poly_stats_2_257_279_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_2_257_279_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4932    4792    263    228            >           0    0 %   poly_stats_2_257_279_valid_pixels_idx    INDEX ATTACH     n   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_2_257_279_valid_pixels_idx;
          public       	   statsuser    false    4933    4793    263    228            ?           0    0    poly_stats_2_279_285_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_2_279_285_pkey;
          public       	   statsuser    false    4791    264    4935    4791    264    228            @           0    0 ?   poly_stats_2_279_285_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_2_279_285_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4936    4792    264    228            A           0    0 %   poly_stats_2_279_285_valid_pixels_idx    INDEX ATTACH     n   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_2_279_285_valid_pixels_idx;
          public       	   statsuser    false    4937    4793    264    228            B           0    0    poly_stats_2_285_38543_pkey    INDEX ATTACH     W   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_2_285_38543_pkey;
          public       	   statsuser    false    4791    265    4939    4791    265    228            C           0    0 ?   poly_stats_2_285_38543_product_file_id_product_file_variabl_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_2_285_38543_product_file_id_product_file_variabl_idx;
          public       	   statsuser    false    4940    4792    265    228            D           0    0 '   poly_stats_2_285_38543_valid_pixels_idx    INDEX ATTACH     p   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_2_285_38543_valid_pixels_idx;
          public       	   statsuser    false    4941    4793    265    228            E           0    0    poly_stats_3_1_257_pkey    INDEX ATTACH     S   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_3_1_257_pkey;
          public       	   statsuser    false    4791    266    4943    4791    266    228            F           0    0 ?   poly_stats_3_1_257_product_file_id_product_file_variable_id_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_3_1_257_product_file_id_product_file_variable_id_idx;
          public       	   statsuser    false    4944    4792    266    228            G           0    0 #   poly_stats_3_1_257_valid_pixels_idx    INDEX ATTACH     l   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_3_1_257_valid_pixels_idx;
          public       	   statsuser    false    4945    4793    266    228            H           0    0    poly_stats_3_257_279_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_3_257_279_pkey;
          public       	   statsuser    false    4791    4947    267    4791    267    228            I           0    0 ?   poly_stats_3_257_279_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_3_257_279_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4948    4792    267    228            J           0    0 %   poly_stats_3_257_279_valid_pixels_idx    INDEX ATTACH     n   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_3_257_279_valid_pixels_idx;
          public       	   statsuser    false    4949    4793    267    228            K           0    0    poly_stats_3_279_285_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_3_279_285_pkey;
          public       	   statsuser    false    4791    268    4951    4791    268    228            L           0    0 ?   poly_stats_3_279_285_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_3_279_285_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4952    4792    268    228            M           0    0 %   poly_stats_3_279_285_valid_pixels_idx    INDEX ATTACH     n   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_3_279_285_valid_pixels_idx;
          public       	   statsuser    false    4953    4793    268    228            N           0    0    poly_stats_3_285_38543_pkey    INDEX ATTACH     W   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_3_285_38543_pkey;
          public       	   statsuser    false    4791    4955    269    4791    269    228            O           0    0 ?   poly_stats_3_285_38543_product_file_id_product_file_variabl_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_3_285_38543_product_file_id_product_file_variabl_idx;
          public       	   statsuser    false    4956    4792    269    228            P           0    0 '   poly_stats_3_285_38543_valid_pixels_idx    INDEX ATTACH     p   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_3_285_38543_valid_pixels_idx;
          public       	   statsuser    false    4957    4793    269    228            Q           0    0    poly_stats_4_1_257_pkey    INDEX ATTACH     S   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_4_1_257_pkey;
          public       	   statsuser    false    4959    4791    270    4791    270    228            R           0    0 ?   poly_stats_4_1_257_product_file_id_product_file_variable_id_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_4_1_257_product_file_id_product_file_variable_id_idx;
          public       	   statsuser    false    4960    4792    270    228            S           0    0 #   poly_stats_4_1_257_valid_pixels_idx    INDEX ATTACH     l   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_4_1_257_valid_pixels_idx;
          public       	   statsuser    false    4961    4793    270    228            T           0    0    poly_stats_4_257_279_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_4_257_279_pkey;
          public       	   statsuser    false    271    4791    4963    4791    271    228            U           0    0 ?   poly_stats_4_257_279_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_4_257_279_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4964    4792    271    228            V           0    0 %   poly_stats_4_257_279_valid_pixels_idx    INDEX ATTACH     n   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_4_257_279_valid_pixels_idx;
          public       	   statsuser    false    4965    4793    271    228            W           0    0    poly_stats_4_279_285_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_4_279_285_pkey;
          public       	   statsuser    false    272    4967    4791    4791    272    228            X           0    0 ?   poly_stats_4_279_285_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_4_279_285_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4968    4792    272    228            Y           0    0 %   poly_stats_4_279_285_valid_pixels_idx    INDEX ATTACH     n   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_4_279_285_valid_pixels_idx;
          public       	   statsuser    false    4969    4793    272    228            Z           0    0    poly_stats_4_285_38543_pkey    INDEX ATTACH     W   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_4_285_38543_pkey;
          public       	   statsuser    false    4791    4971    273    4791    273    228            [           0    0 ?   poly_stats_4_285_38543_product_file_id_product_file_variabl_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_4_285_38543_product_file_id_product_file_variabl_idx;
          public       	   statsuser    false    4972    4792    273    228            \           0    0 '   poly_stats_4_285_38543_valid_pixels_idx    INDEX ATTACH     p   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_4_285_38543_valid_pixels_idx;
          public       	   statsuser    false    4973    4793    273    228            ]           0    0    poly_stats_5_1_257_pkey    INDEX ATTACH     S   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_5_1_257_pkey;
          public       	   statsuser    false    4975    274    4791    4791    274    228            ^           0    0 ?   poly_stats_5_1_257_product_file_id_product_file_variable_id_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_5_1_257_product_file_id_product_file_variable_id_idx;
          public       	   statsuser    false    4976    4792    274    228            _           0    0 #   poly_stats_5_1_257_valid_pixels_idx    INDEX ATTACH     l   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_5_1_257_valid_pixels_idx;
          public       	   statsuser    false    4977    4793    274    228            `           0    0    poly_stats_5_257_279_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_5_257_279_pkey;
          public       	   statsuser    false    275    4979    4791    4791    275    228            a           0    0 ?   poly_stats_5_257_279_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_5_257_279_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4980    4792    275    228            b           0    0 %   poly_stats_5_257_279_valid_pixels_idx    INDEX ATTACH     n   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_5_257_279_valid_pixels_idx;
          public       	   statsuser    false    4981    4793    275    228            c           0    0    poly_stats_5_279_285_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_5_279_285_pkey;
          public       	   statsuser    false    276    4791    4983    4791    276    228            d           0    0 ?   poly_stats_5_279_285_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_5_279_285_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4984    4792    276    228            e           0    0 %   poly_stats_5_279_285_valid_pixels_idx    INDEX ATTACH     n   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_5_279_285_valid_pixels_idx;
          public       	   statsuser    false    4985    4793    276    228            f           0    0    poly_stats_5_285_38543_pkey    INDEX ATTACH     W   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_5_285_38543_pkey;
          public       	   statsuser    false    277    4791    4987    4791    277    228            g           0    0 ?   poly_stats_5_285_38543_product_file_id_product_file_variabl_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_5_285_38543_product_file_id_product_file_variabl_idx;
          public       	   statsuser    false    4988    4792    277    228            h           0    0 '   poly_stats_5_285_38543_valid_pixels_idx    INDEX ATTACH     p   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_5_285_38543_valid_pixels_idx;
          public       	   statsuser    false    4989    4793    277    228            i           0    0    poly_stats_6_1_257_pkey    INDEX ATTACH     S   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_6_1_257_pkey;
          public       	   statsuser    false    4791    278    4991    4791    278    228            j           0    0 ?   poly_stats_6_1_257_product_file_id_product_file_variable_id_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_6_1_257_product_file_id_product_file_variable_id_idx;
          public       	   statsuser    false    4992    4792    278    228            k           0    0 #   poly_stats_6_1_257_valid_pixels_idx    INDEX ATTACH     l   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_6_1_257_valid_pixels_idx;
          public       	   statsuser    false    4993    4793    278    228            l           0    0    poly_stats_6_257_279_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_6_257_279_pkey;
          public       	   statsuser    false    279    4791    4995    4791    279    228            m           0    0 ?   poly_stats_6_257_279_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_6_257_279_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4996    4792    279    228            n           0    0 %   poly_stats_6_257_279_valid_pixels_idx    INDEX ATTACH     n   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_6_257_279_valid_pixels_idx;
          public       	   statsuser    false    4997    4793    279    228            o           0    0    poly_stats_6_279_285_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_6_279_285_pkey;
          public       	   statsuser    false    4999    4791    280    4791    280    228            p           0    0 ?   poly_stats_6_279_285_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_6_279_285_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    5000    4792    280    228            q           0    0 %   poly_stats_6_279_285_valid_pixels_idx    INDEX ATTACH     n   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_6_279_285_valid_pixels_idx;
          public       	   statsuser    false    5001    4793    280    228            r           0    0    poly_stats_6_285_38543_pkey    INDEX ATTACH     W   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_6_285_38543_pkey;
          public       	   statsuser    false    5003    281    4791    4791    281    228            s           0    0 ?   poly_stats_6_285_38543_product_file_id_product_file_variabl_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_6_285_38543_product_file_id_product_file_variabl_idx;
          public       	   statsuser    false    5004    4792    281    228            t           0    0 '   poly_stats_6_285_38543_valid_pixels_idx    INDEX ATTACH     p   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_6_285_38543_valid_pixels_idx;
          public       	   statsuser    false    5005    4793    281    228            u           0    0    poly_stats_7_1_257_pkey    INDEX ATTACH     S   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_7_1_257_pkey;
          public       	   statsuser    false    5007    282    4791    4791    282    228            v           0    0 ?   poly_stats_7_1_257_product_file_id_product_file_variable_id_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_7_1_257_product_file_id_product_file_variable_id_idx;
          public       	   statsuser    false    5008    4792    282    228            w           0    0 #   poly_stats_7_1_257_valid_pixels_idx    INDEX ATTACH     l   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_7_1_257_valid_pixels_idx;
          public       	   statsuser    false    5009    4793    282    228            x           0    0    poly_stats_7_257_279_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_7_257_279_pkey;
          public       	   statsuser    false    4791    283    5011    4791    283    228            y           0    0 ?   poly_stats_7_257_279_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_7_257_279_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    5012    4792    283    228            z           0    0 %   poly_stats_7_257_279_valid_pixels_idx    INDEX ATTACH     n   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_7_257_279_valid_pixels_idx;
          public       	   statsuser    false    5013    4793    283    228            {           0    0    poly_stats_7_279_285_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_7_279_285_pkey;
          public       	   statsuser    false    4791    284    5015    4791    284    228            |           0    0 ?   poly_stats_7_279_285_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_7_279_285_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    5016    4792    284    228            }           0    0 %   poly_stats_7_279_285_valid_pixels_idx    INDEX ATTACH     n   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_7_279_285_valid_pixels_idx;
          public       	   statsuser    false    5017    4793    284    228            ~           0    0    poly_stats_7_285_38543_pkey    INDEX ATTACH     W   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_7_285_38543_pkey;
          public       	   statsuser    false    285    4791    5019    4791    285    228                       0    0 ?   poly_stats_7_285_38543_product_file_id_product_file_variabl_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_7_285_38543_product_file_id_product_file_variabl_idx;
          public       	   statsuser    false    5020    4792    285    228            �           0    0 '   poly_stats_7_285_38543_valid_pixels_idx    INDEX ATTACH     p   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_7_285_38543_valid_pixels_idx;
          public       	   statsuser    false    5021    4793    285    228            �           0    0    poly_stats_9_1_257_pkey    INDEX ATTACH     S   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_9_1_257_pkey;
          public       	   statsuser    false    4791    5023    286    4791    286    228            �           0    0 ?   poly_stats_9_1_257_product_file_id_product_file_variable_id_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_9_1_257_product_file_id_product_file_variable_id_idx;
          public       	   statsuser    false    5024    4792    286    228            �           0    0 #   poly_stats_9_1_257_valid_pixels_idx    INDEX ATTACH     l   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_9_1_257_valid_pixels_idx;
          public       	   statsuser    false    5025    4793    286    228            �           0    0    poly_stats_9_257_279_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_9_257_279_pkey;
          public       	   statsuser    false    4791    5027    287    4791    287    228            �           0    0 ?   poly_stats_9_257_279_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_9_257_279_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    5028    4792    287    228            �           0    0 %   poly_stats_9_257_279_valid_pixels_idx    INDEX ATTACH     n   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_9_257_279_valid_pixels_idx;
          public       	   statsuser    false    5029    4793    287    228            �           0    0    poly_stats_9_279_285_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_9_279_285_pkey;
          public       	   statsuser    false    288    5031    4791    4791    288    228            �           0    0 ?   poly_stats_9_279_285_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_9_279_285_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    5032    4792    288    228            �           0    0 %   poly_stats_9_279_285_valid_pixels_idx    INDEX ATTACH     n   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_9_279_285_valid_pixels_idx;
          public       	   statsuser    false    5033    4793    288    228            �           0    0    poly_stats_9_285_38543_pkey    INDEX ATTACH     W   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_9_285_38543_pkey;
          public       	   statsuser    false    5035    289    4791    4791    289    228            �           0    0 ?   poly_stats_9_285_38543_product_file_id_product_file_variabl_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_9_285_38543_product_file_id_product_file_variabl_idx;
          public       	   statsuser    false    5036    4792    289    228            �           0    0 '   poly_stats_9_285_38543_valid_pixels_idx    INDEX ATTACH     p   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_9_285_38543_valid_pixels_idx;
          public       	   statsuser    false    5037    4793    289    228            �           2606    18283 0   long_term_anomaly_info long_term_anomaly_info_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.long_term_anomaly_info
    ADD CONSTRAINT long_term_anomaly_info_fk FOREIGN KEY (anomaly_product_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 Z   ALTER TABLE ONLY public.long_term_anomaly_info DROP CONSTRAINT long_term_anomaly_info_fk;
       public       	   statsuser    false    225    5048    296            �           2606    18288 2   long_term_anomaly_info long_term_anomaly_info_fk_1    FK CONSTRAINT     �   ALTER TABLE ONLY public.long_term_anomaly_info
    ADD CONSTRAINT long_term_anomaly_info_fk_1 FOREIGN KEY (mean_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 \   ALTER TABLE ONLY public.long_term_anomaly_info DROP CONSTRAINT long_term_anomaly_info_fk_1;
       public       	   statsuser    false    296    225    5048            �           2606    18293 2   long_term_anomaly_info long_term_anomaly_info_fk_2    FK CONSTRAINT     �   ALTER TABLE ONLY public.long_term_anomaly_info
    ADD CONSTRAINT long_term_anomaly_info_fk_2 FOREIGN KEY (stdev_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 \   ALTER TABLE ONLY public.long_term_anomaly_info DROP CONSTRAINT long_term_anomaly_info_fk_2;
       public       	   statsuser    false    5048    225    296            �           2606    18298 2   long_term_anomaly_info long_term_anomaly_info_fk_3    FK CONSTRAINT     �   ALTER TABLE ONLY public.long_term_anomaly_info
    ADD CONSTRAINT long_term_anomaly_info_fk_3 FOREIGN KEY (raw_product_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 \   ALTER TABLE ONLY public.long_term_anomaly_info DROP CONSTRAINT long_term_anomaly_info_fk_3;
       public       	   statsuser    false    5048    225    296            �           2606    18303 &   poly_stats poly_stats_product_file_fk_    FK CONSTRAINT     �   ALTER TABLE public.poly_stats
    ADD CONSTRAINT poly_stats_product_file_fk_ FOREIGN KEY (product_file_id) REFERENCES public.product_file(id) ON UPDATE CASCADE ON DELETE CASCADE;
 K   ALTER TABLE public.poly_stats DROP CONSTRAINT poly_stats_product_file_fk_;
       public       	   statsuser    false    5044    228    291            �           2606    18491 *   poly_stats poly_stats_product_variable_fk_    FK CONSTRAINT     �   ALTER TABLE public.poly_stats
    ADD CONSTRAINT poly_stats_product_variable_fk_ FOREIGN KEY (product_file_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 O   ALTER TABLE public.poly_stats DROP CONSTRAINT poly_stats_product_variable_fk_;
       public       	   statsuser    false    228    5048    296            �           2606    18679 -   poly_stats poly_stats_stratification_geom_fk_    FK CONSTRAINT     �   ALTER TABLE public.poly_stats
    ADD CONSTRAINT poly_stats_stratification_geom_fk_ FOREIGN KEY (poly_id) REFERENCES public.stratification_geom(id) ON UPDATE CASCADE ON DELETE CASCADE;
 R   ALTER TABLE public.poly_stats DROP CONSTRAINT poly_stats_stratification_geom_fk_;
       public       	   statsuser    false    301    5059    228            �           2606    18867 4   product_file_description product_file_description_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.product_file_description
    ADD CONSTRAINT product_file_description_fk FOREIGN KEY (product_id) REFERENCES public.product(id) ON UPDATE CASCADE ON DELETE CASCADE;
 ^   ALTER TABLE ONLY public.product_file_description DROP CONSTRAINT product_file_description_fk;
       public       	   statsuser    false    292    290    5039            �           2606    55131 5   product_file product_file_product_file_description_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.product_file
    ADD CONSTRAINT product_file_product_file_description_fk FOREIGN KEY (product_file_description_id) REFERENCES public.product_file_description(id) ON UPDATE CASCADE ON DELETE CASCADE;
 _   ALTER TABLE ONLY public.product_file DROP CONSTRAINT product_file_product_file_description_fk;
       public       	   statsuser    false    5046    292    291            �           2606    18872    product product_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_fk FOREIGN KEY (category_id) REFERENCES public.category(id) ON UPDATE CASCADE ON DELETE CASCADE;
 <   ALTER TABLE ONLY public.product DROP CONSTRAINT product_fk;
       public       	   statsuser    false    4787    290    223            �           2606    18877 *   stratification_geom stratification_geom_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.stratification_geom
    ADD CONSTRAINT stratification_geom_fk FOREIGN KEY (stratification_id) REFERENCES public.stratification(id) ON DELETE CASCADE;
 T   ALTER TABLE ONLY public.stratification_geom DROP CONSTRAINT stratification_geom_fk;
       public       	   statsuser    false    300    5053    301            �           2606    18882    wms_file wms_file_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.wms_file
    ADD CONSTRAINT wms_file_fk FOREIGN KEY (product_file_id) REFERENCES public.product_file(id) ON UPDATE CASCADE ON DELETE CASCADE;
 >   ALTER TABLE ONLY public.wms_file DROP CONSTRAINT wms_file_fk;
       public       	   statsuser    false    305    291    5044            �           2606    18887    wms_file wms_file_fk2    FK CONSTRAINT     �   ALTER TABLE ONLY public.wms_file
    ADD CONSTRAINT wms_file_fk2 FOREIGN KEY (product_file_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 ?   ALTER TABLE ONLY public.wms_file DROP CONSTRAINT wms_file_fk2;
       public       	   statsuser    false    296    5048    305            �           2606    18892 0   poly_stats_per_region poly_stats_product_file_fk    FK CONSTRAINT     �   ALTER TABLE ONLY tmp.poly_stats_per_region
    ADD CONSTRAINT poly_stats_product_file_fk FOREIGN KEY (product_file_id) REFERENCES public.product_file(id) ON UPDATE CASCADE ON DELETE CASCADE;
 W   ALTER TABLE ONLY tmp.poly_stats_per_region DROP CONSTRAINT poly_stats_product_file_fk;
       tmp       	   statsuser    false    291    5044    307            �           2606    18897 9   poly_stats_per_region poly_stats_product_file_variable_fk    FK CONSTRAINT     �   ALTER TABLE ONLY tmp.poly_stats_per_region
    ADD CONSTRAINT poly_stats_product_file_variable_fk FOREIGN KEY (product_file_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 `   ALTER TABLE ONLY tmp.poly_stats_per_region DROP CONSTRAINT poly_stats_product_file_variable_fk;
       tmp       	   statsuser    false    5048    307    296            �           2606    18902 7   poly_stats_per_region poly_stats_stratification_geom_fk    FK CONSTRAINT     �   ALTER TABLE ONLY tmp.poly_stats_per_region
    ADD CONSTRAINT poly_stats_stratification_geom_fk FOREIGN KEY (poly_id) REFERENCES public.stratification_geom(id) ON UPDATE CASCADE ON DELETE CASCADE;
 ^   ALTER TABLE ONLY tmp.poly_stats_per_region DROP CONSTRAINT poly_stats_stratification_geom_fk;
       tmp       	   statsuser    false    307    5059    301            �   9           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            :           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            ;           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            <           1262    16388    jrcstats    DATABASE     p   CREATE DATABASE jrcstats WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'C.UTF-8';
    DROP DATABASE jrcstats;
             	   statsuser    false            =           0    0    SCHEMA pg_catalog    ACL     -   GRANT ALL ON SCHEMA pg_catalog TO statsuser;
                   postgres    false    5            >           0    0    SCHEMA public    ACL     )   GRANT ALL ON SCHEMA public TO statsuser;
                   pg_database_owner    false    8                        2615    16390    tmp    SCHEMA        CREATE SCHEMA tmp;
    DROP SCHEMA tmp;
                postgres    false            ?           0    0 
   SCHEMA tmp    ACL     &   GRANT ALL ON SCHEMA tmp TO statsuser;
                   postgres    false    4                        3079    16391    fuzzystrmatch 	   EXTENSION     A   CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;
    DROP EXTENSION fuzzystrmatch;
                   false            @           0    0    EXTENSION fuzzystrmatch    COMMENT     ]   COMMENT ON EXTENSION fuzzystrmatch IS 'determine similarities and distance between strings';
                        false    2                        3079    16403    postgis 	   EXTENSION     ;   CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;
    DROP EXTENSION postgis;
                   false            A           0    0    EXTENSION postgis    COMMENT     ^   COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';
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
       public          postgres    false            B           0    0    TABLE pg_aggregate    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_aggregate TO statsuser;
       
   pg_catalog          postgres    false    24            C           0    0    TABLE pg_am    ACL     2   GRANT ALL ON TABLE pg_catalog.pg_am TO statsuser;
       
   pg_catalog          postgres    false    25            D           0    0    TABLE pg_amop    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_amop TO statsuser;
       
   pg_catalog          postgres    false    26            E           0    0    TABLE pg_amproc    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_amproc TO statsuser;
       
   pg_catalog          postgres    false    27            F           0    0    TABLE pg_attrdef    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_attrdef TO statsuser;
       
   pg_catalog          postgres    false    28            G           0    0    TABLE pg_attribute    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_attribute TO statsuser;
       
   pg_catalog          postgres    false    13            H           0    0    TABLE pg_auth_members    ACL     <   GRANT ALL ON TABLE pg_catalog.pg_auth_members TO statsuser;
       
   pg_catalog          postgres    false    17            I           0    0    TABLE pg_authid    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_authid TO statsuser;
       
   pg_catalog          postgres    false    16            J           0    0 %   TABLE pg_available_extension_versions    ACL     L   GRANT ALL ON TABLE pg_catalog.pg_available_extension_versions TO statsuser;
       
   pg_catalog          postgres    false    91            K           0    0    TABLE pg_available_extensions    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_available_extensions TO statsuser;
       
   pg_catalog          postgres    false    90            L           0    0     TABLE pg_backend_memory_contexts    ACL     G   GRANT ALL ON TABLE pg_catalog.pg_backend_memory_contexts TO statsuser;
       
   pg_catalog          postgres    false    103            M           0    0    TABLE pg_cast    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_cast TO statsuser;
       
   pg_catalog          postgres    false    29            N           0    0    TABLE pg_class    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_class TO statsuser;
       
   pg_catalog          postgres    false    15            O           0    0    TABLE pg_collation    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_collation TO statsuser;
       
   pg_catalog          postgres    false    54            P           0    0    TABLE pg_config    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_config TO statsuser;
       
   pg_catalog          postgres    false    101            Q           0    0    TABLE pg_constraint    ACL     :   GRANT ALL ON TABLE pg_catalog.pg_constraint TO statsuser;
       
   pg_catalog          postgres    false    30            R           0    0    TABLE pg_conversion    ACL     :   GRANT ALL ON TABLE pg_catalog.pg_conversion TO statsuser;
       
   pg_catalog          postgres    false    31            S           0    0    TABLE pg_cursors    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_cursors TO statsuser;
       
   pg_catalog          postgres    false    89            T           0    0    TABLE pg_database    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_database TO statsuser;
       
   pg_catalog          postgres    false    18            U           0    0    TABLE pg_db_role_setting    ACL     ?   GRANT ALL ON TABLE pg_catalog.pg_db_role_setting TO statsuser;
       
   pg_catalog          postgres    false    45            V           0    0    TABLE pg_default_acl    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_default_acl TO statsuser;
       
   pg_catalog          postgres    false    9            W           0    0    TABLE pg_depend    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_depend TO statsuser;
       
   pg_catalog          postgres    false    32            X           0    0    TABLE pg_description    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_description TO statsuser;
       
   pg_catalog          postgres    false    33            Y           0    0    TABLE pg_enum    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_enum TO statsuser;
       
   pg_catalog          postgres    false    56            Z           0    0    TABLE pg_event_trigger    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_event_trigger TO statsuser;
       
   pg_catalog          postgres    false    55            [           0    0    TABLE pg_extension    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_extension TO statsuser;
       
   pg_catalog          postgres    false    47            \           0    0    TABLE pg_file_settings    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_file_settings TO statsuser;
       
   pg_catalog          postgres    false    96            ]           0    0    TABLE pg_foreign_data_wrapper    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_foreign_data_wrapper TO statsuser;
       
   pg_catalog          postgres    false    22            ^           0    0    TABLE pg_foreign_server    ACL     >   GRANT ALL ON TABLE pg_catalog.pg_foreign_server TO statsuser;
       
   pg_catalog          postgres    false    19            _           0    0    TABLE pg_foreign_table    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_foreign_table TO statsuser;
       
   pg_catalog          postgres    false    48            `           0    0    TABLE pg_group    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_group TO statsuser;
       
   pg_catalog          postgres    false    75            a           0    0    TABLE pg_hba_file_rules    ACL     >   GRANT ALL ON TABLE pg_catalog.pg_hba_file_rules TO statsuser;
       
   pg_catalog          postgres    false    97            b           0    0    TABLE pg_ident_file_mappings    ACL     C   GRANT ALL ON TABLE pg_catalog.pg_ident_file_mappings TO statsuser;
       
   pg_catalog          postgres    false    98            c           0    0    TABLE pg_index    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_index TO statsuser;
       
   pg_catalog          postgres    false    34            d           0    0    TABLE pg_indexes    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_indexes TO statsuser;
       
   pg_catalog          postgres    false    82            e           0    0    TABLE pg_inherits    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_inherits TO statsuser;
       
   pg_catalog          postgres    false    35            f           0    0    TABLE pg_init_privs    ACL     :   GRANT ALL ON TABLE pg_catalog.pg_init_privs TO statsuser;
       
   pg_catalog          postgres    false    52            g           0    0    TABLE pg_language    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_language TO statsuser;
       
   pg_catalog          postgres    false    36            h           0    0    TABLE pg_largeobject    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_largeobject TO statsuser;
       
   pg_catalog          postgres    false    37            i           0    0    TABLE pg_largeobject_metadata    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_largeobject_metadata TO statsuser;
       
   pg_catalog          postgres    false    46            j           0    0    TABLE pg_locks    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_locks TO statsuser;
       
   pg_catalog          postgres    false    88            k           0    0    TABLE pg_matviews    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_matviews TO statsuser;
       
   pg_catalog          postgres    false    81            l           0    0    TABLE pg_namespace    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_namespace TO statsuser;
       
   pg_catalog          postgres    false    38            m           0    0    TABLE pg_opclass    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_opclass TO statsuser;
       
   pg_catalog          postgres    false    39            n           0    0    TABLE pg_operator    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_operator TO statsuser;
       
   pg_catalog          postgres    false    40            o           0    0    TABLE pg_opfamily    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_opfamily TO statsuser;
       
   pg_catalog          postgres    false    44            p           0    0    TABLE pg_parameter_acl    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_parameter_acl TO statsuser;
       
   pg_catalog          postgres    false    72            q           0    0    TABLE pg_partitioned_table    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_partitioned_table TO statsuser;
       
   pg_catalog          postgres    false    50            r           0    0    TABLE pg_policies    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_policies TO statsuser;
       
   pg_catalog          postgres    false    77            s           0    0    TABLE pg_policy    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_policy TO statsuser;
       
   pg_catalog          postgres    false    49            t           0    0    TABLE pg_prepared_statements    ACL     C   GRANT ALL ON TABLE pg_catalog.pg_prepared_statements TO statsuser;
       
   pg_catalog          postgres    false    93            u           0    0    TABLE pg_prepared_xacts    ACL     >   GRANT ALL ON TABLE pg_catalog.pg_prepared_xacts TO statsuser;
       
   pg_catalog          postgres    false    92            v           0    0    TABLE pg_proc    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_proc TO statsuser;
       
   pg_catalog          postgres    false    14            w           0    0    TABLE pg_publication    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_publication TO statsuser;
       
   pg_catalog          postgres    false    69            x           0    0    TABLE pg_publication_namespace    ACL     E   GRANT ALL ON TABLE pg_catalog.pg_publication_namespace TO statsuser;
       
   pg_catalog          postgres    false    71            y           0    0    TABLE pg_publication_rel    ACL     ?   GRANT ALL ON TABLE pg_catalog.pg_publication_rel TO statsuser;
       
   pg_catalog          postgres    false    70            z           0    0    TABLE pg_publication_tables    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_publication_tables TO statsuser;
       
   pg_catalog          postgres    false    87            {           0    0    TABLE pg_range    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_range TO statsuser;
       
   pg_catalog          postgres    false    57            |           0    0    TABLE pg_replication_origin    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_replication_origin TO statsuser;
       
   pg_catalog          postgres    false    66            }           0    0 "   TABLE pg_replication_origin_status    ACL     I   GRANT ALL ON TABLE pg_catalog.pg_replication_origin_status TO statsuser;
       
   pg_catalog          postgres    false    147            ~           0    0    TABLE pg_replication_slots    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_replication_slots TO statsuser;
       
   pg_catalog          postgres    false    130                       0    0    TABLE pg_rewrite    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_rewrite TO statsuser;
       
   pg_catalog          postgres    false    41            �           0    0    TABLE pg_roles    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_roles TO statsuser;
       
   pg_catalog          postgres    false    73            �           0    0    TABLE pg_rules    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_rules TO statsuser;
       
   pg_catalog          postgres    false    78            �           0    0    TABLE pg_seclabel    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_seclabel TO statsuser;
       
   pg_catalog          postgres    false    60            �           0    0    TABLE pg_seclabels    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_seclabels TO statsuser;
       
   pg_catalog          postgres    false    94            �           0    0    TABLE pg_sequence    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_sequence TO statsuser;
       
   pg_catalog          postgres    false    21            �           0    0    TABLE pg_sequences    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_sequences TO statsuser;
       
   pg_catalog          postgres    false    83            �           0    0    TABLE pg_settings    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_settings TO statsuser;
       
   pg_catalog          postgres    false    95            �           0    0    TABLE pg_shadow    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_shadow TO statsuser;
       
   pg_catalog          postgres    false    74            �           0    0    TABLE pg_shdepend    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_shdepend TO statsuser;
       
   pg_catalog          postgres    false    11            �           0    0    TABLE pg_shdescription    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_shdescription TO statsuser;
       
   pg_catalog          postgres    false    23            �           0    0    TABLE pg_shmem_allocations    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_shmem_allocations TO statsuser;
       
   pg_catalog          postgres    false    102            �           0    0    TABLE pg_shseclabel    ACL     :   GRANT ALL ON TABLE pg_catalog.pg_shseclabel TO statsuser;
       
   pg_catalog          postgres    false    59            �           0    0    TABLE pg_stat_activity    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_stat_activity TO statsuser;
       
   pg_catalog          postgres    false    122            �           0    0    TABLE pg_stat_all_indexes    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_stat_all_indexes TO statsuser;
       
   pg_catalog          postgres    false    113            �           0    0    TABLE pg_stat_all_tables    ACL     ?   GRANT ALL ON TABLE pg_catalog.pg_stat_all_tables TO statsuser;
       
   pg_catalog          postgres    false    104            �           0    0    TABLE pg_stat_archiver    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_stat_archiver TO statsuser;
       
   pg_catalog          postgres    false    136            �           0    0    TABLE pg_stat_bgwriter    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_stat_bgwriter TO statsuser;
       
   pg_catalog          postgres    false    137            �           0    0    TABLE pg_stat_database    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_stat_database TO statsuser;
       
   pg_catalog          postgres    false    132            �           0    0     TABLE pg_stat_database_conflicts    ACL     G   GRANT ALL ON TABLE pg_catalog.pg_stat_database_conflicts TO statsuser;
       
   pg_catalog          postgres    false    133            �           0    0    TABLE pg_stat_gssapi    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_stat_gssapi TO statsuser;
       
   pg_catalog          postgres    false    129            �           0    0    TABLE pg_stat_io    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_stat_io TO statsuser;
       
   pg_catalog          postgres    false    138            �           0    0    TABLE pg_stat_progress_analyze    ACL     E   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_analyze TO statsuser;
       
   pg_catalog          postgres    false    140            �           0    0 !   TABLE pg_stat_progress_basebackup    ACL     H   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_basebackup TO statsuser;
       
   pg_catalog          postgres    false    144            �           0    0    TABLE pg_stat_progress_cluster    ACL     E   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_cluster TO statsuser;
       
   pg_catalog          postgres    false    142            �           0    0    TABLE pg_stat_progress_copy    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_copy TO statsuser;
       
   pg_catalog          postgres    false    145            �           0    0 #   TABLE pg_stat_progress_create_index    ACL     J   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_create_index TO statsuser;
       
   pg_catalog          postgres    false    143            �           0    0    TABLE pg_stat_progress_vacuum    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_vacuum TO statsuser;
       
   pg_catalog          postgres    false    141            �           0    0    TABLE pg_stat_recovery_prefetch    ACL     F   GRANT ALL ON TABLE pg_catalog.pg_stat_recovery_prefetch TO statsuser;
       
   pg_catalog          postgres    false    126            �           0    0    TABLE pg_stat_replication    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_stat_replication TO statsuser;
       
   pg_catalog          postgres    false    123            �           0    0    TABLE pg_stat_replication_slots    ACL     F   GRANT ALL ON TABLE pg_catalog.pg_stat_replication_slots TO statsuser;
       
   pg_catalog          postgres    false    131            �           0    0    TABLE pg_stat_slru    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_stat_slru TO statsuser;
       
   pg_catalog          postgres    false    124            �           0    0    TABLE pg_stat_ssl    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_stat_ssl TO statsuser;
       
   pg_catalog          postgres    false    128            �           0    0    TABLE pg_stat_subscription    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_stat_subscription TO statsuser;
       
   pg_catalog          postgres    false    127            �           0    0     TABLE pg_stat_subscription_stats    ACL     G   GRANT ALL ON TABLE pg_catalog.pg_stat_subscription_stats TO statsuser;
       
   pg_catalog          postgres    false    148            �           0    0    TABLE pg_stat_sys_indexes    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_stat_sys_indexes TO statsuser;
       
   pg_catalog          postgres    false    114            �           0    0    TABLE pg_stat_sys_tables    ACL     ?   GRANT ALL ON TABLE pg_catalog.pg_stat_sys_tables TO statsuser;
       
   pg_catalog          postgres    false    106            �           0    0    TABLE pg_stat_user_functions    ACL     C   GRANT ALL ON TABLE pg_catalog.pg_stat_user_functions TO statsuser;
       
   pg_catalog          postgres    false    134            �           0    0    TABLE pg_stat_user_indexes    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_stat_user_indexes TO statsuser;
       
   pg_catalog          postgres    false    115            �           0    0    TABLE pg_stat_user_tables    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_stat_user_tables TO statsuser;
       
   pg_catalog          postgres    false    108            �           0    0    TABLE pg_stat_wal    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_stat_wal TO statsuser;
       
   pg_catalog          postgres    false    139            �           0    0    TABLE pg_stat_wal_receiver    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_stat_wal_receiver TO statsuser;
       
   pg_catalog          postgres    false    125            �           0    0    TABLE pg_stat_xact_all_tables    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_stat_xact_all_tables TO statsuser;
       
   pg_catalog          postgres    false    105            �           0    0    TABLE pg_stat_xact_sys_tables    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_stat_xact_sys_tables TO statsuser;
       
   pg_catalog          postgres    false    107            �           0    0 !   TABLE pg_stat_xact_user_functions    ACL     H   GRANT ALL ON TABLE pg_catalog.pg_stat_xact_user_functions TO statsuser;
       
   pg_catalog          postgres    false    135            �           0    0    TABLE pg_stat_xact_user_tables    ACL     E   GRANT ALL ON TABLE pg_catalog.pg_stat_xact_user_tables TO statsuser;
       
   pg_catalog          postgres    false    109            �           0    0    TABLE pg_statio_all_indexes    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_statio_all_indexes TO statsuser;
       
   pg_catalog          postgres    false    116            �           0    0    TABLE pg_statio_all_sequences    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_statio_all_sequences TO statsuser;
       
   pg_catalog          postgres    false    119            �           0    0    TABLE pg_statio_all_tables    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_statio_all_tables TO statsuser;
       
   pg_catalog          postgres    false    110            �           0    0    TABLE pg_statio_sys_indexes    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_statio_sys_indexes TO statsuser;
       
   pg_catalog          postgres    false    117            �           0    0    TABLE pg_statio_sys_sequences    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_statio_sys_sequences TO statsuser;
       
   pg_catalog          postgres    false    120            �           0    0    TABLE pg_statio_sys_tables    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_statio_sys_tables TO statsuser;
       
   pg_catalog          postgres    false    111            �           0    0    TABLE pg_statio_user_indexes    ACL     C   GRANT ALL ON TABLE pg_catalog.pg_statio_user_indexes TO statsuser;
       
   pg_catalog          postgres    false    118            �           0    0    TABLE pg_statio_user_sequences    ACL     E   GRANT ALL ON TABLE pg_catalog.pg_statio_user_sequences TO statsuser;
       
   pg_catalog          postgres    false    121            �           0    0    TABLE pg_statio_user_tables    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_statio_user_tables TO statsuser;
       
   pg_catalog          postgres    false    112            �           0    0    TABLE pg_statistic    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_statistic TO statsuser;
       
   pg_catalog          postgres    false    42            �           0    0    TABLE pg_statistic_ext    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_statistic_ext TO statsuser;
       
   pg_catalog          postgres    false    51            �           0    0    TABLE pg_statistic_ext_data    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_statistic_ext_data TO statsuser;
       
   pg_catalog          postgres    false    53            �           0    0    TABLE pg_stats    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_stats TO statsuser;
       
   pg_catalog          postgres    false    84            �           0    0    TABLE pg_stats_ext    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_stats_ext TO statsuser;
       
   pg_catalog          postgres    false    85            �           0    0    TABLE pg_stats_ext_exprs    ACL     ?   GRANT ALL ON TABLE pg_catalog.pg_stats_ext_exprs TO statsuser;
       
   pg_catalog          postgres    false    86            �           0    0    TABLE pg_subscription    ACL     <   GRANT ALL ON TABLE pg_catalog.pg_subscription TO statsuser;
       
   pg_catalog          postgres    false    67            �           0    0    TABLE pg_subscription_rel    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_subscription_rel TO statsuser;
       
   pg_catalog          postgres    false    68            �           0    0    TABLE pg_tables    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_tables TO statsuser;
       
   pg_catalog          postgres    false    80            �           0    0    TABLE pg_tablespace    ACL     :   GRANT ALL ON TABLE pg_catalog.pg_tablespace TO statsuser;
       
   pg_catalog          postgres    false    10            �           0    0    TABLE pg_timezone_abbrevs    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_timezone_abbrevs TO statsuser;
       
   pg_catalog          postgres    false    99            �           0    0    TABLE pg_timezone_names    ACL     >   GRANT ALL ON TABLE pg_catalog.pg_timezone_names TO statsuser;
       
   pg_catalog          postgres    false    100            �           0    0    TABLE pg_transform    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_transform TO statsuser;
       
   pg_catalog          postgres    false    58            �           0    0    TABLE pg_trigger    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_trigger TO statsuser;
       
   pg_catalog          postgres    false    43            �           0    0    TABLE pg_ts_config    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_ts_config TO statsuser;
       
   pg_catalog          postgres    false    63            �           0    0    TABLE pg_ts_config_map    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_ts_config_map TO statsuser;
       
   pg_catalog          postgres    false    64            �           0    0    TABLE pg_ts_dict    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_ts_dict TO statsuser;
       
   pg_catalog          postgres    false    61            �           0    0    TABLE pg_ts_parser    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_ts_parser TO statsuser;
       
   pg_catalog          postgres    false    62            �           0    0    TABLE pg_ts_template    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_ts_template TO statsuser;
       
   pg_catalog          postgres    false    65            �           0    0    TABLE pg_type    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_type TO statsuser;
       
   pg_catalog          postgres    false    12            �           0    0    TABLE pg_user    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_user TO statsuser;
       
   pg_catalog          postgres    false    76            �           0    0    TABLE pg_user_mapping    ACL     <   GRANT ALL ON TABLE pg_catalog.pg_user_mapping TO statsuser;
       
   pg_catalog          postgres    false    20            �           0    0    TABLE pg_user_mappings    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_user_mappings TO statsuser;
       
   pg_catalog          postgres    false    146            �           0    0    TABLE pg_views    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_views TO statsuser;
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
            public       	   statsuser    false    223            �           0    0    TABLE geography_columns    ACL     :   GRANT ALL ON TABLE public.geography_columns TO statsuser;
          public          postgres    false    221            �           0    0    TABLE geometry_columns    ACL     9   GRANT ALL ON TABLE public.geometry_columns TO statsuser;
          public          postgres    false    222            8           1259    25410    global_land_cover_2019    TABLE     �   CREATE TABLE public.global_land_cover_2019 (
    id integer NOT NULL,
    geom public.geometry(Polygon,4326),
    fid bigint,
    "DN" integer
);
 *   DROP TABLE public.global_land_cover_2019;
       public         heap 	   statsuser    false    3    3    3    3    3    3    3    3            7           1259    25409    global_land_cover_2019_id_seq    SEQUENCE     �   CREATE SEQUENCE public.global_land_cover_2019_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 4   DROP SEQUENCE public.global_land_cover_2019_id_seq;
       public       	   statsuser    false    312            �           0    0    global_land_cover_2019_id_seq    SEQUENCE OWNED BY     _   ALTER SEQUENCE public.global_land_cover_2019_id_seq OWNED BY public.global_land_cover_2019.id;
          public       	   statsuser    false    311            �            1259    17487    long_term_anomaly_info    TABLE     �   CREATE TABLE public.long_term_anomaly_info (
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
       public       	   statsuser    false    225            �           0    0    long_term_anomaly_info_id_seq    SEQUENCE OWNED BY     _   ALTER SEQUENCE public.long_term_anomaly_info_id_seq OWNED BY public.long_term_anomaly_info.id;
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
       public         heap 	   statsuser    false    228            5           1259    23018    poly_stats_25_1_2    TABLE     �  CREATE TABLE public.poly_stats_25_1_2 (
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
 %   DROP TABLE public.poly_stats_25_1_2;
       public         heap 	   statsuser    false    228            6           1259    23111    poly_stats_25_2_257    TABLE     �  CREATE TABLE public.poly_stats_25_2_257 (
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
 '   DROP TABLE public.poly_stats_25_2_257;
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
       public       	   statsuser    false    292            �           0    0    product_file_description_id_seq    SEQUENCE OWNED BY     c   ALTER SEQUENCE public.product_file_description_id_seq OWNED BY public.product_file_description.id;
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
       public       	   statsuser    false    291            �           0    0    product_file_id_seq1    SEQUENCE OWNED BY     L   ALTER SEQUENCE public.product_file_id_seq1 OWNED BY public.product_file.id;
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
       public       	   statsuser    false    296            �           0    0    product_file_variable_id_seq    SEQUENCE OWNED BY     ]   ALTER SEQUENCE public.product_file_variable_id_seq OWNED BY public.product_file_variable.id;
          public       	   statsuser    false    297            *           1259    18013    product_id_seq    SEQUENCE     w   CREATE SEQUENCE public.product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public.product_id_seq;
       public       	   statsuser    false    290            �           0    0    product_id_seq    SEQUENCE OWNED BY     A   ALTER SEQUENCE public.product_id_seq OWNED BY public.product.id;
          public       	   statsuser    false    298            +           1259    18014    product_order    TABLE     /  CREATE TABLE public.product_order (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    email text,
    aoi public.geometry(MultiPolygon,3857),
    request_data jsonb,
    date_created timestamp without time zone DEFAULT (now() AT TIME ZONE 'UTC'::text),
    processed boolean DEFAULT false NOT NULL
);
 !   DROP TABLE public.product_order;
       public         heap 	   statsuser    false    3    3    3    3    3    3    3    3            �           0    0    TABLE spatial_ref_sys    ACL     8   GRANT ALL ON TABLE public.spatial_ref_sys TO statsuser;
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
       public       	   statsuser    false    301            �           0    0    stratification_geom_id_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE public.stratification_geom_id_seq OWNED BY public.stratification_geom.id;
          public       	   statsuser    false    302            /           1259    18033    stratification_id_seq    SEQUENCE     ~   CREATE SEQUENCE public.stratification_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE public.stratification_id_seq;
       public       	   statsuser    false    300            �           0    0    stratification_id_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE public.stratification_id_seq OWNED BY public.stratification.id;
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
       public       	   statsuser    false    305            �           0    0    wms_file_id_seq    SEQUENCE OWNED BY     C   ALTER SEQUENCE public.wms_file_id_seq OWNED BY public.wms_file.id;
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
       tmp       	   statsuser    false    4    307            �           0    0    poly_stats_per_region_id_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE tmp.poly_stats_per_region_id_seq OWNED BY tmp.poly_stats_per_region.id;
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
          public       	   statsuser    false    261    228            �           0    0    poly_stats_25_1_2    TABLE ATTACH     y   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_25_1_2 FOR VALUES FROM ('25', '1') TO ('25', '2');
          public       	   statsuser    false    309    228            �           0    0    poly_stats_25_2_257    TABLE ATTACH     }   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_25_2_257 FOR VALUES FROM ('25', '2') TO ('25', '257');
          public       	   statsuser    false    310    228            �           0    0    poly_stats_2_1_257    TABLE ATTACH     z   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_2_1_257 FOR VALUES FROM ('2', '1') TO ('2', '257');
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
          public       	   statsuser    false    289    228            �           2604    25413    global_land_cover_2019 id    DEFAULT     �   ALTER TABLE ONLY public.global_land_cover_2019 ALTER COLUMN id SET DEFAULT nextval('public.global_land_cover_2019_id_seq'::regclass);
 H   ALTER TABLE public.global_land_cover_2019 ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    311    312    312            �           2604    18054    long_term_anomaly_info id    DEFAULT     �   ALTER TABLE ONLY public.long_term_anomaly_info ALTER COLUMN id SET DEFAULT nextval('public.long_term_anomaly_info_id_seq'::regclass);
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
       tmp       	   statsuser    false    308    307            �           2606    25415 2   global_land_cover_2019 global_land_cover_2019_pkey 
   CONSTRAINT     p   ALTER TABLE ONLY public.global_land_cover_2019
    ADD CONSTRAINT global_land_cover_2019_pkey PRIMARY KEY (id);
 \   ALTER TABLE ONLY public.global_land_cover_2019 DROP CONSTRAINT global_land_cover_2019_pkey;
       public         	   statsuser    false    312            �           2606    18064 0   long_term_anomaly_info long_term_anomaly_info_pk 
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
       public         	   statsuser    false    229    4791    229    229    229            �           2606    18072 0   poly_stats_10_257_279 poly_stats_10_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_10_257_279
    ADD CONSTRAINT poly_stats_10_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_10_257_279 DROP CONSTRAINT poly_stats_10_257_279_pkey;
       public         	   statsuser    false    4791    230    230    230    230            �           2606    18074 0   poly_stats_10_279_285 poly_stats_10_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_10_279_285
    ADD CONSTRAINT poly_stats_10_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_10_279_285 DROP CONSTRAINT poly_stats_10_279_285_pkey;
       public         	   statsuser    false    231    4791    231    231    231            �           2606    18076 4   poly_stats_10_285_38543 poly_stats_10_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_10_285_38543
    ADD CONSTRAINT poly_stats_10_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 ^   ALTER TABLE ONLY public.poly_stats_10_285_38543 DROP CONSTRAINT poly_stats_10_285_38543_pkey;
       public         	   statsuser    false    232    232    232    4791    232            �           2606    18078 ,   poly_stats_12_1_257 poly_stats_12_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_12_1_257
    ADD CONSTRAINT poly_stats_12_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 V   ALTER TABLE ONLY public.poly_stats_12_1_257 DROP CONSTRAINT poly_stats_12_1_257_pkey;
       public         	   statsuser    false    233    233    4791    233    233            �           2606    18080 0   poly_stats_12_257_279 poly_stats_12_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_12_257_279
    ADD CONSTRAINT poly_stats_12_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_12_257_279 DROP CONSTRAINT poly_stats_12_257_279_pkey;
       public         	   statsuser    false    234    234    234    4791    234            �           2606    18082 0   poly_stats_12_279_285 poly_stats_12_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_12_279_285
    ADD CONSTRAINT poly_stats_12_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_12_279_285 DROP CONSTRAINT poly_stats_12_279_285_pkey;
       public         	   statsuser    false    235    235    4791    235    235            �           2606    18084 4   poly_stats_12_285_38543 poly_stats_12_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_12_285_38543
    ADD CONSTRAINT poly_stats_12_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 ^   ALTER TABLE ONLY public.poly_stats_12_285_38543 DROP CONSTRAINT poly_stats_12_285_38543_pkey;
       public         	   statsuser    false    4791    236    236    236    236            �           2606    18086 ,   poly_stats_14_1_257 poly_stats_14_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_14_1_257
    ADD CONSTRAINT poly_stats_14_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 V   ALTER TABLE ONLY public.poly_stats_14_1_257 DROP CONSTRAINT poly_stats_14_1_257_pkey;
       public         	   statsuser    false    237    4791    237    237    237            �           2606    18088 0   poly_stats_14_257_279 poly_stats_14_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_14_257_279
    ADD CONSTRAINT poly_stats_14_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_14_257_279 DROP CONSTRAINT poly_stats_14_257_279_pkey;
       public         	   statsuser    false    238    4791    238    238    238            �           2606    18090 0   poly_stats_14_279_285 poly_stats_14_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_14_279_285
    ADD CONSTRAINT poly_stats_14_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_14_279_285 DROP CONSTRAINT poly_stats_14_279_285_pkey;
       public         	   statsuser    false    239    4791    239    239    239            �           2606    18092 4   poly_stats_14_285_38543 poly_stats_14_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_14_285_38543
    ADD CONSTRAINT poly_stats_14_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 ^   ALTER TABLE ONLY public.poly_stats_14_285_38543 DROP CONSTRAINT poly_stats_14_285_38543_pkey;
       public         	   statsuser    false    240    240    240    4791    240            �           2606    18094 ,   poly_stats_16_1_257 poly_stats_16_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_16_1_257
    ADD CONSTRAINT poly_stats_16_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 V   ALTER TABLE ONLY public.poly_stats_16_1_257 DROP CONSTRAINT poly_stats_16_1_257_pkey;
       public         	   statsuser    false    241    241    241    4791    241            �           2606    18096 0   poly_stats_16_257_279 poly_stats_16_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_16_257_279
    ADD CONSTRAINT poly_stats_16_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_16_257_279 DROP CONSTRAINT poly_stats_16_257_279_pkey;
       public         	   statsuser    false    242    242    242    242    4791            �           2606    18098 0   poly_stats_16_279_285 poly_stats_16_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_16_279_285
    ADD CONSTRAINT poly_stats_16_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_16_279_285 DROP CONSTRAINT poly_stats_16_279_285_pkey;
       public         	   statsuser    false    243    243    243    4791    243            �           2606    18100 4   poly_stats_16_285_38543 poly_stats_16_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_16_285_38543
    ADD CONSTRAINT poly_stats_16_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 ^   ALTER TABLE ONLY public.poly_stats_16_285_38543 DROP CONSTRAINT poly_stats_16_285_38543_pkey;
       public         	   statsuser    false    244    244    244    4791    244            �           2606    18102 ,   poly_stats_17_1_257 poly_stats_17_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_17_1_257
    ADD CONSTRAINT poly_stats_17_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 V   ALTER TABLE ONLY public.poly_stats_17_1_257 DROP CONSTRAINT poly_stats_17_1_257_pkey;
       public         	   statsuser    false    245    245    245    245    4791            �           2606    18104 0   poly_stats_17_257_279 poly_stats_17_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_17_257_279
    ADD CONSTRAINT poly_stats_17_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_17_257_279 DROP CONSTRAINT poly_stats_17_257_279_pkey;
       public         	   statsuser    false    246    4791    246    246    246                       2606    18106 0   poly_stats_17_279_285 poly_stats_17_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_17_279_285
    ADD CONSTRAINT poly_stats_17_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_17_279_285 DROP CONSTRAINT poly_stats_17_279_285_pkey;
       public         	   statsuser    false    247    247    247    4791    247                       2606    18108 4   poly_stats_17_285_38543 poly_stats_17_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_17_285_38543
    ADD CONSTRAINT poly_stats_17_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 ^   ALTER TABLE ONLY public.poly_stats_17_285_38543 DROP CONSTRAINT poly_stats_17_285_38543_pkey;
       public         	   statsuser    false    248    248    248    4791    248                       2606    18110 ,   poly_stats_19_1_257 poly_stats_19_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_19_1_257
    ADD CONSTRAINT poly_stats_19_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 V   ALTER TABLE ONLY public.poly_stats_19_1_257 DROP CONSTRAINT poly_stats_19_1_257_pkey;
       public         	   statsuser    false    249    249    249    4791    249                       2606    18112 0   poly_stats_19_257_279 poly_stats_19_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_19_257_279
    ADD CONSTRAINT poly_stats_19_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_19_257_279 DROP CONSTRAINT poly_stats_19_257_279_pkey;
       public         	   statsuser    false    250    250    250    4791    250                       2606    18114 0   poly_stats_19_279_285 poly_stats_19_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_19_279_285
    ADD CONSTRAINT poly_stats_19_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_19_279_285 DROP CONSTRAINT poly_stats_19_279_285_pkey;
       public         	   statsuser    false    251    251    251    251    4791                       2606    18116 4   poly_stats_19_285_38543 poly_stats_19_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_19_285_38543
    ADD CONSTRAINT poly_stats_19_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 ^   ALTER TABLE ONLY public.poly_stats_19_285_38543 DROP CONSTRAINT poly_stats_19_285_38543_pkey;
       public         	   statsuser    false    252    4791    252    252    252                       2606    18118 *   poly_stats_1_1_257 poly_stats_1_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_1_1_257
    ADD CONSTRAINT poly_stats_1_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 T   ALTER TABLE ONLY public.poly_stats_1_1_257 DROP CONSTRAINT poly_stats_1_1_257_pkey;
       public         	   statsuser    false    253    253    253    253    4791                       2606    18120 .   poly_stats_1_257_279 poly_stats_1_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_1_257_279
    ADD CONSTRAINT poly_stats_1_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_1_257_279 DROP CONSTRAINT poly_stats_1_257_279_pkey;
       public         	   statsuser    false    254    254    254    254    4791            #           2606    18122 .   poly_stats_1_279_285 poly_stats_1_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_1_279_285
    ADD CONSTRAINT poly_stats_1_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_1_279_285 DROP CONSTRAINT poly_stats_1_279_285_pkey;
       public         	   statsuser    false    255    255    4791    255    255            '           2606    18124 2   poly_stats_1_285_38543 poly_stats_1_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_1_285_38543
    ADD CONSTRAINT poly_stats_1_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 \   ALTER TABLE ONLY public.poly_stats_1_285_38543 DROP CONSTRAINT poly_stats_1_285_38543_pkey;
       public         	   statsuser    false    256    256    256    256    4791            +           2606    18126 ,   poly_stats_21_1_257 poly_stats_21_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_21_1_257
    ADD CONSTRAINT poly_stats_21_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 V   ALTER TABLE ONLY public.poly_stats_21_1_257 DROP CONSTRAINT poly_stats_21_1_257_pkey;
       public         	   statsuser    false    257    257    257    4791    257            /           2606    18128 0   poly_stats_21_257_279 poly_stats_21_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_21_257_279
    ADD CONSTRAINT poly_stats_21_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_21_257_279 DROP CONSTRAINT poly_stats_21_257_279_pkey;
       public         	   statsuser    false    258    4791    258    258    258            3           2606    18130 0   poly_stats_21_279_285 poly_stats_21_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_21_279_285
    ADD CONSTRAINT poly_stats_21_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_21_279_285 DROP CONSTRAINT poly_stats_21_279_285_pkey;
       public         	   statsuser    false    259    4791    259    259    259            7           2606    18132 4   poly_stats_21_285_38543 poly_stats_21_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_21_285_38543
    ADD CONSTRAINT poly_stats_21_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 ^   ALTER TABLE ONLY public.poly_stats_21_285_38543 DROP CONSTRAINT poly_stats_21_285_38543_pkey;
       public         	   statsuser    false    260    4791    260    260    260            ;           2606    18134 ,   poly_stats_24_1_257 poly_stats_24_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_24_1_257
    ADD CONSTRAINT poly_stats_24_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 V   ALTER TABLE ONLY public.poly_stats_24_1_257 DROP CONSTRAINT poly_stats_24_1_257_pkey;
       public         	   statsuser    false    261    261    261    4791    261            �           2606    23025 (   poly_stats_25_1_2 poly_stats_25_1_2_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_25_1_2
    ADD CONSTRAINT poly_stats_25_1_2_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 R   ALTER TABLE ONLY public.poly_stats_25_1_2 DROP CONSTRAINT poly_stats_25_1_2_pkey;
       public         	   statsuser    false    309    309    309    4791    309            �           2606    23118 ,   poly_stats_25_2_257 poly_stats_25_2_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_25_2_257
    ADD CONSTRAINT poly_stats_25_2_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 V   ALTER TABLE ONLY public.poly_stats_25_2_257 DROP CONSTRAINT poly_stats_25_2_257_pkey;
       public         	   statsuser    false    4791    310    310    310    310            ?           2606    18136 *   poly_stats_2_1_257 poly_stats_2_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_2_1_257
    ADD CONSTRAINT poly_stats_2_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 T   ALTER TABLE ONLY public.poly_stats_2_1_257 DROP CONSTRAINT poly_stats_2_1_257_pkey;
       public         	   statsuser    false    262    4791    262    262    262            C           2606    18138 .   poly_stats_2_257_279 poly_stats_2_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_2_257_279
    ADD CONSTRAINT poly_stats_2_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_2_257_279 DROP CONSTRAINT poly_stats_2_257_279_pkey;
       public         	   statsuser    false    4791    263    263    263    263            G           2606    18140 .   poly_stats_2_279_285 poly_stats_2_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_2_279_285
    ADD CONSTRAINT poly_stats_2_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_2_279_285 DROP CONSTRAINT poly_stats_2_279_285_pkey;
       public         	   statsuser    false    264    264    264    4791    264            K           2606    18142 2   poly_stats_2_285_38543 poly_stats_2_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_2_285_38543
    ADD CONSTRAINT poly_stats_2_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 \   ALTER TABLE ONLY public.poly_stats_2_285_38543 DROP CONSTRAINT poly_stats_2_285_38543_pkey;
       public         	   statsuser    false    4791    265    265    265    265            O           2606    18144 *   poly_stats_3_1_257 poly_stats_3_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_3_1_257
    ADD CONSTRAINT poly_stats_3_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 T   ALTER TABLE ONLY public.poly_stats_3_1_257 DROP CONSTRAINT poly_stats_3_1_257_pkey;
       public         	   statsuser    false    266    4791    266    266    266            S           2606    18146 .   poly_stats_3_257_279 poly_stats_3_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_3_257_279
    ADD CONSTRAINT poly_stats_3_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_3_257_279 DROP CONSTRAINT poly_stats_3_257_279_pkey;
       public         	   statsuser    false    267    267    4791    267    267            W           2606    18148 .   poly_stats_3_279_285 poly_stats_3_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_3_279_285
    ADD CONSTRAINT poly_stats_3_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_3_279_285 DROP CONSTRAINT poly_stats_3_279_285_pkey;
       public         	   statsuser    false    268    4791    268    268    268            [           2606    18150 2   poly_stats_3_285_38543 poly_stats_3_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_3_285_38543
    ADD CONSTRAINT poly_stats_3_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 \   ALTER TABLE ONLY public.poly_stats_3_285_38543 DROP CONSTRAINT poly_stats_3_285_38543_pkey;
       public         	   statsuser    false    269    4791    269    269    269            _           2606    18152 *   poly_stats_4_1_257 poly_stats_4_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_4_1_257
    ADD CONSTRAINT poly_stats_4_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 T   ALTER TABLE ONLY public.poly_stats_4_1_257 DROP CONSTRAINT poly_stats_4_1_257_pkey;
       public         	   statsuser    false    270    270    270    4791    270            c           2606    18154 .   poly_stats_4_257_279 poly_stats_4_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_4_257_279
    ADD CONSTRAINT poly_stats_4_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_4_257_279 DROP CONSTRAINT poly_stats_4_257_279_pkey;
       public         	   statsuser    false    4791    271    271    271    271            g           2606    18156 .   poly_stats_4_279_285 poly_stats_4_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_4_279_285
    ADD CONSTRAINT poly_stats_4_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_4_279_285 DROP CONSTRAINT poly_stats_4_279_285_pkey;
       public         	   statsuser    false    4791    272    272    272    272            k           2606    18158 2   poly_stats_4_285_38543 poly_stats_4_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_4_285_38543
    ADD CONSTRAINT poly_stats_4_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 \   ALTER TABLE ONLY public.poly_stats_4_285_38543 DROP CONSTRAINT poly_stats_4_285_38543_pkey;
       public         	   statsuser    false    273    273    273    4791    273            o           2606    18160 *   poly_stats_5_1_257 poly_stats_5_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_5_1_257
    ADD CONSTRAINT poly_stats_5_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 T   ALTER TABLE ONLY public.poly_stats_5_1_257 DROP CONSTRAINT poly_stats_5_1_257_pkey;
       public         	   statsuser    false    274    4791    274    274    274            s           2606    18162 .   poly_stats_5_257_279 poly_stats_5_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_5_257_279
    ADD CONSTRAINT poly_stats_5_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_5_257_279 DROP CONSTRAINT poly_stats_5_257_279_pkey;
       public         	   statsuser    false    275    275    4791    275    275            w           2606    18164 .   poly_stats_5_279_285 poly_stats_5_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_5_279_285
    ADD CONSTRAINT poly_stats_5_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_5_279_285 DROP CONSTRAINT poly_stats_5_279_285_pkey;
       public         	   statsuser    false    276    276    4791    276    276            {           2606    18166 2   poly_stats_5_285_38543 poly_stats_5_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_5_285_38543
    ADD CONSTRAINT poly_stats_5_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 \   ALTER TABLE ONLY public.poly_stats_5_285_38543 DROP CONSTRAINT poly_stats_5_285_38543_pkey;
       public         	   statsuser    false    277    4791    277    277    277                       2606    18168 *   poly_stats_6_1_257 poly_stats_6_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_6_1_257
    ADD CONSTRAINT poly_stats_6_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 T   ALTER TABLE ONLY public.poly_stats_6_1_257 DROP CONSTRAINT poly_stats_6_1_257_pkey;
       public         	   statsuser    false    4791    278    278    278    278            �           2606    18170 .   poly_stats_6_257_279 poly_stats_6_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_6_257_279
    ADD CONSTRAINT poly_stats_6_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_6_257_279 DROP CONSTRAINT poly_stats_6_257_279_pkey;
       public         	   statsuser    false    279    4791    279    279    279            �           2606    18172 .   poly_stats_6_279_285 poly_stats_6_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_6_279_285
    ADD CONSTRAINT poly_stats_6_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_6_279_285 DROP CONSTRAINT poly_stats_6_279_285_pkey;
       public         	   statsuser    false    280    280    280    4791    280            �           2606    18174 2   poly_stats_6_285_38543 poly_stats_6_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_6_285_38543
    ADD CONSTRAINT poly_stats_6_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 \   ALTER TABLE ONLY public.poly_stats_6_285_38543 DROP CONSTRAINT poly_stats_6_285_38543_pkey;
       public         	   statsuser    false    281    281    281    4791    281            �           2606    18176 *   poly_stats_7_1_257 poly_stats_7_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_7_1_257
    ADD CONSTRAINT poly_stats_7_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 T   ALTER TABLE ONLY public.poly_stats_7_1_257 DROP CONSTRAINT poly_stats_7_1_257_pkey;
       public         	   statsuser    false    282    4791    282    282    282            �           2606    18178 .   poly_stats_7_257_279 poly_stats_7_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_7_257_279
    ADD CONSTRAINT poly_stats_7_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_7_257_279 DROP CONSTRAINT poly_stats_7_257_279_pkey;
       public         	   statsuser    false    283    4791    283    283    283            �           2606    18180 .   poly_stats_7_279_285 poly_stats_7_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_7_279_285
    ADD CONSTRAINT poly_stats_7_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_7_279_285 DROP CONSTRAINT poly_stats_7_279_285_pkey;
       public         	   statsuser    false    284    4791    284    284    284            �           2606    18182 2   poly_stats_7_285_38543 poly_stats_7_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_7_285_38543
    ADD CONSTRAINT poly_stats_7_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 \   ALTER TABLE ONLY public.poly_stats_7_285_38543 DROP CONSTRAINT poly_stats_7_285_38543_pkey;
       public         	   statsuser    false    285    4791    285    285    285            �           2606    18184 *   poly_stats_9_1_257 poly_stats_9_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_9_1_257
    ADD CONSTRAINT poly_stats_9_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 T   ALTER TABLE ONLY public.poly_stats_9_1_257 DROP CONSTRAINT poly_stats_9_1_257_pkey;
       public         	   statsuser    false    286    286    4791    286    286            �           2606    18186 .   poly_stats_9_257_279 poly_stats_9_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_9_257_279
    ADD CONSTRAINT poly_stats_9_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_9_257_279 DROP CONSTRAINT poly_stats_9_257_279_pkey;
       public         	   statsuser    false    287    287    287    4791    287            �           2606    18188 .   poly_stats_9_279_285 poly_stats_9_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_9_279_285
    ADD CONSTRAINT poly_stats_9_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_9_279_285 DROP CONSTRAINT poly_stats_9_279_285_pkey;
       public         	   statsuser    false    288    4791    288    288    288            �           2606    18190 2   poly_stats_9_285_38543 poly_stats_9_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_9_285_38543
    ADD CONSTRAINT poly_stats_9_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 \   ALTER TABLE ONLY public.poly_stats_9_285_38543 DROP CONSTRAINT poly_stats_9_285_38543_pkey;
       public         	   statsuser    false    289    289    4791    289    289            �           2606    18192 6   product_file product_file_date_product_description_idx 
   CONSTRAINT     �   ALTER TABLE ONLY public.product_file
    ADD CONSTRAINT product_file_date_product_description_idx UNIQUE (product_file_description_id, date, rt_flag);
 `   ALTER TABLE ONLY public.product_file DROP CONSTRAINT product_file_date_product_description_idx;
       public         	   statsuser    false    291    291    291            �           2606    18194    product_file product_file_pk 
   CONSTRAINT     Z   ALTER TABLE ONLY public.product_file
    ADD CONSTRAINT product_file_pk PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.product_file DROP CONSTRAINT product_file_pk;
       public         	   statsuser    false    291            �           2606    18196 .   product_file_variable product_file_variable_pk 
   CONSTRAINT     l   ALTER TABLE ONLY public.product_file_variable
    ADD CONSTRAINT product_file_variable_pk PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.product_file_variable DROP CONSTRAINT product_file_variable_pk;
       public         	   statsuser    false    296            �           2606    18198    product_order product_order_pk 
   CONSTRAINT     \   ALTER TABLE ONLY public.product_order
    ADD CONSTRAINT product_order_pk PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.product_order DROP CONSTRAINT product_order_pk;
       public         	   statsuser    false    299            �           2606    18200    product product_pk1 
   CONSTRAINT     Q   ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_pk1 PRIMARY KEY (id);
 =   ALTER TABLE ONLY public.product DROP CONSTRAINT product_pk1;
       public         	   statsuser    false    290            �           2606    18202 <   product_file_description product_product_file_description_pk 
   CONSTRAINT     z   ALTER TABLE ONLY public.product_file_description
    ADD CONSTRAINT product_product_file_description_pk PRIMARY KEY (id);
 f   ALTER TABLE ONLY public.product_file_description DROP CONSTRAINT product_product_file_description_pk;
       public         	   statsuser    false    292            �           2606    18204     stratification stratification_pk 
   CONSTRAINT     ^   ALTER TABLE ONLY public.stratification
    ADD CONSTRAINT stratification_pk PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.stratification DROP CONSTRAINT stratification_pk;
       public         	   statsuser    false    300            �           2606    18206 '   stratification_geom stratification_pkey 
   CONSTRAINT     e   ALTER TABLE ONLY public.stratification_geom
    ADD CONSTRAINT stratification_pkey PRIMARY KEY (id);
 Q   ALTER TABLE ONLY public.stratification_geom DROP CONSTRAINT stratification_pkey;
       public         	   statsuser    false    301            �           2606    18208     stratification stratification_un 
   CONSTRAINT     b   ALTER TABLE ONLY public.stratification
    ADD CONSTRAINT stratification_un UNIQUE (description);
 J   ALTER TABLE ONLY public.stratification DROP CONSTRAINT stratification_un;
       public         	   statsuser    false    300            �           2606    18210    wms_file wms_file_pk 
   CONSTRAINT     R   ALTER TABLE ONLY public.wms_file
    ADD CONSTRAINT wms_file_pk PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.wms_file DROP CONSTRAINT wms_file_pk;
       public         	   statsuser    false    305            �           2606    18212    wms_file wms_file_un 
   CONSTRAINT     t   ALTER TABLE ONLY public.wms_file
    ADD CONSTRAINT wms_file_un UNIQUE (product_file_id, product_file_variable_id);
 >   ALTER TABLE ONLY public.wms_file DROP CONSTRAINT wms_file_un;
       public         	   statsuser    false    305    305            �           2606    18214 #   poly_stats_per_region poly_stats_pk 
   CONSTRAINT     ^   ALTER TABLE ONLY tmp.poly_stats_per_region
    ADD CONSTRAINT poly_stats_pk PRIMARY KEY (id);
 J   ALTER TABLE ONLY tmp.poly_stats_per_region DROP CONSTRAINT poly_stats_pk;
       tmp         	   statsuser    false    307            �           2606    18216 #   poly_stats_per_region poly_stats_un 
   CONSTRAINT     �   ALTER TABLE ONLY tmp.poly_stats_per_region
    ADD CONSTRAINT poly_stats_un UNIQUE (poly_id, product_file_id, product_file_variable_id, region_id);
 J   ALTER TABLE ONLY tmp.poly_stats_per_region DROP CONSTRAINT poly_stats_un;
       tmp         	   statsuser    false    307    307    307    307            �           1259    18217    poly_stats_product_file_id_idx    INDEX        CREATE INDEX poly_stats_product_file_id_idx ON ONLY public.poly_stats USING btree (product_file_id, product_file_variable_id);
 2   DROP INDEX public.poly_stats_product_file_id_idx;
       public         	   statsuser    false    228    228            �           1259    18218 ?   poly_stats_10_1_257_product_file_id_product_file_variable_i_idx    INDEX     �   CREATE INDEX poly_stats_10_1_257_product_file_id_product_file_variable_i_idx ON public.poly_stats_10_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_10_1_257_product_file_id_product_file_variable_i_idx;
       public         	   statsuser    false    4792    229    229    229            �           1259    25266    poly_stats_valid_pixels_idx    INDEX     _   CREATE INDEX poly_stats_valid_pixels_idx ON ONLY public.poly_stats USING btree (valid_pixels);
 /   DROP INDEX public.poly_stats_valid_pixels_idx;
       public         	   statsuser    false    228            �           1259    25299 $   poly_stats_10_1_257_valid_pixels_idx    INDEX     l   CREATE INDEX poly_stats_10_1_257_valid_pixels_idx ON public.poly_stats_10_1_257 USING btree (valid_pixels);
 8   DROP INDEX public.poly_stats_10_1_257_valid_pixels_idx;
       public         	   statsuser    false    229    229    4793            �           1259    18219 ?   poly_stats_10_257_279_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_10_257_279_product_file_id_product_file_variable_idx ON public.poly_stats_10_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_10_257_279_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    230    230    230    4792            �           1259    25300 &   poly_stats_10_257_279_valid_pixels_idx    INDEX     p   CREATE INDEX poly_stats_10_257_279_valid_pixels_idx ON public.poly_stats_10_257_279 USING btree (valid_pixels);
 :   DROP INDEX public.poly_stats_10_257_279_valid_pixels_idx;
       public         	   statsuser    false    230    230    4793            �           1259    18220 ?   poly_stats_10_279_285_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_10_279_285_product_file_id_product_file_variable_idx ON public.poly_stats_10_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_10_279_285_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    231    4792    231    231            �           1259    25301 &   poly_stats_10_279_285_valid_pixels_idx    INDEX     p   CREATE INDEX poly_stats_10_279_285_valid_pixels_idx ON public.poly_stats_10_279_285 USING btree (valid_pixels);
 :   DROP INDEX public.poly_stats_10_279_285_valid_pixels_idx;
       public         	   statsuser    false    231    231    4793            �           1259    18221 ?   poly_stats_10_285_38543_product_file_id_product_file_variab_idx    INDEX     �   CREATE INDEX poly_stats_10_285_38543_product_file_id_product_file_variab_idx ON public.poly_stats_10_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_10_285_38543_product_file_id_product_file_variab_idx;
       public         	   statsuser    false    232    232    4792    232            �           1259    25302 (   poly_stats_10_285_38543_valid_pixels_idx    INDEX     t   CREATE INDEX poly_stats_10_285_38543_valid_pixels_idx ON public.poly_stats_10_285_38543 USING btree (valid_pixels);
 <   DROP INDEX public.poly_stats_10_285_38543_valid_pixels_idx;
       public         	   statsuser    false    232    4793    232            �           1259    18222 ?   poly_stats_12_1_257_product_file_id_product_file_variable_i_idx    INDEX     �   CREATE INDEX poly_stats_12_1_257_product_file_id_product_file_variable_i_idx ON public.poly_stats_12_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_12_1_257_product_file_id_product_file_variable_i_idx;
       public         	   statsuser    false    233    233    233    4792            �           1259    25303 $   poly_stats_12_1_257_valid_pixels_idx    INDEX     l   CREATE INDEX poly_stats_12_1_257_valid_pixels_idx ON public.poly_stats_12_1_257 USING btree (valid_pixels);
 8   DROP INDEX public.poly_stats_12_1_257_valid_pixels_idx;
       public         	   statsuser    false    4793    233    233            �           1259    18223 ?   poly_stats_12_257_279_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_12_257_279_product_file_id_product_file_variable_idx ON public.poly_stats_12_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_12_257_279_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    234    234    4792    234            �           1259    25304 &   poly_stats_12_257_279_valid_pixels_idx    INDEX     p   CREATE INDEX poly_stats_12_257_279_valid_pixels_idx ON public.poly_stats_12_257_279 USING btree (valid_pixels);
 :   DROP INDEX public.poly_stats_12_257_279_valid_pixels_idx;
       public         	   statsuser    false    234    4793    234            �           1259    18224 ?   poly_stats_12_279_285_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_12_279_285_product_file_id_product_file_variable_idx ON public.poly_stats_12_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_12_279_285_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    235    235    4792    235            �           1259    25305 &   poly_stats_12_279_285_valid_pixels_idx    INDEX     p   CREATE INDEX poly_stats_12_279_285_valid_pixels_idx ON public.poly_stats_12_279_285 USING btree (valid_pixels);
 :   DROP INDEX public.poly_stats_12_279_285_valid_pixels_idx;
       public         	   statsuser    false    235    4793    235            �           1259    18225 ?   poly_stats_12_285_38543_product_file_id_product_file_variab_idx    INDEX     �   CREATE INDEX poly_stats_12_285_38543_product_file_id_product_file_variab_idx ON public.poly_stats_12_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_12_285_38543_product_file_id_product_file_variab_idx;
       public         	   statsuser    false    236    236    236    4792            �           1259    25306 (   poly_stats_12_285_38543_valid_pixels_idx    INDEX     t   CREATE INDEX poly_stats_12_285_38543_valid_pixels_idx ON public.poly_stats_12_285_38543 USING btree (valid_pixels);
 <   DROP INDEX public.poly_stats_12_285_38543_valid_pixels_idx;
       public         	   statsuser    false    236    236    4793            �           1259    18226 ?   poly_stats_14_1_257_product_file_id_product_file_variable_i_idx    INDEX     �   CREATE INDEX poly_stats_14_1_257_product_file_id_product_file_variable_i_idx ON public.poly_stats_14_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_14_1_257_product_file_id_product_file_variable_i_idx;
       public         	   statsuser    false    4792    237    237    237            �           1259    25307 $   poly_stats_14_1_257_valid_pixels_idx    INDEX     l   CREATE INDEX poly_stats_14_1_257_valid_pixels_idx ON public.poly_stats_14_1_257 USING btree (valid_pixels);
 8   DROP INDEX public.poly_stats_14_1_257_valid_pixels_idx;
       public         	   statsuser    false    4793    237    237            �           1259    18227 ?   poly_stats_14_257_279_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_14_257_279_product_file_id_product_file_variable_idx ON public.poly_stats_14_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_14_257_279_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    4792    238    238    238            �           1259    25308 &   poly_stats_14_257_279_valid_pixels_idx    INDEX     p   CREATE INDEX poly_stats_14_257_279_valid_pixels_idx ON public.poly_stats_14_257_279 USING btree (valid_pixels);
 :   DROP INDEX public.poly_stats_14_257_279_valid_pixels_idx;
       public         	   statsuser    false    238    4793    238            �           1259    18228 ?   poly_stats_14_279_285_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_14_279_285_product_file_id_product_file_variable_idx ON public.poly_stats_14_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_14_279_285_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    239    4792    239    239            �           1259    25309 &   poly_stats_14_279_285_valid_pixels_idx    INDEX     p   CREATE INDEX poly_stats_14_279_285_valid_pixels_idx ON public.poly_stats_14_279_285 USING btree (valid_pixels);
 :   DROP INDEX public.poly_stats_14_279_285_valid_pixels_idx;
       public         	   statsuser    false    239    4793    239            �           1259    18229 ?   poly_stats_14_285_38543_product_file_id_product_file_variab_idx    INDEX     �   CREATE INDEX poly_stats_14_285_38543_product_file_id_product_file_variab_idx ON public.poly_stats_14_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_14_285_38543_product_file_id_product_file_variab_idx;
       public         	   statsuser    false    240    240    4792    240            �           1259    25310 (   poly_stats_14_285_38543_valid_pixels_idx    INDEX     t   CREATE INDEX poly_stats_14_285_38543_valid_pixels_idx ON public.poly_stats_14_285_38543 USING btree (valid_pixels);
 <   DROP INDEX public.poly_stats_14_285_38543_valid_pixels_idx;
       public         	   statsuser    false    240    240    4793            �           1259    18230 ?   poly_stats_16_1_257_product_file_id_product_file_variable_i_idx    INDEX     �   CREATE INDEX poly_stats_16_1_257_product_file_id_product_file_variable_i_idx ON public.poly_stats_16_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_16_1_257_product_file_id_product_file_variable_i_idx;
       public         	   statsuser    false    241    241    4792    241            �           1259    25311 $   poly_stats_16_1_257_valid_pixels_idx    INDEX     l   CREATE INDEX poly_stats_16_1_257_valid_pixels_idx ON public.poly_stats_16_1_257 USING btree (valid_pixels);
 8   DROP INDEX public.poly_stats_16_1_257_valid_pixels_idx;
       public         	   statsuser    false    4793    241    241            �           1259    18231 ?   poly_stats_16_257_279_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_16_257_279_product_file_id_product_file_variable_idx ON public.poly_stats_16_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_16_257_279_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    242    4792    242    242            �           1259    25312 &   poly_stats_16_257_279_valid_pixels_idx    INDEX     p   CREATE INDEX poly_stats_16_257_279_valid_pixels_idx ON public.poly_stats_16_257_279 USING btree (valid_pixels);
 :   DROP INDEX public.poly_stats_16_257_279_valid_pixels_idx;
       public         	   statsuser    false    242    242    4793            �           1259    18232 ?   poly_stats_16_279_285_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_16_279_285_product_file_id_product_file_variable_idx ON public.poly_stats_16_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_16_279_285_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    243    243    243    4792            �           1259    25313 &   poly_stats_16_279_285_valid_pixels_idx    INDEX     p   CREATE INDEX poly_stats_16_279_285_valid_pixels_idx ON public.poly_stats_16_279_285 USING btree (valid_pixels);
 :   DROP INDEX public.poly_stats_16_279_285_valid_pixels_idx;
       public         	   statsuser    false    243    4793    243            �           1259    18233 ?   poly_stats_16_285_38543_product_file_id_product_file_variab_idx    INDEX     �   CREATE INDEX poly_stats_16_285_38543_product_file_id_product_file_variab_idx ON public.poly_stats_16_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_16_285_38543_product_file_id_product_file_variab_idx;
       public         	   statsuser    false    244    244    4792    244            �           1259    25314 (   poly_stats_16_285_38543_valid_pixels_idx    INDEX     t   CREATE INDEX poly_stats_16_285_38543_valid_pixels_idx ON public.poly_stats_16_285_38543 USING btree (valid_pixels);
 <   DROP INDEX public.poly_stats_16_285_38543_valid_pixels_idx;
       public         	   statsuser    false    244    4793    244            �           1259    18234 ?   poly_stats_17_1_257_product_file_id_product_file_variable_i_idx    INDEX     �   CREATE INDEX poly_stats_17_1_257_product_file_id_product_file_variable_i_idx ON public.poly_stats_17_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_17_1_257_product_file_id_product_file_variable_i_idx;
       public         	   statsuser    false    245    245    245    4792            �           1259    25315 $   poly_stats_17_1_257_valid_pixels_idx    INDEX     l   CREATE INDEX poly_stats_17_1_257_valid_pixels_idx ON public.poly_stats_17_1_257 USING btree (valid_pixels);
 8   DROP INDEX public.poly_stats_17_1_257_valid_pixels_idx;
       public         	   statsuser    false    245    4793    245                        1259    18235 ?   poly_stats_17_257_279_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_17_257_279_product_file_id_product_file_variable_idx ON public.poly_stats_17_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_17_257_279_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    246    246    4792    246                       1259    25316 &   poly_stats_17_257_279_valid_pixels_idx    INDEX     p   CREATE INDEX poly_stats_17_257_279_valid_pixels_idx ON public.poly_stats_17_257_279 USING btree (valid_pixels);
 :   DROP INDEX public.poly_stats_17_257_279_valid_pixels_idx;
       public         	   statsuser    false    246    4793    246                       1259    18236 ?   poly_stats_17_279_285_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_17_279_285_product_file_id_product_file_variable_idx ON public.poly_stats_17_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_17_279_285_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    4792    247    247    247                       1259    25317 &   poly_stats_17_279_285_valid_pixels_idx    INDEX     p   CREATE INDEX poly_stats_17_279_285_valid_pixels_idx ON public.poly_stats_17_279_285 USING btree (valid_pixels);
 :   DROP INDEX public.poly_stats_17_279_285_valid_pixels_idx;
       public         	   statsuser    false    247    247    4793                       1259    18237 ?   poly_stats_17_285_38543_product_file_id_product_file_variab_idx    INDEX     �   CREATE INDEX poly_stats_17_285_38543_product_file_id_product_file_variab_idx ON public.poly_stats_17_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_17_285_38543_product_file_id_product_file_variab_idx;
       public         	   statsuser    false    248    248    248    4792            	           1259    25318 (   poly_stats_17_285_38543_valid_pixels_idx    INDEX     t   CREATE INDEX poly_stats_17_285_38543_valid_pixels_idx ON public.poly_stats_17_285_38543 USING btree (valid_pixels);
 <   DROP INDEX public.poly_stats_17_285_38543_valid_pixels_idx;
       public         	   statsuser    false    4793    248    248                       1259    18238 ?   poly_stats_19_1_257_product_file_id_product_file_variable_i_idx    INDEX     �   CREATE INDEX poly_stats_19_1_257_product_file_id_product_file_variable_i_idx ON public.poly_stats_19_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_19_1_257_product_file_id_product_file_variable_i_idx;
       public         	   statsuser    false    249    249    249    4792                       1259    25319 $   poly_stats_19_1_257_valid_pixels_idx    INDEX     l   CREATE INDEX poly_stats_19_1_257_valid_pixels_idx ON public.poly_stats_19_1_257 USING btree (valid_pixels);
 8   DROP INDEX public.poly_stats_19_1_257_valid_pixels_idx;
       public         	   statsuser    false    249    249    4793                       1259    18239 ?   poly_stats_19_257_279_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_19_257_279_product_file_id_product_file_variable_idx ON public.poly_stats_19_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_19_257_279_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    250    250    4792    250                       1259    25320 &   poly_stats_19_257_279_valid_pixels_idx    INDEX     p   CREATE INDEX poly_stats_19_257_279_valid_pixels_idx ON public.poly_stats_19_257_279 USING btree (valid_pixels);
 :   DROP INDEX public.poly_stats_19_257_279_valid_pixels_idx;
       public         	   statsuser    false    250    250    4793                       1259    18240 ?   poly_stats_19_279_285_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_19_279_285_product_file_id_product_file_variable_idx ON public.poly_stats_19_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_19_279_285_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    251    251    251    4792                       1259    25321 &   poly_stats_19_279_285_valid_pixels_idx    INDEX     p   CREATE INDEX poly_stats_19_279_285_valid_pixels_idx ON public.poly_stats_19_279_285 USING btree (valid_pixels);
 :   DROP INDEX public.poly_stats_19_279_285_valid_pixels_idx;
       public         	   statsuser    false    4793    251    251                       1259    18241 ?   poly_stats_19_285_38543_product_file_id_product_file_variab_idx    INDEX     �   CREATE INDEX poly_stats_19_285_38543_product_file_id_product_file_variab_idx ON public.poly_stats_19_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_19_285_38543_product_file_id_product_file_variab_idx;
       public         	   statsuser    false    252    252    252    4792                       1259    25322 (   poly_stats_19_285_38543_valid_pixels_idx    INDEX     t   CREATE INDEX poly_stats_19_285_38543_valid_pixels_idx ON public.poly_stats_19_285_38543 USING btree (valid_pixels);
 <   DROP INDEX public.poly_stats_19_285_38543_valid_pixels_idx;
       public         	   statsuser    false    4793    252    252                       1259    18242 ?   poly_stats_1_1_257_product_file_id_product_file_variable_id_idx    INDEX     �   CREATE INDEX poly_stats_1_1_257_product_file_id_product_file_variable_id_idx ON public.poly_stats_1_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_1_1_257_product_file_id_product_file_variable_id_idx;
       public         	   statsuser    false    4792    253    253    253                       1259    25267 #   poly_stats_1_1_257_valid_pixels_idx    INDEX     j   CREATE INDEX poly_stats_1_1_257_valid_pixels_idx ON public.poly_stats_1_1_257 USING btree (valid_pixels);
 7   DROP INDEX public.poly_stats_1_1_257_valid_pixels_idx;
       public         	   statsuser    false    4793    253    253                        1259    18243 ?   poly_stats_1_257_279_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_1_257_279_product_file_id_product_file_variable__idx ON public.poly_stats_1_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_1_257_279_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    254    4792    254    254            !           1259    25268 %   poly_stats_1_257_279_valid_pixels_idx    INDEX     n   CREATE INDEX poly_stats_1_257_279_valid_pixels_idx ON public.poly_stats_1_257_279 USING btree (valid_pixels);
 9   DROP INDEX public.poly_stats_1_257_279_valid_pixels_idx;
       public         	   statsuser    false    254    254    4793            $           1259    18244 ?   poly_stats_1_279_285_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_1_279_285_product_file_id_product_file_variable__idx ON public.poly_stats_1_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_1_279_285_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    255    255    4792    255            %           1259    25269 %   poly_stats_1_279_285_valid_pixels_idx    INDEX     n   CREATE INDEX poly_stats_1_279_285_valid_pixels_idx ON public.poly_stats_1_279_285 USING btree (valid_pixels);
 9   DROP INDEX public.poly_stats_1_279_285_valid_pixels_idx;
       public         	   statsuser    false    4793    255    255            (           1259    18245 ?   poly_stats_1_285_38543_product_file_id_product_file_variabl_idx    INDEX     �   CREATE INDEX poly_stats_1_285_38543_product_file_id_product_file_variabl_idx ON public.poly_stats_1_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_1_285_38543_product_file_id_product_file_variabl_idx;
       public         	   statsuser    false    256    256    256    4792            )           1259    25270 '   poly_stats_1_285_38543_valid_pixels_idx    INDEX     r   CREATE INDEX poly_stats_1_285_38543_valid_pixels_idx ON public.poly_stats_1_285_38543 USING btree (valid_pixels);
 ;   DROP INDEX public.poly_stats_1_285_38543_valid_pixels_idx;
       public         	   statsuser    false    256    256    4793            ,           1259    18246 ?   poly_stats_21_1_257_product_file_id_product_file_variable_i_idx    INDEX     �   CREATE INDEX poly_stats_21_1_257_product_file_id_product_file_variable_i_idx ON public.poly_stats_21_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_21_1_257_product_file_id_product_file_variable_i_idx;
       public         	   statsuser    false    257    257    4792    257            -           1259    25323 $   poly_stats_21_1_257_valid_pixels_idx    INDEX     l   CREATE INDEX poly_stats_21_1_257_valid_pixels_idx ON public.poly_stats_21_1_257 USING btree (valid_pixels);
 8   DROP INDEX public.poly_stats_21_1_257_valid_pixels_idx;
       public         	   statsuser    false    4793    257    257            0           1259    18247 ?   poly_stats_21_257_279_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_21_257_279_product_file_id_product_file_variable_idx ON public.poly_stats_21_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_21_257_279_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    258    258    4792    258            1           1259    25324 &   poly_stats_21_257_279_valid_pixels_idx    INDEX     p   CREATE INDEX poly_stats_21_257_279_valid_pixels_idx ON public.poly_stats_21_257_279 USING btree (valid_pixels);
 :   DROP INDEX public.poly_stats_21_257_279_valid_pixels_idx;
       public         	   statsuser    false    4793    258    258            4           1259    18248 ?   poly_stats_21_279_285_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_21_279_285_product_file_id_product_file_variable_idx ON public.poly_stats_21_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_21_279_285_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    259    259    4792    259            5           1259    25325 &   poly_stats_21_279_285_valid_pixels_idx    INDEX     p   CREATE INDEX poly_stats_21_279_285_valid_pixels_idx ON public.poly_stats_21_279_285 USING btree (valid_pixels);
 :   DROP INDEX public.poly_stats_21_279_285_valid_pixels_idx;
       public         	   statsuser    false    259    259    4793            8           1259    18249 ?   poly_stats_21_285_38543_product_file_id_product_file_variab_idx    INDEX     �   CREATE INDEX poly_stats_21_285_38543_product_file_id_product_file_variab_idx ON public.poly_stats_21_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_21_285_38543_product_file_id_product_file_variab_idx;
       public         	   statsuser    false    4792    260    260    260            9           1259    25326 (   poly_stats_21_285_38543_valid_pixels_idx    INDEX     t   CREATE INDEX poly_stats_21_285_38543_valid_pixels_idx ON public.poly_stats_21_285_38543 USING btree (valid_pixels);
 <   DROP INDEX public.poly_stats_21_285_38543_valid_pixels_idx;
       public         	   statsuser    false    4793    260    260            <           1259    18250 ?   poly_stats_24_1_257_product_file_id_product_file_variable_i_idx    INDEX     �   CREATE INDEX poly_stats_24_1_257_product_file_id_product_file_variable_i_idx ON public.poly_stats_24_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_24_1_257_product_file_id_product_file_variable_i_idx;
       public         	   statsuser    false    261    4792    261    261            =           1259    25327 $   poly_stats_24_1_257_valid_pixels_idx    INDEX     l   CREATE INDEX poly_stats_24_1_257_valid_pixels_idx ON public.poly_stats_24_1_257 USING btree (valid_pixels);
 8   DROP INDEX public.poly_stats_24_1_257_valid_pixels_idx;
       public         	   statsuser    false    4793    261    261            �           1259    23026 >   poly_stats_25_1_2_product_file_id_product_file_variable_id_idx    INDEX     �   CREATE INDEX poly_stats_25_1_2_product_file_id_product_file_variable_id_idx ON public.poly_stats_25_1_2 USING btree (product_file_id, product_file_variable_id);
 R   DROP INDEX public.poly_stats_25_1_2_product_file_id_product_file_variable_id_idx;
       public         	   statsuser    false    4792    309    309    309            �           1259    25328 "   poly_stats_25_1_2_valid_pixels_idx    INDEX     h   CREATE INDEX poly_stats_25_1_2_valid_pixels_idx ON public.poly_stats_25_1_2 USING btree (valid_pixels);
 6   DROP INDEX public.poly_stats_25_1_2_valid_pixels_idx;
       public         	   statsuser    false    309    309    4793            �           1259    23119 ?   poly_stats_25_2_257_product_file_id_product_file_variable_i_idx    INDEX     �   CREATE INDEX poly_stats_25_2_257_product_file_id_product_file_variable_i_idx ON public.poly_stats_25_2_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_25_2_257_product_file_id_product_file_variable_i_idx;
       public         	   statsuser    false    310    310    310    4792            �           1259    25329 $   poly_stats_25_2_257_valid_pixels_idx    INDEX     l   CREATE INDEX poly_stats_25_2_257_valid_pixels_idx ON public.poly_stats_25_2_257 USING btree (valid_pixels);
 8   DROP INDEX public.poly_stats_25_2_257_valid_pixels_idx;
       public         	   statsuser    false    310    4793    310            @           1259    18251 ?   poly_stats_2_1_257_product_file_id_product_file_variable_id_idx    INDEX     �   CREATE INDEX poly_stats_2_1_257_product_file_id_product_file_variable_id_idx ON public.poly_stats_2_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_2_1_257_product_file_id_product_file_variable_id_idx;
       public         	   statsuser    false    262    262    262    4792            A           1259    25271 #   poly_stats_2_1_257_valid_pixels_idx    INDEX     j   CREATE INDEX poly_stats_2_1_257_valid_pixels_idx ON public.poly_stats_2_1_257 USING btree (valid_pixels);
 7   DROP INDEX public.poly_stats_2_1_257_valid_pixels_idx;
       public         	   statsuser    false    262    4793    262            D           1259    18252 ?   poly_stats_2_257_279_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_2_257_279_product_file_id_product_file_variable__idx ON public.poly_stats_2_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_2_257_279_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    4792    263    263    263            E           1259    25272 %   poly_stats_2_257_279_valid_pixels_idx    INDEX     n   CREATE INDEX poly_stats_2_257_279_valid_pixels_idx ON public.poly_stats_2_257_279 USING btree (valid_pixels);
 9   DROP INDEX public.poly_stats_2_257_279_valid_pixels_idx;
       public         	   statsuser    false    4793    263    263            H           1259    18253 ?   poly_stats_2_279_285_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_2_279_285_product_file_id_product_file_variable__idx ON public.poly_stats_2_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_2_279_285_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    264    4792    264    264            I           1259    25273 %   poly_stats_2_279_285_valid_pixels_idx    INDEX     n   CREATE INDEX poly_stats_2_279_285_valid_pixels_idx ON public.poly_stats_2_279_285 USING btree (valid_pixels);
 9   DROP INDEX public.poly_stats_2_279_285_valid_pixels_idx;
       public         	   statsuser    false    264    4793    264            L           1259    18254 ?   poly_stats_2_285_38543_product_file_id_product_file_variabl_idx    INDEX     �   CREATE INDEX poly_stats_2_285_38543_product_file_id_product_file_variabl_idx ON public.poly_stats_2_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_2_285_38543_product_file_id_product_file_variabl_idx;
       public         	   statsuser    false    265    265    265    4792            M           1259    25274 '   poly_stats_2_285_38543_valid_pixels_idx    INDEX     r   CREATE INDEX poly_stats_2_285_38543_valid_pixels_idx ON public.poly_stats_2_285_38543 USING btree (valid_pixels);
 ;   DROP INDEX public.poly_stats_2_285_38543_valid_pixels_idx;
       public         	   statsuser    false    265    265    4793            P           1259    18255 ?   poly_stats_3_1_257_product_file_id_product_file_variable_id_idx    INDEX     �   CREATE INDEX poly_stats_3_1_257_product_file_id_product_file_variable_id_idx ON public.poly_stats_3_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_3_1_257_product_file_id_product_file_variable_id_idx;
       public         	   statsuser    false    266    4792    266    266            Q           1259    25275 #   poly_stats_3_1_257_valid_pixels_idx    INDEX     j   CREATE INDEX poly_stats_3_1_257_valid_pixels_idx ON public.poly_stats_3_1_257 USING btree (valid_pixels);
 7   DROP INDEX public.poly_stats_3_1_257_valid_pixels_idx;
       public         	   statsuser    false    266    4793    266            T           1259    18256 ?   poly_stats_3_257_279_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_3_257_279_product_file_id_product_file_variable__idx ON public.poly_stats_3_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_3_257_279_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    267    4792    267    267            U           1259    25276 %   poly_stats_3_257_279_valid_pixels_idx    INDEX     n   CREATE INDEX poly_stats_3_257_279_valid_pixels_idx ON public.poly_stats_3_257_279 USING btree (valid_pixels);
 9   DROP INDEX public.poly_stats_3_257_279_valid_pixels_idx;
       public         	   statsuser    false    267    267    4793            X           1259    18257 ?   poly_stats_3_279_285_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_3_279_285_product_file_id_product_file_variable__idx ON public.poly_stats_3_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_3_279_285_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    4792    268    268    268            Y           1259    25277 %   poly_stats_3_279_285_valid_pixels_idx    INDEX     n   CREATE INDEX poly_stats_3_279_285_valid_pixels_idx ON public.poly_stats_3_279_285 USING btree (valid_pixels);
 9   DROP INDEX public.poly_stats_3_279_285_valid_pixels_idx;
       public         	   statsuser    false    268    4793    268            \           1259    18258 ?   poly_stats_3_285_38543_product_file_id_product_file_variabl_idx    INDEX     �   CREATE INDEX poly_stats_3_285_38543_product_file_id_product_file_variabl_idx ON public.poly_stats_3_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_3_285_38543_product_file_id_product_file_variabl_idx;
       public         	   statsuser    false    269    4792    269    269            ]           1259    25278 '   poly_stats_3_285_38543_valid_pixels_idx    INDEX     r   CREATE INDEX poly_stats_3_285_38543_valid_pixels_idx ON public.poly_stats_3_285_38543 USING btree (valid_pixels);
 ;   DROP INDEX public.poly_stats_3_285_38543_valid_pixels_idx;
       public         	   statsuser    false    269    4793    269            `           1259    18259 ?   poly_stats_4_1_257_product_file_id_product_file_variable_id_idx    INDEX     �   CREATE INDEX poly_stats_4_1_257_product_file_id_product_file_variable_id_idx ON public.poly_stats_4_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_4_1_257_product_file_id_product_file_variable_id_idx;
       public         	   statsuser    false    270    270    4792    270            a           1259    25279 #   poly_stats_4_1_257_valid_pixels_idx    INDEX     j   CREATE INDEX poly_stats_4_1_257_valid_pixels_idx ON public.poly_stats_4_1_257 USING btree (valid_pixels);
 7   DROP INDEX public.poly_stats_4_1_257_valid_pixels_idx;
       public         	   statsuser    false    270    270    4793            d           1259    18260 ?   poly_stats_4_257_279_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_4_257_279_product_file_id_product_file_variable__idx ON public.poly_stats_4_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_4_257_279_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    271    271    4792    271            e           1259    25280 %   poly_stats_4_257_279_valid_pixels_idx    INDEX     n   CREATE INDEX poly_stats_4_257_279_valid_pixels_idx ON public.poly_stats_4_257_279 USING btree (valid_pixels);
 9   DROP INDEX public.poly_stats_4_257_279_valid_pixels_idx;
       public         	   statsuser    false    4793    271    271            h           1259    18261 ?   poly_stats_4_279_285_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_4_279_285_product_file_id_product_file_variable__idx ON public.poly_stats_4_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_4_279_285_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    272    4792    272    272            i           1259    25281 %   poly_stats_4_279_285_valid_pixels_idx    INDEX     n   CREATE INDEX poly_stats_4_279_285_valid_pixels_idx ON public.poly_stats_4_279_285 USING btree (valid_pixels);
 9   DROP INDEX public.poly_stats_4_279_285_valid_pixels_idx;
       public         	   statsuser    false    4793    272    272            l           1259    18262 ?   poly_stats_4_285_38543_product_file_id_product_file_variabl_idx    INDEX     �   CREATE INDEX poly_stats_4_285_38543_product_file_id_product_file_variabl_idx ON public.poly_stats_4_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_4_285_38543_product_file_id_product_file_variabl_idx;
       public         	   statsuser    false    273    273    4792    273            m           1259    25282 '   poly_stats_4_285_38543_valid_pixels_idx    INDEX     r   CREATE INDEX poly_stats_4_285_38543_valid_pixels_idx ON public.poly_stats_4_285_38543 USING btree (valid_pixels);
 ;   DROP INDEX public.poly_stats_4_285_38543_valid_pixels_idx;
       public         	   statsuser    false    273    4793    273            p           1259    18263 ?   poly_stats_5_1_257_product_file_id_product_file_variable_id_idx    INDEX     �   CREATE INDEX poly_stats_5_1_257_product_file_id_product_file_variable_id_idx ON public.poly_stats_5_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_5_1_257_product_file_id_product_file_variable_id_idx;
       public         	   statsuser    false    274    274    274    4792            q           1259    25283 #   poly_stats_5_1_257_valid_pixels_idx    INDEX     j   CREATE INDEX poly_stats_5_1_257_valid_pixels_idx ON public.poly_stats_5_1_257 USING btree (valid_pixels);
 7   DROP INDEX public.poly_stats_5_1_257_valid_pixels_idx;
       public         	   statsuser    false    274    4793    274            t           1259    18264 ?   poly_stats_5_257_279_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_5_257_279_product_file_id_product_file_variable__idx ON public.poly_stats_5_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_5_257_279_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    275    275    275    4792            u           1259    25284 %   poly_stats_5_257_279_valid_pixels_idx    INDEX     n   CREATE INDEX poly_stats_5_257_279_valid_pixels_idx ON public.poly_stats_5_257_279 USING btree (valid_pixels);
 9   DROP INDEX public.poly_stats_5_257_279_valid_pixels_idx;
       public         	   statsuser    false    275    275    4793            x           1259    18265 ?   poly_stats_5_279_285_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_5_279_285_product_file_id_product_file_variable__idx ON public.poly_stats_5_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_5_279_285_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    276    276    276    4792            y           1259    25285 %   poly_stats_5_279_285_valid_pixels_idx    INDEX     n   CREATE INDEX poly_stats_5_279_285_valid_pixels_idx ON public.poly_stats_5_279_285 USING btree (valid_pixels);
 9   DROP INDEX public.poly_stats_5_279_285_valid_pixels_idx;
       public         	   statsuser    false    276    276    4793            |           1259    18266 ?   poly_stats_5_285_38543_product_file_id_product_file_variabl_idx    INDEX     �   CREATE INDEX poly_stats_5_285_38543_product_file_id_product_file_variabl_idx ON public.poly_stats_5_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_5_285_38543_product_file_id_product_file_variabl_idx;
       public         	   statsuser    false    277    4792    277    277            }           1259    25286 '   poly_stats_5_285_38543_valid_pixels_idx    INDEX     r   CREATE INDEX poly_stats_5_285_38543_valid_pixels_idx ON public.poly_stats_5_285_38543 USING btree (valid_pixels);
 ;   DROP INDEX public.poly_stats_5_285_38543_valid_pixels_idx;
       public         	   statsuser    false    277    277    4793            �           1259    18267 ?   poly_stats_6_1_257_product_file_id_product_file_variable_id_idx    INDEX     �   CREATE INDEX poly_stats_6_1_257_product_file_id_product_file_variable_id_idx ON public.poly_stats_6_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_6_1_257_product_file_id_product_file_variable_id_idx;
       public         	   statsuser    false    278    278    4792    278            �           1259    25287 #   poly_stats_6_1_257_valid_pixels_idx    INDEX     j   CREATE INDEX poly_stats_6_1_257_valid_pixels_idx ON public.poly_stats_6_1_257 USING btree (valid_pixels);
 7   DROP INDEX public.poly_stats_6_1_257_valid_pixels_idx;
       public         	   statsuser    false    278    4793    278            �           1259    18268 ?   poly_stats_6_257_279_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_6_257_279_product_file_id_product_file_variable__idx ON public.poly_stats_6_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_6_257_279_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    279    4792    279    279            �           1259    25288 %   poly_stats_6_257_279_valid_pixels_idx    INDEX     n   CREATE INDEX poly_stats_6_257_279_valid_pixels_idx ON public.poly_stats_6_257_279 USING btree (valid_pixels);
 9   DROP INDEX public.poly_stats_6_257_279_valid_pixels_idx;
       public         	   statsuser    false    279    4793    279            �           1259    18269 ?   poly_stats_6_279_285_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_6_279_285_product_file_id_product_file_variable__idx ON public.poly_stats_6_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_6_279_285_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    280    280    280    4792            �           1259    25289 %   poly_stats_6_279_285_valid_pixels_idx    INDEX     n   CREATE INDEX poly_stats_6_279_285_valid_pixels_idx ON public.poly_stats_6_279_285 USING btree (valid_pixels);
 9   DROP INDEX public.poly_stats_6_279_285_valid_pixels_idx;
       public         	   statsuser    false    280    4793    280            �           1259    18270 ?   poly_stats_6_285_38543_product_file_id_product_file_variabl_idx    INDEX     �   CREATE INDEX poly_stats_6_285_38543_product_file_id_product_file_variabl_idx ON public.poly_stats_6_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_6_285_38543_product_file_id_product_file_variabl_idx;
       public         	   statsuser    false    281    281    4792    281            �           1259    25290 '   poly_stats_6_285_38543_valid_pixels_idx    INDEX     r   CREATE INDEX poly_stats_6_285_38543_valid_pixels_idx ON public.poly_stats_6_285_38543 USING btree (valid_pixels);
 ;   DROP INDEX public.poly_stats_6_285_38543_valid_pixels_idx;
       public         	   statsuser    false    281    4793    281            �           1259    18271 ?   poly_stats_7_1_257_product_file_id_product_file_variable_id_idx    INDEX     �   CREATE INDEX poly_stats_7_1_257_product_file_id_product_file_variable_id_idx ON public.poly_stats_7_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_7_1_257_product_file_id_product_file_variable_id_idx;
       public         	   statsuser    false    282    4792    282    282            �           1259    25291 #   poly_stats_7_1_257_valid_pixels_idx    INDEX     j   CREATE INDEX poly_stats_7_1_257_valid_pixels_idx ON public.poly_stats_7_1_257 USING btree (valid_pixels);
 7   DROP INDEX public.poly_stats_7_1_257_valid_pixels_idx;
       public         	   statsuser    false    282    4793    282            �           1259    18272 ?   poly_stats_7_257_279_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_7_257_279_product_file_id_product_file_variable__idx ON public.poly_stats_7_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_7_257_279_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    283    283    283    4792            �           1259    25292 %   poly_stats_7_257_279_valid_pixels_idx    INDEX     n   CREATE INDEX poly_stats_7_257_279_valid_pixels_idx ON public.poly_stats_7_257_279 USING btree (valid_pixels);
 9   DROP INDEX public.poly_stats_7_257_279_valid_pixels_idx;
       public         	   statsuser    false    283    4793    283            �           1259    18273 ?   poly_stats_7_279_285_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_7_279_285_product_file_id_product_file_variable__idx ON public.poly_stats_7_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_7_279_285_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    4792    284    284    284            �           1259    25293 %   poly_stats_7_279_285_valid_pixels_idx    INDEX     n   CREATE INDEX poly_stats_7_279_285_valid_pixels_idx ON public.poly_stats_7_279_285 USING btree (valid_pixels);
 9   DROP INDEX public.poly_stats_7_279_285_valid_pixels_idx;
       public         	   statsuser    false    284    4793    284            �           1259    18274 ?   poly_stats_7_285_38543_product_file_id_product_file_variabl_idx    INDEX     �   CREATE INDEX poly_stats_7_285_38543_product_file_id_product_file_variabl_idx ON public.poly_stats_7_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_7_285_38543_product_file_id_product_file_variabl_idx;
       public         	   statsuser    false    285    285    4792    285            �           1259    25294 '   poly_stats_7_285_38543_valid_pixels_idx    INDEX     r   CREATE INDEX poly_stats_7_285_38543_valid_pixels_idx ON public.poly_stats_7_285_38543 USING btree (valid_pixels);
 ;   DROP INDEX public.poly_stats_7_285_38543_valid_pixels_idx;
       public         	   statsuser    false    285    4793    285            �           1259    18275 ?   poly_stats_9_1_257_product_file_id_product_file_variable_id_idx    INDEX     �   CREATE INDEX poly_stats_9_1_257_product_file_id_product_file_variable_id_idx ON public.poly_stats_9_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_9_1_257_product_file_id_product_file_variable_id_idx;
       public         	   statsuser    false    286    286    286    4792            �           1259    25295 #   poly_stats_9_1_257_valid_pixels_idx    INDEX     j   CREATE INDEX poly_stats_9_1_257_valid_pixels_idx ON public.poly_stats_9_1_257 USING btree (valid_pixels);
 7   DROP INDEX public.poly_stats_9_1_257_valid_pixels_idx;
       public         	   statsuser    false    286    4793    286            �           1259    18276 ?   poly_stats_9_257_279_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_9_257_279_product_file_id_product_file_variable__idx ON public.poly_stats_9_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_9_257_279_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    287    4792    287    287            �           1259    25296 %   poly_stats_9_257_279_valid_pixels_idx    INDEX     n   CREATE INDEX poly_stats_9_257_279_valid_pixels_idx ON public.poly_stats_9_257_279 USING btree (valid_pixels);
 9   DROP INDEX public.poly_stats_9_257_279_valid_pixels_idx;
       public         	   statsuser    false    287    287    4793            �           1259    18277 ?   poly_stats_9_279_285_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_9_279_285_product_file_id_product_file_variable__idx ON public.poly_stats_9_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_9_279_285_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    288    288    4792    288            �           1259    25297 %   poly_stats_9_279_285_valid_pixels_idx    INDEX     n   CREATE INDEX poly_stats_9_279_285_valid_pixels_idx ON public.poly_stats_9_279_285 USING btree (valid_pixels);
 9   DROP INDEX public.poly_stats_9_279_285_valid_pixels_idx;
       public         	   statsuser    false    288    288    4793            �           1259    18278 ?   poly_stats_9_285_38543_product_file_id_product_file_variabl_idx    INDEX     �   CREATE INDEX poly_stats_9_285_38543_product_file_id_product_file_variabl_idx ON public.poly_stats_9_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_9_285_38543_product_file_id_product_file_variabl_idx;
       public         	   statsuser    false    289    289    289    4792            �           1259    25298 '   poly_stats_9_285_38543_valid_pixels_idx    INDEX     r   CREATE INDEX poly_stats_9_285_38543_valid_pixels_idx ON public.poly_stats_9_285_38543 USING btree (valid_pixels);
 ;   DROP INDEX public.poly_stats_9_285_38543_valid_pixels_idx;
       public         	   statsuser    false    289    289    4793            �           1259    18279    product_file_date_idx    INDEX     W   CREATE INDEX product_file_date_idx ON public.product_file USING btree (date, rt_flag);
 )   DROP INDEX public.product_file_date_idx;
       public         	   statsuser    false    291    291            �           1259    18280    product_order_email_idx    INDEX     `   CREATE INDEX product_order_email_idx ON public.product_order USING btree (email, date_created);
 +   DROP INDEX public.product_order_email_idx;
       public         	   statsuser    false    299    299            �           1259    18281    sidx_stratification_geom    INDEX     W   CREATE INDEX sidx_stratification_geom ON public.stratification_geom USING gist (geom);
 ,   DROP INDEX public.sidx_stratification_geom;
       public         	   statsuser    false    301    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3            �           1259    18282    sidx_stratification_geom3857    INDEX     �   CREATE INDEX sidx_stratification_geom3857 ON public.stratification_geom USING gist (geom3857);

ALTER TABLE public.stratification_geom CLUSTER ON sidx_stratification_geom3857;
 0   DROP INDEX public.sidx_stratification_geom3857;
       public         	   statsuser    false    301    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3            �           0    0    poly_stats_10_1_257_pkey    INDEX ATTACH     T   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_10_1_257_pkey;
          public       	   statsuser    false    229    4795    4791    4791    229    228            �           0    0 ?   poly_stats_10_1_257_product_file_id_product_file_variable_i_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_10_1_257_product_file_id_product_file_variable_i_idx;
          public       	   statsuser    false    4796    4792    229    228            �           0    0 $   poly_stats_10_1_257_valid_pixels_idx    INDEX ATTACH     m   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_10_1_257_valid_pixels_idx;
          public       	   statsuser    false    4797    4793    229    228            �           0    0    poly_stats_10_257_279_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_10_257_279_pkey;
          public       	   statsuser    false    230    4799    4791    4791    230    228            �           0    0 ?   poly_stats_10_257_279_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_10_257_279_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4800    4792    230    228            �           0    0 &   poly_stats_10_257_279_valid_pixels_idx    INDEX ATTACH     o   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_10_257_279_valid_pixels_idx;
          public       	   statsuser    false    4801    4793    230    228            �           0    0    poly_stats_10_279_285_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_10_279_285_pkey;
          public       	   statsuser    false    4803    231    4791    4791    231    228            �           0    0 ?   poly_stats_10_279_285_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_10_279_285_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4804    4792    231    228            �           0    0 &   poly_stats_10_279_285_valid_pixels_idx    INDEX ATTACH     o   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_10_279_285_valid_pixels_idx;
          public       	   statsuser    false    4805    4793    231    228            �           0    0    poly_stats_10_285_38543_pkey    INDEX ATTACH     X   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_10_285_38543_pkey;
          public       	   statsuser    false    4791    232    4807    4791    232    228            �           0    0 ?   poly_stats_10_285_38543_product_file_id_product_file_variab_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_10_285_38543_product_file_id_product_file_variab_idx;
          public       	   statsuser    false    4808    4792    232    228            �           0    0 (   poly_stats_10_285_38543_valid_pixels_idx    INDEX ATTACH     q   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_10_285_38543_valid_pixels_idx;
          public       	   statsuser    false    4809    4793    232    228            �           0    0    poly_stats_12_1_257_pkey    INDEX ATTACH     T   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_12_1_257_pkey;
          public       	   statsuser    false    4791    4811    233    4791    233    228            �           0    0 ?   poly_stats_12_1_257_product_file_id_product_file_variable_i_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_12_1_257_product_file_id_product_file_variable_i_idx;
          public       	   statsuser    false    4812    4792    233    228            �           0    0 $   poly_stats_12_1_257_valid_pixels_idx    INDEX ATTACH     m   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_12_1_257_valid_pixels_idx;
          public       	   statsuser    false    4813    4793    233    228            �           0    0    poly_stats_12_257_279_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_12_257_279_pkey;
          public       	   statsuser    false    4815    234    4791    4791    234    228            �           0    0 ?   poly_stats_12_257_279_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_12_257_279_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4816    4792    234    228            �           0    0 &   poly_stats_12_257_279_valid_pixels_idx    INDEX ATTACH     o   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_12_257_279_valid_pixels_idx;
          public       	   statsuser    false    4817    4793    234    228            �           0    0    poly_stats_12_279_285_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_12_279_285_pkey;
          public       	   statsuser    false    235    4819    4791    4791    235    228            �           0    0 ?   poly_stats_12_279_285_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_12_279_285_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4820    4792    235    228            �           0    0 &   poly_stats_12_279_285_valid_pixels_idx    INDEX ATTACH     o   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_12_279_285_valid_pixels_idx;
          public       	   statsuser    false    4821    4793    235    228            �           0    0    poly_stats_12_285_38543_pkey    INDEX ATTACH     X   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_12_285_38543_pkey;
          public       	   statsuser    false    4791    236    4823    4791    236    228            �           0    0 ?   poly_stats_12_285_38543_product_file_id_product_file_variab_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_12_285_38543_product_file_id_product_file_variab_idx;
          public       	   statsuser    false    4824    4792    236    228            �           0    0 (   poly_stats_12_285_38543_valid_pixels_idx    INDEX ATTACH     q   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_12_285_38543_valid_pixels_idx;
          public       	   statsuser    false    4825    4793    236    228            �           0    0    poly_stats_14_1_257_pkey    INDEX ATTACH     T   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_14_1_257_pkey;
          public       	   statsuser    false    237    4791    4827    4791    237    228            �           0    0 ?   poly_stats_14_1_257_product_file_id_product_file_variable_i_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_14_1_257_product_file_id_product_file_variable_i_idx;
          public       	   statsuser    false    4828    4792    237    228            �           0    0 $   poly_stats_14_1_257_valid_pixels_idx    INDEX ATTACH     m   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_14_1_257_valid_pixels_idx;
          public       	   statsuser    false    4829    4793    237    228            �           0    0    poly_stats_14_257_279_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_14_257_279_pkey;
          public       	   statsuser    false    4831    238    4791    4791    238    228            �           0    0 ?   poly_stats_14_257_279_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_14_257_279_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4832    4792    238    228            �           0    0 &   poly_stats_14_257_279_valid_pixels_idx    INDEX ATTACH     o   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_14_257_279_valid_pixels_idx;
          public       	   statsuser    false    4833    4793    238    228            �           0    0    poly_stats_14_279_285_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_14_279_285_pkey;
          public       	   statsuser    false    4791    239    4835    4791    239    228            �           0    0 ?   poly_stats_14_279_285_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_14_279_285_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4836    4792    239    228            �           0    0 &   poly_stats_14_279_285_valid_pixels_idx    INDEX ATTACH     o   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_14_279_285_valid_pixels_idx;
          public       	   statsuser    false    4837    4793    239    228            �           0    0    poly_stats_14_285_38543_pkey    INDEX ATTACH     X   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_14_285_38543_pkey;
          public       	   statsuser    false    240    4791    4839    4791    240    228            �           0    0 ?   poly_stats_14_285_38543_product_file_id_product_file_variab_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_14_285_38543_product_file_id_product_file_variab_idx;
          public       	   statsuser    false    4840    4792    240    228            �           0    0 (   poly_stats_14_285_38543_valid_pixels_idx    INDEX ATTACH     q   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_14_285_38543_valid_pixels_idx;
          public       	   statsuser    false    4841    4793    240    228            �           0    0    poly_stats_16_1_257_pkey    INDEX ATTACH     T   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_16_1_257_pkey;
          public       	   statsuser    false    241    4843    4791    4791    241    228            �           0    0 ?   poly_stats_16_1_257_product_file_id_product_file_variable_i_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_16_1_257_product_file_id_product_file_variable_i_idx;
          public       	   statsuser    false    4844    4792    241    228            �           0    0 $   poly_stats_16_1_257_valid_pixels_idx    INDEX ATTACH     m   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_16_1_257_valid_pixels_idx;
          public       	   statsuser    false    4845    4793    241    228            �           0    0    poly_stats_16_257_279_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_16_257_279_pkey;
          public       	   statsuser    false    4791    242    4847    4791    242    228            �           0    0 ?   poly_stats_16_257_279_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_16_257_279_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4848    4792    242    228            �           0    0 &   poly_stats_16_257_279_valid_pixels_idx    INDEX ATTACH     o   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_16_257_279_valid_pixels_idx;
          public       	   statsuser    false    4849    4793    242    228                        0    0    poly_stats_16_279_285_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_16_279_285_pkey;
          public       	   statsuser    false    243    4851    4791    4791    243    228                       0    0 ?   poly_stats_16_279_285_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_16_279_285_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4852    4792    243    228                       0    0 &   poly_stats_16_279_285_valid_pixels_idx    INDEX ATTACH     o   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_16_279_285_valid_pixels_idx;
          public       	   statsuser    false    4853    4793    243    228                       0    0    poly_stats_16_285_38543_pkey    INDEX ATTACH     X   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_16_285_38543_pkey;
          public       	   statsuser    false    244    4855    4791    4791    244    228                       0    0 ?   poly_stats_16_285_38543_product_file_id_product_file_variab_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_16_285_38543_product_file_id_product_file_variab_idx;
          public       	   statsuser    false    4856    4792    244    228                       0    0 (   poly_stats_16_285_38543_valid_pixels_idx    INDEX ATTACH     q   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_16_285_38543_valid_pixels_idx;
          public       	   statsuser    false    4857    4793    244    228                       0    0    poly_stats_17_1_257_pkey    INDEX ATTACH     T   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_17_1_257_pkey;
          public       	   statsuser    false    245    4859    4791    4791    245    228                       0    0 ?   poly_stats_17_1_257_product_file_id_product_file_variable_i_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_17_1_257_product_file_id_product_file_variable_i_idx;
          public       	   statsuser    false    4860    4792    245    228                       0    0 $   poly_stats_17_1_257_valid_pixels_idx    INDEX ATTACH     m   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_17_1_257_valid_pixels_idx;
          public       	   statsuser    false    4861    4793    245    228            	           0    0    poly_stats_17_257_279_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_17_257_279_pkey;
          public       	   statsuser    false    4791    4863    246    4791    246    228            
           0    0 ?   poly_stats_17_257_279_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_17_257_279_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4864    4792    246    228                       0    0 &   poly_stats_17_257_279_valid_pixels_idx    INDEX ATTACH     o   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_17_257_279_valid_pixels_idx;
          public       	   statsuser    false    4865    4793    246    228                       0    0    poly_stats_17_279_285_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_17_279_285_pkey;
          public       	   statsuser    false    4867    247    4791    4791    247    228                       0    0 ?   poly_stats_17_279_285_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_17_279_285_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4868    4792    247    228                       0    0 &   poly_stats_17_279_285_valid_pixels_idx    INDEX ATTACH     o   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_17_279_285_valid_pixels_idx;
          public       	   statsuser    false    4869    4793    247    228                       0    0    poly_stats_17_285_38543_pkey    INDEX ATTACH     X   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_17_285_38543_pkey;
          public       	   statsuser    false    4871    248    4791    4791    248    228                       0    0 ?   poly_stats_17_285_38543_product_file_id_product_file_variab_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_17_285_38543_product_file_id_product_file_variab_idx;
          public       	   statsuser    false    4872    4792    248    228                       0    0 (   poly_stats_17_285_38543_valid_pixels_idx    INDEX ATTACH     q   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_17_285_38543_valid_pixels_idx;
          public       	   statsuser    false    4873    4793    248    228                       0    0    poly_stats_19_1_257_pkey    INDEX ATTACH     T   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_19_1_257_pkey;
          public       	   statsuser    false    4791    249    4875    4791    249    228                       0    0 ?   poly_stats_19_1_257_product_file_id_product_file_variable_i_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_19_1_257_product_file_id_product_file_variable_i_idx;
          public       	   statsuser    false    4876    4792    249    228                       0    0 $   poly_stats_19_1_257_valid_pixels_idx    INDEX ATTACH     m   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_19_1_257_valid_pixels_idx;
          public       	   statsuser    false    4877    4793    249    228                       0    0    poly_stats_19_257_279_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_19_257_279_pkey;
          public       	   statsuser    false    4791    250    4879    4791    250    228                       0    0 ?   poly_stats_19_257_279_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_19_257_279_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4880    4792    250    228                       0    0 &   poly_stats_19_257_279_valid_pixels_idx    INDEX ATTACH     o   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_19_257_279_valid_pixels_idx;
          public       	   statsuser    false    4881    4793    250    228                       0    0    poly_stats_19_279_285_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_19_279_285_pkey;
          public       	   statsuser    false    4883    251    4791    4791    251    228                       0    0 ?   poly_stats_19_279_285_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_19_279_285_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4884    4792    251    228                       0    0 &   poly_stats_19_279_285_valid_pixels_idx    INDEX ATTACH     o   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_19_279_285_valid_pixels_idx;
          public       	   statsuser    false    4885    4793    251    228                       0    0    poly_stats_19_285_38543_pkey    INDEX ATTACH     X   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_19_285_38543_pkey;
          public       	   statsuser    false    4887    4791    252    4791    252    228                       0    0 ?   poly_stats_19_285_38543_product_file_id_product_file_variab_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_19_285_38543_product_file_id_product_file_variab_idx;
          public       	   statsuser    false    4888    4792    252    228                       0    0 (   poly_stats_19_285_38543_valid_pixels_idx    INDEX ATTACH     q   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_19_285_38543_valid_pixels_idx;
          public       	   statsuser    false    4889    4793    252    228                       0    0    poly_stats_1_1_257_pkey    INDEX ATTACH     S   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_1_1_257_pkey;
          public       	   statsuser    false    4891    4791    253    4791    253    228                       0    0 ?   poly_stats_1_1_257_product_file_id_product_file_variable_id_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_1_1_257_product_file_id_product_file_variable_id_idx;
          public       	   statsuser    false    4892    4792    253    228                        0    0 #   poly_stats_1_1_257_valid_pixels_idx    INDEX ATTACH     l   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_1_1_257_valid_pixels_idx;
          public       	   statsuser    false    4893    4793    253    228            !           0    0    poly_stats_1_257_279_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_1_257_279_pkey;
          public       	   statsuser    false    4895    4791    254    4791    254    228            "           0    0 ?   poly_stats_1_257_279_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_1_257_279_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4896    4792    254    228            #           0    0 %   poly_stats_1_257_279_valid_pixels_idx    INDEX ATTACH     n   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_1_257_279_valid_pixels_idx;
          public       	   statsuser    false    4897    4793    254    228            $           0    0    poly_stats_1_279_285_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_1_279_285_pkey;
          public       	   statsuser    false    4791    4899    255    4791    255    228            %           0    0 ?   poly_stats_1_279_285_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_1_279_285_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4900    4792    255    228            &           0    0 %   poly_stats_1_279_285_valid_pixels_idx    INDEX ATTACH     n   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_1_279_285_valid_pixels_idx;
          public       	   statsuser    false    4901    4793    255    228            '           0    0    poly_stats_1_285_38543_pkey    INDEX ATTACH     W   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_1_285_38543_pkey;
          public       	   statsuser    false    256    4791    4903    4791    256    228            (           0    0 ?   poly_stats_1_285_38543_product_file_id_product_file_variabl_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_1_285_38543_product_file_id_product_file_variabl_idx;
          public       	   statsuser    false    4904    4792    256    228            )           0    0 '   poly_stats_1_285_38543_valid_pixels_idx    INDEX ATTACH     p   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_1_285_38543_valid_pixels_idx;
          public       	   statsuser    false    4905    4793    256    228            *           0    0    poly_stats_21_1_257_pkey    INDEX ATTACH     T   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_21_1_257_pkey;
          public       	   statsuser    false    4907    257    4791    4791    257    228            +           0    0 ?   poly_stats_21_1_257_product_file_id_product_file_variable_i_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_21_1_257_product_file_id_product_file_variable_i_idx;
          public       	   statsuser    false    4908    4792    257    228            ,           0    0 $   poly_stats_21_1_257_valid_pixels_idx    INDEX ATTACH     m   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_21_1_257_valid_pixels_idx;
          public       	   statsuser    false    4909    4793    257    228            -           0    0    poly_stats_21_257_279_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_21_257_279_pkey;
          public       	   statsuser    false    258    4791    4911    4791    258    228            .           0    0 ?   poly_stats_21_257_279_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_21_257_279_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4912    4792    258    228            /           0    0 &   poly_stats_21_257_279_valid_pixels_idx    INDEX ATTACH     o   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_21_257_279_valid_pixels_idx;
          public       	   statsuser    false    4913    4793    258    228            0           0    0    poly_stats_21_279_285_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_21_279_285_pkey;
          public       	   statsuser    false    4791    259    4915    4791    259    228            1           0    0 ?   poly_stats_21_279_285_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_21_279_285_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4916    4792    259    228            2           0    0 &   poly_stats_21_279_285_valid_pixels_idx    INDEX ATTACH     o   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_21_279_285_valid_pixels_idx;
          public       	   statsuser    false    4917    4793    259    228            3           0    0    poly_stats_21_285_38543_pkey    INDEX ATTACH     X   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_21_285_38543_pkey;
          public       	   statsuser    false    260    4791    4919    4791    260    228            4           0    0 ?   poly_stats_21_285_38543_product_file_id_product_file_variab_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_21_285_38543_product_file_id_product_file_variab_idx;
          public       	   statsuser    false    4920    4792    260    228            5           0    0 (   poly_stats_21_285_38543_valid_pixels_idx    INDEX ATTACH     q   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_21_285_38543_valid_pixels_idx;
          public       	   statsuser    false    4921    4793    260    228            6           0    0    poly_stats_24_1_257_pkey    INDEX ATTACH     T   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_24_1_257_pkey;
          public       	   statsuser    false    4923    4791    261    4791    261    228            7           0    0 ?   poly_stats_24_1_257_product_file_id_product_file_variable_i_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_24_1_257_product_file_id_product_file_variable_i_idx;
          public       	   statsuser    false    4924    4792    261    228            8           0    0 $   poly_stats_24_1_257_valid_pixels_idx    INDEX ATTACH     m   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_24_1_257_valid_pixels_idx;
          public       	   statsuser    false    4925    4793    261    228            �           0    0    poly_stats_25_1_2_pkey    INDEX ATTACH     R   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_25_1_2_pkey;
          public       	   statsuser    false    5069    4791    309    4791    309    228            �           0    0 >   poly_stats_25_1_2_product_file_id_product_file_variable_id_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_25_1_2_product_file_id_product_file_variable_id_idx;
          public       	   statsuser    false    5070    4792    309    228            �           0    0 "   poly_stats_25_1_2_valid_pixels_idx    INDEX ATTACH     k   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_25_1_2_valid_pixels_idx;
          public       	   statsuser    false    5071    4793    309    228            �           0    0    poly_stats_25_2_257_pkey    INDEX ATTACH     T   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_25_2_257_pkey;
          public       	   statsuser    false    310    5073    4791    4791    310    228            �           0    0 ?   poly_stats_25_2_257_product_file_id_product_file_variable_i_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_25_2_257_product_file_id_product_file_variable_i_idx;
          public       	   statsuser    false    5074    4792    310    228            �           0    0 $   poly_stats_25_2_257_valid_pixels_idx    INDEX ATTACH     m   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_25_2_257_valid_pixels_idx;
          public       	   statsuser    false    5075    4793    310    228            9           0    0    poly_stats_2_1_257_pkey    INDEX ATTACH     S   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_2_1_257_pkey;
          public       	   statsuser    false    4927    262    4791    4791    262    228            :           0    0 ?   poly_stats_2_1_257_product_file_id_product_file_variable_id_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_2_1_257_product_file_id_product_file_variable_id_idx;
          public       	   statsuser    false    4928    4792    262    228            ;           0    0 #   poly_stats_2_1_257_valid_pixels_idx    INDEX ATTACH     l   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_2_1_257_valid_pixels_idx;
          public       	   statsuser    false    4929    4793    262    228            <           0    0    poly_stats_2_257_279_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_2_257_279_pkey;
          public       	   statsuser    false    4931    263    4791    4791    263    228            =           0    0 ?   poly_stats_2_257_279_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_2_257_279_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4932    4792    263    228            >           0    0 %   poly_stats_2_257_279_valid_pixels_idx    INDEX ATTACH     n   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_2_257_279_valid_pixels_idx;
          public       	   statsuser    false    4933    4793    263    228            ?           0    0    poly_stats_2_279_285_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_2_279_285_pkey;
          public       	   statsuser    false    4791    264    4935    4791    264    228            @           0    0 ?   poly_stats_2_279_285_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_2_279_285_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4936    4792    264    228            A           0    0 %   poly_stats_2_279_285_valid_pixels_idx    INDEX ATTACH     n   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_2_279_285_valid_pixels_idx;
          public       	   statsuser    false    4937    4793    264    228            B           0    0    poly_stats_2_285_38543_pkey    INDEX ATTACH     W   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_2_285_38543_pkey;
          public       	   statsuser    false    4791    265    4939    4791    265    228            C           0    0 ?   poly_stats_2_285_38543_product_file_id_product_file_variabl_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_2_285_38543_product_file_id_product_file_variabl_idx;
          public       	   statsuser    false    4940    4792    265    228            D           0    0 '   poly_stats_2_285_38543_valid_pixels_idx    INDEX ATTACH     p   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_2_285_38543_valid_pixels_idx;
          public       	   statsuser    false    4941    4793    265    228            E           0    0    poly_stats_3_1_257_pkey    INDEX ATTACH     S   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_3_1_257_pkey;
          public       	   statsuser    false    4791    266    4943    4791    266    228            F           0    0 ?   poly_stats_3_1_257_product_file_id_product_file_variable_id_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_3_1_257_product_file_id_product_file_variable_id_idx;
          public       	   statsuser    false    4944    4792    266    228            G           0    0 #   poly_stats_3_1_257_valid_pixels_idx    INDEX ATTACH     l   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_3_1_257_valid_pixels_idx;
          public       	   statsuser    false    4945    4793    266    228            H           0    0    poly_stats_3_257_279_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_3_257_279_pkey;
          public       	   statsuser    false    4791    4947    267    4791    267    228            I           0    0 ?   poly_stats_3_257_279_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_3_257_279_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4948    4792    267    228            J           0    0 %   poly_stats_3_257_279_valid_pixels_idx    INDEX ATTACH     n   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_3_257_279_valid_pixels_idx;
          public       	   statsuser    false    4949    4793    267    228            K           0    0    poly_stats_3_279_285_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_3_279_285_pkey;
          public       	   statsuser    false    4791    268    4951    4791    268    228            L           0    0 ?   poly_stats_3_279_285_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_3_279_285_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4952    4792    268    228            M           0    0 %   poly_stats_3_279_285_valid_pixels_idx    INDEX ATTACH     n   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_3_279_285_valid_pixels_idx;
          public       	   statsuser    false    4953    4793    268    228            N           0    0    poly_stats_3_285_38543_pkey    INDEX ATTACH     W   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_3_285_38543_pkey;
          public       	   statsuser    false    4791    4955    269    4791    269    228            O           0    0 ?   poly_stats_3_285_38543_product_file_id_product_file_variabl_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_3_285_38543_product_file_id_product_file_variabl_idx;
          public       	   statsuser    false    4956    4792    269    228            P           0    0 '   poly_stats_3_285_38543_valid_pixels_idx    INDEX ATTACH     p   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_3_285_38543_valid_pixels_idx;
          public       	   statsuser    false    4957    4793    269    228            Q           0    0    poly_stats_4_1_257_pkey    INDEX ATTACH     S   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_4_1_257_pkey;
          public       	   statsuser    false    4959    4791    270    4791    270    228            R           0    0 ?   poly_stats_4_1_257_product_file_id_product_file_variable_id_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_4_1_257_product_file_id_product_file_variable_id_idx;
          public       	   statsuser    false    4960    4792    270    228            S           0    0 #   poly_stats_4_1_257_valid_pixels_idx    INDEX ATTACH     l   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_4_1_257_valid_pixels_idx;
          public       	   statsuser    false    4961    4793    270    228            T           0    0    poly_stats_4_257_279_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_4_257_279_pkey;
          public       	   statsuser    false    271    4791    4963    4791    271    228            U           0    0 ?   poly_stats_4_257_279_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_4_257_279_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4964    4792    271    228            V           0    0 %   poly_stats_4_257_279_valid_pixels_idx    INDEX ATTACH     n   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_4_257_279_valid_pixels_idx;
          public       	   statsuser    false    4965    4793    271    228            W           0    0    poly_stats_4_279_285_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_4_279_285_pkey;
          public       	   statsuser    false    272    4967    4791    4791    272    228            X           0    0 ?   poly_stats_4_279_285_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_4_279_285_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4968    4792    272    228            Y           0    0 %   poly_stats_4_279_285_valid_pixels_idx    INDEX ATTACH     n   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_4_279_285_valid_pixels_idx;
          public       	   statsuser    false    4969    4793    272    228            Z           0    0    poly_stats_4_285_38543_pkey    INDEX ATTACH     W   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_4_285_38543_pkey;
          public       	   statsuser    false    4791    4971    273    4791    273    228            [           0    0 ?   poly_stats_4_285_38543_product_file_id_product_file_variabl_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_4_285_38543_product_file_id_product_file_variabl_idx;
          public       	   statsuser    false    4972    4792    273    228            \           0    0 '   poly_stats_4_285_38543_valid_pixels_idx    INDEX ATTACH     p   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_4_285_38543_valid_pixels_idx;
          public       	   statsuser    false    4973    4793    273    228            ]           0    0    poly_stats_5_1_257_pkey    INDEX ATTACH     S   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_5_1_257_pkey;
          public       	   statsuser    false    4975    274    4791    4791    274    228            ^           0    0 ?   poly_stats_5_1_257_product_file_id_product_file_variable_id_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_5_1_257_product_file_id_product_file_variable_id_idx;
          public       	   statsuser    false    4976    4792    274    228            _           0    0 #   poly_stats_5_1_257_valid_pixels_idx    INDEX ATTACH     l   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_5_1_257_valid_pixels_idx;
          public       	   statsuser    false    4977    4793    274    228            `           0    0    poly_stats_5_257_279_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_5_257_279_pkey;
          public       	   statsuser    false    275    4979    4791    4791    275    228            a           0    0 ?   poly_stats_5_257_279_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_5_257_279_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4980    4792    275    228            b           0    0 %   poly_stats_5_257_279_valid_pixels_idx    INDEX ATTACH     n   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_5_257_279_valid_pixels_idx;
          public       	   statsuser    false    4981    4793    275    228            c           0    0    poly_stats_5_279_285_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_5_279_285_pkey;
          public       	   statsuser    false    276    4791    4983    4791    276    228            d           0    0 ?   poly_stats_5_279_285_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_5_279_285_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4984    4792    276    228            e           0    0 %   poly_stats_5_279_285_valid_pixels_idx    INDEX ATTACH     n   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_5_279_285_valid_pixels_idx;
          public       	   statsuser    false    4985    4793    276    228            f           0    0    poly_stats_5_285_38543_pkey    INDEX ATTACH     W   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_5_285_38543_pkey;
          public       	   statsuser    false    277    4791    4987    4791    277    228            g           0    0 ?   poly_stats_5_285_38543_product_file_id_product_file_variabl_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_5_285_38543_product_file_id_product_file_variabl_idx;
          public       	   statsuser    false    4988    4792    277    228            h           0    0 '   poly_stats_5_285_38543_valid_pixels_idx    INDEX ATTACH     p   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_5_285_38543_valid_pixels_idx;
          public       	   statsuser    false    4989    4793    277    228            i           0    0    poly_stats_6_1_257_pkey    INDEX ATTACH     S   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_6_1_257_pkey;
          public       	   statsuser    false    4791    278    4991    4791    278    228            j           0    0 ?   poly_stats_6_1_257_product_file_id_product_file_variable_id_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_6_1_257_product_file_id_product_file_variable_id_idx;
          public       	   statsuser    false    4992    4792    278    228            k           0    0 #   poly_stats_6_1_257_valid_pixels_idx    INDEX ATTACH     l   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_6_1_257_valid_pixels_idx;
          public       	   statsuser    false    4993    4793    278    228            l           0    0    poly_stats_6_257_279_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_6_257_279_pkey;
          public       	   statsuser    false    279    4791    4995    4791    279    228            m           0    0 ?   poly_stats_6_257_279_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_6_257_279_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4996    4792    279    228            n           0    0 %   poly_stats_6_257_279_valid_pixels_idx    INDEX ATTACH     n   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_6_257_279_valid_pixels_idx;
          public       	   statsuser    false    4997    4793    279    228            o           0    0    poly_stats_6_279_285_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_6_279_285_pkey;
          public       	   statsuser    false    4999    4791    280    4791    280    228            p           0    0 ?   poly_stats_6_279_285_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_6_279_285_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    5000    4792    280    228            q           0    0 %   poly_stats_6_279_285_valid_pixels_idx    INDEX ATTACH     n   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_6_279_285_valid_pixels_idx;
          public       	   statsuser    false    5001    4793    280    228            r           0    0    poly_stats_6_285_38543_pkey    INDEX ATTACH     W   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_6_285_38543_pkey;
          public       	   statsuser    false    5003    281    4791    4791    281    228            s           0    0 ?   poly_stats_6_285_38543_product_file_id_product_file_variabl_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_6_285_38543_product_file_id_product_file_variabl_idx;
          public       	   statsuser    false    5004    4792    281    228            t           0    0 '   poly_stats_6_285_38543_valid_pixels_idx    INDEX ATTACH     p   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_6_285_38543_valid_pixels_idx;
          public       	   statsuser    false    5005    4793    281    228            u           0    0    poly_stats_7_1_257_pkey    INDEX ATTACH     S   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_7_1_257_pkey;
          public       	   statsuser    false    5007    282    4791    4791    282    228            v           0    0 ?   poly_stats_7_1_257_product_file_id_product_file_variable_id_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_7_1_257_product_file_id_product_file_variable_id_idx;
          public       	   statsuser    false    5008    4792    282    228            w           0    0 #   poly_stats_7_1_257_valid_pixels_idx    INDEX ATTACH     l   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_7_1_257_valid_pixels_idx;
          public       	   statsuser    false    5009    4793    282    228            x           0    0    poly_stats_7_257_279_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_7_257_279_pkey;
          public       	   statsuser    false    4791    283    5011    4791    283    228            y           0    0 ?   poly_stats_7_257_279_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_7_257_279_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    5012    4792    283    228            z           0    0 %   poly_stats_7_257_279_valid_pixels_idx    INDEX ATTACH     n   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_7_257_279_valid_pixels_idx;
          public       	   statsuser    false    5013    4793    283    228            {           0    0    poly_stats_7_279_285_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_7_279_285_pkey;
          public       	   statsuser    false    4791    284    5015    4791    284    228            |           0    0 ?   poly_stats_7_279_285_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_7_279_285_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    5016    4792    284    228            }           0    0 %   poly_stats_7_279_285_valid_pixels_idx    INDEX ATTACH     n   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_7_279_285_valid_pixels_idx;
          public       	   statsuser    false    5017    4793    284    228            ~           0    0    poly_stats_7_285_38543_pkey    INDEX ATTACH     W   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_7_285_38543_pkey;
          public       	   statsuser    false    285    4791    5019    4791    285    228                       0    0 ?   poly_stats_7_285_38543_product_file_id_product_file_variabl_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_7_285_38543_product_file_id_product_file_variabl_idx;
          public       	   statsuser    false    5020    4792    285    228            �           0    0 '   poly_stats_7_285_38543_valid_pixels_idx    INDEX ATTACH     p   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_7_285_38543_valid_pixels_idx;
          public       	   statsuser    false    5021    4793    285    228            �           0    0    poly_stats_9_1_257_pkey    INDEX ATTACH     S   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_9_1_257_pkey;
          public       	   statsuser    false    4791    5023    286    4791    286    228            �           0    0 ?   poly_stats_9_1_257_product_file_id_product_file_variable_id_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_9_1_257_product_file_id_product_file_variable_id_idx;
          public       	   statsuser    false    5024    4792    286    228            �           0    0 #   poly_stats_9_1_257_valid_pixels_idx    INDEX ATTACH     l   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_9_1_257_valid_pixels_idx;
          public       	   statsuser    false    5025    4793    286    228            �           0    0    poly_stats_9_257_279_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_9_257_279_pkey;
          public       	   statsuser    false    4791    5027    287    4791    287    228            �           0    0 ?   poly_stats_9_257_279_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_9_257_279_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    5028    4792    287    228            �           0    0 %   poly_stats_9_257_279_valid_pixels_idx    INDEX ATTACH     n   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_9_257_279_valid_pixels_idx;
          public       	   statsuser    false    5029    4793    287    228            �           0    0    poly_stats_9_279_285_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_9_279_285_pkey;
          public       	   statsuser    false    288    5031    4791    4791    288    228            �           0    0 ?   poly_stats_9_279_285_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_9_279_285_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    5032    4792    288    228            �           0    0 %   poly_stats_9_279_285_valid_pixels_idx    INDEX ATTACH     n   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_9_279_285_valid_pixels_idx;
          public       	   statsuser    false    5033    4793    288    228            �           0    0    poly_stats_9_285_38543_pkey    INDEX ATTACH     W   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_9_285_38543_pkey;
          public       	   statsuser    false    5035    289    4791    4791    289    228            �           0    0 ?   poly_stats_9_285_38543_product_file_id_product_file_variabl_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_9_285_38543_product_file_id_product_file_variabl_idx;
          public       	   statsuser    false    5036    4792    289    228            �           0    0 '   poly_stats_9_285_38543_valid_pixels_idx    INDEX ATTACH     p   ALTER INDEX public.poly_stats_valid_pixels_idx ATTACH PARTITION public.poly_stats_9_285_38543_valid_pixels_idx;
          public       	   statsuser    false    5037    4793    289    228            �           2606    18283 0   long_term_anomaly_info long_term_anomaly_info_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.long_term_anomaly_info
    ADD CONSTRAINT long_term_anomaly_info_fk FOREIGN KEY (anomaly_product_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 Z   ALTER TABLE ONLY public.long_term_anomaly_info DROP CONSTRAINT long_term_anomaly_info_fk;
       public       	   statsuser    false    225    5048    296            �           2606    18288 2   long_term_anomaly_info long_term_anomaly_info_fk_1    FK CONSTRAINT     �   ALTER TABLE ONLY public.long_term_anomaly_info
    ADD CONSTRAINT long_term_anomaly_info_fk_1 FOREIGN KEY (mean_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 \   ALTER TABLE ONLY public.long_term_anomaly_info DROP CONSTRAINT long_term_anomaly_info_fk_1;
       public       	   statsuser    false    296    225    5048            �           2606    18293 2   long_term_anomaly_info long_term_anomaly_info_fk_2    FK CONSTRAINT     �   ALTER TABLE ONLY public.long_term_anomaly_info
    ADD CONSTRAINT long_term_anomaly_info_fk_2 FOREIGN KEY (stdev_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 \   ALTER TABLE ONLY public.long_term_anomaly_info DROP CONSTRAINT long_term_anomaly_info_fk_2;
       public       	   statsuser    false    5048    225    296            �           2606    18298 2   long_term_anomaly_info long_term_anomaly_info_fk_3    FK CONSTRAINT     �   ALTER TABLE ONLY public.long_term_anomaly_info
    ADD CONSTRAINT long_term_anomaly_info_fk_3 FOREIGN KEY (raw_product_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 \   ALTER TABLE ONLY public.long_term_anomaly_info DROP CONSTRAINT long_term_anomaly_info_fk_3;
       public       	   statsuser    false    5048    225    296            �           2606    18303 &   poly_stats poly_stats_product_file_fk_    FK CONSTRAINT     �   ALTER TABLE public.poly_stats
    ADD CONSTRAINT poly_stats_product_file_fk_ FOREIGN KEY (product_file_id) REFERENCES public.product_file(id) ON UPDATE CASCADE ON DELETE CASCADE;
 K   ALTER TABLE public.poly_stats DROP CONSTRAINT poly_stats_product_file_fk_;
       public       	   statsuser    false    5044    228    291            �           2606    18491 *   poly_stats poly_stats_product_variable_fk_    FK CONSTRAINT     �   ALTER TABLE public.poly_stats
    ADD CONSTRAINT poly_stats_product_variable_fk_ FOREIGN KEY (product_file_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 O   ALTER TABLE public.poly_stats DROP CONSTRAINT poly_stats_product_variable_fk_;
       public       	   statsuser    false    228    5048    296            �           2606    18679 -   poly_stats poly_stats_stratification_geom_fk_    FK CONSTRAINT     �   ALTER TABLE public.poly_stats
    ADD CONSTRAINT poly_stats_stratification_geom_fk_ FOREIGN KEY (poly_id) REFERENCES public.stratification_geom(id) ON UPDATE CASCADE ON DELETE CASCADE;
 R   ALTER TABLE public.poly_stats DROP CONSTRAINT poly_stats_stratification_geom_fk_;
       public       	   statsuser    false    301    5059    228            �           2606    18867 4   product_file_description product_file_description_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.product_file_description
    ADD CONSTRAINT product_file_description_fk FOREIGN KEY (product_id) REFERENCES public.product(id) ON UPDATE CASCADE ON DELETE CASCADE;
 ^   ALTER TABLE ONLY public.product_file_description DROP CONSTRAINT product_file_description_fk;
       public       	   statsuser    false    292    290    5039            �           2606    55131 5   product_file product_file_product_file_description_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.product_file
    ADD CONSTRAINT product_file_product_file_description_fk FOREIGN KEY (product_file_description_id) REFERENCES public.product_file_description(id) ON UPDATE CASCADE ON DELETE CASCADE;
 _   ALTER TABLE ONLY public.product_file DROP CONSTRAINT product_file_product_file_description_fk;
       public       	   statsuser    false    5046    292    291            �           2606    18872    product product_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_fk FOREIGN KEY (category_id) REFERENCES public.category(id) ON UPDATE CASCADE ON DELETE CASCADE;
 <   ALTER TABLE ONLY public.product DROP CONSTRAINT product_fk;
       public       	   statsuser    false    4787    290    223            �           2606    18877 *   stratification_geom stratification_geom_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.stratification_geom
    ADD CONSTRAINT stratification_geom_fk FOREIGN KEY (stratification_id) REFERENCES public.stratification(id) ON DELETE CASCADE;
 T   ALTER TABLE ONLY public.stratification_geom DROP CONSTRAINT stratification_geom_fk;
       public       	   statsuser    false    300    5053    301            �           2606    18882    wms_file wms_file_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.wms_file
    ADD CONSTRAINT wms_file_fk FOREIGN KEY (product_file_id) REFERENCES public.product_file(id) ON UPDATE CASCADE ON DELETE CASCADE;
 >   ALTER TABLE ONLY public.wms_file DROP CONSTRAINT wms_file_fk;
       public       	   statsuser    false    305    291    5044            �           2606    18887    wms_file wms_file_fk2    FK CONSTRAINT     �   ALTER TABLE ONLY public.wms_file
    ADD CONSTRAINT wms_file_fk2 FOREIGN KEY (product_file_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 ?   ALTER TABLE ONLY public.wms_file DROP CONSTRAINT wms_file_fk2;
       public       	   statsuser    false    296    5048    305            �           2606    18892 0   poly_stats_per_region poly_stats_product_file_fk    FK CONSTRAINT     �   ALTER TABLE ONLY tmp.poly_stats_per_region
    ADD CONSTRAINT poly_stats_product_file_fk FOREIGN KEY (product_file_id) REFERENCES public.product_file(id) ON UPDATE CASCADE ON DELETE CASCADE;
 W   ALTER TABLE ONLY tmp.poly_stats_per_region DROP CONSTRAINT poly_stats_product_file_fk;
       tmp       	   statsuser    false    291    5044    307            �           2606    18897 9   poly_stats_per_region poly_stats_product_file_variable_fk    FK CONSTRAINT     �   ALTER TABLE ONLY tmp.poly_stats_per_region
    ADD CONSTRAINT poly_stats_product_file_variable_fk FOREIGN KEY (product_file_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 `   ALTER TABLE ONLY tmp.poly_stats_per_region DROP CONSTRAINT poly_stats_product_file_variable_fk;
       tmp       	   statsuser    false    5048    307    296            �           2606    18902 7   poly_stats_per_region poly_stats_stratification_geom_fk    FK CONSTRAINT     �   ALTER TABLE ONLY tmp.poly_stats_per_region
    ADD CONSTRAINT poly_stats_stratification_geom_fk FOREIGN KEY (poly_id) REFERENCES public.stratification_geom(id) ON UPDATE CASCADE ON DELETE CASCADE;
 ^   ALTER TABLE ONLY tmp.poly_stats_per_region DROP CONSTRAINT poly_stats_stratification_geom_fk;
       tmp       	   statsuser    false    307    5059    301           