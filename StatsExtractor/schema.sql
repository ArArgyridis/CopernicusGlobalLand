PGDMP     #                    {           jrcstats_export    15.3    15.3 �    /           0    0    ENCODING    ENCODING     #   SET client_encoding = 'SQL_ASCII';
                      false            0           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            1           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            2           1262    157595    jrcstats_export    DATABASE     v   CREATE DATABASE jrcstats_export WITH TEMPLATE = template0 ENCODING = 'SQL_ASCII' LOCALE_PROVIDER = libc LOCALE = 'C';
    DROP DATABASE jrcstats_export;
                postgres    false            3           0    0    SCHEMA pg_catalog    ACL     -   GRANT ALL ON SCHEMA pg_catalog TO statsuser;
                   postgres    false    4                        2615    2200    public    SCHEMA     2   -- *not* creating schema, since initdb creates it
 2   -- *not* dropping schema, since initdb creates it
             	   statsuser    false                        2615    157596    tmp    SCHEMA        CREATE SCHEMA tmp;
    DROP SCHEMA tmp;
             	   statsuser    false                        3079    157597    fuzzystrmatch 	   EXTENSION     A   CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;
    DROP EXTENSION fuzzystrmatch;
                   false    8            4           0    0    EXTENSION fuzzystrmatch    COMMENT     ]   COMMENT ON EXTENSION fuzzystrmatch IS 'determine similarities and distance between strings';
                        false    2                        3079    157608    postgis 	   EXTENSION     ;   CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;
    DROP EXTENSION postgis;
                   false    8            5           0    0    EXTENSION postgis    COMMENT     ^   COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';
                        false    3            �           1255    158652    clms_updatepolygonstats()    FUNCTION     �  CREATE FUNCTION public.clms_updatepolygonstats() RETURNS smallint
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
       public       	   statsuser    false    8            6           0    0    TABLE pg_aggregate    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_aggregate TO statsuser;
       
   pg_catalog          postgres    false    24            7           0    0    TABLE pg_am    ACL     2   GRANT ALL ON TABLE pg_catalog.pg_am TO statsuser;
       
   pg_catalog          postgres    false    25            8           0    0    TABLE pg_amop    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_amop TO statsuser;
       
   pg_catalog          postgres    false    26            9           0    0    TABLE pg_amproc    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_amproc TO statsuser;
       
   pg_catalog          postgres    false    27            :           0    0    TABLE pg_attrdef    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_attrdef TO statsuser;
       
   pg_catalog          postgres    false    28            ;           0    0    TABLE pg_attribute    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_attribute TO statsuser;
       
   pg_catalog          postgres    false    13            <           0    0    TABLE pg_auth_members    ACL     <   GRANT ALL ON TABLE pg_catalog.pg_auth_members TO statsuser;
       
   pg_catalog          postgres    false    17            =           0    0    TABLE pg_authid    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_authid TO statsuser;
       
   pg_catalog          postgres    false    16            >           0    0 %   TABLE pg_available_extension_versions    ACL     L   GRANT ALL ON TABLE pg_catalog.pg_available_extension_versions TO statsuser;
       
   pg_catalog          postgres    false    91            ?           0    0    TABLE pg_available_extensions    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_available_extensions TO statsuser;
       
   pg_catalog          postgres    false    90            @           0    0     TABLE pg_backend_memory_contexts    ACL     G   GRANT ALL ON TABLE pg_catalog.pg_backend_memory_contexts TO statsuser;
       
   pg_catalog          postgres    false    103            A           0    0    TABLE pg_cast    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_cast TO statsuser;
       
   pg_catalog          postgres    false    29            B           0    0    TABLE pg_class    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_class TO statsuser;
       
   pg_catalog          postgres    false    15            C           0    0    TABLE pg_collation    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_collation TO statsuser;
       
   pg_catalog          postgres    false    54            D           0    0    TABLE pg_config    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_config TO statsuser;
       
   pg_catalog          postgres    false    101            E           0    0    TABLE pg_constraint    ACL     :   GRANT ALL ON TABLE pg_catalog.pg_constraint TO statsuser;
       
   pg_catalog          postgres    false    30            F           0    0    TABLE pg_conversion    ACL     :   GRANT ALL ON TABLE pg_catalog.pg_conversion TO statsuser;
       
   pg_catalog          postgres    false    31            G           0    0    TABLE pg_cursors    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_cursors TO statsuser;
       
   pg_catalog          postgres    false    89            H           0    0    TABLE pg_database    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_database TO statsuser;
       
   pg_catalog          postgres    false    18            I           0    0    TABLE pg_db_role_setting    ACL     ?   GRANT ALL ON TABLE pg_catalog.pg_db_role_setting TO statsuser;
       
   pg_catalog          postgres    false    45            J           0    0    TABLE pg_default_acl    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_default_acl TO statsuser;
       
   pg_catalog          postgres    false    9            K           0    0    TABLE pg_depend    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_depend TO statsuser;
       
   pg_catalog          postgres    false    32            L           0    0    TABLE pg_description    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_description TO statsuser;
       
   pg_catalog          postgres    false    33            M           0    0    TABLE pg_enum    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_enum TO statsuser;
       
   pg_catalog          postgres    false    56            N           0    0    TABLE pg_event_trigger    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_event_trigger TO statsuser;
       
   pg_catalog          postgres    false    55            O           0    0    TABLE pg_extension    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_extension TO statsuser;
       
   pg_catalog          postgres    false    47            P           0    0    TABLE pg_file_settings    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_file_settings TO statsuser;
       
   pg_catalog          postgres    false    96            Q           0    0    TABLE pg_foreign_data_wrapper    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_foreign_data_wrapper TO statsuser;
       
   pg_catalog          postgres    false    22            R           0    0    TABLE pg_foreign_server    ACL     >   GRANT ALL ON TABLE pg_catalog.pg_foreign_server TO statsuser;
       
   pg_catalog          postgres    false    19            S           0    0    TABLE pg_foreign_table    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_foreign_table TO statsuser;
       
   pg_catalog          postgres    false    48            T           0    0    TABLE pg_group    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_group TO statsuser;
       
   pg_catalog          postgres    false    75            U           0    0    TABLE pg_hba_file_rules    ACL     >   GRANT ALL ON TABLE pg_catalog.pg_hba_file_rules TO statsuser;
       
   pg_catalog          postgres    false    97            V           0    0    TABLE pg_ident_file_mappings    ACL     C   GRANT ALL ON TABLE pg_catalog.pg_ident_file_mappings TO statsuser;
       
   pg_catalog          postgres    false    98            W           0    0    TABLE pg_index    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_index TO statsuser;
       
   pg_catalog          postgres    false    34            X           0    0    TABLE pg_indexes    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_indexes TO statsuser;
       
   pg_catalog          postgres    false    82            Y           0    0    TABLE pg_inherits    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_inherits TO statsuser;
       
   pg_catalog          postgres    false    35            Z           0    0    TABLE pg_init_privs    ACL     :   GRANT ALL ON TABLE pg_catalog.pg_init_privs TO statsuser;
       
   pg_catalog          postgres    false    52            [           0    0    TABLE pg_language    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_language TO statsuser;
       
   pg_catalog          postgres    false    36            \           0    0    TABLE pg_largeobject    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_largeobject TO statsuser;
       
   pg_catalog          postgres    false    37            ]           0    0    TABLE pg_largeobject_metadata    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_largeobject_metadata TO statsuser;
       
   pg_catalog          postgres    false    46            ^           0    0    TABLE pg_locks    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_locks TO statsuser;
       
   pg_catalog          postgres    false    88            _           0    0    TABLE pg_matviews    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_matviews TO statsuser;
       
   pg_catalog          postgres    false    81            `           0    0    TABLE pg_namespace    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_namespace TO statsuser;
       
   pg_catalog          postgres    false    38            a           0    0    TABLE pg_opclass    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_opclass TO statsuser;
       
   pg_catalog          postgres    false    39            b           0    0    TABLE pg_operator    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_operator TO statsuser;
       
   pg_catalog          postgres    false    40            c           0    0    TABLE pg_opfamily    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_opfamily TO statsuser;
       
   pg_catalog          postgres    false    44            d           0    0    TABLE pg_parameter_acl    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_parameter_acl TO statsuser;
       
   pg_catalog          postgres    false    72            e           0    0    TABLE pg_partitioned_table    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_partitioned_table TO statsuser;
       
   pg_catalog          postgres    false    50            f           0    0    TABLE pg_policies    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_policies TO statsuser;
       
   pg_catalog          postgres    false    77            g           0    0    TABLE pg_policy    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_policy TO statsuser;
       
   pg_catalog          postgres    false    49            h           0    0    TABLE pg_prepared_statements    ACL     C   GRANT ALL ON TABLE pg_catalog.pg_prepared_statements TO statsuser;
       
   pg_catalog          postgres    false    93            i           0    0    TABLE pg_prepared_xacts    ACL     >   GRANT ALL ON TABLE pg_catalog.pg_prepared_xacts TO statsuser;
       
   pg_catalog          postgres    false    92            j           0    0    TABLE pg_proc    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_proc TO statsuser;
       
   pg_catalog          postgres    false    14            k           0    0    TABLE pg_publication    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_publication TO statsuser;
       
   pg_catalog          postgres    false    69            l           0    0    TABLE pg_publication_namespace    ACL     E   GRANT ALL ON TABLE pg_catalog.pg_publication_namespace TO statsuser;
       
   pg_catalog          postgres    false    71            m           0    0    TABLE pg_publication_rel    ACL     ?   GRANT ALL ON TABLE pg_catalog.pg_publication_rel TO statsuser;
       
   pg_catalog          postgres    false    70            n           0    0    TABLE pg_publication_tables    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_publication_tables TO statsuser;
       
   pg_catalog          postgres    false    87            o           0    0    TABLE pg_range    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_range TO statsuser;
       
   pg_catalog          postgres    false    57            p           0    0    TABLE pg_replication_origin    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_replication_origin TO statsuser;
       
   pg_catalog          postgres    false    66            q           0    0 "   TABLE pg_replication_origin_status    ACL     I   GRANT ALL ON TABLE pg_catalog.pg_replication_origin_status TO statsuser;
       
   pg_catalog          postgres    false    146            r           0    0    TABLE pg_replication_slots    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_replication_slots TO statsuser;
       
   pg_catalog          postgres    false    130            s           0    0    TABLE pg_rewrite    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_rewrite TO statsuser;
       
   pg_catalog          postgres    false    41            t           0    0    TABLE pg_roles    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_roles TO statsuser;
       
   pg_catalog          postgres    false    73            u           0    0    TABLE pg_rules    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_rules TO statsuser;
       
   pg_catalog          postgres    false    78            v           0    0    TABLE pg_seclabel    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_seclabel TO statsuser;
       
   pg_catalog          postgres    false    60            w           0    0    TABLE pg_seclabels    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_seclabels TO statsuser;
       
   pg_catalog          postgres    false    94            x           0    0    TABLE pg_sequence    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_sequence TO statsuser;
       
   pg_catalog          postgres    false    21            y           0    0    TABLE pg_sequences    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_sequences TO statsuser;
       
   pg_catalog          postgres    false    83            z           0    0    TABLE pg_settings    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_settings TO statsuser;
       
   pg_catalog          postgres    false    95            {           0    0    TABLE pg_shadow    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_shadow TO statsuser;
       
   pg_catalog          postgres    false    74            |           0    0    TABLE pg_shdepend    ACL     8   GRANT ALL ON TABLE pg_catalog.pg_shdepend TO statsuser;
       
   pg_catalog          postgres    false    11            }           0    0    TABLE pg_shdescription    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_shdescription TO statsuser;
       
   pg_catalog          postgres    false    23            ~           0    0    TABLE pg_shmem_allocations    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_shmem_allocations TO statsuser;
       
   pg_catalog          postgres    false    102                       0    0    TABLE pg_shseclabel    ACL     :   GRANT ALL ON TABLE pg_catalog.pg_shseclabel TO statsuser;
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
   pg_catalog          postgres    false    129            �           0    0    TABLE pg_stat_progress_analyze    ACL     E   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_analyze TO statsuser;
       
   pg_catalog          postgres    false    139            �           0    0 !   TABLE pg_stat_progress_basebackup    ACL     H   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_basebackup TO statsuser;
       
   pg_catalog          postgres    false    143            �           0    0    TABLE pg_stat_progress_cluster    ACL     E   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_cluster TO statsuser;
       
   pg_catalog          postgres    false    141            �           0    0    TABLE pg_stat_progress_copy    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_copy TO statsuser;
       
   pg_catalog          postgres    false    144            �           0    0 #   TABLE pg_stat_progress_create_index    ACL     J   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_create_index TO statsuser;
       
   pg_catalog          postgres    false    142            �           0    0    TABLE pg_stat_progress_vacuum    ACL     D   GRANT ALL ON TABLE pg_catalog.pg_stat_progress_vacuum TO statsuser;
       
   pg_catalog          postgres    false    140            �           0    0    TABLE pg_stat_recovery_prefetch    ACL     F   GRANT ALL ON TABLE pg_catalog.pg_stat_recovery_prefetch TO statsuser;
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
   pg_catalog          postgres    false    147            �           0    0    TABLE pg_stat_sys_indexes    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_stat_sys_indexes TO statsuser;
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
   pg_catalog          postgres    false    138            �           0    0    TABLE pg_stat_wal_receiver    ACL     A   GRANT ALL ON TABLE pg_catalog.pg_stat_wal_receiver TO statsuser;
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
   pg_catalog          postgres    false    121            �           0    0    TABLE pg_statio_user_tables    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_statio_user_tables TO statsuser;
       
   pg_catalog          postgres    false    112            �           0    0    TABLE pg_statistic    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_statistic TO statsuser;
       
   pg_catalog          postgres    false    42            �           0    0    TABLE pg_statistic_ext    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_statistic_ext TO statsuser;
       
   pg_catalog          postgres    false    51            �           0    0    TABLE pg_statistic_ext_data    ACL     B   GRANT ALL ON TABLE pg_catalog.pg_statistic_ext_data TO statsuser;
       
   pg_catalog          postgres    false    53            �           0    0    TABLE pg_stats    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_stats TO statsuser;
       
   pg_catalog          postgres    false    84            �           0    0    TABLE pg_stats_ext    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_stats_ext TO statsuser;
       
   pg_catalog          postgres    false    85            �           0    0    TABLE pg_stats_ext_exprs    ACL     ?   GRANT ALL ON TABLE pg_catalog.pg_stats_ext_exprs TO statsuser;
       
   pg_catalog          postgres    false    86            �           0    0    TABLE pg_subscription    ACL     <   GRANT ALL ON TABLE pg_catalog.pg_subscription TO statsuser;
       
   pg_catalog          postgres    false    67            �           0    0    TABLE pg_subscription_rel    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_subscription_rel TO statsuser;
       
   pg_catalog          postgres    false    68            �           0    0    TABLE pg_tables    ACL     6   GRANT ALL ON TABLE pg_catalog.pg_tables TO statsuser;
       
   pg_catalog          postgres    false    80            �           0    0    TABLE pg_tablespace    ACL     :   GRANT ALL ON TABLE pg_catalog.pg_tablespace TO statsuser;
       
   pg_catalog          postgres    false    10            �           0    0    TABLE pg_timezone_abbrevs    ACL     @   GRANT ALL ON TABLE pg_catalog.pg_timezone_abbrevs TO statsuser;
       
   pg_catalog          postgres    false    99            �           0    0    TABLE pg_timezone_names    ACL     >   GRANT ALL ON TABLE pg_catalog.pg_timezone_names TO statsuser;
       
   pg_catalog          postgres    false    100            �           0    0    TABLE pg_transform    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_transform TO statsuser;
       
   pg_catalog          postgres    false    58            �           0    0    TABLE pg_trigger    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_trigger TO statsuser;
       
   pg_catalog          postgres    false    43            �           0    0    TABLE pg_ts_config    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_ts_config TO statsuser;
       
   pg_catalog          postgres    false    63            �           0    0    TABLE pg_ts_config_map    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_ts_config_map TO statsuser;
       
   pg_catalog          postgres    false    64            �           0    0    TABLE pg_ts_dict    ACL     7   GRANT ALL ON TABLE pg_catalog.pg_ts_dict TO statsuser;
       
   pg_catalog          postgres    false    61            �           0    0    TABLE pg_ts_parser    ACL     9   GRANT ALL ON TABLE pg_catalog.pg_ts_parser TO statsuser;
       
   pg_catalog          postgres    false    62            �           0    0    TABLE pg_ts_template    ACL     ;   GRANT ALL ON TABLE pg_catalog.pg_ts_template TO statsuser;
       
   pg_catalog          postgres    false    65            �           0    0    TABLE pg_type    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_type TO statsuser;
       
   pg_catalog          postgres    false    12            �           0    0    TABLE pg_user    ACL     4   GRANT ALL ON TABLE pg_catalog.pg_user TO statsuser;
       
   pg_catalog          postgres    false    76            �           0    0    TABLE pg_user_mapping    ACL     <   GRANT ALL ON TABLE pg_catalog.pg_user_mapping TO statsuser;
       
   pg_catalog          postgres    false    20            �           0    0    TABLE pg_user_mappings    ACL     =   GRANT ALL ON TABLE pg_catalog.pg_user_mappings TO statsuser;
       
   pg_catalog          postgres    false    145            �           0    0    TABLE pg_views    ACL     5   GRANT ALL ON TABLE pg_catalog.pg_views TO statsuser;
       
   pg_catalog          postgres    false    79            �            1259    158653    category    TABLE     }   CREATE TABLE public.category (
    id bigint NOT NULL,
    title text NOT NULL,
    active boolean DEFAULT false NOT NULL
);
    DROP TABLE public.category;
       public         heap 	   statsuser    false    8            �            1259    158659    category_id_seq    SEQUENCE     �   ALTER TABLE public.category ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.category_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   statsuser    false    222    8            �           0    0    TABLE geography_columns    ACL     v   REVOKE ALL ON TABLE public.geography_columns FROM postgres;
GRANT ALL ON TABLE public.geography_columns TO statsuser;
          public          postgres    false    220            �           0    0    TABLE geometry_columns    ACL     t   REVOKE ALL ON TABLE public.geometry_columns FROM postgres;
GRANT ALL ON TABLE public.geometry_columns TO statsuser;
          public          postgres    false    221            �            1259    158660    long_term_anomaly_info    TABLE     �   CREATE TABLE public.long_term_anomaly_info (
    id bigint NOT NULL,
    anomaly_product_variable_id bigint NOT NULL,
    mean_variable_id bigint NOT NULL,
    stdev_variable_id bigint NOT NULL,
    raw_product_variable_id bigint NOT NULL
);
 *   DROP TABLE public.long_term_anomaly_info;
       public         heap 	   statsuser    false    8            �            1259    158663    long_term_anomaly_info_id_seq    SEQUENCE     �   CREATE SEQUENCE public.long_term_anomaly_info_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 4   DROP SEQUENCE public.long_term_anomaly_info_id_seq;
       public       	   statsuser    false    224    8            �           0    0    long_term_anomaly_info_id_seq    SEQUENCE OWNED BY     _   ALTER SEQUENCE public.long_term_anomaly_info_id_seq OWNED BY public.long_term_anomaly_info.id;
          public       	   statsuser    false    225            �            1259    158664 
   poly_stats    TABLE     �  CREATE TABLE public.poly_stats (
    id bigint NOT NULL,
    poly_id bigint,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint NOT NULL,
    mean double precision,
    sd double precision,
    min_val double precision,
    max_val double precision,
    noval_area_ha double precision,
    sparse_area_ha double precision,
    mid_area_ha double precision,
    dense_area_ha double precision,
    meanval_color text,
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
       public         heap 	   statsuser    false    8            �            1259    158672    poly_stats_id_seq    SEQUENCE     z   CREATE SEQUENCE public.poly_stats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.poly_stats_id_seq;
       public       	   statsuser    false    8    226            �           0    0    poly_stats_id_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE public.poly_stats_id_seq OWNED BY public.poly_stats.id;
          public       	   statsuser    false    227            �            1259    158673    product    TABLE     �   CREATE TABLE public.product (
    id bigint NOT NULL,
    name text[] NOT NULL,
    type text DEFAULT 'raw'::text NOT NULL,
    category_id bigint,
    description text
);
    DROP TABLE public.product;
       public         heap 	   statsuser    false    8            �            1259    158679    product_file    TABLE       CREATE TABLE public.product_file (
    id bigint NOT NULL,
    product_file_description_id bigint NOT NULL,
    rel_file_path text NOT NULL,
    date timestamp without time zone NOT NULL,
    date_created timestamp without time zone DEFAULT (now() AT TIME ZONE 'UTC'::text)
);
     DROP TABLE public.product_file;
       public         heap 	   statsuser    false    8            �            1259    158685    product_file_description    TABLE     �   CREATE TABLE public.product_file_description (
    id bigint NOT NULL,
    product_id bigint,
    pattern text NOT NULL,
    types text NOT NULL,
    create_date text NOT NULL,
    file_name_creation_pattern text,
    rt_flag_pattern text
);
 ,   DROP TABLE public.product_file_description;
       public         heap 	   statsuser    false    8            �            1259    158690    product_file_description_id_seq    SEQUENCE     �   CREATE SEQUENCE public.product_file_description_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 6   DROP SEQUENCE public.product_file_description_id_seq;
       public       	   statsuser    false    8    230            �           0    0    product_file_description_id_seq    SEQUENCE OWNED BY     c   ALTER SEQUENCE public.product_file_description_id_seq OWNED BY public.product_file_description.id;
          public       	   statsuser    false    231            �            1259    158691    product_file_id_seq    SEQUENCE     |   CREATE SEQUENCE public.product_file_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.product_file_id_seq;
       public       	   statsuser    false    229    8            �           0    0    product_file_id_seq    SEQUENCE OWNED BY     K   ALTER SEQUENCE public.product_file_id_seq OWNED BY public.product_file.id;
          public       	   statsuser    false    232            �            1259    158692    product_file_variable    TABLE     <  CREATE TABLE public.product_file_variable (
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
       public         heap 	   statsuser    false    8            �            1259    158698    product_file_variable_id_seq    SEQUENCE     �   CREATE SEQUENCE public.product_file_variable_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 3   DROP SEQUENCE public.product_file_variable_id_seq;
       public       	   statsuser    false    233    8            �           0    0    product_file_variable_id_seq    SEQUENCE OWNED BY     ]   ALTER SEQUENCE public.product_file_variable_id_seq OWNED BY public.product_file_variable.id;
          public       	   statsuser    false    234            �            1259    158699    product_id_seq    SEQUENCE     w   CREATE SEQUENCE public.product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public.product_id_seq;
       public       	   statsuser    false    228    8            �           0    0    product_id_seq    SEQUENCE OWNED BY     A   ALTER SEQUENCE public.product_id_seq OWNED BY public.product.id;
          public       	   statsuser    false    235            �           0    0    TABLE spatial_ref_sys    ACL     r   REVOKE ALL ON TABLE public.spatial_ref_sys FROM postgres;
GRANT ALL ON TABLE public.spatial_ref_sys TO statsuser;
          public          postgres    false    218            �            1259    158700    stratification    TABLE     m   CREATE TABLE public.stratification (
    id bigint NOT NULL,
    description text,
    tilelayer_url text
);
 "   DROP TABLE public.stratification;
       public         heap 	   statsuser    false    8            �            1259    158705    stratification_geom    TABLE     �   CREATE TABLE public.stratification_geom (
    id bigint NOT NULL,
    stratification_id bigint NOT NULL,
    geom public.geometry(MultiPolygon,4326),
    geom3857 public.geometry(MultiPolygon,3857),
    description text
);
 '   DROP TABLE public.stratification_geom;
       public         heap 	   statsuser    false    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    8    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8            �            1259    158710    stratification_geom_id_seq    SEQUENCE     �   CREATE SEQUENCE public.stratification_geom_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE public.stratification_geom_id_seq;
       public       	   statsuser    false    237    8            �           0    0    stratification_geom_id_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE public.stratification_geom_id_seq OWNED BY public.stratification_geom.id;
          public       	   statsuser    false    238            �            1259    158711    stratification_id_seq    SEQUENCE     ~   CREATE SEQUENCE public.stratification_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE public.stratification_id_seq;
       public       	   statsuser    false    236    8            �           0    0    stratification_id_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE public.stratification_id_seq OWNED BY public.stratification.id;
          public       	   statsuser    false    239            �            1259    158712    wms_file    TABLE     �   CREATE TABLE public.wms_file (
    id bigint NOT NULL,
    product_file_id bigint NOT NULL,
    product_file_variable_id bigint,
    rel_file_path text
);
    DROP TABLE public.wms_file;
       public         heap 	   statsuser    false    8            �            1259    158717    wms_file_id_seq    SEQUENCE     x   CREATE SEQUENCE public.wms_file_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.wms_file_id_seq;
       public       	   statsuser    false    240    8            �           0    0    wms_file_id_seq    SEQUENCE OWNED BY     C   ALTER SEQUENCE public.wms_file_id_seq OWNED BY public.wms_file.id;
          public       	   statsuser    false    241            �            1259    158718    poly_stats_per_region    TABLE     �  CREATE TABLE tmp.poly_stats_per_region (
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
       tmp         heap 	   statsuser    false    7            �            1259    158726    poly_stats_per_region_id_seq    SEQUENCE     �   CREATE SEQUENCE tmp.poly_stats_per_region_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE tmp.poly_stats_per_region_id_seq;
       tmp       	   statsuser    false    242    7            �           0    0    poly_stats_per_region_id_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE tmp.poly_stats_per_region_id_seq OWNED BY tmp.poly_stats_per_region.id;
          tmp       	   statsuser    false    243            =           2604    158727    long_term_anomaly_info id    DEFAULT     �   ALTER TABLE ONLY public.long_term_anomaly_info ALTER COLUMN id SET DEFAULT nextval('public.long_term_anomaly_info_id_seq'::regclass);
 H   ALTER TABLE public.long_term_anomaly_info ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    225    224            >           2604    158728    poly_stats id    DEFAULT     n   ALTER TABLE ONLY public.poly_stats ALTER COLUMN id SET DEFAULT nextval('public.poly_stats_id_seq'::regclass);
 <   ALTER TABLE public.poly_stats ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    227    226            B           2604    158729 
   product id    DEFAULT     h   ALTER TABLE ONLY public.product ALTER COLUMN id SET DEFAULT nextval('public.product_id_seq'::regclass);
 9   ALTER TABLE public.product ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    235    228            D           2604    158730    product_file id    DEFAULT     r   ALTER TABLE ONLY public.product_file ALTER COLUMN id SET DEFAULT nextval('public.product_file_id_seq'::regclass);
 >   ALTER TABLE public.product_file ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    232    229            F           2604    158731    product_file_description id    DEFAULT     �   ALTER TABLE ONLY public.product_file_description ALTER COLUMN id SET DEFAULT nextval('public.product_file_description_id_seq'::regclass);
 J   ALTER TABLE public.product_file_description ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    231    230            G           2604    158732    product_file_variable id    DEFAULT     �   ALTER TABLE ONLY public.product_file_variable ALTER COLUMN id SET DEFAULT nextval('public.product_file_variable_id_seq'::regclass);
 G   ALTER TABLE public.product_file_variable ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    234    233            I           2604    158733    stratification id    DEFAULT     v   ALTER TABLE ONLY public.stratification ALTER COLUMN id SET DEFAULT nextval('public.stratification_id_seq'::regclass);
 @   ALTER TABLE public.stratification ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    239    236            J           2604    158734    stratification_geom id    DEFAULT     �   ALTER TABLE ONLY public.stratification_geom ALTER COLUMN id SET DEFAULT nextval('public.stratification_geom_id_seq'::regclass);
 E   ALTER TABLE public.stratification_geom ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    238    237            K           2604    158735    wms_file id    DEFAULT     j   ALTER TABLE ONLY public.wms_file ALTER COLUMN id SET DEFAULT nextval('public.wms_file_id_seq'::regclass);
 :   ALTER TABLE public.wms_file ALTER COLUMN id DROP DEFAULT;
       public       	   statsuser    false    241    240            L           2604    158736    poly_stats_per_region id    DEFAULT     ~   ALTER TABLE ONLY tmp.poly_stats_per_region ALTER COLUMN id SET DEFAULT nextval('tmp.poly_stats_per_region_id_seq'::regclass);
 D   ALTER TABLE tmp.poly_stats_per_region ALTER COLUMN id DROP DEFAULT;
       tmp       	   statsuser    false    243    242                      0    158653    category 
   TABLE DATA           5   COPY public.category (id, title, active) FROM stdin;
    public       	   statsuser    false    222   	)                0    158660    long_term_anomaly_info 
   TABLE DATA           �   COPY public.long_term_anomaly_info (id, anomaly_product_variable_id, mean_variable_id, stdev_variable_id, raw_product_variable_id) FROM stdin;
    public       	   statsuser    false    224   s)                0    158664 
   poly_stats 
   TABLE DATA           2  COPY public.poly_stats (id, poly_id, product_file_id, product_file_variable_id, mean, sd, min_val, max_val, noval_area_ha, sparse_area_ha, mid_area_ha, dense_area_ha, meanval_color, noval_color, sparseval_color, midval_color, highval_color, histogram, total_pixels, valid_pixels, date_created) FROM stdin;
    public       	   statsuser    false    226   �)                0    158673    product 
   TABLE DATA           K   COPY public.product (id, name, type, category_id, description) FROM stdin;
    public       	   statsuser    false    228   �)                0    158679    product_file 
   TABLE DATA           j   COPY public.product_file (id, product_file_description_id, rel_file_path, date, date_created) FROM stdin;
    public       	   statsuser    false    229   �*                0    158685    product_file_description 
   TABLE DATA           �   COPY public.product_file_description (id, product_id, pattern, types, create_date, file_name_creation_pattern, rt_flag_pattern) FROM stdin;
    public       	   statsuser    false    230   +      "          0    158692    product_file_variable 
   TABLE DATA           )  COPY public.product_file_variable (id, product_file_description_id, variable, style, description, low_value, mid_value, high_value, noval_colors, sparseval_colors, midval_colors, highval_colors, min_prod_value, max_prod_value, histogram_bins, min_value, max_value, compute_statistics) FROM stdin;
    public       	   statsuser    false    233   -,      ;          0    157921    spatial_ref_sys 
   TABLE DATA           X   COPY public.spatial_ref_sys (srid, auth_name, auth_srid, srtext, proj4text) FROM stdin;
    public          postgres    false    218   �P      %          0    158700    stratification 
   TABLE DATA           H   COPY public.stratification (id, description, tilelayer_url) FROM stdin;
    public       	   statsuser    false    236   �P      &          0    158705    stratification_geom 
   TABLE DATA           a   COPY public.stratification_geom (id, stratification_id, geom, geom3857, description) FROM stdin;
    public       	   statsuser    false    237   Q      )          0    158712    wms_file 
   TABLE DATA           `   COPY public.wms_file (id, product_file_id, product_file_variable_id, rel_file_path) FROM stdin;
    public       	   statsuser    false    240   1Q      +          0    158718    poly_stats_per_region 
   TABLE DATA           �   COPY tmp.poly_stats_per_region (id, poly_id, product_file_id, product_file_variable_id, region_id, mean, sd, min_val, max_val, noval_area_ha, sparse_area_ha, mid_area_ha, dense_area_ha, histogram, total_pixels, valid_pixels, date_created) FROM stdin;
    tmp       	   statsuser    false    242   NQ      �           0    0    category_id_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public.category_id_seq', 6, true);
          public       	   statsuser    false    223            �           0    0    long_term_anomaly_info_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.long_term_anomaly_info_id_seq', 1, true);
          public       	   statsuser    false    225            �           0    0    poly_stats_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.poly_stats_id_seq', 1, false);
          public       	   statsuser    false    227            �           0    0    product_file_description_id_seq    SEQUENCE SET     N   SELECT pg_catalog.setval('public.product_file_description_id_seq', 10, true);
          public       	   statsuser    false    231            �           0    0    product_file_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.product_file_id_seq', 1, false);
          public       	   statsuser    false    232            �           0    0    product_file_variable_id_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public.product_file_variable_id_seq', 6, true);
          public       	   statsuser    false    234            �           0    0    product_id_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public.product_id_seq', 9, true);
          public       	   statsuser    false    235            �           0    0    stratification_geom_id_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public.stratification_geom_id_seq', 1, false);
          public       	   statsuser    false    238            �           0    0    stratification_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.stratification_id_seq', 1, false);
          public       	   statsuser    false    239            �           0    0    wms_file_id_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.wms_file_id_seq', 1, false);
          public       	   statsuser    false    241            �           0    0    poly_stats_per_region_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('tmp.poly_stats_per_region_id_seq', 1, false);
          tmp       	   statsuser    false    243            V           2606    158743 0   long_term_anomaly_info long_term_anomaly_info_pk 
   CONSTRAINT     n   ALTER TABLE ONLY public.long_term_anomaly_info
    ADD CONSTRAINT long_term_anomaly_info_pk PRIMARY KEY (id);
 Z   ALTER TABLE ONLY public.long_term_anomaly_info DROP CONSTRAINT long_term_anomaly_info_pk;
       public         	   statsuser    false    224            T           2606    158745    category newtable_pk 
   CONSTRAINT     R   ALTER TABLE ONLY public.category
    ADD CONSTRAINT newtable_pk PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.category DROP CONSTRAINT newtable_pk;
       public         	   statsuser    false    222            X           2606    158747    poly_stats poly_stats_pk 
   CONSTRAINT     V   ALTER TABLE ONLY public.poly_stats
    ADD CONSTRAINT poly_stats_pk PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.poly_stats DROP CONSTRAINT poly_stats_pk;
       public         	   statsuser    false    226            Z           2606    158749    poly_stats poly_stats_un 
   CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats
    ADD CONSTRAINT poly_stats_un UNIQUE (poly_id, product_file_id, product_file_variable_id);
 B   ALTER TABLE ONLY public.poly_stats DROP CONSTRAINT poly_stats_un;
       public         	   statsuser    false    226    226    226            ^           2606    158751 6   product_file product_file_date_product_description_idx 
   CONSTRAINT     �   ALTER TABLE ONLY public.product_file
    ADD CONSTRAINT product_file_date_product_description_idx UNIQUE (product_file_description_id, date);
 `   ALTER TABLE ONLY public.product_file DROP CONSTRAINT product_file_date_product_description_idx;
       public         	   statsuser    false    229    229            `           2606    158753    product_file product_file_pk 
   CONSTRAINT     Z   ALTER TABLE ONLY public.product_file
    ADD CONSTRAINT product_file_pk PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.product_file DROP CONSTRAINT product_file_pk;
       public         	   statsuser    false    229            e           2606    158755 .   product_file_variable product_file_variable_pk 
   CONSTRAINT     l   ALTER TABLE ONLY public.product_file_variable
    ADD CONSTRAINT product_file_variable_pk PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.product_file_variable DROP CONSTRAINT product_file_variable_pk;
       public         	   statsuser    false    233            \           2606    158757    product product_pk1 
   CONSTRAINT     Q   ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_pk1 PRIMARY KEY (id);
 =   ALTER TABLE ONLY public.product DROP CONSTRAINT product_pk1;
       public         	   statsuser    false    228            c           2606    158759 <   product_file_description product_product_file_description_pk 
   CONSTRAINT     z   ALTER TABLE ONLY public.product_file_description
    ADD CONSTRAINT product_product_file_description_pk PRIMARY KEY (id);
 f   ALTER TABLE ONLY public.product_file_description DROP CONSTRAINT product_product_file_description_pk;
       public         	   statsuser    false    230            g           2606    158761     stratification stratification_pk 
   CONSTRAINT     ^   ALTER TABLE ONLY public.stratification
    ADD CONSTRAINT stratification_pk PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.stratification DROP CONSTRAINT stratification_pk;
       public         	   statsuser    false    236            m           2606    158763 '   stratification_geom stratification_pkey 
   CONSTRAINT     e   ALTER TABLE ONLY public.stratification_geom
    ADD CONSTRAINT stratification_pkey PRIMARY KEY (id);
 Q   ALTER TABLE ONLY public.stratification_geom DROP CONSTRAINT stratification_pkey;
       public         	   statsuser    false    237            i           2606    158765     stratification stratification_un 
   CONSTRAINT     b   ALTER TABLE ONLY public.stratification
    ADD CONSTRAINT stratification_un UNIQUE (description);
 J   ALTER TABLE ONLY public.stratification DROP CONSTRAINT stratification_un;
       public         	   statsuser    false    236            o           2606    158767    wms_file wms_file_pk 
   CONSTRAINT     R   ALTER TABLE ONLY public.wms_file
    ADD CONSTRAINT wms_file_pk PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.wms_file DROP CONSTRAINT wms_file_pk;
       public         	   statsuser    false    240            q           2606    158769    wms_file wms_file_un 
   CONSTRAINT     t   ALTER TABLE ONLY public.wms_file
    ADD CONSTRAINT wms_file_un UNIQUE (product_file_id, product_file_variable_id);
 >   ALTER TABLE ONLY public.wms_file DROP CONSTRAINT wms_file_un;
       public         	   statsuser    false    240    240            s           2606    158771 #   poly_stats_per_region poly_stats_pk 
   CONSTRAINT     ^   ALTER TABLE ONLY tmp.poly_stats_per_region
    ADD CONSTRAINT poly_stats_pk PRIMARY KEY (id);
 J   ALTER TABLE ONLY tmp.poly_stats_per_region DROP CONSTRAINT poly_stats_pk;
       tmp         	   statsuser    false    242            u           2606    158773 #   poly_stats_per_region poly_stats_un 
   CONSTRAINT     �   ALTER TABLE ONLY tmp.poly_stats_per_region
    ADD CONSTRAINT poly_stats_un UNIQUE (poly_id, product_file_id, product_file_variable_id, region_id);
 J   ALTER TABLE ONLY tmp.poly_stats_per_region DROP CONSTRAINT poly_stats_un;
       tmp         	   statsuser    false    242    242    242    242            a           1259    158774 '   product_file_product_description_id_idx    INDEX     �   CREATE UNIQUE INDEX product_file_product_description_id_idx ON public.product_file USING btree (product_file_description_id, rel_file_path);
 ;   DROP INDEX public.product_file_product_description_id_idx;
       public         	   statsuser    false    229    229            j           1259    158775    sidx_stratification_geom    INDEX     W   CREATE INDEX sidx_stratification_geom ON public.stratification_geom USING gist (geom);
 ,   DROP INDEX public.sidx_stratification_geom;
       public         	   statsuser    false    3    8    3    3    8    3    8    8    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    3    3    8    3    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    8    3    8    3    8    3    8    3    8    3    8    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    3    8    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    3    8    8    3    3    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    8    8    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    3    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    3    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    8    8    3    3    8    8    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    3    8    3    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    8    3    8    3    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    8    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    3    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    3    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    8    8    3    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    3    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    8    8    3    8    3    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    8    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    3    8    3    8    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    3    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    3    8    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    8    3    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    3    8    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    8    3    8    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    3    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    8    3    3    8    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    8    3    8    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    3    8    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    3    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    3    8    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    8    237            k           1259    158776    sidx_stratification_geom3857    INDEX     �   CREATE INDEX sidx_stratification_geom3857 ON public.stratification_geom USING gist (geom3857);

