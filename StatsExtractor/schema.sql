PGDMP                         {            cdse    15.4    15.4 O   +           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            ,           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            -           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            .           1262    186841    cdse    DATABASE     l   CREATE DATABASE cdse WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'C.UTF-8';
    DROP DATABASE cdse;
                postgres    false            /           0    0    SCHEMA pg_catalog    ACL     -   GRANT ALL ON SCHEMA pg_catalog TO statsuser;
                   postgres    false    6            0           0    0    SCHEMA public    ACL     )   GRANT ALL ON SCHEMA public TO statsuser;
                   pg_database_owner    false    4                        2615    186842    tmp    SCHEMA        CREATE SCHEMA tmp;
    DROP SCHEMA tmp;
                postgres    false            1           0    0 
   SCHEMA tmp    ACL     &   GRANT ALL ON SCHEMA tmp TO statsuser;
                   postgres    false    5                        3079    186843    fuzzystrmatch 	   EXTENSION     A   CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;
    DROP EXTENSION fuzzystrmatch;
                   false            2           0    0    EXTENSION fuzzystrmatch    COMMENT     ]   COMMENT ON EXTENSION fuzzystrmatch IS 'determine similarities and distance between strings';
                        false    2                        3079    186854    postgis 	   EXTENSION     ;   CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;
    DROP EXTENSION postgis;
                   false            3           0    0    EXTENSION postgis    COMMENT     ^   COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';
                        false    3                       1255    187898    clms_updatepolygonstats()    FUNCTION     �  CREATE FUNCTION public.clms_updatepolygonstats() RETURNS smallint
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
       public          postgres    false            4           0    0    TABLE pg_aggregate    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_aggregate TO statsuser;
       
   pg_catalog          postgres    false    26            5           0    0    TABLE pg_am    ACL     2   GRANT ALL ON TABLE pg_catalog.pg_am TO statsuser;
       
   pg_catalog          postgres    false    27            6           0    0    TABLE pg_amop    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_amop TO statsuser;
       
   pg_catalog          postgres    false    28            7           0    0    TABLE pg_amproc    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_amproc TO statsuser;
       
   pg_catalog          postgres    false    29            8           0    0    TABLE pg_attrdef    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_attrdef TO statsuser;
       
   pg_catalog          postgres    false    30            9           0    0    TABLE pg_attribute    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_attribute TO statsuser;
       
   pg_catalog          postgres    false    15            :           0    0    TABLE pg_auth_members    ACL     <   GRANT ALL ON TABLE pg_catalog.pg_auth_members TO statsuser;
       
   pg_catalog          postgres    false    19            ;           0    0    TABLE pg_authid    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_authid TO statsuser;
       
   pg_catalog          postgres    false    18            <           0    0 %   TABLE pg_available_extension_versions    ACL     L   GRANT ALL ON TABLE pg_catalog.pg_available_extension_versions TO statsuser;
       
   pg_catalog          postgres    false    93            =           0    0    TABLE pg_available_extensions    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_available_extensions TO statsuser;
       
   pg_catalog          postgres    false    92            >           0    0     TABLE pg_backend_memory_contexts    ACL     G   GRANT ALL ON TABLE pg_catalog.pg_backend_memory_contexts TO statsuser;
       
   pg_catalog          postgres    false    105            ?           0    0    TABLE pg_cast    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_cast TO statsuser;
       
   pg_catalog          postgres    false    31            @           0    0    TABLE pg_class    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_class TO statsuser;
       
   pg_catalog          postgres    false    17            A           0    0    TABLE pg_collation    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_collation TO statsuser;
       
   pg_catalog          postgres    false    56            B           0    0    TABLE pg_config    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_config TO statsuser;
       
   pg_catalog          postgres    false    103            C           0    0    TABLE pg_constraint    ACL     :   GRANT ALL ON TABLE pg_catalog.pg_constraint TO statsuser;
       
   pg_catalog          postgres    false    32            D           0    0    TABLE pg_conversion    ACL     :   GRANT ALL ON TABLE pg_catalog.pg_conversion TO statsuser;
       
   pg_catalog          postgres    false    33            E           0    0    TABLE pg_cursors    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_cursors TO statsuser;
       
   pg_catalog          postgres    false    91            F           0    0    TABLE pg_database    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_database TO statsuser;
       
   pg_catalog          postgres    false    20            G           0    0    TABLE pg_db_role_setting    ACL     ?   GRANT ALL ON TABLE pg_catalog.pg_db_role_setting TO statsuser;
       
   pg_catalog          postgres    false    47            H           0    0    TABLE pg_default_acl    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_default_acl TO statsuser;
       
   pg_catalog          postgres    false    11            I           0    0    TABLE pg_depend    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_depend TO statsuser;
       
   pg_catalog          postgres    false    34            J           0    0    TABLE pg_description    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_description TO statsuser;
       
   pg_catalog          postgres    false    35            K           0    0    TABLE pg_enum    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_enum TO statsuser;
       
   pg_catalog          postgres    false    58            L           0    0    TABLE pg_event_trigger    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_event_trigger TO statsuser;
       
   pg_catalog          postgres    false    57            M           0    0    TABLE pg_extension    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_extension TO statsuser;
       
   pg_catalog          postgres    false    49            N           0    0    TABLE pg_file_settings    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_file_settings TO statsuser;
       
   pg_catalog          postgres    false    98            O           0    0    TABLE pg_foreign_data_wrapper    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_foreign_data_wrapper TO statsuser;
       
   pg_catalog          postgres    false    24            P           0    0    TABLE pg_foreign_server    ACL     >   GRANT ALL ON TABLE pg_catalog.pg_foreign_server TO statsuser;
       
   pg_catalog          postgres    false    21            Q           0    0    TABLE pg_foreign_table    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_foreign_table TO statsuser;
       
   pg_catalog          postgres    false    50            R           0    0    TABLE pg_group    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_group TO statsuser;
       
   pg_catalog          postgres    false    77            S           0    0    TABLE pg_hba_file_rules    ACL     >   GRANT ALL ON TABLE pg_catalog.pg_hba_file_rules TO statsuser;
       
   pg_catalog          postgres    false    99            T           0    0    TABLE pg_ident_file_mappings    ACL     C   GRANT ALL ON TABLE pg_catalog.pg_ident_file_mappings TO statsuser;
       
   pg_catalog          postgres    false    100            U           0    0    TABLE pg_index    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_index TO statsuser;
       
   pg_catalog          postgres    false    36            V           0    0    TABLE pg_indexes    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_indexes TO statsuser;
       
   pg_catalog          postgres    false    84            W           0    0    TABLE pg_inherits    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_inherits TO statsuser;
       
   pg_catalog          postgres    false    37            X           0    0    TABLE pg_init_privs    ACL     :   GRANT ALL ON TABLE pg_catalog.pg_init_privs TO statsuser;
       
   pg_catalog          postgres    false    54            Y           0    0    TABLE pg_language    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_language TO statsuser;
       
   pg_catalog          postgres    false    38            Z           0    0    TABLE pg_largeobject    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_largeobject TO statsuser;
       
   pg_catalog          postgres    false    39            [           0    0    TABLE pg_largeobject_metadata    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_largeobject_metadata TO statsuser;
       
   pg_catalog          postgres    false    48            \           0    0    TABLE pg_locks    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_locks TO statsuser;
       
   pg_catalog          postgres    false    90            ]           0    0    TABLE pg_matviews    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_matviews TO statsuser;
       
   pg_catalog          postgres    false    83            ^           0    0    TABLE pg_namespace    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_namespace TO statsuser;
       
   pg_catalog          postgres    false    40            _           0    0    TABLE pg_opclass    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_opclass TO statsuser;
       
   pg_catalog          postgres    false    41            `           0    0    TABLE pg_operator    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_operator TO statsuser;
       
   pg_catalog          postgres    false    42            a           0    0    TABLE pg_opfamily    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_opfamily TO statsuser;
       
   pg_catalog          postgres    false    46            b           0    0    TABLE pg_parameter_acl    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_parameter_acl TO statsuser;
       
   pg_catalog          postgres    false    74            c           0    0    TABLE pg_partitioned_table    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_partitioned_table TO statsuser;
       
   pg_catalog          postgres    false    52            d           0    0    TABLE pg_policies    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_policies TO statsuser;
       
   pg_catalog          postgres    false    79            e           0    0    TABLE pg_policy    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_policy TO statsuser;
       
   pg_catalog          postgres    false    51            f           0    0    TABLE pg_prepared_statements    ACL     C   GRANT ALL ON TABLE pg_catalog.pg_prepared_statements TO statsuser;
       
   pg_catalog          postgres    false    95            g           0    0    TABLE pg_prepared_xacts    ACL     >   GRANT ALL ON TABLE pg_catalog.pg_prepared_xacts TO statsuser;
       
   pg_catalog          postgres    false    94            h           0    0    TABLE pg_proc    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_proc TO statsuser;
       
   pg_catalog          postgres    false    16            i           0    0    TABLE pg_publication    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_publication TO statsuser;
       
   pg_catalog          postgres    false    71            j           0    0    TABLE pg_publication_namespace    ACL     E   GRANT ALL ON TABLE pg_catalog.pg_publication_namespace TO statsuser;
       
   pg_catalog          postgres    false    73            k           0    0    TABLE pg_publication_rel    ACL     ?   GRANT ALL ON TABLE pg_catalog.pg_publication_rel TO statsuser;
       
   pg_catalog          postgres    false    72            l           0    0    TABLE pg_publication_tables    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_publication_tables TO statsuser;
       
   pg_catalog          postgres    false    89            m           0    0    TABLE pg_range    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_range TO statsuser;
       
   pg_catalog          postgres    false    59            n           0    0    TABLE pg_replication_origin    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_replication_origin TO statsuser;
       
   pg_catalog          postgres    false    68            o           0    0 "   TABLE pg_replication_origin_status    ACL     I   GRANT ALL ON TABLE pg_catalog.pg_replication_origin_status TO statsuser;
       
   pg_catalog          postgres    false    148            p           0    0    TABLE pg_replication_slots    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_replication_slots TO statsuser;
       
   pg_catalog          postgres    false    132            q           0    0    TABLE pg_rewrite    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_rewrite TO statsuser;
       
   pg_catalog          postgres    false    43            r           0    0    TABLE pg_roles    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_roles TO statsuser;
       
   pg_catalog          postgres    false    75            s           0    0    TABLE pg_rules    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_rules TO statsuser;
       
   pg_catalog          postgres    false    80            t           0    0    TABLE pg_seclabel    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_seclabel TO statsuser;
       
   pg_catalog          postgres    false    62            u           0    0    TABLE pg_seclabels    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_seclabels TO statsuser;
       
   pg_catalog          postgres    false    96            v           0    0    TABLE pg_sequence    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_sequence TO statsuser;
       
   pg_catalog          postgres    false    23            w           0    0    TABLE pg_sequences    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_sequences TO statsuser;
       
   pg_catalog          postgres    false    85            x           0    0    TABLE pg_settings    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_settings TO statsuser;
       
   pg_catalog          postgres    false    97            y           0    0    TABLE pg_shadow    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_shadow TO statsuser;
       
   pg_catalog          postgres    false    76            z           0    0    TABLE pg_shdepend    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_shdepend TO statsuser;
       
   pg_catalog          postgres    false    13            {           0    0    TABLE pg_shdescription    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_shdescription TO statsuser;
       
   pg_catalog          postgres    false    25            |           0    0    TABLE pg_shmem_allocations    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_shmem_allocations TO statsuser;
       
   pg_catalog          postgres    false    104            }           0    0    TABLE pg_shseclabel    ACL     :   GRANT ALL ON TABLE pg_catalog.pg_shseclabel TO statsuser;
       
   pg_catalog          postgres    false    61            ~           0    0    TABLE pg_stat_activity    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_stat_activity TO statsuser;
       
   pg_catalog          postgres    false    124                       0    0    TABLE pg_stat_all_indexes    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_stat_all_indexes TO statsuser;
       
   pg_catalog          postgres    false    115            �           0    0    TABLE pg_stat_all_tables    ACL     ?   GRANT ALL ON TABLE pg_catalog.pg_stat_all_tables TO statsuser;
       
   pg_catalog          postgres    false    106            �           0    0    TABLE pg_stat_archiver    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_stat_archiver TO statsuser;
       
   pg_catalog          postgres    false    138            �           0    0    TABLE pg_stat_bgwriter    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_stat_bgwriter TO statsuser;
       
   pg_catalog          postgres    false    139            �           0    0    TABLE pg_stat_database    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_stat_database TO statsuser;
       
   pg_catalog          postgres    false    134            �           0    0     TABLE pg_stat_database_conflicts    ACL     G   GRANT ALL ON TABLE pg_catalog.pg_stat_database_conflicts TO statsuser;
       
   pg_catalog          postgres    false    135            �           0    0    TABLE pg_stat_gssapi    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_stat_gssapi TO statsuser;
       
   pg_catalog          postgres    false    131            �           0    0    TABLE pg_stat_progress_analyze    ACL     E   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_analyze TO statsuser;
       
   pg_catalog          postgres    false    141            �           0    0 !   TABLE pg_stat_progress_basebackup    ACL     H   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_basebackup TO statsuser;
       
   pg_catalog          postgres    false    145            �           0    0    TABLE pg_stat_progress_cluster    ACL     E   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_cluster TO statsuser;
       
   pg_catalog          postgres    false    143            �           0    0    TABLE pg_stat_progress_copy    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_copy TO statsuser;
       
   pg_catalog          postgres    false    146            �           0    0 #   TABLE pg_stat_progress_create_index    ACL     J   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_create_index TO statsuser;
       
   pg_catalog          postgres    false    144            �           0    0    TABLE pg_stat_progress_vacuum    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_vacuum TO statsuser;
       
   pg_catalog          postgres    false    142            �           0    0    TABLE pg_stat_recovery_prefetch    ACL     F   GRANT ALL ON TABLE pg_catalog.pg_stat_recovery_prefetch TO statsuser;
       
   pg_catalog          postgres    false    128            �           0    0    TABLE pg_stat_replication    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_stat_replication TO statsuser;
       
   pg_catalog          postgres    false    125            �           0    0    TABLE pg_stat_replication_slots    ACL     F   GRANT ALL ON TABLE pg_catalog.pg_stat_replication_slots TO statsuser;
       
   pg_catalog          postgres    false    133            �           0    0    TABLE pg_stat_slru    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_stat_slru TO statsuser;
       
   pg_catalog          postgres    false    126            �           0    0    TABLE pg_stat_ssl    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_stat_ssl TO statsuser;
       
   pg_catalog          postgres    false    130            �           0    0    TABLE pg_stat_subscription    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_stat_subscription TO statsuser;
       
   pg_catalog          postgres    false    129            �           0    0     TABLE pg_stat_subscription_stats    ACL     G   GRANT ALL ON TABLE pg_catalog.pg_stat_subscription_stats TO statsuser;
       
   pg_catalog          postgres    false    149            �           0    0    TABLE pg_stat_sys_indexes    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_stat_sys_indexes TO statsuser;
       
   pg_catalog          postgres    false    116            �           0    0    TABLE pg_stat_sys_tables    ACL     ?   GRANT ALL ON TABLE pg_catalog.pg_stat_sys_tables TO statsuser;
       
   pg_catalog          postgres    false    108            �           0    0    TABLE pg_stat_user_functions    ACL     C   GRANT ALL ON TABLE pg_catalog.pg_stat_user_functions TO statsuser;
       
   pg_catalog          postgres    false    136            �           0    0    TABLE pg_stat_user_indexes    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_stat_user_indexes TO statsuser;
       
   pg_catalog          postgres    false    117            �           0    0    TABLE pg_stat_user_tables    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_stat_user_tables TO statsuser;
       
   pg_catalog          postgres    false    110            �           0    0    TABLE pg_stat_wal    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_stat_wal TO statsuser;
       
   pg_catalog          postgres    false    140            �           0    0    TABLE pg_stat_wal_receiver    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_stat_wal_receiver TO statsuser;
       
   pg_catalog          postgres    false    127            �           0    0    TABLE pg_stat_xact_all_tables    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_stat_xact_all_tables TO statsuser;
       
   pg_catalog          postgres    false    107            �           0    0    TABLE pg_stat_xact_sys_tables    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_stat_xact_sys_tables TO statsuser;
       
   pg_catalog          postgres    false    109            �           0    0 !   TABLE pg_stat_xact_user_functions    ACL     H   GRANT ALL ON TABLE pg_catalog.pg_stat_xact_user_functions TO statsuser;
       
   pg_catalog          postgres    false    137            �           0    0    TABLE pg_stat_xact_user_tables    ACL     E   GRANT ALL ON TABLE pg_catalog.pg_stat_xact_user_tables TO statsuser;
       
   pg_catalog          postgres    false    111            �           0    0    TABLE pg_statio_all_indexes    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_statio_all_indexes TO statsuser;
       
   pg_catalog          postgres    false    118            �           0    0    TABLE pg_statio_all_sequences    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_statio_all_sequences TO statsuser;
       
   pg_catalog          postgres    false    121            �           0    0    TABLE pg_statio_all_tables    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_statio_all_tables TO statsuser;
       
   pg_catalog          postgres    false    112            �           0    0    TABLE pg_statio_sys_indexes    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_statio_sys_indexes TO statsuser;
       
   pg_catalog          postgres    false    119            �           0    0    TABLE pg_statio_sys_sequences    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_statio_sys_sequences TO statsuser;
       
   pg_catalog          postgres    false    122            �           0    0    TABLE pg_statio_sys_tables    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_statio_sys_tables TO statsuser;
       
   pg_catalog          postgres    false    113            �           0    0    TABLE pg_statio_user_indexes    ACL     C   GRANT ALL ON TABLE pg_catalog.pg_statio_user_indexes TO statsuser;
       
   pg_catalog          postgres    false    120            �           0    0    TABLE pg_statio_user_sequences    ACL     E   GRANT ALL ON TABLE pg_catalog.pg_statio_user_sequences TO statsuser;
       
   pg_catalog          postgres    false    123            �           0    0    TABLE pg_statio_user_tables    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_statio_user_tables TO statsuser;
       
   pg_catalog          postgres    false    114            �           0    0    TABLE pg_statistic    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_statistic TO statsuser;
       
   pg_catalog          postgres    false    44            �           0    0    TABLE pg_statistic_ext    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_statistic_ext TO statsuser;
       
   pg_catalog          postgres    false    53            �           0    0    TABLE pg_statistic_ext_data    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_statistic_ext_data TO statsuser;
       
   pg_catalog          postgres    false    55            �           0    0    TABLE pg_stats    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_stats TO statsuser;
       
   pg_catalog          postgres    false    86            �           0    0    TABLE pg_stats_ext    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_stats_ext TO statsuser;
       
   pg_catalog          postgres    false    87            �           0    0    TABLE pg_stats_ext_exprs    ACL     ?   GRANT ALL ON TABLE pg_catalog.pg_stats_ext_exprs TO statsuser;
       
   pg_catalog          postgres    false    88            �           0    0    TABLE pg_subscription    ACL     <   GRANT ALL ON TABLE pg_catalog.pg_subscription TO statsuser;
       
   pg_catalog          postgres    false    69            �           0    0    TABLE pg_subscription_rel    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_subscription_rel TO statsuser;
       
   pg_catalog          postgres    false    70            �           0    0    TABLE pg_tables    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_tables TO statsuser;
       
   pg_catalog          postgres    false    82            �           0    0    TABLE pg_tablespace    ACL     :   GRANT ALL ON TABLE pg_catalog.pg_tablespace TO statsuser;
       
   pg_catalog          postgres    false    12            �           0    0    TABLE pg_timezone_abbrevs    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_timezone_abbrevs TO statsuser;
       
   pg_catalog          postgres    false    101            �           0    0    TABLE pg_timezone_names    ACL     >   GRANT ALL ON TABLE pg_catalog.pg_timezone_names TO statsuser;
       
   pg_catalog          postgres    false    102            �           0    0    TABLE pg_transform    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_transform TO statsuser;
       
   pg_catalog          postgres    false    60            �           0    0    TABLE pg_trigger    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_trigger TO statsuser;
       
   pg_catalog          postgres    false    45            �           0    0    TABLE pg_ts_config    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_ts_config TO statsuser;
       
   pg_catalog          postgres    false    65            �           0    0    TABLE pg_ts_config_map    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_ts_config_map TO statsuser;
       
   pg_catalog          postgres    false    66            �           0    0    TABLE pg_ts_dict    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_ts_dict TO statsuser;
       
   pg_catalog          postgres    false    63            �           0    0    TABLE pg_ts_parser    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_ts_parser TO statsuser;
       
   pg_catalog          postgres    false    64            �           0    0    TABLE pg_ts_template    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_ts_template TO statsuser;
       
   pg_catalog          postgres    false    67            �           0    0    TABLE pg_type    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_type TO statsuser;
       
   pg_catalog          postgres    false    14            �           0    0    TABLE pg_user    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_user TO statsuser;
       
   pg_catalog          postgres    false    78            �           0    0    TABLE pg_user_mapping    ACL     <   GRANT ALL ON TABLE pg_catalog.pg_user_mapping TO statsuser;
       
   pg_catalog          postgres    false    22            �           0    0    TABLE pg_user_mappings    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_user_mappings TO statsuser;
       
   pg_catalog          postgres    false    147            �           0    0    TABLE pg_views    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_views TO statsuser;
       
   pg_catalog          postgres    false    81            �            1259    187899    category    TABLE     }   CREATE TABLE public.category (
    id bigint NOT NULL,
    title text NOT NULL,
    active boolean DEFAULT false NOT NULL
);
    DROP TABLE public.category;
       public         heap 	   statsuser    false            �            1259    187905    category_id_seq    SEQUENCE     �   ALTER TABLE public.category ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.category_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   statsuser    false    224            �           0    0    TABLE geography_columns    ACL     :   GRANT ALL ON TABLE public.geography_columns TO statsuser;
          public          postgres    false    222            �           0    0    TABLE geometry_columns    ACL     9   GRANT ALL ON TABLE public.geometry_columns TO statsuser;
          public          postgres    false    223            �            1259    187906    long_term_anomaly_info    TABLE     �   CREATE TABLE public.long_term_anomaly_info (
    id bigint NOT NULL,
    anomaly_product_variable_id bigint NOT NULL,
    mean_variable_id bigint NOT NULL,
    stdev_variable_id bigint NOT NULL,
    raw_product_variable_id bigint NOT NULL
);
 *   DROP TABLE public.long_term_anomaly_info;
       public         heap 	   statsuser    false            �            1259    187909    long_term_anomaly_info_id_seq    SEQUENCE     �   CREATE SEQUENCE public.long_term_anomaly_info_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 4   DROP SEQUENCE public.long_term_anomaly_info_id_seq;
       public       	   statsuser    false    226            �           0    0    long_term_anomaly_info_id_seq    SEQUENCE OWNED BY     _   ALTER SEQUENCE public.long_term_anomaly_info_id_seq OWNED BY public.long_term_anomaly_info.id;
          public       	   statsuser    false    227            �            1259    187910    output_product_id_seq    SEQUENCE     ~   CREATE SEQUENCE public.output_product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE public.output_product_id_seq;
       public       	   statsuser    false            �            1259    364709 
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
       public         	   statsuser    false                        1259    368493    poly_stats_10_1_257    TABLE     �  CREATE TABLE public.poly_stats_10_1_257 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
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
       public         heap 	   statsuser    false    247                       1259    368793    poly_stats_10_257_279    TABLE     �  CREATE TABLE public.poly_stats_10_257_279 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
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
       public         heap 	   statsuser    false    247                       1259    369093    poly_stats_10_279_285    TABLE     �  CREATE TABLE public.poly_stats_10_279_285 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
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
       public         heap 	   statsuser    false    247            -           1259    369393    poly_stats_10_285_38543    TABLE     �  CREATE TABLE public.poly_stats_10_285_38543 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
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
       public         heap 	   statsuser    false    247                       1259    368513    poly_stats_12_1_257    TABLE     �  CREATE TABLE public.poly_stats_12_1_257 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
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
       public         heap 	   statsuser    false    247                       1259    368813    poly_stats_12_257_279    TABLE     �  CREATE TABLE public.poly_stats_12_257_279 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
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
       public         heap 	   statsuser    false    247                       1259    369113    poly_stats_12_279_285    TABLE     �  CREATE TABLE public.poly_stats_12_279_285 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
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
       public         heap 	   statsuser    false    247            .           1259    369413    poly_stats_12_285_38543    TABLE     �  CREATE TABLE public.poly_stats_12_285_38543 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
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
       public         heap 	   statsuser    false    247                       1259    368533    poly_stats_14_1_257    TABLE     �  CREATE TABLE public.poly_stats_14_1_257 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
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
       public         heap 	   statsuser    false    247                       1259    368833    poly_stats_14_257_279    TABLE     �  CREATE TABLE public.poly_stats_14_257_279 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
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
       public         heap 	   statsuser    false    247                        1259    369133    poly_stats_14_279_285    TABLE     �  CREATE TABLE public.poly_stats_14_279_285 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
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
       public         heap 	   statsuser    false    247            /           1259    369433    poly_stats_14_285_38543    TABLE     �  CREATE TABLE public.poly_stats_14_285_38543 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
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
       public         heap 	   statsuser    false    247                       1259    368553    poly_stats_16_1_257    TABLE     �  CREATE TABLE public.poly_stats_16_1_257 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
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
       public         heap 	   statsuser    false    247                       1259    368853    poly_stats_16_257_279    TABLE     �  CREATE TABLE public.poly_stats_16_257_279 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
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
       public         heap 	   statsuser    false    247            !           1259    369153    poly_stats_16_279_285    TABLE     �  CREATE TABLE public.poly_stats_16_279_285 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
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
       public         heap 	   statsuser    false    247            0           1259    369453    poly_stats_16_285_38543    TABLE     �  CREATE TABLE public.poly_stats_16_285_38543 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
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
       public         heap 	   statsuser    false    247                       1259    368573    poly_stats_17_1_257    TABLE     �  CREATE TABLE public.poly_stats_17_1_257 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
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
       public         heap 	   statsuser    false    247                       1259    368873    poly_stats_17_257_279    TABLE     �  CREATE TABLE public.poly_stats_17_257_279 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
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
       public         heap 	   statsuser    false    247            "           1259    369173    poly_stats_17_279_285    TABLE     �  CREATE TABLE public.poly_stats_17_279_285 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
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
       public         heap 	   statsuser    false    247            1           1259    369473    poly_stats_17_285_38543    TABLE     �  CREATE TABLE public.poly_stats_17_285_38543 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
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
       public         heap 	   statsuser    false    247                       1259    368593    poly_stats_19_1_257    TABLE     �  CREATE TABLE public.poly_stats_19_1_257 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
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
       public         heap 	   statsuser    false    247                       1259    368893    poly_stats_19_257_279    TABLE     �  CREATE TABLE public.poly_stats_19_257_279 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
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
       public         heap 	   statsuser    false    247            #           1259    369193    poly_stats_19_279_285    TABLE     �  CREATE TABLE public.poly_stats_19_279_285 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
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
       public         heap 	   statsuser    false    247            2           1259    369493    poly_stats_19_285_38543    TABLE     �  CREATE TABLE public.poly_stats_19_285_38543 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
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
       public         heap 	   statsuser    false    247            �            1259    368333    poly_stats_1_1_257    TABLE     �  CREATE TABLE public.poly_stats_1_1_257 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
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
       public         heap 	   statsuser    false    247                       1259    368633    poly_stats_1_257_279    TABLE     �  CREATE TABLE public.poly_stats_1_257_279 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
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
       public         heap 	   statsuser    false    247                       1259    368933    poly_stats_1_279_285    TABLE     �  CREATE TABLE public.poly_stats_1_279_285 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
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
       public         heap 	   statsuser    false    247            %           1259    369233    poly_stats_1_285_38543    TABLE     �  CREATE TABLE public.poly_stats_1_285_38543 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
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
       public         heap 	   statsuser    false    247                       1259    368613    poly_stats_21_1_257    TABLE     �  CREATE TABLE public.poly_stats_21_1_257 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
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
       public         heap 	   statsuser    false    247                       1259    368913    poly_stats_21_257_279    TABLE     �  CREATE TABLE public.poly_stats_21_257_279 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
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
       public         heap 	   statsuser    false    247            $           1259    369213    poly_stats_21_279_285    TABLE     �  CREATE TABLE public.poly_stats_21_279_285 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
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
       public         heap 	   statsuser    false    247            3           1259    369513    poly_stats_21_285_38543    TABLE     �  CREATE TABLE public.poly_stats_21_285_38543 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
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
       public         heap 	   statsuser    false    247            �            1259    368353    poly_stats_2_1_257    TABLE     �  CREATE TABLE public.poly_stats_2_1_257 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
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
       public         heap 	   statsuser    false    247                       1259    368653    poly_stats_2_257_279    TABLE     �  CREATE TABLE public.poly_stats_2_257_279 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
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
       public         heap 	   statsuser    false    247                       1259    368953    poly_stats_2_279_285    TABLE     �  CREATE TABLE public.poly_stats_2_279_285 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
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
       public         heap 	   statsuser    false    247            &           1259    369253    poly_stats_2_285_38543    TABLE     �  CREATE TABLE public.poly_stats_2_285_38543 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
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
       public         heap 	   statsuser    false    247            �            1259    368373    poly_stats_3_1_257    TABLE     �  CREATE TABLE public.poly_stats_3_1_257 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
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
       public         heap 	   statsuser    false    247            	           1259    368673    poly_stats_3_257_279    TABLE     �  CREATE TABLE public.poly_stats_3_257_279 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
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
       public         heap 	   statsuser    false    247                       1259    368973    poly_stats_3_279_285    TABLE     �  CREATE TABLE public.poly_stats_3_279_285 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
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
       public         heap 	   statsuser    false    247            '           1259    369273    poly_stats_3_285_38543    TABLE     �  CREATE TABLE public.poly_stats_3_285_38543 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
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
       public         heap 	   statsuser    false    247            �            1259    368393    poly_stats_4_1_257    TABLE     �  CREATE TABLE public.poly_stats_4_1_257 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
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
       public         heap 	   statsuser    false    247            
           1259    368693    poly_stats_4_257_279    TABLE     �  CREATE TABLE public.poly_stats_4_257_279 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
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
       public         heap 	   statsuser    false    247                       1259    368993    poly_stats_4_279_285    TABLE     �  CREATE TABLE public.poly_stats_4_279_285 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
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
       public         heap 	   statsuser    false    247            (           1259    369293    poly_stats_4_285_38543    TABLE     �  CREATE TABLE public.poly_stats_4_285_38543 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
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
       public         heap 	   statsuser    false    247            �            1259    368413    poly_stats_5_1_257    TABLE     �  CREATE TABLE public.poly_stats_5_1_257 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
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
       public         heap 	   statsuser    false    247                       1259    368713    poly_stats_5_257_279    TABLE     �  CREATE TABLE public.poly_stats_5_257_279 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
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
       public         heap 	   statsuser    false    247                       1259    369013    poly_stats_5_279_285    TABLE     �  CREATE TABLE public.poly_stats_5_279_285 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
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
       public         heap 	   statsuser    false    247            )           1259    369313    poly_stats_5_285_38543    TABLE     �  CREATE TABLE public.poly_stats_5_285_38543 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
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
       public         heap 	   statsuser    false    247            �            1259    368433    poly_stats_6_1_257    TABLE     �  CREATE TABLE public.poly_stats_6_1_257 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
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
       public         heap 	   statsuser    false    247                       1259    368733    poly_stats_6_257_279    TABLE     �  CREATE TABLE public.poly_stats_6_257_279 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
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
       public         heap 	   statsuser    false    247                       1259    369033    poly_stats_6_279_285    TABLE     �  CREATE TABLE public.poly_stats_6_279_285 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
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
       public         heap 	   statsuser    false    247            *           1259    369333    poly_stats_6_285_38543    TABLE     �  CREATE TABLE public.poly_stats_6_285_38543 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
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
       public         heap 	   statsuser    false    247            �            1259    368453    poly_stats_7_1_257    TABLE     �  CREATE TABLE public.poly_stats_7_1_257 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
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
       public         heap 	   statsuser    false    247                       1259    368753    poly_stats_7_257_279    TABLE     �  CREATE TABLE public.poly_stats_7_257_279 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
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
       public         heap 	   statsuser    false    247                       1259    369053    poly_stats_7_279_285    TABLE     �  CREATE TABLE public.poly_stats_7_279_285 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
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
       public         heap 	   statsuser    false    247            +           1259    369353    poly_stats_7_285_38543    TABLE     �  CREATE TABLE public.poly_stats_7_285_38543 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
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
       public         heap 	   statsuser    false    247            �            1259    368473    poly_stats_9_1_257    TABLE     �  CREATE TABLE public.poly_stats_9_1_257 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
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
       public         heap 	   statsuser    false    247                       1259    368773    poly_stats_9_257_279    TABLE     �  CREATE TABLE public.poly_stats_9_257_279 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
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
       public         heap 	   statsuser    false    247                       1259    369073    poly_stats_9_279_285    TABLE     �  CREATE TABLE public.poly_stats_9_279_285 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
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
       public         heap 	   statsuser    false    247            ,           1259    369373    poly_stats_9_285_38543    TABLE     �  CREATE TABLE public.poly_stats_9_285_38543 (
    poly_id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
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
       public         heap 	   statsuser    false    247            �            1259    187920    product    TABLE     �   CREATE TABLE public.product (
    id bigint NOT NULL,
    name text[] NOT NULL,
    type text DEFAULT 'raw'::text NOT NULL,
    category_id bigint,
    description text
);
    DROP TABLE public.product;
       public         heap 	   statsuser    false            �            1259    187926    product_file    TABLE     +  CREATE TABLE public.product_file (
    id bigint NOT NULL,
    product_file_description_id bigint NOT NULL,
    rel_file_path text NOT NULL,
    rt_flag smallint,
    date timestamp without time zone NOT NULL,
    date_created timestamp without time zone DEFAULT (now() AT TIME ZONE 'UTC'::text)
);
     DROP TABLE public.product_file;
       public         heap 	   statsuser    false            �            1259    187932    product_file_description    TABLE     �   CREATE TABLE public.product_file_description (
    id bigint NOT NULL,
    product_id bigint,
    pattern text NOT NULL,
    types text NOT NULL,
    create_date text NOT NULL,
    file_name_creation_pattern text,
    rt_flag_pattern text
);
 ,   DROP TABLE public.product_file_description;
       public         heap 	   statsuser    false            �            1259    187937    product_file_description_id_seq    SEQUENCE     �   CREATE SEQUENCE public.product_file_description_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 6   DROP SEQUENCE public.product_file_description_id_seq;
       public       	   statsuser    false    231            �           0    0    product_file_description_id_seq    SEQUENCE OWNED BY     c   ALTER SEQUENCE public.product_file_description_id_seq OWNED BY public.product_file_description.id;
          public       	   statsuser    false    232            �            1259    187938    product_file_id_seq    SEQUENCE     |   CREATE SEQUENCE public.product_file_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.product_file_id_seq;
       public       	   statsuser    false            �            1259    187939    product_file_id_seq1    SEQUENCE     }   CREATE SEQUENCE public.product_file_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.product_file_id_seq1;
       public       	   statsuser    false    230            �           0    0    product_file_id_seq1    SEQUENCE OWNED BY     L   ALTER SEQUENCE public.product_file_id_seq1 OWNED BY public.product_file.id;
          public       	   statsuser    false    234            �            1259    187940    product_file_variable    TABLE     <  CREATE TABLE public.product_file_variable (
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
       public         heap 	   statsuser    false            �            1259    187946    product_file_variable_id_seq    SEQUENCE     �   CREATE SEQUENCE public.product_file_variable_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 3   DROP SEQUENCE public.product_file_variable_id_seq;
       public       	   statsuser    false    235            �           0    0    product_file_variable_id_seq    SEQUENCE OWNED BY     ]   ALTER SEQUENCE public.product_file_variable_id_seq OWNED BY public.product_file_variable.id;
          public       	   statsuser    false    236            �            1259    187947    product_id_seq    SEQUENCE     w   CREATE SEQUENCE public.product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public.product_id_seq;
       public       	   statsuser    false    229            �           0    0    product_id_seq    SEQUENCE OWNED BY     A   ALTER SEQUENCE public.product_id_seq OWNED BY public.product.id;
          public       	   statsuser    false    237            �           0    0    TABLE spatial_ref_sys    ACL     8   GRANT ALL ON TABLE public.spatial_ref_sys TO statsuser;
          public          postgres    false    220            �            1259    187948    stratification    TABLE     m   CREATE TABLE public.stratification (
    id bigint NOT NULL,
    description text,
    tilelayer_url text
);
 "   DROP TABLE public.stratification;
       public         heap 	   statsuser    false            �            1259    187953    stratification_geom    TABLE     �   CREATE TABLE public.stratification_geom (
    id bigint NOT NULL,
    stratification_id bigint NOT NULL,
    geom public.geometry(MultiPolygon,4326),
    geom3857 public.geometry(MultiPolygon,3857),
    description text
);
 '   DROP TABLE public.stratification_geom;
       public         heap 	   statsuser    false    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3            �            1259    187958    stratification_geom_id_seq    SEQUENCE     �   CREATE SEQUENCE public.stratification_geom_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE public.stratification_geom_id_seq;
       public       	   statsuser    false    239            �           0    0    stratification_geom_id_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE public.stratification_geom_id_seq OWNED BY public.stratification_geom.id;
          public       	   statsuser    false    240            �            1259    187959    stratification_id_seq    SEQUENCE     ~   CREATE SEQUENCE public.stratification_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE public.stratification_id_seq;
       public       	   statsuser    false    238            �           0    0    stratification_id_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE public.stratification_id_seq OWNED BY public.stratification.id;
          public       	   statsuser    false    241            �            1259    187960    tmp    TABLE     6   CREATE TABLE public.tmp (
    json_object_agg json
);
    DROP TABLE public.tmp;
       public         heap 	   statsuser    false            �            1259    363252    wms_file    TABLE     �   CREATE TABLE public.wms_file (
    id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint,
    rel_file_path text
);
    DROP TABLE public.wms_file;
       public         heap 	   statsuser    false            �            1259    363251    wms_file_id_seq    SEQUENCE     x   CREATE SEQUENCE public.wms_file_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.wms_file_id_seq;
       public       	   statsuser    false    246            �           0    0    wms_file_id_seq    SEQUENCE OWNED BY     C   ALTER SEQUENCE public.wms_file_id_seq OWNED BY public.wms_file.id;
          public       	   statsuser    false    245            �            1259    187965    poly_stats_per_region    TABLE     �  CREATE TABLE tmp.poly_stats_per_region (
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
       tmp         heap 	   statsuser    false    5            �            1259    187973    poly_stats_per_region_id_seq    SEQUENCE     �   CREATE SEQUENCE tmp.poly_stats_per_region_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE tmp.poly_stats_per_region_id_seq;
       tmp       	   statsuser    false    243    5            �           0    0    poly_stats_per_region_id_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE tmp.poly_stats_per_region_id_seq OWNED BY tmp.poly_stats_per_region.id;
          tmp       	   statsuser    false    244            ;           0    0    poly_stats_10_1_257    TABLE ATTACH     }   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_10_1_257 FOR VALUES FROM ('10', '1') TO ('10', '257');
          public       	   statsuser    false    256    247            J           0    0    poly_stats_10_257_279    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_10_257_279 FOR VALUES FROM ('10', '257') TO ('10', '279');
          public       	   statsuser    false    271    247            Y           0    0    poly_stats_10_279_285    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_10_279_285 FOR VALUES FROM ('10', '279') TO ('10', '285');
          public       	   statsuser    false    286    247            h           0    0    poly_stats_10_285_38543    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_10_285_38543 FOR VALUES FROM ('10', '285') TO ('10', '38543');
          public       	   statsuser    false    301    247            <           0    0    poly_stats_12_1_257    TABLE ATTACH     }   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_12_1_257 FOR VALUES FROM ('12', '1') TO ('12', '257');
          public       	   statsuser    false    257    247            K           0    0    poly_stats_12_257_279    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_12_257_279 FOR VALUES FROM ('12', '257') TO ('12', '279');
          public       	   statsuser    false    272    247            Z           0    0    poly_stats_12_279_285    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_12_279_285 FOR VALUES FROM ('12', '279') TO ('12', '285');
          public       	   statsuser    false    287    247            i           0    0    poly_stats_12_285_38543    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_12_285_38543 FOR VALUES FROM ('12', '285') TO ('12', '38543');
          public       	   statsuser    false    302    247            =           0    0    poly_stats_14_1_257    TABLE ATTACH     }   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_14_1_257 FOR VALUES FROM ('14', '1') TO ('14', '257');
          public       	   statsuser    false    258    247            L           0    0    poly_stats_14_257_279    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_14_257_279 FOR VALUES FROM ('14', '257') TO ('14', '279');
          public       	   statsuser    false    273    247            [           0    0    poly_stats_14_279_285    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_14_279_285 FOR VALUES FROM ('14', '279') TO ('14', '285');
          public       	   statsuser    false    288    247            j           0    0    poly_stats_14_285_38543    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_14_285_38543 FOR VALUES FROM ('14', '285') TO ('14', '38543');
          public       	   statsuser    false    303    247            >           0    0    poly_stats_16_1_257    TABLE ATTACH     }   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_16_1_257 FOR VALUES FROM ('16', '1') TO ('16', '257');
          public       	   statsuser    false    259    247            M           0    0    poly_stats_16_257_279    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_16_257_279 FOR VALUES FROM ('16', '257') TO ('16', '279');
          public       	   statsuser    false    274    247            \           0    0    poly_stats_16_279_285    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_16_279_285 FOR VALUES FROM ('16', '279') TO ('16', '285');
          public       	   statsuser    false    289    247            k           0    0    poly_stats_16_285_38543    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_16_285_38543 FOR VALUES FROM ('16', '285') TO ('16', '38543');
          public       	   statsuser    false    304    247            ?           0    0    poly_stats_17_1_257    TABLE ATTACH     }   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_17_1_257 FOR VALUES FROM ('17', '1') TO ('17', '257');
          public       	   statsuser    false    260    247            N           0    0    poly_stats_17_257_279    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_17_257_279 FOR VALUES FROM ('17', '257') TO ('17', '279');
          public       	   statsuser    false    275    247            ]           0    0    poly_stats_17_279_285    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_17_279_285 FOR VALUES FROM ('17', '279') TO ('17', '285');
          public       	   statsuser    false    290    247            l           0    0    poly_stats_17_285_38543    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_17_285_38543 FOR VALUES FROM ('17', '285') TO ('17', '38543');
          public       	   statsuser    false    305    247            @           0    0    poly_stats_19_1_257    TABLE ATTACH     }   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_19_1_257 FOR VALUES FROM ('19', '1') TO ('19', '257');
          public       	   statsuser    false    261    247            O           0    0    poly_stats_19_257_279    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_19_257_279 FOR VALUES FROM ('19', '257') TO ('19', '279');
          public       	   statsuser    false    276    247            ^           0    0    poly_stats_19_279_285    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_19_279_285 FOR VALUES FROM ('19', '279') TO ('19', '285');
          public       	   statsuser    false    291    247            m           0    0    poly_stats_19_285_38543    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_19_285_38543 FOR VALUES FROM ('19', '285') TO ('19', '38543');
          public       	   statsuser    false    306    247            3           0    0    poly_stats_1_1_257    TABLE ATTACH     z   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_1_1_257 FOR VALUES FROM ('1', '1') TO ('1', '257');
          public       	   statsuser    false    248    247            B           0    0    poly_stats_1_257_279    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_1_257_279 FOR VALUES FROM ('1', '257') TO ('1', '279');
          public       	   statsuser    false    263    247            Q           0    0    poly_stats_1_279_285    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_1_279_285 FOR VALUES FROM ('1', '279') TO ('1', '285');
          public       	   statsuser    false    278    247            `           0    0    poly_stats_1_285_38543    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_1_285_38543 FOR VALUES FROM ('1', '285') TO ('1', '38543');
          public       	   statsuser    false    293    247            A           0    0    poly_stats_21_1_257    TABLE ATTACH     }   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_21_1_257 FOR VALUES FROM ('21', '1') TO ('21', '257');
          public       	   statsuser    false    262    247            P           0    0    poly_stats_21_257_279    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_21_257_279 FOR VALUES FROM ('21', '257') TO ('21', '279');
          public       	   statsuser    false    277    247            _           0    0    poly_stats_21_279_285    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_21_279_285 FOR VALUES FROM ('21', '279') TO ('21', '285');
          public       	   statsuser    false    292    247            n           0    0    poly_stats_21_285_38543    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_21_285_38543 FOR VALUES FROM ('21', '285') TO ('21', '38543');
          public       	   statsuser    false    307    247            4           0    0    poly_stats_2_1_257    TABLE ATTACH     z   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_2_1_257 FOR VALUES FROM ('2', '1') TO ('2', '257');
          public       	   statsuser    false    249    247            C           0    0    poly_stats_2_257_279    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_2_257_279 FOR VALUES FROM ('2', '257') TO ('2', '279');
          public       	   statsuser    false    264    247            R           0    0    poly_stats_2_279_285    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_2_279_285 FOR VALUES FROM ('2', '279') TO ('2', '285');
          public       	   statsuser    false    279    247            a           0    0    poly_stats_2_285_38543    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_2_285_38543 FOR VALUES FROM ('2', '285') TO ('2', '38543');
          public       	   statsuser    false    294    247            5           0    0    poly_stats_3_1_257    TABLE ATTACH     z   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_3_1_257 FOR VALUES FROM ('3', '1') TO ('3', '257');
          public       	   statsuser    false    250    247            D           0    0    poly_stats_3_257_279    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_3_257_279 FOR VALUES FROM ('3', '257') TO ('3', '279');
          public       	   statsuser    false    265    247            S           0    0    poly_stats_3_279_285    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_3_279_285 FOR VALUES FROM ('3', '279') TO ('3', '285');
          public       	   statsuser    false    280    247            b           0    0    poly_stats_3_285_38543    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_3_285_38543 FOR VALUES FROM ('3', '285') TO ('3', '38543');
          public       	   statsuser    false    295    247            6           0    0    poly_stats_4_1_257    TABLE ATTACH     z   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_4_1_257 FOR VALUES FROM ('4', '1') TO ('4', '257');
          public       	   statsuser    false    251    247            E           0    0    poly_stats_4_257_279    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_4_257_279 FOR VALUES FROM ('4', '257') TO ('4', '279');
          public       	   statsuser    false    266    247            T           0    0    poly_stats_4_279_285    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_4_279_285 FOR VALUES FROM ('4', '279') TO ('4', '285');
          public       	   statsuser    false    281    247            c           0    0    poly_stats_4_285_38543    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_4_285_38543 FOR VALUES FROM ('4', '285') TO ('4', '38543');
          public       	   statsuser    false    296    247            7           0    0    poly_stats_5_1_257    TABLE ATTACH     z   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_5_1_257 FOR VALUES FROM ('5', '1') TO ('5', '257');
          public       	   statsuser    false    252    247            F           0    0    poly_stats_5_257_279    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_5_257_279 FOR VALUES FROM ('5', '257') TO ('5', '279');
          public       	   statsuser    false    267    247            U           0    0    poly_stats_5_279_285    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_5_279_285 FOR VALUES FROM ('5', '279') TO ('5', '285');
          public       	   statsuser    false    282    247            d           0    0    poly_stats_5_285_38543    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_5_285_38543 FOR VALUES FROM ('5', '285') TO ('5', '38543');
          public       	   statsuser    false    297    247            8           0    0    poly_stats_6_1_257    TABLE ATTACH     z   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_6_1_257 FOR VALUES FROM ('6', '1') TO ('6', '257');
          public       	   statsuser    false    253    247            G           0    0    poly_stats_6_257_279    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_6_257_279 FOR VALUES FROM ('6', '257') TO ('6', '279');
          public       	   statsuser    false    268    247            V           0    0    poly_stats_6_279_285    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_6_279_285 FOR VALUES FROM ('6', '279') TO ('6', '285');
          public       	   statsuser    false    283    247            e           0    0    poly_stats_6_285_38543    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_6_285_38543 FOR VALUES FROM ('6', '285') TO ('6', '38543');
          public       	   statsuser    false    298    247            9           0    0    poly_stats_7_1_257    TABLE ATTACH     z   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_7_1_257 FOR VALUES FROM ('7', '1') TO ('7', '257');
          public       	   statsuser    false    254    247            H           0    0    poly_stats_7_257_279    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_7_257_279 FOR VALUES FROM ('7', '257') TO ('7', '279');
          public       	   statsuser    false    269    247            W           0    0    poly_stats_7_279_285    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_7_279_285 FOR VALUES FROM ('7', '279') TO ('7', '285');
          public       	   statsuser    false    284    247            f           0    0    poly_stats_7_285_38543    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_7_285_38543 FOR VALUES FROM ('7', '285') TO ('7', '38543');
          public       	   statsuser    false    299    247            :           0    0    poly_stats_9_1_257    TABLE ATTACH     z   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_9_1_257 FOR VALUES FROM ('9', '1') TO ('9', '257');
          public       	   statsuser    false    255    247            I           0    0    poly_stats_9_257_279    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_9_257_279 FOR VALUES FROM ('9', '257') TO ('9', '279');
          public       	   statsuser    false    270    247            X           0    0    poly_stats_9_279_285    TABLE ATTACH     ~   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_9_279_285 FOR VALUES FROM ('9', '279') TO ('9', '285');
          public       	   statsuser    false    285    247            g           0    0    poly_stats_9_285_38543    TABLE ATTACH     �   ALTER TABLE ONLY public.poly_stats ATTACH PARTITION public.poly_stats_9_285_38543 FOR VALUES FROM ('9', '285') TO ('9', '38543');
          public       	   statsuser    false    300    247            p           2604    187974    long_term_anomaly_info id    DEFAULT     �   ALTER TABLE ONLY public.long_term_anomaly_info ALTER COLUMN id SET DEFAULT nextval('public.long_term_anomaly_info_id_seq'::regclass);
 H   ALTER TABLE public.long_term_anomaly_info ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    227    226            q           2604    187976 
   product id    DEFAULT     h   ALTER TABLE ONLY public.product ALTER COLUMN id SET DEFAULT nextval('public.product_id_seq'::regclass);
 9   ALTER TABLE public.product ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    237    229            s           2604    187977    product_file id    DEFAULT     s   ALTER TABLE ONLY public.product_file ALTER COLUMN id SET DEFAULT nextval('public.product_file_id_seq1'::regclass);
 >   ALTER TABLE public.product_file ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    234    230            u           2604    187978    product_file_description id    DEFAULT     �   ALTER TABLE ONLY public.product_file_description ALTER COLUMN id SET DEFAULT nextval('public.product_file_description_id_seq'::regclass);
 J   ALTER TABLE public.product_file_description ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    232    231            v           2604    187979    product_file_variable id    DEFAULT     �   ALTER TABLE ONLY public.product_file_variable ALTER COLUMN id SET DEFAULT nextval('public.product_file_variable_id_seq'::regclass);
 G   ALTER TABLE public.product_file_variable ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    236    235            x           2604    187980    stratification id    DEFAULT     v   ALTER TABLE ONLY public.stratification ALTER COLUMN id SET DEFAULT nextval('public.stratification_id_seq'::regclass);
 @   ALTER TABLE public.stratification ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    241    238            y           2604    187981    stratification_geom id    DEFAULT     �   ALTER TABLE ONLY public.stratification_geom ALTER COLUMN id SET DEFAULT nextval('public.stratification_geom_id_seq'::regclass);
 E   ALTER TABLE public.stratification_geom ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    240    239            ~           2604    363255    wms_file id    DEFAULT     j   ALTER TABLE ONLY public.wms_file ALTER COLUMN id SET DEFAULT nextval('public.wms_file_id_seq'::regclass);
 :   ALTER TABLE public.wms_file ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    245    246    246            z           2604    187982    poly_stats_per_region id    DEFAULT     ~   ALTER TABLE ONLY tmp.poly_stats_per_region ALTER COLUMN id SET DEFAULT nextval('tmp.poly_stats_per_region_id_seq'::regclass);
 D   ALTER TABLE tmp.poly_stats_per_region ALTER COLUMN id DROP DEFAULT;
       tmp       	   statsuser    false    244    243            <           2606    187999 0   long_term_anomaly_info long_term_anomaly_info_pk 
   CONSTRAINT     n   ALTER TABLE ONLY public.long_term_anomaly_info
    ADD CONSTRAINT long_term_anomaly_info_pk PRIMARY KEY (id);
 Z   ALTER TABLE ONLY public.long_term_anomaly_info DROP CONSTRAINT long_term_anomaly_info_pk;
       public         	   statsuser    false    226            :           2606    188001    category newtable_pk 
   CONSTRAINT     R   ALTER TABLE ONLY public.category
    ADD CONSTRAINT newtable_pk PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.category DROP CONSTRAINT newtable_pk;
       public         	   statsuser    false    224            Y           2606    364716    poly_stats poly_stats_pk_ 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats
    ADD CONSTRAINT poly_stats_pk_ PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 C   ALTER TABLE ONLY public.poly_stats DROP CONSTRAINT poly_stats_pk_;
       public         	   statsuser    false    247    247    247            t           2606    368500 ,   poly_stats_10_1_257 poly_stats_10_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_10_1_257
    ADD CONSTRAINT poly_stats_10_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 V   ALTER TABLE ONLY public.poly_stats_10_1_257 DROP CONSTRAINT poly_stats_10_1_257_pkey;
       public         	   statsuser    false    4697    256    256    256    256            �           2606    368800 0   poly_stats_10_257_279 poly_stats_10_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_10_257_279
    ADD CONSTRAINT poly_stats_10_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_10_257_279 DROP CONSTRAINT poly_stats_10_257_279_pkey;
       public         	   statsuser    false    271    271    4697    271    271            �           2606    369100 0   poly_stats_10_279_285 poly_stats_10_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_10_279_285
    ADD CONSTRAINT poly_stats_10_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_10_279_285 DROP CONSTRAINT poly_stats_10_279_285_pkey;
       public         	   statsuser    false    286    286    286    4697    286            �           2606    369400 4   poly_stats_10_285_38543 poly_stats_10_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_10_285_38543
    ADD CONSTRAINT poly_stats_10_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 ^   ALTER TABLE ONLY public.poly_stats_10_285_38543 DROP CONSTRAINT poly_stats_10_285_38543_pkey;
       public         	   statsuser    false    301    4697    301    301    301            w           2606    368520 ,   poly_stats_12_1_257 poly_stats_12_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_12_1_257
    ADD CONSTRAINT poly_stats_12_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 V   ALTER TABLE ONLY public.poly_stats_12_1_257 DROP CONSTRAINT poly_stats_12_1_257_pkey;
       public         	   statsuser    false    257    257    4697    257    257            �           2606    368820 0   poly_stats_12_257_279 poly_stats_12_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_12_257_279
    ADD CONSTRAINT poly_stats_12_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_12_257_279 DROP CONSTRAINT poly_stats_12_257_279_pkey;
       public         	   statsuser    false    272    272    272    4697    272            �           2606    369120 0   poly_stats_12_279_285 poly_stats_12_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_12_279_285
    ADD CONSTRAINT poly_stats_12_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_12_279_285 DROP CONSTRAINT poly_stats_12_279_285_pkey;
       public         	   statsuser    false    4697    287    287    287    287            �           2606    369420 4   poly_stats_12_285_38543 poly_stats_12_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_12_285_38543
    ADD CONSTRAINT poly_stats_12_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 ^   ALTER TABLE ONLY public.poly_stats_12_285_38543 DROP CONSTRAINT poly_stats_12_285_38543_pkey;
       public         	   statsuser    false    302    302    302    302    4697            z           2606    368540 ,   poly_stats_14_1_257 poly_stats_14_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_14_1_257
    ADD CONSTRAINT poly_stats_14_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 V   ALTER TABLE ONLY public.poly_stats_14_1_257 DROP CONSTRAINT poly_stats_14_1_257_pkey;
       public         	   statsuser    false    4697    258    258    258    258            �           2606    368840 0   poly_stats_14_257_279 poly_stats_14_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_14_257_279
    ADD CONSTRAINT poly_stats_14_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_14_257_279 DROP CONSTRAINT poly_stats_14_257_279_pkey;
       public         	   statsuser    false    4697    273    273    273    273            �           2606    369140 0   poly_stats_14_279_285 poly_stats_14_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_14_279_285
    ADD CONSTRAINT poly_stats_14_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_14_279_285 DROP CONSTRAINT poly_stats_14_279_285_pkey;
       public         	   statsuser    false    288    288    288    4697    288                       2606    369440 4   poly_stats_14_285_38543 poly_stats_14_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_14_285_38543
    ADD CONSTRAINT poly_stats_14_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 ^   ALTER TABLE ONLY public.poly_stats_14_285_38543 DROP CONSTRAINT poly_stats_14_285_38543_pkey;
       public         	   statsuser    false    4697    303    303    303    303            }           2606    368560 ,   poly_stats_16_1_257 poly_stats_16_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_16_1_257
    ADD CONSTRAINT poly_stats_16_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 V   ALTER TABLE ONLY public.poly_stats_16_1_257 DROP CONSTRAINT poly_stats_16_1_257_pkey;
       public         	   statsuser    false    259    4697    259    259    259            �           2606    368860 0   poly_stats_16_257_279 poly_stats_16_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_16_257_279
    ADD CONSTRAINT poly_stats_16_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_16_257_279 DROP CONSTRAINT poly_stats_16_257_279_pkey;
       public         	   statsuser    false    274    274    4697    274    274            �           2606    369160 0   poly_stats_16_279_285 poly_stats_16_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_16_279_285
    ADD CONSTRAINT poly_stats_16_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_16_279_285 DROP CONSTRAINT poly_stats_16_279_285_pkey;
       public         	   statsuser    false    289    289    4697    289    289                       2606    369460 4   poly_stats_16_285_38543 poly_stats_16_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_16_285_38543
    ADD CONSTRAINT poly_stats_16_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 ^   ALTER TABLE ONLY public.poly_stats_16_285_38543 DROP CONSTRAINT poly_stats_16_285_38543_pkey;
       public         	   statsuser    false    304    304    304    4697    304            �           2606    368580 ,   poly_stats_17_1_257 poly_stats_17_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_17_1_257
    ADD CONSTRAINT poly_stats_17_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 V   ALTER TABLE ONLY public.poly_stats_17_1_257 DROP CONSTRAINT poly_stats_17_1_257_pkey;
       public         	   statsuser    false    260    260    4697    260    260            �           2606    368880 0   poly_stats_17_257_279 poly_stats_17_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_17_257_279
    ADD CONSTRAINT poly_stats_17_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_17_257_279 DROP CONSTRAINT poly_stats_17_257_279_pkey;
       public         	   statsuser    false    275    275    4697    275    275            �           2606    369180 0   poly_stats_17_279_285 poly_stats_17_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_17_279_285
    ADD CONSTRAINT poly_stats_17_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_17_279_285 DROP CONSTRAINT poly_stats_17_279_285_pkey;
       public         	   statsuser    false    4697    290    290    290    290                       2606    369480 4   poly_stats_17_285_38543 poly_stats_17_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_17_285_38543
    ADD CONSTRAINT poly_stats_17_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 ^   ALTER TABLE ONLY public.poly_stats_17_285_38543 DROP CONSTRAINT poly_stats_17_285_38543_pkey;
       public         	   statsuser    false    305    305    305    4697    305            �           2606    368600 ,   poly_stats_19_1_257 poly_stats_19_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_19_1_257
    ADD CONSTRAINT poly_stats_19_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 V   ALTER TABLE ONLY public.poly_stats_19_1_257 DROP CONSTRAINT poly_stats_19_1_257_pkey;
       public         	   statsuser    false    4697    261    261    261    261            �           2606    368900 0   poly_stats_19_257_279 poly_stats_19_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_19_257_279
    ADD CONSTRAINT poly_stats_19_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_19_257_279 DROP CONSTRAINT poly_stats_19_257_279_pkey;
       public         	   statsuser    false    276    276    276    4697    276            �           2606    369200 0   poly_stats_19_279_285 poly_stats_19_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_19_279_285
    ADD CONSTRAINT poly_stats_19_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_19_279_285 DROP CONSTRAINT poly_stats_19_279_285_pkey;
       public         	   statsuser    false    291    291    291    4697    291            
           2606    369500 4   poly_stats_19_285_38543 poly_stats_19_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_19_285_38543
    ADD CONSTRAINT poly_stats_19_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 ^   ALTER TABLE ONLY public.poly_stats_19_285_38543 DROP CONSTRAINT poly_stats_19_285_38543_pkey;
       public         	   statsuser    false    306    4697    306    306    306            \           2606    368340 *   poly_stats_1_1_257 poly_stats_1_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_1_1_257
    ADD CONSTRAINT poly_stats_1_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 T   ALTER TABLE ONLY public.poly_stats_1_1_257 DROP CONSTRAINT poly_stats_1_1_257_pkey;
       public         	   statsuser    false    4697    248    248    248    248            �           2606    368640 .   poly_stats_1_257_279 poly_stats_1_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_1_257_279
    ADD CONSTRAINT poly_stats_1_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_1_257_279 DROP CONSTRAINT poly_stats_1_257_279_pkey;
       public         	   statsuser    false    263    4697    263    263    263            �           2606    368940 .   poly_stats_1_279_285 poly_stats_1_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_1_279_285
    ADD CONSTRAINT poly_stats_1_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_1_279_285 DROP CONSTRAINT poly_stats_1_279_285_pkey;
       public         	   statsuser    false    278    278    278    4697    278            �           2606    369240 2   poly_stats_1_285_38543 poly_stats_1_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_1_285_38543
    ADD CONSTRAINT poly_stats_1_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 \   ALTER TABLE ONLY public.poly_stats_1_285_38543 DROP CONSTRAINT poly_stats_1_285_38543_pkey;
       public         	   statsuser    false    293    293    293    293    4697            �           2606    368620 ,   poly_stats_21_1_257 poly_stats_21_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_21_1_257
    ADD CONSTRAINT poly_stats_21_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 V   ALTER TABLE ONLY public.poly_stats_21_1_257 DROP CONSTRAINT poly_stats_21_1_257_pkey;
       public         	   statsuser    false    262    262    4697    262    262            �           2606    368920 0   poly_stats_21_257_279 poly_stats_21_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_21_257_279
    ADD CONSTRAINT poly_stats_21_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_21_257_279 DROP CONSTRAINT poly_stats_21_257_279_pkey;
       public         	   statsuser    false    4697    277    277    277    277            �           2606    369220 0   poly_stats_21_279_285 poly_stats_21_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_21_279_285
    ADD CONSTRAINT poly_stats_21_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 Z   ALTER TABLE ONLY public.poly_stats_21_279_285 DROP CONSTRAINT poly_stats_21_279_285_pkey;
       public         	   statsuser    false    292    292    292    292    4697                       2606    369520 4   poly_stats_21_285_38543 poly_stats_21_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_21_285_38543
    ADD CONSTRAINT poly_stats_21_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 ^   ALTER TABLE ONLY public.poly_stats_21_285_38543 DROP CONSTRAINT poly_stats_21_285_38543_pkey;
       public         	   statsuser    false    307    4697    307    307    307            _           2606    368360 *   poly_stats_2_1_257 poly_stats_2_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_2_1_257
    ADD CONSTRAINT poly_stats_2_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 T   ALTER TABLE ONLY public.poly_stats_2_1_257 DROP CONSTRAINT poly_stats_2_1_257_pkey;
       public         	   statsuser    false    249    249    249    249    4697            �           2606    368660 .   poly_stats_2_257_279 poly_stats_2_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_2_257_279
    ADD CONSTRAINT poly_stats_2_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_2_257_279 DROP CONSTRAINT poly_stats_2_257_279_pkey;
       public         	   statsuser    false    264    264    4697    264    264            �           2606    368960 .   poly_stats_2_279_285 poly_stats_2_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_2_279_285
    ADD CONSTRAINT poly_stats_2_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_2_279_285 DROP CONSTRAINT poly_stats_2_279_285_pkey;
       public         	   statsuser    false    279    279    279    4697    279            �           2606    369260 2   poly_stats_2_285_38543 poly_stats_2_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_2_285_38543
    ADD CONSTRAINT poly_stats_2_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 \   ALTER TABLE ONLY public.poly_stats_2_285_38543 DROP CONSTRAINT poly_stats_2_285_38543_pkey;
       public         	   statsuser    false    294    294    294    4697    294            b           2606    368380 *   poly_stats_3_1_257 poly_stats_3_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_3_1_257
    ADD CONSTRAINT poly_stats_3_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 T   ALTER TABLE ONLY public.poly_stats_3_1_257 DROP CONSTRAINT poly_stats_3_1_257_pkey;
       public         	   statsuser    false    250    250    4697    250    250            �           2606    368680 .   poly_stats_3_257_279 poly_stats_3_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_3_257_279
    ADD CONSTRAINT poly_stats_3_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_3_257_279 DROP CONSTRAINT poly_stats_3_257_279_pkey;
       public         	   statsuser    false    265    265    4697    265    265            �           2606    368980 .   poly_stats_3_279_285 poly_stats_3_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_3_279_285
    ADD CONSTRAINT poly_stats_3_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_3_279_285 DROP CONSTRAINT poly_stats_3_279_285_pkey;
       public         	   statsuser    false    280    280    4697    280    280            �           2606    369280 2   poly_stats_3_285_38543 poly_stats_3_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_3_285_38543
    ADD CONSTRAINT poly_stats_3_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 \   ALTER TABLE ONLY public.poly_stats_3_285_38543 DROP CONSTRAINT poly_stats_3_285_38543_pkey;
       public         	   statsuser    false    4697    295    295    295    295            e           2606    368400 *   poly_stats_4_1_257 poly_stats_4_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_4_1_257
    ADD CONSTRAINT poly_stats_4_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 T   ALTER TABLE ONLY public.poly_stats_4_1_257 DROP CONSTRAINT poly_stats_4_1_257_pkey;
       public         	   statsuser    false    4697    251    251    251    251            �           2606    368700 .   poly_stats_4_257_279 poly_stats_4_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_4_257_279
    ADD CONSTRAINT poly_stats_4_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_4_257_279 DROP CONSTRAINT poly_stats_4_257_279_pkey;
       public         	   statsuser    false    266    266    4697    266    266            �           2606    369000 .   poly_stats_4_279_285 poly_stats_4_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_4_279_285
    ADD CONSTRAINT poly_stats_4_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_4_279_285 DROP CONSTRAINT poly_stats_4_279_285_pkey;
       public         	   statsuser    false    4697    281    281    281    281            �           2606    369300 2   poly_stats_4_285_38543 poly_stats_4_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_4_285_38543
    ADD CONSTRAINT poly_stats_4_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 \   ALTER TABLE ONLY public.poly_stats_4_285_38543 DROP CONSTRAINT poly_stats_4_285_38543_pkey;
       public         	   statsuser    false    296    296    296    4697    296            h           2606    368420 *   poly_stats_5_1_257 poly_stats_5_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_5_1_257
    ADD CONSTRAINT poly_stats_5_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 T   ALTER TABLE ONLY public.poly_stats_5_1_257 DROP CONSTRAINT poly_stats_5_1_257_pkey;
       public         	   statsuser    false    4697    252    252    252    252            �           2606    368720 .   poly_stats_5_257_279 poly_stats_5_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_5_257_279
    ADD CONSTRAINT poly_stats_5_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_5_257_279 DROP CONSTRAINT poly_stats_5_257_279_pkey;
       public         	   statsuser    false    4697    267    267    267    267            �           2606    369020 .   poly_stats_5_279_285 poly_stats_5_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_5_279_285
    ADD CONSTRAINT poly_stats_5_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_5_279_285 DROP CONSTRAINT poly_stats_5_279_285_pkey;
       public         	   statsuser    false    4697    282    282    282    282            �           2606    369320 2   poly_stats_5_285_38543 poly_stats_5_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_5_285_38543
    ADD CONSTRAINT poly_stats_5_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 \   ALTER TABLE ONLY public.poly_stats_5_285_38543 DROP CONSTRAINT poly_stats_5_285_38543_pkey;
       public         	   statsuser    false    297    297    4697    297    297            k           2606    368440 *   poly_stats_6_1_257 poly_stats_6_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_6_1_257
    ADD CONSTRAINT poly_stats_6_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 T   ALTER TABLE ONLY public.poly_stats_6_1_257 DROP CONSTRAINT poly_stats_6_1_257_pkey;
       public         	   statsuser    false    253    4697    253    253    253            �           2606    368740 .   poly_stats_6_257_279 poly_stats_6_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_6_257_279
    ADD CONSTRAINT poly_stats_6_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_6_257_279 DROP CONSTRAINT poly_stats_6_257_279_pkey;
       public         	   statsuser    false    268    268    268    4697    268            �           2606    369040 .   poly_stats_6_279_285 poly_stats_6_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_6_279_285
    ADD CONSTRAINT poly_stats_6_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_6_279_285 DROP CONSTRAINT poly_stats_6_279_285_pkey;
       public         	   statsuser    false    283    283    283    4697    283            �           2606    369340 2   poly_stats_6_285_38543 poly_stats_6_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_6_285_38543
    ADD CONSTRAINT poly_stats_6_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 \   ALTER TABLE ONLY public.poly_stats_6_285_38543 DROP CONSTRAINT poly_stats_6_285_38543_pkey;
       public         	   statsuser    false    4697    298    298    298    298            n           2606    368460 *   poly_stats_7_1_257 poly_stats_7_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_7_1_257
    ADD CONSTRAINT poly_stats_7_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 T   ALTER TABLE ONLY public.poly_stats_7_1_257 DROP CONSTRAINT poly_stats_7_1_257_pkey;
       public         	   statsuser    false    254    4697    254    254    254            �           2606    368760 .   poly_stats_7_257_279 poly_stats_7_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_7_257_279
    ADD CONSTRAINT poly_stats_7_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_7_257_279 DROP CONSTRAINT poly_stats_7_257_279_pkey;
       public         	   statsuser    false    4697    269    269    269    269            �           2606    369060 .   poly_stats_7_279_285 poly_stats_7_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_7_279_285
    ADD CONSTRAINT poly_stats_7_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_7_279_285 DROP CONSTRAINT poly_stats_7_279_285_pkey;
       public         	   statsuser    false    4697    284    284    284    284            �           2606    369360 2   poly_stats_7_285_38543 poly_stats_7_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_7_285_38543
    ADD CONSTRAINT poly_stats_7_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 \   ALTER TABLE ONLY public.poly_stats_7_285_38543 DROP CONSTRAINT poly_stats_7_285_38543_pkey;
       public         	   statsuser    false    299    299    4697    299    299            q           2606    368480 *   poly_stats_9_1_257 poly_stats_9_1_257_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_9_1_257
    ADD CONSTRAINT poly_stats_9_1_257_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 T   ALTER TABLE ONLY public.poly_stats_9_1_257 DROP CONSTRAINT poly_stats_9_1_257_pkey;
       public         	   statsuser    false    4697    255    255    255    255            �           2606    368780 .   poly_stats_9_257_279 poly_stats_9_257_279_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_9_257_279
    ADD CONSTRAINT poly_stats_9_257_279_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_9_257_279 DROP CONSTRAINT poly_stats_9_257_279_pkey;
       public         	   statsuser    false    270    270    4697    270    270            �           2606    369080 .   poly_stats_9_279_285 poly_stats_9_279_285_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_9_279_285
    ADD CONSTRAINT poly_stats_9_279_285_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 X   ALTER TABLE ONLY public.poly_stats_9_279_285 DROP CONSTRAINT poly_stats_9_279_285_pkey;
       public         	   statsuser    false    285    285    4697    285    285            �           2606    369380 2   poly_stats_9_285_38543 poly_stats_9_285_38543_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats_9_285_38543
    ADD CONSTRAINT poly_stats_9_285_38543_pkey PRIMARY KEY (poly_id, product_file_id, product_file_variable_id);
 \   ALTER TABLE ONLY public.poly_stats_9_285_38543 DROP CONSTRAINT poly_stats_9_285_38543_pkey;
       public         	   statsuser    false    300    300    300    300    4697            A           2606    188007 6   product_file product_file_date_product_description_idx 
   CONSTRAINT     �   ALTER TABLE ONLY public.product_file
    ADD CONSTRAINT product_file_date_product_description_idx UNIQUE (product_file_description_id, date, rt_flag);
 `   ALTER TABLE ONLY public.product_file DROP CONSTRAINT product_file_date_product_description_idx;
       public         	   statsuser    false    230    230    230            C           2606    188009    product_file product_file_pk 
   CONSTRAINT     Z   ALTER TABLE ONLY public.product_file
    ADD CONSTRAINT product_file_pk PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.product_file DROP CONSTRAINT product_file_pk;
       public         	   statsuser    false    230            G           2606    188011 .   product_file_variable product_file_variable_pk 
   CONSTRAINT     l   ALTER TABLE ONLY public.product_file_variable
    ADD CONSTRAINT product_file_variable_pk PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.product_file_variable DROP CONSTRAINT product_file_variable_pk;
       public         	   statsuser    false    235            >           2606    188013    product product_pk1 
   CONSTRAINT     Q   ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_pk1 PRIMARY KEY (id);
 =   ALTER TABLE ONLY public.product DROP CONSTRAINT product_pk1;
       public         	   statsuser    false    229            E           2606    188015 <   product_file_description product_product_file_description_pk 
   CONSTRAINT     z   ALTER TABLE ONLY public.product_file_description
    ADD CONSTRAINT product_product_file_description_pk PRIMARY KEY (id);
 f   ALTER TABLE ONLY public.product_file_description DROP CONSTRAINT product_product_file_description_pk;
       public         	   statsuser    false    231            I           2606    188017     stratification stratification_pk 
   CONSTRAINT     ^   ALTER TABLE ONLY public.stratification
    ADD CONSTRAINT stratification_pk PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.stratification DROP CONSTRAINT stratification_pk;
       public         	   statsuser    false    238            O           2606    188019 '   stratification_geom stratification_pkey 
   CONSTRAINT     e   ALTER TABLE ONLY public.stratification_geom
    ADD CONSTRAINT stratification_pkey PRIMARY KEY (id);
 Q   ALTER TABLE ONLY public.stratification_geom DROP CONSTRAINT stratification_pkey;
       public         	   statsuser    false    239            K           2606    188021     stratification stratification_un 
   CONSTRAINT     b   ALTER TABLE ONLY public.stratification
    ADD CONSTRAINT stratification_un UNIQUE (description);
 J   ALTER TABLE ONLY public.stratification DROP CONSTRAINT stratification_un;
       public         	   statsuser    false    238            U           2606    363259    wms_file wms_file_pk 
   CONSTRAINT     R   ALTER TABLE ONLY public.wms_file
    ADD CONSTRAINT wms_file_pk PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.wms_file DROP CONSTRAINT wms_file_pk;
       public         	   statsuser    false    246            W           2606    363261    wms_file wms_file_un 
   CONSTRAINT     t   ALTER TABLE ONLY public.wms_file
    ADD CONSTRAINT wms_file_un UNIQUE (product_file_id, product_file_variable_id);
 >   ALTER TABLE ONLY public.wms_file DROP CONSTRAINT wms_file_un;
       public         	   statsuser    false    246    246            Q           2606    188023 #   poly_stats_per_region poly_stats_pk 
   CONSTRAINT     ^   ALTER TABLE ONLY tmp.poly_stats_per_region
    ADD CONSTRAINT poly_stats_pk PRIMARY KEY (id);
 J   ALTER TABLE ONLY tmp.poly_stats_per_region DROP CONSTRAINT poly_stats_pk;
       tmp         	   statsuser    false    243            S           2606    188025 #   poly_stats_per_region poly_stats_un 
   CONSTRAINT     �   ALTER TABLE ONLY tmp.poly_stats_per_region
    ADD CONSTRAINT poly_stats_un UNIQUE (poly_id, product_file_id, product_file_variable_id, region_id);
 J   ALTER TABLE ONLY tmp.poly_stats_per_region DROP CONSTRAINT poly_stats_un;
       tmp         	   statsuser    false    243    243    243    243            Z           1259    364732    poly_stats_product_file_id_idx    INDEX        CREATE INDEX poly_stats_product_file_id_idx ON ONLY public.poly_stats USING btree (product_file_id, product_file_variable_id);
 2   DROP INDEX public.poly_stats_product_file_id_idx;
       public         	   statsuser    false    247    247            u           1259    368501 ?   poly_stats_10_1_257_product_file_id_product_file_variable_i_idx    INDEX     �   CREATE INDEX poly_stats_10_1_257_product_file_id_product_file_variable_i_idx ON public.poly_stats_10_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_10_1_257_product_file_id_product_file_variable_i_idx;
       public         	   statsuser    false    256    256    4698    256            �           1259    368801 ?   poly_stats_10_257_279_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_10_257_279_product_file_id_product_file_variable_idx ON public.poly_stats_10_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_10_257_279_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    4698    271    271    271            �           1259    369101 ?   poly_stats_10_279_285_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_10_279_285_product_file_id_product_file_variable_idx ON public.poly_stats_10_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_10_279_285_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    4698    286    286    286            �           1259    369401 ?   poly_stats_10_285_38543_product_file_id_product_file_variab_idx    INDEX     �   CREATE INDEX poly_stats_10_285_38543_product_file_id_product_file_variab_idx ON public.poly_stats_10_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_10_285_38543_product_file_id_product_file_variab_idx;
       public         	   statsuser    false    4698    301    301    301            x           1259    368521 ?   poly_stats_12_1_257_product_file_id_product_file_variable_i_idx    INDEX     �   CREATE INDEX poly_stats_12_1_257_product_file_id_product_file_variable_i_idx ON public.poly_stats_12_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_12_1_257_product_file_id_product_file_variable_i_idx;
       public         	   statsuser    false    4698    257    257    257            �           1259    368821 ?   poly_stats_12_257_279_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_12_257_279_product_file_id_product_file_variable_idx ON public.poly_stats_12_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_12_257_279_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    272    272    4698    272            �           1259    369121 ?   poly_stats_12_279_285_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_12_279_285_product_file_id_product_file_variable_idx ON public.poly_stats_12_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_12_279_285_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    287    287    287    4698            �           1259    369421 ?   poly_stats_12_285_38543_product_file_id_product_file_variab_idx    INDEX     �   CREATE INDEX poly_stats_12_285_38543_product_file_id_product_file_variab_idx ON public.poly_stats_12_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_12_285_38543_product_file_id_product_file_variab_idx;
       public         	   statsuser    false    4698    302    302    302            {           1259    368541 ?   poly_stats_14_1_257_product_file_id_product_file_variable_i_idx    INDEX     �   CREATE INDEX poly_stats_14_1_257_product_file_id_product_file_variable_i_idx ON public.poly_stats_14_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_14_1_257_product_file_id_product_file_variable_i_idx;
       public         	   statsuser    false    258    258    4698    258            �           1259    368841 ?   poly_stats_14_257_279_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_14_257_279_product_file_id_product_file_variable_idx ON public.poly_stats_14_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_14_257_279_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    273    273    4698    273            �           1259    369141 ?   poly_stats_14_279_285_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_14_279_285_product_file_id_product_file_variable_idx ON public.poly_stats_14_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_14_279_285_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    288    288    4698    288                       1259    369441 ?   poly_stats_14_285_38543_product_file_id_product_file_variab_idx    INDEX     �   CREATE INDEX poly_stats_14_285_38543_product_file_id_product_file_variab_idx ON public.poly_stats_14_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_14_285_38543_product_file_id_product_file_variab_idx;
       public         	   statsuser    false    303    303    303    4698            ~           1259    368561 ?   poly_stats_16_1_257_product_file_id_product_file_variable_i_idx    INDEX     �   CREATE INDEX poly_stats_16_1_257_product_file_id_product_file_variable_i_idx ON public.poly_stats_16_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_16_1_257_product_file_id_product_file_variable_i_idx;
       public         	   statsuser    false    259    259    4698    259            �           1259    368861 ?   poly_stats_16_257_279_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_16_257_279_product_file_id_product_file_variable_idx ON public.poly_stats_16_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_16_257_279_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    4698    274    274    274            �           1259    369161 ?   poly_stats_16_279_285_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_16_279_285_product_file_id_product_file_variable_idx ON public.poly_stats_16_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_16_279_285_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    289    289    289    4698                       1259    369461 ?   poly_stats_16_285_38543_product_file_id_product_file_variab_idx    INDEX     �   CREATE INDEX poly_stats_16_285_38543_product_file_id_product_file_variab_idx ON public.poly_stats_16_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_16_285_38543_product_file_id_product_file_variab_idx;
       public         	   statsuser    false    4698    304    304    304            �           1259    368581 ?   poly_stats_17_1_257_product_file_id_product_file_variable_i_idx    INDEX     �   CREATE INDEX poly_stats_17_1_257_product_file_id_product_file_variable_i_idx ON public.poly_stats_17_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_17_1_257_product_file_id_product_file_variable_i_idx;
       public         	   statsuser    false    4698    260    260    260            �           1259    368881 ?   poly_stats_17_257_279_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_17_257_279_product_file_id_product_file_variable_idx ON public.poly_stats_17_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_17_257_279_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    4698    275    275    275            �           1259    369181 ?   poly_stats_17_279_285_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_17_279_285_product_file_id_product_file_variable_idx ON public.poly_stats_17_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_17_279_285_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    290    4698    290    290                       1259    369481 ?   poly_stats_17_285_38543_product_file_id_product_file_variab_idx    INDEX     �   CREATE INDEX poly_stats_17_285_38543_product_file_id_product_file_variab_idx ON public.poly_stats_17_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_17_285_38543_product_file_id_product_file_variab_idx;
       public         	   statsuser    false    4698    305    305    305            �           1259    368601 ?   poly_stats_19_1_257_product_file_id_product_file_variable_i_idx    INDEX     �   CREATE INDEX poly_stats_19_1_257_product_file_id_product_file_variable_i_idx ON public.poly_stats_19_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_19_1_257_product_file_id_product_file_variable_i_idx;
       public         	   statsuser    false    261    261    261    4698            �           1259    368901 ?   poly_stats_19_257_279_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_19_257_279_product_file_id_product_file_variable_idx ON public.poly_stats_19_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_19_257_279_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    4698    276    276    276            �           1259    369201 ?   poly_stats_19_279_285_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_19_279_285_product_file_id_product_file_variable_idx ON public.poly_stats_19_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_19_279_285_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    4698    291    291    291                       1259    369501 ?   poly_stats_19_285_38543_product_file_id_product_file_variab_idx    INDEX     �   CREATE INDEX poly_stats_19_285_38543_product_file_id_product_file_variab_idx ON public.poly_stats_19_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_19_285_38543_product_file_id_product_file_variab_idx;
       public         	   statsuser    false    306    306    4698    306            ]           1259    368341 ?   poly_stats_1_1_257_product_file_id_product_file_variable_id_idx    INDEX     �   CREATE INDEX poly_stats_1_1_257_product_file_id_product_file_variable_id_idx ON public.poly_stats_1_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_1_1_257_product_file_id_product_file_variable_id_idx;
       public         	   statsuser    false    248    248    4698    248            �           1259    368641 ?   poly_stats_1_257_279_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_1_257_279_product_file_id_product_file_variable__idx ON public.poly_stats_1_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_1_257_279_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    263    263    263    4698            �           1259    368941 ?   poly_stats_1_279_285_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_1_279_285_product_file_id_product_file_variable__idx ON public.poly_stats_1_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_1_279_285_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    278    4698    278    278            �           1259    369241 ?   poly_stats_1_285_38543_product_file_id_product_file_variabl_idx    INDEX     �   CREATE INDEX poly_stats_1_285_38543_product_file_id_product_file_variabl_idx ON public.poly_stats_1_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_1_285_38543_product_file_id_product_file_variabl_idx;
       public         	   statsuser    false    293    293    293    4698            �           1259    368621 ?   poly_stats_21_1_257_product_file_id_product_file_variable_i_idx    INDEX     �   CREATE INDEX poly_stats_21_1_257_product_file_id_product_file_variable_i_idx ON public.poly_stats_21_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_21_1_257_product_file_id_product_file_variable_i_idx;
       public         	   statsuser    false    262    262    4698    262            �           1259    368921 ?   poly_stats_21_257_279_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_21_257_279_product_file_id_product_file_variable_idx ON public.poly_stats_21_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_21_257_279_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    4698    277    277    277            �           1259    369221 ?   poly_stats_21_279_285_product_file_id_product_file_variable_idx    INDEX     �   CREATE INDEX poly_stats_21_279_285_product_file_id_product_file_variable_idx ON public.poly_stats_21_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_21_279_285_product_file_id_product_file_variable_idx;
       public         	   statsuser    false    292    4698    292    292                       1259    369521 ?   poly_stats_21_285_38543_product_file_id_product_file_variab_idx    INDEX     �   CREATE INDEX poly_stats_21_285_38543_product_file_id_product_file_variab_idx ON public.poly_stats_21_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_21_285_38543_product_file_id_product_file_variab_idx;
       public         	   statsuser    false    307    307    4698    307            `           1259    368361 ?   poly_stats_2_1_257_product_file_id_product_file_variable_id_idx    INDEX     �   CREATE INDEX poly_stats_2_1_257_product_file_id_product_file_variable_id_idx ON public.poly_stats_2_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_2_1_257_product_file_id_product_file_variable_id_idx;
       public         	   statsuser    false    249    249    4698    249            �           1259    368661 ?   poly_stats_2_257_279_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_2_257_279_product_file_id_product_file_variable__idx ON public.poly_stats_2_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_2_257_279_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    264    264    4698    264            �           1259    368961 ?   poly_stats_2_279_285_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_2_279_285_product_file_id_product_file_variable__idx ON public.poly_stats_2_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_2_279_285_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    279    279    4698    279            �           1259    369261 ?   poly_stats_2_285_38543_product_file_id_product_file_variabl_idx    INDEX     �   CREATE INDEX poly_stats_2_285_38543_product_file_id_product_file_variabl_idx ON public.poly_stats_2_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_2_285_38543_product_file_id_product_file_variabl_idx;
       public         	   statsuser    false    294    4698    294    294            c           1259    368381 ?   poly_stats_3_1_257_product_file_id_product_file_variable_id_idx    INDEX     �   CREATE INDEX poly_stats_3_1_257_product_file_id_product_file_variable_id_idx ON public.poly_stats_3_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_3_1_257_product_file_id_product_file_variable_id_idx;
       public         	   statsuser    false    250    4698    250    250            �           1259    368681 ?   poly_stats_3_257_279_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_3_257_279_product_file_id_product_file_variable__idx ON public.poly_stats_3_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_3_257_279_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    265    4698    265    265            �           1259    368981 ?   poly_stats_3_279_285_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_3_279_285_product_file_id_product_file_variable__idx ON public.poly_stats_3_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_3_279_285_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    280    280    280    4698            �           1259    369281 ?   poly_stats_3_285_38543_product_file_id_product_file_variabl_idx    INDEX     �   CREATE INDEX poly_stats_3_285_38543_product_file_id_product_file_variabl_idx ON public.poly_stats_3_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_3_285_38543_product_file_id_product_file_variabl_idx;
       public         	   statsuser    false    4698    295    295    295            f           1259    368401 ?   poly_stats_4_1_257_product_file_id_product_file_variable_id_idx    INDEX     �   CREATE INDEX poly_stats_4_1_257_product_file_id_product_file_variable_id_idx ON public.poly_stats_4_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_4_1_257_product_file_id_product_file_variable_id_idx;
       public         	   statsuser    false    4698    251    251    251            �           1259    368701 ?   poly_stats_4_257_279_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_4_257_279_product_file_id_product_file_variable__idx ON public.poly_stats_4_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_4_257_279_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    266    4698    266    266            �           1259    369001 ?   poly_stats_4_279_285_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_4_279_285_product_file_id_product_file_variable__idx ON public.poly_stats_4_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_4_279_285_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    281    281    4698    281            �           1259    369301 ?   poly_stats_4_285_38543_product_file_id_product_file_variabl_idx    INDEX     �   CREATE INDEX poly_stats_4_285_38543_product_file_id_product_file_variabl_idx ON public.poly_stats_4_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_4_285_38543_product_file_id_product_file_variabl_idx;
       public         	   statsuser    false    4698    296    296    296            i           1259    368421 ?   poly_stats_5_1_257_product_file_id_product_file_variable_id_idx    INDEX     �   CREATE INDEX poly_stats_5_1_257_product_file_id_product_file_variable_id_idx ON public.poly_stats_5_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_5_1_257_product_file_id_product_file_variable_id_idx;
       public         	   statsuser    false    252    4698    252    252            �           1259    368721 ?   poly_stats_5_257_279_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_5_257_279_product_file_id_product_file_variable__idx ON public.poly_stats_5_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_5_257_279_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    4698    267    267    267            �           1259    369021 ?   poly_stats_5_279_285_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_5_279_285_product_file_id_product_file_variable__idx ON public.poly_stats_5_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_5_279_285_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    282    282    282    4698            �           1259    369321 ?   poly_stats_5_285_38543_product_file_id_product_file_variabl_idx    INDEX     �   CREATE INDEX poly_stats_5_285_38543_product_file_id_product_file_variabl_idx ON public.poly_stats_5_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_5_285_38543_product_file_id_product_file_variabl_idx;
       public         	   statsuser    false    297    297    297    4698            l           1259    368441 ?   poly_stats_6_1_257_product_file_id_product_file_variable_id_idx    INDEX     �   CREATE INDEX poly_stats_6_1_257_product_file_id_product_file_variable_id_idx ON public.poly_stats_6_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_6_1_257_product_file_id_product_file_variable_id_idx;
       public         	   statsuser    false    4698    253    253    253            �           1259    368741 ?   poly_stats_6_257_279_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_6_257_279_product_file_id_product_file_variable__idx ON public.poly_stats_6_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_6_257_279_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    268    268    268    4698            �           1259    369041 ?   poly_stats_6_279_285_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_6_279_285_product_file_id_product_file_variable__idx ON public.poly_stats_6_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_6_279_285_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    283    283    283    4698            �           1259    369341 ?   poly_stats_6_285_38543_product_file_id_product_file_variabl_idx    INDEX     �   CREATE INDEX poly_stats_6_285_38543_product_file_id_product_file_variabl_idx ON public.poly_stats_6_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_6_285_38543_product_file_id_product_file_variabl_idx;
       public         	   statsuser    false    298    298    298    4698            o           1259    368461 ?   poly_stats_7_1_257_product_file_id_product_file_variable_id_idx    INDEX     �   CREATE INDEX poly_stats_7_1_257_product_file_id_product_file_variable_id_idx ON public.poly_stats_7_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_7_1_257_product_file_id_product_file_variable_id_idx;
       public         	   statsuser    false    4698    254    254    254            �           1259    368761 ?   poly_stats_7_257_279_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_7_257_279_product_file_id_product_file_variable__idx ON public.poly_stats_7_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_7_257_279_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    269    269    4698    269            �           1259    369061 ?   poly_stats_7_279_285_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_7_279_285_product_file_id_product_file_variable__idx ON public.poly_stats_7_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_7_279_285_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    284    284    284    4698            �           1259    369361 ?   poly_stats_7_285_38543_product_file_id_product_file_variabl_idx    INDEX     �   CREATE INDEX poly_stats_7_285_38543_product_file_id_product_file_variabl_idx ON public.poly_stats_7_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_7_285_38543_product_file_id_product_file_variabl_idx;
       public         	   statsuser    false    299    299    299    4698            r           1259    368481 ?   poly_stats_9_1_257_product_file_id_product_file_variable_id_idx    INDEX     �   CREATE INDEX poly_stats_9_1_257_product_file_id_product_file_variable_id_idx ON public.poly_stats_9_1_257 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_9_1_257_product_file_id_product_file_variable_id_idx;
       public         	   statsuser    false    4698    255    255    255            �           1259    368781 ?   poly_stats_9_257_279_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_9_257_279_product_file_id_product_file_variable__idx ON public.poly_stats_9_257_279 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_9_257_279_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    270    4698    270    270            �           1259    369081 ?   poly_stats_9_279_285_product_file_id_product_file_variable__idx    INDEX     �   CREATE INDEX poly_stats_9_279_285_product_file_id_product_file_variable__idx ON public.poly_stats_9_279_285 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_9_279_285_product_file_id_product_file_variable__idx;
       public         	   statsuser    false    285    285    285    4698            �           1259    369381 ?   poly_stats_9_285_38543_product_file_id_product_file_variabl_idx    INDEX     �   CREATE INDEX poly_stats_9_285_38543_product_file_id_product_file_variabl_idx ON public.poly_stats_9_285_38543 USING btree (product_file_id, product_file_variable_id);
 S   DROP INDEX public.poly_stats_9_285_38543_product_file_id_product_file_variabl_idx;
       public         	   statsuser    false    300    300    4698    300            ?           1259    369610    product_file_date_idx    INDEX     W   CREATE INDEX product_file_date_idx ON public.product_file USING btree (date, rt_flag);
 )   DROP INDEX public.product_file_date_idx;
       public         	   statsuser    false    230    230            L           1259    188026    sidx_stratification_geom    INDEX     W   CREATE INDEX sidx_stratification_geom ON public.stratification_geom USING gist (geom);
 ,   DROP INDEX public.sidx_stratification_geom;
       public         	   statsuser    false    239    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3            M           1259    188027    sidx_stratification_geom3857    INDEX     �   CREATE INDEX sidx_stratification_geom3857 ON public.stratification_geom USING gist (geom3857);