ALTER TABLE public.stratification_geom CLUSTER ON sidx_stratification_geom3857;
 0   DROP INDEX public.sidx_stratification_geom3857;
       public         	   statsuser    false    3    8    3    3    8    3    8    8    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    3    3    8    3    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    8    3    8    3    8    3    8    3    8    3    8    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    3    8    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    3    8    8    3    3    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    8    8    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    3    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    3    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    8    8    3    3    8    8    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    3    8    3    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    8    3    8    3    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    8    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    3    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    3    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    8    8    3    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    3    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    8    8    3    8    3    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    8    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    3    8    3    8    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    3    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    3    8    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    8    3    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    3    8    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    8    3    8    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    3    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    8    3    3    8    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    8    3    8    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    3    8    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    3    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    3    8    3    3    8    3    8    3    8    3    8    8    3    8    3    8    3    8    8    237            v           2606    158777 0   long_term_anomaly_info long_term_anomaly_info_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.long_term_anomaly_info
    ADD CONSTRAINT long_term_anomaly_info_fk FOREIGN KEY (anomaly_product_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 Z   ALTER TABLE ONLY public.long_term_anomaly_info DROP CONSTRAINT long_term_anomaly_info_fk;
       public       	   statsuser    false    224    233    4197            w           2606    158782 2   long_term_anomaly_info long_term_anomaly_info_fk_1    FK CONSTRAINT     �   ALTER TABLE ONLY public.long_term_anomaly_info
    ADD CONSTRAINT long_term_anomaly_info_fk_1 FOREIGN KEY (mean_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 \   ALTER TABLE ONLY public.long_term_anomaly_info DROP CONSTRAINT long_term_anomaly_info_fk_1;
       public       	   statsuser    false    4197    233    224            x           2606    158787 2   long_term_anomaly_info long_term_anomaly_info_fk_2    FK CONSTRAINT     �   ALTER TABLE ONLY public.long_term_anomaly_info
    ADD CONSTRAINT long_term_anomaly_info_fk_2 FOREIGN KEY (stdev_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 \   ALTER TABLE ONLY public.long_term_anomaly_info DROP CONSTRAINT long_term_anomaly_info_fk_2;
       public       	   statsuser    false    233    224    4197            y           2606    158792 2   long_term_anomaly_info long_term_anomaly_info_fk_3    FK CONSTRAINT     �   ALTER TABLE ONLY public.long_term_anomaly_info
    ADD CONSTRAINT long_term_anomaly_info_fk_3 FOREIGN KEY (raw_product_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 \   ALTER TABLE ONLY public.long_term_anomaly_info DROP CONSTRAINT long_term_anomaly_info_fk_3;
       public       	   statsuser    false    4197    224    233            z           2606    158797 %   poly_stats poly_stats_product_file_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats
    ADD CONSTRAINT poly_stats_product_file_fk FOREIGN KEY (product_file_id) REFERENCES public.product_file(id) ON UPDATE CASCADE ON DELETE CASCADE;
 O   ALTER TABLE ONLY public.poly_stats DROP CONSTRAINT poly_stats_product_file_fk;
       public       	   statsuser    false    226    229    4192            {           2606    158802 )   poly_stats poly_stats_product_variable_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats
    ADD CONSTRAINT poly_stats_product_variable_fk FOREIGN KEY (product_file_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 S   ALTER TABLE ONLY public.poly_stats DROP CONSTRAINT poly_stats_product_variable_fk;
       public       	   statsuser    false    4197    226    233            |           2606    158807 ,   poly_stats poly_stats_stratification_geom_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.poly_stats
    ADD CONSTRAINT poly_stats_stratification_geom_fk FOREIGN KEY (poly_id) REFERENCES public.stratification_geom(id) ON UPDATE CASCADE ON DELETE CASCADE;
 V   ALTER TABLE ONLY public.poly_stats DROP CONSTRAINT poly_stats_stratification_geom_fk;
       public       	   statsuser    false    226    237    4205            }           2606    158812    product product_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_fk FOREIGN KEY (category_id) REFERENCES public.category(id) ON UPDATE CASCADE ON DELETE CASCADE;
 <   ALTER TABLE ONLY public.product DROP CONSTRAINT product_fk;
       public       	   statsuser    false    222    4180    228            ~           2606    158817 *   stratification_geom stratification_geom_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.stratification_geom
    ADD CONSTRAINT stratification_geom_fk FOREIGN KEY (stratification_id) REFERENCES public.stratification(id) ON DELETE CASCADE;
 T   ALTER TABLE ONLY public.stratification_geom DROP CONSTRAINT stratification_geom_fk;
       public       	   statsuser    false    4199    237    236                       2606    158822    wms_file wms_file_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.wms_file
    ADD CONSTRAINT wms_file_fk FOREIGN KEY (product_file_id) REFERENCES public.product_file(id) ON UPDATE CASCADE ON DELETE CASCADE;
 >   ALTER TABLE ONLY public.wms_file DROP CONSTRAINT wms_file_fk;
       public       	   statsuser    false    4192    240    229            �           2606    158827    wms_file wms_file_fk2    FK CONSTRAINT     �   ALTER TABLE ONLY public.wms_file
    ADD CONSTRAINT wms_file_fk2 FOREIGN KEY (product_file_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 ?   ALTER TABLE ONLY public.wms_file DROP CONSTRAINT wms_file_fk2;
       public       	   statsuser    false    240    233    4197            �           2606    158832 0   poly_stats_per_region poly_stats_product_file_fk    FK CONSTRAINT     �   ALTER TABLE ONLY tmp.poly_stats_per_region
    ADD CONSTRAINT poly_stats_product_file_fk FOREIGN KEY (product_file_id) REFERENCES public.product_file(id) ON UPDATE CASCADE ON DELETE CASCADE;
 W   ALTER TABLE ONLY tmp.poly_stats_per_region DROP CONSTRAINT poly_stats_product_file_fk;
       tmp       	   statsuser    false    229    4192    242            �           2606    158837 9   poly_stats_per_region poly_stats_product_file_variable_fk    FK CONSTRAINT     �   ALTER TABLE ONLY tmp.poly_stats_per_region
    ADD CONSTRAINT poly_stats_product_file_variable_fk FOREIGN KEY (product_file_variable_id) REFERENCES public.product_file_variable(id) ON UPDATE CASCADE ON DELETE CASCADE;
 `   ALTER TABLE ONLY tmp.poly_stats_per_region DROP CONSTRAINT poly_stats_product_file_variable_fk;
       tmp       	   statsuser    false    4197    233    242            �           2606    158842 7   poly_stats_per_region poly_stats_stratification_geom_fk    FK CONSTRAINT     �   ALTER TABLE ONLY tmp.poly_stats_per_region
    ADD CONSTRAINT poly_stats_stratification_geom_fk FOREIGN KEY (poly_id) REFERENCES public.stratification_geom(id) ON UPDATE CASCADE ON DELETE CASCADE;
 ^   ALTER TABLE ONLY tmp.poly_stats_per_region DROP CONSTRAINT poly_stats_stratification_geom_fk;
       tmp       	   statsuser    false    242    237    4205               Z   x�3�t�K-J��L�2�O,I-�L8��*�2R�R�\SN�������b όӽ(�4/E�)�85(`����Z�X����Y����� owq            x�3�4�4�4�4����� b�            x������ � �         "  x�]��n�0���U�� ��"�Bb:�81!�|�&�.�����V�N�>�O��;-��r]��m�F|�̃�Q９\��j�Ϟ�_^��(Z���<��=:�a ��%s��<�W��8~�YJW4c=8w�ӽ.JG�l"D�<-YelD�����ɽ�;i�d��nc�~p-:%#�Z�0�7J�=��#�O��P��j��N�3c�Έ}��ш��'�Y�-�����V\4GL��5�*���4�=�j0}g*+�Ƅ�=��V��� ��!�\�D�n@_�YPA��n���"�;            x������ � �           x����k�0���ر�%$Ѯ��j)B�nJz	��Ơ����@���j�e��=<}�I~������BJY%q
��먙��VsaD��4�����<ښ��6�f�x�@�̬�F�C��I=��ް��b	�L2P�P���mXӹ��-���Hq�,�{��_�>����{����p�
;2�U	L��M���U��G�X�
ϼ�-2�!'G�zoyO6��9t�r��*7��j\&q�;e�'r����V�襌N�uQ�>�b�����z|�~�I?��z�      "      x��]�]�u��[��������)�GN����b��e(RC�l+����$w��ݪu�8�=%#��|O������S���17߶�,����������?�W���|���h{r�^���ًo>}�_��������^|����[�"��^���.��}w���m��/^���ww�������?~����g�?z��>~��>a٧��?������؛/{�My�����}�7�>���������'������������~y��l���W���/^߽J�^ܽ~�%o������;�����|��9�)�׿�g��I߶�+O�y���o~���z۞�MmDm������o��?<���}��k���������K�2o?�?�g{�����_?|�_>��?���~�^�hϿl�[��o��׼��z�~x��?���_����_������o�6?�ď^���_����;}�y���N�����O��!=���~���ӻ���w�~���ߧw��~��I��Sn��WN_���ִ	Z=�XEG]��(um�>���Q�2�F�#�^�(wm�?���Q�
�F�#*^=D�p���;��G<�!OW�y����4�=]=�i|�z���t�ا1����Oc���� t5j��&@`L�Z��baUq� @!�nڊ�
	pVi'(���A�B��:��ʳ���8l���`���A�B�m��/	�n�U6�H@rZ7q� @+f�.�$ ;o6q� @#�%C�A��,���� @#���C6�H@�dĳ�h$�ymĳ�h$`�Έg30&���7��x
2� �XX5�)���ߍx
2p��*�OAf`,닝8l`��]gĳ��¢�f`��݄lų� `��Z��� �n7+�p�� ����x
�� �X���)�,ࣷ�)�,b��)���eaŊ� ;�H@�͊g;�H@J��v`�V<k�A�Er�V<k�A��X���7pH@IɊ� 7pH@Mŉ� 7p��5'��� �!5oN<k�A��,��x�p�ȱ0�Ġ�A��,L;1�n��N|y�.�0�Ġ�A��X�wb6� ��N̦xF@NN��xF@�^L�xN@�򧍃 �	h^L�xN���릇����y1~�Ey�R�	hE{1a6f�x���@,�y1a�^�:�A@�,,�����8�A@�,,�����8�A@�,��@�1Nau�%"#�R��PU/(q�1Nq���P]��PC���A@d��8�A@d��JDF@-Q�S!�	�Q��ІJ�3Т(�@�m��=��@�m��FQm �6FBSQ���jlc,4�`�rlc4��X��B豍��\�@�� ��'�C(��1�B3AH��Q�R/2��M񾷜�T0UL,��#��
����o+�u1���'�bC(�����%9����8���P�5�q:_� �@o��L/:���q��Y���ct�=�g9d �I1*���K�cR���T�!S���Q��,_z@!�bT�%�!�L�S�ox�q@��T�,�D2)�V��%q@�bw�����/T�M��Z��	
t2�O��驈|�P�Fy�}��'wPʄNy�=NHe��(�9�F�[��
�!��( �	��{����2if���"��A.��}�q��*�_>M��31�\w�:���c.=NHfb�9��k�̄���'gD3�ina�\߁j&t���&ə5���[�'gt3��n�I~Q�87���̂r&t΍v��̂t&�ε_.^pڙ�;����̂x&4ϵ��7���	�s�=N�,�gB�\c�/���L�kh-�FЄ��vɓ
�[Q��j�%�Q@BZ�jz�|aM衫jE���@D��J-˟��hB]������&�ѥ��F9���	}t�-ɟwiB#]r�A�,(iB']R�G�R��J����#hiB/]|��G��p�6PQ\sA�iB7]L��/� �	�t���5��&�Ӆz�|aAMh��֌\(jBG�[����@Z�\{�|aMM�si�˙QMh�s�qrfAU��y�����Vg�6�y%�G���z�|aaMh���7rfAY:�{��Y�ք�:��䦟@[z��*߅@ �	�u�{��YPׄ�:�Z�7�5��N��ə}M�S�}���
4�)�$�DC��	v
=N�,HlB�ݿ�(�|D��	=v25\"��d'U�|���&t�i��ɧ �ل6;�j/�*�g�\�|���&4�1V-�=G��	�v����xR��jG[Oh�8��vTu��;$ۄf;ne�$����&�b��m+tۡ��.8:���m�T�%qp��v�%�7�*p�
�v�%�7�*p�
�v�%\���m*^�GX��V�}+N�Y��V�})��88��nۧb�[��m�nۇr�6rn[�����K��(P�u!��yn[���T6�n~n[��v{�/�*�m���������m���%q@�mr��P��m�r��P��mg�'H�m�n�Q��-
F�۶{��7
�F�۶����8<T����)<�nۆl���F�m]֗�趭�J~�K�!it�Ve��CSxLݶ��vIP�n�Դˏ�)<*�n��T���m�n�ľ�]T��6>e#_g�m+t�Ƥ$?H��m+t�F�xIP�n�l)�ό*p�
ݶn��ϳ*p�
ݶ��]T���1Y��]n[���>��bn[���6���m+t�Z'%?A��m+t�zKtIP�n[����+p�
ݶ*q�dW����X�$�@��|,�3�
ܶB��l��>n[���0]T����?���Yp�
�6��M
ܶB�M%��Ľ�9{��>��S�����{����|���}�1��}��{��gnn���eH�՜~����<ٞ���*k~q��￐��_ܞ�\�?��G��9���a���U���_܆x�����������t��i~�(���۞����=^��/����^l�}u��ь#�O�)��x5s�-���^���=�����vӇ�m7nm���Q��}`n��_�=��e푯���Ͱ�9�G���Z=���~�����7��F�oi�F�\k#��Hr�2��K_.�lna��h�{k#���oy���3.ڱ���H�/y���HJѽ���f��U�_�����Ǉ���W���n��Z��J_m�q��_�>�7���]mXU�?��zU=��٫�y~�^U��ZU�°U����[Uϫ����U����[Uϫ�����U����[Uϫ����U����[Uϫ����U����[Uϫ����U����[Uϫ����U�����[Uϫ�y&nU=�����V��z��[Uϫ�y*nU=��穸U������V��z��[Uϫ�y*nU=��穸U������V��z��[Uϟ��穸U������V��z��[Uϫ�y*nU=��穸U������V��z��[Uϫ�y*nU=��穸U����g�V��*��9�������M����>�m���Dr�4��Z�f���K$��B�����"�7����E�W_~����~�?R�F��S#y��t�^��G�ݫ��T������^���21yKsD9���FM�l��&�a��\펨`Di��\���~�Q�&���0;DY���:��œa�&/Ҏ�j5Dy���=�v��!`��u򻨴Y�&o�(����ccT8ޓ�8�x�O�� 6�I8�u� �$��9Ć=	�}��l��p��p`�$�)964��'��O�cß��864 $%�yb��M�Rv�CC1����y�O�B2y��0����=�PB��84#@		��7c(!�a� %$���U� %$�<����Ӥ��%�@H�y#@K	p�Ԍ����#��0~�#%�4��0[��P#`���p
Ҍ����#,�0F�l�+�ᕵfh)ga����X�x��m=�"c�6�B��0���0F��3�#,�a��_J�Y#`�Q(��Rg��i
c    �>�>�r���}Z�P#`V@��0��2�1f5�V�TXF��Q=�����e���wae�89ZF���>�TD6-�Ptġa���0ٻ����p����T�0���	Wt��݂r����c�n;�r���1f��a5!��0�w�k	��#`v�⻰�%�u���-�Ge�
r���ݢG�θ;�HH@�� ��ݴ{���89F���#,d�#`v��N��0���˅=9c�n�?�J���3f���Vpr��s���V����3G�=#`�|��+N����4S5����A���f��m��0{H�s�o�c� :�|��10f�a�&*#�0۷x��Z`]`̞�;�Rm��*0fO�a��j��0{r�+{0# H	�M�<��G$���,lN	����G���\	طLa���Z�#�Z���0[�x��V�x"#`�l��[��ё0{n�3m���0{���;��DF@��]����=<���Ԇ{�1f�a������B��8��GX�O�ُ0.Ĥ�=㩪�L�I({�	�ۤ�}OXSɵ�&� �-��Jb����͍ׄ\�mR�^v#r9�Ii{N�ۤ<�=�� ۤD�=f|g�"ۤL�=d�\�mR*��3�r*���_1�T��b)�ns�8N���}�=6�B�[�M��KN�����r�+�qҫ����͍�
�5ni��!�S!��-�[iǩ����^�ϔS!u�ͷV�j�S!��ͶZ�̐S!��ʹR�.�l��
��`��
����ӝ�q*���׆���
�G�{�[/9R�\[yg��'}�Tz���
�M��,�S!��5�8�ܹP&�Q��,�S!u���w&(.�Ij�+�8�B�m-�:��,�S!5˥�8X�Z&�[.�C�q�
�].������2I�rqgq�
�a.����3IsQ<�Kf�Z���7�q*Ğ���q*Ħ9�8l��T�]s<]�@�ٖ;�~�VX�B�m��MN��8�8N��9o=;99R��	�,�S!�Ω�8,3�TH�sJgq�
�{N��a7"�Bj��;��TH�s�WP;V-r*�:�-������]عYǩ�Z��fq�
����m,�S!5ёjeq�
���Î��\F��F�T�;�u4I}t𕽳\H��H]��TH�t�*{g��������|-��Zz��舋%���x�E[H�w%�8N��M{U,��TH��ۋbq�
��v%��5I����8RG�lf�,��$�Ԏ�gq�
���-�w��j��j�2{g��&���>�w�S!���$�Ξ]Ra���YN��X�S�/�q*�κ�9���Қ����d�
�kk�zkS�ƋY.�Ij�{��+w��I�MNަpyMR{mR���[<��I�{\��Y.�Ij�M�d�h�+l�:lb��(\b��b�8��kl�zl�o��ǩ��l�mXfȩ���gV-r*�6�ب�Y�$�I�0��^r*�Fۘ��Y��I괍>ݔA�Bj��
�d\k��k���ɹ�&��6}�W�,�u�R�� F@q���n�ǹ�u�����m�=X���m%uۺ�;ln�Gޤn�ǩz�+�qB*t�7*X�ɏ�Iݶ.�U<���Iݶξ�vS�m+���ɧR!�~��m�mT�8~�M�{�/X�ǩ��m�-�>xvTJ���`7"�B궵�7yXɩ��mm�n[q���n[�
vrr*�n���{F��THݶ�.�6�ݶ��m�\�0���VR����>�P�m+���[���~?N��m���e��
���q
������B*Ts[>��8!���m,��THݶ*��N#uvDZ�U�9��~vHZ�{\�mU�옴�m�d}�a|vPZ�U�6�0�THݶ
��S̎8�m�8�w�J궕����8R���(a�Yi��
gv�l���VR���l�T�m+��V�Ԅ	�
���q%��m+��V���r���n�ǥ+w�J��{#L�m+���q>���ݶ���>�:؂���VR���,t�+�m�k$?�@��2)d4���ݶ���~_���B(�m�8����m%u۴�~���n{������ݶ��mj��#Q�m+���q~T��n[I�6U�LP�mOwUC\�=���m%u�Tt0Aq���n{�������R�O�ǳ�W����_�|����R�nn?Q۟n������_}jo�����_��ԉi�%��ߒ�*3BK�ֿ�N�}6��Oݙt�%���������^o�Q�}�����{T�Ҫ ]��tU�ND�
���U*	[���U�*@[�����U�*@g�V�<lU���V�Dت ]���
�U�@ت ]���
�U�@ت ]���
�U�@ت ]���
��*@%uU��s����K�Uzĭ
��n�V��*@{�*@��U�أ�Uzĭ
�G�ت q���n�tĭ
�G�V�[��ĭ
��*@�[�#nU�>�*@��U�Xܪ q����U:�V�q��]ܪ }$nU���U�Hܪ q����U:�V�#q�tĭ
�G�V軸U�Hܪ q��ѸU�6nU�>�*@��V�Ҫ ��x�U������_�_����b��?�:W�9Y�������-��v��܈6:M?o�?��g�?�Z�����gi��YƄϪ>߭M�0{���ǃ�k��*�ڨq}���Wn�ڨqMi��W��ڨqg﯍���F���x��]�W��I����8^=�	l�գ�p���a�;��0P�W�}�]nW�~�~��'�p5�w}^��ɳO��a$<�dau��>Á�;f�6�do}��~.�wXp�����S1�GH��~�!���]�¢N�0x���u���&$ ڦ����w}�0��*h$ 9��8l��z������} 	a� ��fGB� @[VfFB� @#յ�g�6�H@�ӧb l������sCh$`�n��!\��O��!l`��}�i��!��baՈ� 30@�N~7�)���?��@F<�A��,�/v�A�v��f`<��l!l`��݄<����m��k���w}����>���A�E\�~Pa� �X��=�a� ���g A� �"!���G7������G6�H@�͊g;�H@J��v`�V<k�A�Er�V<k8��	aފ/\���!%%+��� �!5�ٓ_6p����s_6pH@���1-8�¦iA<r,L͞���A��,LϞ���A�,�����A��,�91�w}B�wb6� ��N̦xF@NN����JF@γg� l�9u���<'��Ȃ�A���Ǳ �2�6{z
��P���)��P$����yL;��I��X��b���0�ūS�����0�����0�]��g�rA4�:VfOrA�  xVg^A����}���As+#�n���@-��cT
b�`�KdT�
lĉ��j�'�$���"#���see���f��A�  2j�=aP���i���A�*#���[B�PgX�C%�h��0;9{/*��G�QCEP�}�{�SQ���|q��������#����cŋ�}���xh.]�NA�m���x��/�<�-$1�������ċ�(FS��-'9L�����8��T,�%9�����=�Ba��x��-ɩ@e�θ�Q/8���q����= �
�Y���E�P�9�q6��Bu����,��1)F��|�}L�Qї
9d
�P0*���K(dR���d9d �Iq*��<�P���吁H&�֊}�$��s����,P�6�k5�'(�Ʉ>���}�@�Lh�O��Y>��R&tʻ�qr�@*�fFa�Y�0j�Z�T��|F�Lh�w�����I3��g�lr��.�[��`WP���i���d �����YP��s�qr�@2��iw\��f&��-�89� �	Ms����T3�knn7Iά�-w����悋Y��dخ�]'�EgB��T��3ʙ�97�U�3ҙ�:�~�x�MhgB�\[��3��<ײo܀� �  z&t�5�89� �	�s�m��n�3����(_A@���%O*,nE*�m�<G	Mh���q�44������'Mh�+�,6F��	]t�w��v2��F�~;;[.�q@��RO�s�8��t���sw�q@:�Z�?�%�҄V��'_AKz�⛗?'�[���⚛�H�8�"*��q��4��.�Y�� �ӄ~�P��/� �	uٚ��!EM�skz���
�Թ�8�����S�Ҕ�3���T����̂�&t�96��d5��ξmr�J�. ��8���Xg�o,�̂�&t�Y�89� �	�uV��M?��&��y�U��@\���89���	�u���wo�kB{�J��3���_�\�Г�a�+P�bM�M4
��a����̂�&���[���G��c'S�q �	MvR���Y�lB����fk�1�4��ت�$������w�a#�ю�j��9�M责�l�#�ڄV;�:]��q@z���&�wH �	�v��~Iu*B+M����B�J)�=����m�T�%q�	T_�|s����m[�|����m]�%qXE
T*^�GX��V�}+N�Y��V�})��8l�*|*F�U[��V�}(l#W��mo��$�^��W��mOe���W��m����8�*\�m�ǜ`P�nۥ\.�âT����*�m�n۹��G>�m�nۙ|�	n[��v���t���ힽ��£��m�4�$G����CF
�G�۶!�(���m[��%q@�mk�t1�a�*PaU���XT�۶[�.��vN��Դˏ�)<*�n��T���m�n�ľ�]���@��)�:n[��6&%�AJn[��6*�K�;�0[
�3�
ܶB��[���
ܶB��sr��a+,P�c��
ܶB��}2�c�
ܶB��m�ā�V趵Nӭ�T���[�����@�ji�W��mU�.?Ȯ�m+t۝�zI�s��"?���m+t���,�P���>�%qX�
T��8[��qX�
TP�A�Ġ�m+t�T�O�_M��o^��6���z��g��^���~ݾiw�T���j�f��_��_�闿lѤ:�"1��TͨO/1�S�b�)���������W�/�Nu�?�}��z����S���G[�oeT7w��>��?��a      ;      x������ � �      %      x������ � �      &      x������ � �      )      x������ � �      +      x������ � �     