ALTER TABLE public.stratification_geom CLUSTER ON sidx_stratification_geom3857;
 0   DROP INDEX public.sidx_stratification_geom3857;
       public         	   statsuser    false    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    239                       0    0    poly_stats_10_1_257_pkey    INDEX ATTACH     T   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_10_1_257_pkey;
          public       	   statsuser    false    4697    256    4724    4697    256    247                        0    0 ?   poly_stats_10_1_257_product_file_id_product_file_variable_i_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_10_1_257_product_file_id_product_file_variable_i_idx;
          public       	   statsuser    false    4725    4698    256    247            =           0    0    poly_stats_10_257_279_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_10_257_279_pkey;
          public       	   statsuser    false    271    4769    4697    4697    271    247            >           0    0 ?   poly_stats_10_257_279_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_10_257_279_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4770    4698    271    247            [           0    0    poly_stats_10_279_285_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_10_279_285_pkey;
          public       	   statsuser    false    286    4814    4697    4697    286    247            \           0    0 ?   poly_stats_10_279_285_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_10_279_285_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4815    4698    286    247            y           0    0    poly_stats_10_285_38543_pkey    INDEX ATTACH     X   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_10_285_38543_pkey;
          public       	   statsuser    false    301    4697    4859    4697    301    247            z           0    0 ?   poly_stats_10_285_38543_product_file_id_product_file_variab_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_10_285_38543_product_file_id_product_file_variab_idx;
          public       	   statsuser    false    4860    4698    301    247            !           0    0    poly_stats_12_1_257_pkey    INDEX ATTACH     T   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_12_1_257_pkey;
          public       	   statsuser    false    257    4727    4697    4697    257    247            "           0    0 ?   poly_stats_12_1_257_product_file_id_product_file_variable_i_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_12_1_257_product_file_id_product_file_variable_i_idx;
          public       	   statsuser    false    4728    4698    257    247            ?           0    0    poly_stats_12_257_279_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_12_257_279_pkey;
          public       	   statsuser    false    4697    4772    272    4697    272    247            @           0    0 ?   poly_stats_12_257_279_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_12_257_279_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4773    4698    272    247            ]           0    0    poly_stats_12_279_285_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_12_279_285_pkey;
          public       	   statsuser    false    4697    4817    287    4697    287    247            ^           0    0 ?   poly_stats_12_279_285_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_12_279_285_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4818    4698    287    247            {           0    0    poly_stats_12_285_38543_pkey    INDEX ATTACH     X   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_12_285_38543_pkey;
          public       	   statsuser    false    4697    4862    302    4697    302    247            |           0    0 ?   poly_stats_12_285_38543_product_file_id_product_file_variab_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_12_285_38543_product_file_id_product_file_variab_idx;
          public       	   statsuser    false    4863    4698    302    247            #           0    0    poly_stats_14_1_257_pkey    INDEX ATTACH     T   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_14_1_257_pkey;
          public       	   statsuser    false    258    4697    4730    4697    258    247            $           0    0 ?   poly_stats_14_1_257_product_file_id_product_file_variable_i_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_14_1_257_product_file_id_product_file_variable_i_idx;
          public       	   statsuser    false    4731    4698    258    247            A           0    0    poly_stats_14_257_279_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_14_257_279_pkey;
          public       	   statsuser    false    4775    4697    273    4697    273    247            B           0    0 ?   poly_stats_14_257_279_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_14_257_279_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4776    4698    273    247            _           0    0    poly_stats_14_279_285_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_14_279_285_pkey;
          public       	   statsuser    false    4697    288    4820    4697    288    247            `           0    0 ?   poly_stats_14_279_285_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_14_279_285_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4821    4698    288    247            }           0    0    poly_stats_14_285_38543_pkey    INDEX ATTACH     X   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_14_285_38543_pkey;
          public       	   statsuser    false    303    4865    4697    4697    303    247            ~           0    0 ?   poly_stats_14_285_38543_product_file_id_product_file_variab_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_14_285_38543_product_file_id_product_file_variab_idx;
          public       	   statsuser    false    4866    4698    303    247            %           0    0    poly_stats_16_1_257_pkey    INDEX ATTACH     T   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_16_1_257_pkey;
          public       	   statsuser    false    4697    259    4733    4697    259    247            &           0    0 ?   poly_stats_16_1_257_product_file_id_product_file_variable_i_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_16_1_257_product_file_id_product_file_variable_i_idx;
          public       	   statsuser    false    4734    4698    259    247            C           0    0    poly_stats_16_257_279_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_16_257_279_pkey;
          public       	   statsuser    false    4697    274    4778    4697    274    247            D           0    0 ?   poly_stats_16_257_279_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_16_257_279_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4779    4698    274    247            a           0    0    poly_stats_16_279_285_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_16_279_285_pkey;
          public       	   statsuser    false    289    4697    4823    4697    289    247            b           0    0 ?   poly_stats_16_279_285_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_16_279_285_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4824    4698    289    247                       0    0    poly_stats_16_285_38543_pkey    INDEX ATTACH     X   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_16_285_38543_pkey;
          public       	   statsuser    false    4868    4697    304    4697    304    247            �           0    0 ?   poly_stats_16_285_38543_product_file_id_product_file_variab_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_16_285_38543_product_file_id_product_file_variab_idx;
          public       	   statsuser    false    4869    4698    304    247            '           0    0    poly_stats_17_1_257_pkey    INDEX ATTACH     T   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_17_1_257_pkey;
          public       	   statsuser    false    4697    260    4736    4697    260    247            (           0    0 ?   poly_stats_17_1_257_product_file_id_product_file_variable_i_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_17_1_257_product_file_id_product_file_variable_i_idx;
          public       	   statsuser    false    4737    4698    260    247            E           0    0    poly_stats_17_257_279_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_17_257_279_pkey;
          public       	   statsuser    false    275    4697    4781    4697    275    247            F           0    0 ?   poly_stats_17_257_279_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_17_257_279_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4782    4698    275    247            c           0    0    poly_stats_17_279_285_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_17_279_285_pkey;
          public       	   statsuser    false    4826    4697    290    4697    290    247            d           0    0 ?   poly_stats_17_279_285_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_17_279_285_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4827    4698    290    247            �           0    0    poly_stats_17_285_38543_pkey    INDEX ATTACH     X   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_17_285_38543_pkey;
          public       	   statsuser    false    4871    4697    305    4697    305    247            �           0    0 ?   poly_stats_17_285_38543_product_file_id_product_file_variab_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_17_285_38543_product_file_id_product_file_variab_idx;
          public       	   statsuser    false    4872    4698    305    247            )           0    0    poly_stats_19_1_257_pkey    INDEX ATTACH     T   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_19_1_257_pkey;
          public       	   statsuser    false    4739    261    4697    4697    261    247            *           0    0 ?   poly_stats_19_1_257_product_file_id_product_file_variable_i_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_19_1_257_product_file_id_product_file_variable_i_idx;
          public       	   statsuser    false    4740    4698    261    247            G           0    0    poly_stats_19_257_279_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_19_257_279_pkey;
          public       	   statsuser    false    4784    4697    276    4697    276    247            H           0    0 ?   poly_stats_19_257_279_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_19_257_279_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4785    4698    276    247            e           0    0    poly_stats_19_279_285_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_19_279_285_pkey;
          public       	   statsuser    false    291    4829    4697    4697    291    247            f           0    0 ?   poly_stats_19_279_285_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_19_279_285_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4830    4698    291    247            �           0    0    poly_stats_19_285_38543_pkey    INDEX ATTACH     X   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_19_285_38543_pkey;
          public       	   statsuser    false    4697    4874    306    4697    306    247            �           0    0 ?   poly_stats_19_285_38543_product_file_id_product_file_variab_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_19_285_38543_product_file_id_product_file_variab_idx;
          public       	   statsuser    false    4875    4698    306    247                       0    0    poly_stats_1_1_257_pkey    INDEX ATTACH     S   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_1_1_257_pkey;
          public       	   statsuser    false    4700    248    4697    4697    248    247                       0    0 ?   poly_stats_1_1_257_product_file_id_product_file_variable_id_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_1_1_257_product_file_id_product_file_variable_id_idx;
          public       	   statsuser    false    4701    4698    248    247            -           0    0    poly_stats_1_257_279_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_1_257_279_pkey;
          public       	   statsuser    false    4697    4745    263    4697    263    247            .           0    0 ?   poly_stats_1_257_279_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_1_257_279_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4746    4698    263    247            K           0    0    poly_stats_1_279_285_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_1_279_285_pkey;
          public       	   statsuser    false    4790    278    4697    4697    278    247            L           0    0 ?   poly_stats_1_279_285_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_1_279_285_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4791    4698    278    247            i           0    0    poly_stats_1_285_38543_pkey    INDEX ATTACH     W   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_1_285_38543_pkey;
          public       	   statsuser    false    293    4835    4697    4697    293    247            j           0    0 ?   poly_stats_1_285_38543_product_file_id_product_file_variabl_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_1_285_38543_product_file_id_product_file_variabl_idx;
          public       	   statsuser    false    4836    4698    293    247            +           0    0    poly_stats_21_1_257_pkey    INDEX ATTACH     T   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_21_1_257_pkey;
          public       	   statsuser    false    4742    262    4697    4697    262    247            ,           0    0 ?   poly_stats_21_1_257_product_file_id_product_file_variable_i_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_21_1_257_product_file_id_product_file_variable_i_idx;
          public       	   statsuser    false    4743    4698    262    247            I           0    0    poly_stats_21_257_279_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_21_257_279_pkey;
          public       	   statsuser    false    4697    277    4787    4697    277    247            J           0    0 ?   poly_stats_21_257_279_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_21_257_279_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4788    4698    277    247            g           0    0    poly_stats_21_279_285_pkey    INDEX ATTACH     V   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_21_279_285_pkey;
          public       	   statsuser    false    4697    292    4832    4697    292    247            h           0    0 ?   poly_stats_21_279_285_product_file_id_product_file_variable_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_21_279_285_product_file_id_product_file_variable_idx;
          public       	   statsuser    false    4833    4698    292    247            �           0    0    poly_stats_21_285_38543_pkey    INDEX ATTACH     X   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_21_285_38543_pkey;
          public       	   statsuser    false    4697    4877    307    4697    307    247            �           0    0 ?   poly_stats_21_285_38543_product_file_id_product_file_variab_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_21_285_38543_product_file_id_product_file_variab_idx;
          public       	   statsuser    false    4878    4698    307    247                       0    0    poly_stats_2_1_257_pkey    INDEX ATTACH     S   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_2_1_257_pkey;
          public       	   statsuser    false    249    4697    4703    4697    249    247                       0    0 ?   poly_stats_2_1_257_product_file_id_product_file_variable_id_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_2_1_257_product_file_id_product_file_variable_id_idx;
          public       	   statsuser    false    4704    4698    249    247            /           0    0    poly_stats_2_257_279_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_2_257_279_pkey;
          public       	   statsuser    false    4748    264    4697    4697    264    247            0           0    0 ?   poly_stats_2_257_279_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_2_257_279_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4749    4698    264    247            M           0    0    poly_stats_2_279_285_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_2_279_285_pkey;
          public       	   statsuser    false    279    4697    4793    4697    279    247            N           0    0 ?   poly_stats_2_279_285_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_2_279_285_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4794    4698    279    247            k           0    0    poly_stats_2_285_38543_pkey    INDEX ATTACH     W   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_2_285_38543_pkey;
          public       	   statsuser    false    4838    4697    294    4697    294    247            l           0    0 ?   poly_stats_2_285_38543_product_file_id_product_file_variabl_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_2_285_38543_product_file_id_product_file_variabl_idx;
          public       	   statsuser    false    4839    4698    294    247                       0    0    poly_stats_3_1_257_pkey    INDEX ATTACH     S   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_3_1_257_pkey;
          public       	   statsuser    false    4706    4697    250    4697    250    247                       0    0 ?   poly_stats_3_1_257_product_file_id_product_file_variable_id_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_3_1_257_product_file_id_product_file_variable_id_idx;
          public       	   statsuser    false    4707    4698    250    247            1           0    0    poly_stats_3_257_279_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_3_257_279_pkey;
          public       	   statsuser    false    265    4751    4697    4697    265    247            2           0    0 ?   poly_stats_3_257_279_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_3_257_279_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4752    4698    265    247            O           0    0    poly_stats_3_279_285_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_3_279_285_pkey;
          public       	   statsuser    false    4796    4697    280    4697    280    247            P           0    0 ?   poly_stats_3_279_285_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_3_279_285_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4797    4698    280    247            m           0    0    poly_stats_3_285_38543_pkey    INDEX ATTACH     W   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_3_285_38543_pkey;
          public       	   statsuser    false    4841    295    4697    4697    295    247            n           0    0 ?   poly_stats_3_285_38543_product_file_id_product_file_variabl_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_3_285_38543_product_file_id_product_file_variabl_idx;
          public       	   statsuser    false    4842    4698    295    247                       0    0    poly_stats_4_1_257_pkey    INDEX ATTACH     S   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_4_1_257_pkey;
          public       	   statsuser    false    251    4697    4709    4697    251    247                       0    0 ?   poly_stats_4_1_257_product_file_id_product_file_variable_id_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_4_1_257_product_file_id_product_file_variable_id_idx;
          public       	   statsuser    false    4710    4698    251    247            3           0    0    poly_stats_4_257_279_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_4_257_279_pkey;
          public       	   statsuser    false    4754    4697    266    4697    266    247            4           0    0 ?   poly_stats_4_257_279_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_4_257_279_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4755    4698    266    247            Q           0    0    poly_stats_4_279_285_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_4_279_285_pkey;
          public       	   statsuser    false    4799    4697    281    4697    281    247            R           0    0 ?   poly_stats_4_279_285_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_4_279_285_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4800    4698    281    247            o           0    0    poly_stats_4_285_38543_pkey    INDEX ATTACH     W   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_4_285_38543_pkey;
          public       	   statsuser    false    296    4844    4697    4697    296    247            p           0    0 ?   poly_stats_4_285_38543_product_file_id_product_file_variabl_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_4_285_38543_product_file_id_product_file_variabl_idx;
          public       	   statsuser    false    4845    4698    296    247                       0    0    poly_stats_5_1_257_pkey    INDEX ATTACH     S   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_5_1_257_pkey;
          public       	   statsuser    false    4697    252    4712    4697    252    247                       0    0 ?   poly_stats_5_1_257_product_file_id_product_file_variable_id_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_5_1_257_product_file_id_product_file_variable_id_idx;
          public       	   statsuser    false    4713    4698    252    247            5           0    0    poly_stats_5_257_279_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_5_257_279_pkey;
          public       	   statsuser    false    267    4697    4757    4697    267    247            6           0    0 ?   poly_stats_5_257_279_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_5_257_279_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4758    4698    267    247            S           0    0    poly_stats_5_279_285_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_5_279_285_pkey;
          public       	   statsuser    false    4802    4697    282    4697    282    247            T           0    0 ?   poly_stats_5_279_285_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_5_279_285_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4803    4698    282    247            q           0    0    poly_stats_5_285_38543_pkey    INDEX ATTACH     W   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_5_285_38543_pkey;
          public       	   statsuser    false    4847    297    4697    4697    297    247            r           0    0 ?   poly_stats_5_285_38543_product_file_id_product_file_variabl_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_5_285_38543_product_file_id_product_file_variabl_idx;
          public       	   statsuser    false    4848    4698    297    247                       0    0    poly_stats_6_1_257_pkey    INDEX ATTACH     S   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_6_1_257_pkey;
          public       	   statsuser    false    4715    4697    253    4697    253    247                       0    0 ?   poly_stats_6_1_257_product_file_id_product_file_variable_id_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_6_1_257_product_file_id_product_file_variable_id_idx;
          public       	   statsuser    false    4716    4698    253    247            7           0    0    poly_stats_6_257_279_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_6_257_279_pkey;
          public       	   statsuser    false    4697    4760    268    4697    268    247            8           0    0 ?   poly_stats_6_257_279_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_6_257_279_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4761    4698    268    247            U           0    0    poly_stats_6_279_285_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_6_279_285_pkey;
          public       	   statsuser    false    4697    4805    283    4697    283    247            V           0    0 ?   poly_stats_6_279_285_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_6_279_285_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4806    4698    283    247            s           0    0    poly_stats_6_285_38543_pkey    INDEX ATTACH     W   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_6_285_38543_pkey;
          public       	   statsuser    false    4850    298    4697    4697    298    247            t           0    0 ?   poly_stats_6_285_38543_product_file_id_product_file_variabl_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_6_285_38543_product_file_id_product_file_variabl_idx;
          public       	   statsuser    false    4851    4698    298    247                       0    0    poly_stats_7_1_257_pkey    INDEX ATTACH     S   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_7_1_257_pkey;
          public       	   statsuser    false    254    4718    4697    4697    254    247                       0    0 ?   poly_stats_7_1_257_product_file_id_product_file_variable_id_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_7_1_257_product_file_id_product_file_variable_id_idx;
          public       	   statsuser    false    4719    4698    254    247            9           0    0    poly_stats_7_257_279_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_7_257_279_pkey;
          public       	   statsuser    false    4697    4763    269    4697    269    247            :           0    0 ?   poly_stats_7_257_279_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_7_257_279_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4764    4698    269    247            W           0    0    poly_stats_7_279_285_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_7_279_285_pkey;
          public       	   statsuser    false    4697    4808    284    4697    284    247            X           0    0 ?   poly_stats_7_279_285_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_7_279_285_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4809    4698    284    247            u           0    0    poly_stats_7_285_38543_pkey    INDEX ATTACH     W   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_7_285_38543_pkey;
          public       	   statsuser    false    4853    4697    299    4697    299    247            v           0    0 ?   poly_stats_7_285_38543_product_file_id_product_file_variabl_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_7_285_38543_product_file_id_product_file_variabl_idx;
          public       	   statsuser    false    4854    4698    299    247                       0    0    poly_stats_9_1_257_pkey    INDEX ATTACH     S   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_9_1_257_pkey;
          public       	   statsuser    false    4721    255    4697    4697    255    247                       0    0 ?   poly_stats_9_1_257_product_file_id_product_file_variable_id_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_9_1_257_product_file_id_product_file_variable_id_idx;
          public       	   statsuser    false    4722    4698    255    247            ;           0    0    poly_stats_9_257_279_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_9_257_279_pkey;
          public       	   statsuser    false    4697    270    4766    4697    270    247            <           0    0 ?   poly_stats_9_257_279_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_9_257_279_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4767    4698    270    247            Y           0    0    poly_stats_9_279_285_pkey    INDEX ATTACH     U   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_9_279_285_pkey;
          public       	   statsuser    false    285    4811    4697    4697    285    247            Z           0    0 ?   poly_stats_9_279_285_product_file_id_product_file_variable__idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_9_279_285_product_file_id_product_file_variable__idx;
          public       	   statsuser    false    4812    4698    285    247            w           0    0    poly_stats_9_285_38543_pkey    INDEX ATTACH     W   ALTER INDEX public.poly_stats_pk_ ATTACH PARTITION public.poly_stats_9_285_38543_pkey;
          public       	   statsuser    false    4697    300    4856    4697    300    247            x           0    0 ?   poly_stats_9_285_38543_product_file_id_product_file_variabl_idx    INDEX ATTACH     �   ALTER INDEX public.poly_stats_product_file_id_idx ATTACH PARTITION public.poly_stats_9_285_38543_product_file_id_product_file_variabl_idx;
          public       	   statsuser    false    4857    4698    300    247            �           2606    188028 0   long_term_anomaly_info long_term_anomaly_info_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.long_term_anomaly_info
    ADD CONSTRAINT long_term_anomaly_info_fk FOREIGN KEY (anomaly_product_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 Z   ALTER TABLE ONLY public.long_term_anomaly_info DROP CONSTRAINT long_term_anomaly_info_fk;
       public       	   statsuser    false    226    4679    235            �           2606    188033 2   long_term_anomaly_info long_term_anomaly_info_fk_1    FK CONSTRAINT     �   ALTER TABLE ONLY public.long_term_anomaly_info
    ADD CONSTRAINT long_term_anomaly_info_fk_1 FOREIGN KEY (mean_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 \   ALTER TABLE ONLY public.long_term_anomaly_info DROP CONSTRAINT long_term_anomaly_info_fk_1;
       public       	   statsuser    false    226    4679    235            �           2606    188038 2   long_term_anomaly_info long_term_anomaly_info_fk_2    FK CONSTRAINT     �   ALTER TABLE ONLY public.long_term_anomaly_info
    ADD CONSTRAINT long_term_anomaly_info_fk_2 FOREIGN KEY (stdev_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 \   ALTER TABLE ONLY public.long_term_anomaly_info DROP CONSTRAINT long_term_anomaly_info_fk_2;
       public       	   statsuser    false    226    4679    235            �           2606    188043 2   long_term_anomaly_info long_term_anomaly_info_fk_3    FK CONSTRAINT     �   ALTER TABLE ONLY public.long_term_anomaly_info
    ADD CONSTRAINT long_term_anomaly_info_fk_3 FOREIGN KEY (raw_product_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 \   ALTER TABLE ONLY public.long_term_anomaly_info DROP CONSTRAINT long_term_anomaly_info_fk_3;
       public       	   statsuser    false    235    4679    226            �           2606    364717 &   poly_stats poly_stats_product_file_fk_    FK CONSTRAINT     �   ALTER TABLE public.poly_stats
    ADD CONSTRAINT poly_stats_product_file_fk_ FOREIGN KEY (product_file_id) REFERENCES public.product_file(id) ON UPDATE CASCADE ON DELETE CASCADE;
 K   ALTER TABLE public.poly_stats DROP CONSTRAINT poly_stats_product_file_fk_;
       public       	   statsuser    false    4675    230    247            �           2606    364722 *   poly_stats poly_stats_product_variable_fk_    FK CONSTRAINT     �   ALTER TABLE public.poly_stats
    ADD CONSTRAINT poly_stats_product_variable_fk_ FOREIGN KEY (product_file_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 O   ALTER TABLE public.poly_stats DROP CONSTRAINT poly_stats_product_variable_fk_;
       public       	   statsuser    false    235    4679    247            �           2606    364727 -   poly_stats poly_stats_stratification_geom_fk_    FK CONSTRAINT     �   ALTER TABLE public.poly_stats
    ADD CONSTRAINT poly_stats_stratification_geom_fk_ FOREIGN KEY (poly_id) REFERENCES public.stratification_geom(id) ON UPDATE CASCADE ON DELETE CASCADE;
 R   ALTER TABLE public.poly_stats DROP CONSTRAINT poly_stats_stratification_geom_fk_;
       public       	   statsuser    false    4687    247    239            �           2606    188063 4   product_file_description product_file_description_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.product_file_description
    ADD CONSTRAINT product_file_description_fk FOREIGN KEY (product_id) REFERENCES public.product(id) ON UPDATE CASCADE ON DELETE CASCADE;
 ^   ALTER TABLE ONLY public.product_file_description DROP CONSTRAINT product_file_description_fk;
       public       	   statsuser    false    231    229    4670            �           2606    188068    product product_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_fk FOREIGN KEY (category_id) REFERENCES public.category(id) ON UPDATE CASCADE ON DELETE CASCADE;
 <   ALTER TABLE ONLY public.product DROP CONSTRAINT product_fk;
       public       	   statsuser    false    4666    224    229            �           2606    188073 *   stratification_geom stratification_geom_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.stratification_geom
    ADD CONSTRAINT stratification_geom_fk FOREIGN KEY (stratification_id) REFERENCES public.stratification(id) ON DELETE CASCADE;
 T   ALTER TABLE ONLY public.stratification_geom DROP CONSTRAINT stratification_geom_fk;
       public       	   statsuser    false    239    238    4681            �           2606    363262    wms_file wms_file_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.wms_file
    ADD CONSTRAINT wms_file_fk FOREIGN KEY (product_file_id) REFERENCES public.product_file(id) ON UPDATE CASCADE ON DELETE CASCADE;
 >   ALTER TABLE ONLY public.wms_file DROP CONSTRAINT wms_file_fk;
       public       	   statsuser    false    246    4675    230            �           2606    363267    wms_file wms_file_fk2    FK CONSTRAINT     �   ALTER TABLE ONLY public.wms_file
    ADD CONSTRAINT wms_file_fk2 FOREIGN KEY (product_file_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 ?   ALTER TABLE ONLY public.wms_file DROP CONSTRAINT wms_file_fk2;
       public       	   statsuser    false    246    235    4679            �           2606    188078 0   poly_stats_per_region poly_stats_product_file_fk    FK CONSTRAINT     �   ALTER TABLE ONLY tmp.poly_stats_per_region
    ADD CONSTRAINT poly_stats_product_file_fk FOREIGN KEY (product_file_id) REFERENCES public.product_file(id) ON UPDATE CASCADE ON DELETE CASCADE;
 W   ALTER TABLE ONLY tmp.poly_stats_per_region DROP CONSTRAINT poly_stats_product_file_fk;
       tmp       	   statsuser    false    230    243    4675            �           2606    188083 9   poly_stats_per_region poly_stats_product_file_variable_fk    FK CONSTRAINT     �   ALTER TABLE ONLY tmp.poly_stats_per_region
    ADD CONSTRAINT poly_stats_product_file_variable_fk FOREIGN KEY (product_file_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 `   ALTER TABLE ONLY tmp.poly_stats_per_region DROP CONSTRAINT poly_stats_product_file_variable_fk;
       tmp       	   statsuser    false    243    4679    235            �           2606    188088 7   poly_stats_per_region poly_stats_stratification_geom_fk    FK CONSTRAINT     �   ALTER TABLE ONLY tmp.poly_stats_per_region
    ADD CONSTRAINT poly_stats_stratification_geom_fk FOREIGN KEY (poly_id) REFERENCES public.stratification_geom(id) ON UPDATE CASCADE ON DELETE CASCADE;
 ^   ALTER TABLE ONLY tmp.poly_stats_per_region DROP CONSTRAINT poly_stats_stratification_geom_fk;
       tmp       	   statsuser    false    243    4687    239           