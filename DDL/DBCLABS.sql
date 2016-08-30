--
-- PostgreSQL database dump
--

-- Dumped from database version 9.3.13
-- Dumped by pg_dump version 9.3.14
-- Started on 2016-08-30 01:41:28 PET

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 1 (class 3079 OID 11829)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner:
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 2290 (class 0 OID 0)
-- Dependencies: 1
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner:
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- TOC entry 563 (class 1247 OID 58381)
-- Name: sexo_full_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE sexo_full_type AS ENUM (
	'F',
	'M',
	'A'
);


ALTER TYPE public.sexo_full_type OWNER TO postgres;

--
-- TOC entry 566 (class 1247 OID 58388)
-- Name: sexo_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE sexo_type AS ENUM (
	'F',
	'M'
);


ALTER TYPE public.sexo_type OWNER TO postgres;

--
-- TOC entry 227 (class 1255 OID 76103)
-- Name: fn_get_producto_costo(integer, date); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION fn_get_producto_costo(p_insumo_id integer, p_a_fecha date) RETURNS numeric
LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 23-08-2016

Funcion que calcula el costo de un producto en base a todos sus insumos/productos que lo
componen.

PARAMETROS :
p_insumo_id - is del producto a procesar
p_a_fecha - a que fecha se calculara el costo (necesaria cuando la moneda del producto formulado es diferente
	al de sus insumos componentes).

RETURN:
	-1.000 si se requiere tipo de cambio y el mismo no existe definido.
	-2.000 si se requiere conversion de unidades y no existe.
	-3.000 cualquier otro error no contemplado.
	 0.000 si no tiene items.
	el costo si todo esta ok.

Historia : Creado 22-08-2016
*/
DECLARE v_costo numeric(10,4);
				DECLARE v_min_costo numeric(10,4);
				DECLARE v_producto_detalle_id integer;

BEGIN

	-- Leemos los valoresa trabajar.
	SELECT SUM(costo),min(costo),min(producto_detalle_id) INTO v_costo,v_min_costo,v_producto_detalle_id
	FROM (
				 SELECT
					 --	CASE
					 --	 WHEN inso.insumo_tipo = 'IN' THEN
					 --	 (select fn_get_producto_detalle_costo(producto_detalle_id, p_a_fecha) )
					 --	 ELSE
					 --	 (select fn_get_producto_costo(inso.insumo_id, p_a_fecha) )
					 --     END AS costo,
					 (select fn_get_producto_detalle_costo(producto_detalle_id, now()::date) ) as costo,
					 pd.producto_detalle_id
				 FROM   tb_insumo ins
					 inner join tb_producto_detalle pd
						 ON pd.insumo_id_origen = ins.insumo_id
					 inner join tb_insumo inso
						 ON inso.insumo_id = pd.insumo_id
				 WHERE  ins.insumo_id = p_insumo_id
			 ) res;

	RAISE NOTICE 'v_costo %',v_costo;
	RAISE NOTICE 'v_min_costo %',v_min_costo;
	RAISE NOTICE 'v_producto_detalle_id %',v_producto_detalle_id;

	-- Si v_producto_detalle_id es null significa que no hay items y el costo es cero.
	IF v_producto_detalle_id IS NULL
	THEN
		v_costo := 0.0000;
	END IF;


	-- si en el calculo de los items hubo alguno que no encontro tipo de cambio
	-- o conversion requerida retornara 0 -1 o -2 segun el caso.
	IF coalesce(v_min_costo,0) < 0
	THEN
		v_costo := v_min_costo;
	END IF;

	--  Este es un ilogico pero si se diera devovemos 3 indicando que hubo problemas de calculo.
	IF v_costo IS NULL
	THEN
		v_costo := -3;
	END IF;
	RAISE NOTICE 'v_costo %',v_costo;

	RETURN v_costo;

END;
$$;


ALTER FUNCTION public.fn_get_producto_costo(p_insumo_id integer, p_a_fecha date) OWNER TO clabsuser;

--
-- TOC entry 228 (class 1255 OID 76089)
-- Name: fn_get_producto_detalle_costo(integer, date); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION fn_get_producto_detalle_costo(p_producto_detalle_id integer, p_a_fecha date) RETURNS numeric
LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 22-08-2016

Funcion que calcula el costo de un insumo/producto que pertenece a la receta de un producto.

PARAMETROS :
p_producto_detalle_id - is del item a procesar
p_a_fecha - a que fecha se calculara el costo (necesaria cuando la moneda del producto formulado es diferente
	al de sus insumos componentes.

RETURN:
	-1.000 si se requiere tipo de cambio y el mismo no existe definido.
	-2.000 si se requiere conversion de unidades y no existe.
	el costo si todo esta ok.

Historia : Creado 24-08-2016
*/
DECLARE v_costo  numeric(10,4) = 0.00 ;
				DECLARE v_producto_detalle_cantidad numeric(10,4);
				DECLARE v_producto_detalle_merma numeric(10,4);
				DECLARE v_moneda_codigo_producto character varying(8);
				DECLARE v_moneda_codigo_costo character varying(8);
				DECLARE v_producto_detalle_id integer;
				DECLARE v_insumo_id_origen integer;
				DECLARE v_insumo_id integer;
				DECLARE v_tipo_cambio_tasa_compra numeric(8,4);
				DECLARE v_tipo_cambio_tasa_venta numeric(8,4);
				DECLARE v_unidad_medida_codigo_costo character varying(8);
				DECLARE v_unidad_medida_codigo character varying(8);
				DECLARE v_unidad_medida_conversion_factor numeric(12,5);
				DECLARE v_insumo_costo numeric(10,4);
BEGIN

	-- Leemos los valoresa trabajar.
	SELECT     pd.producto_detalle_id,
		pd.insumo_id,
		pd.producto_detalle_cantidad,
		pd.producto_detalle_merma,
		ins.moneda_codigo_costo,
		inso.insumo_id,
		inso.moneda_codigo_costo,
		unidad_medida_codigo,
		ins.unidad_medida_codigo_costo,
		--   ins.insumo_costo,
		CASE
		WHEN ins.insumo_tipo = 'IN' THEN
			ins.insumo_costo
		ELSE
			(select fn_get_producto_costo(pd.insumo_id, p_a_fecha) )
		END AS insumo_costo
	INTO       v_producto_detalle_id,
		v_insumo_id,
		v_producto_detalle_cantidad,
		v_producto_detalle_merma,
		v_moneda_codigo_costo,
		v_insumo_id_origen,
		v_moneda_codigo_producto,
		v_unidad_medida_codigo,
		v_unidad_medida_codigo_costo,
		v_insumo_costo
	FROM       tb_producto_detalle pd
		inner join tb_insumo ins
			ON         ins.insumo_id = pd.insumo_id
		inner join tb_insumo inso
			ON         inso.insumo_id = pd.insumo_id_origen
	WHERE      producto_detalle_id = p_producto_detalle_id;

	IF v_producto_detalle_id  IS NULL
	THEN
		RAISE  'No existe el item solicitado a calcular' USING ERRCODE = 'restrict_violation';
	END IF;

	IF v_insumo_id_origen  IS NULL
	THEN
		RAISE  'No existe el producto principal a calcular' USING ERRCODE = 'restrict_violation';
	END IF;

	-- buscamos que exista el tipo de cambio entre las monedas a la fecha solicitada.
	-- de ser la misma moneda el tipo de cambio siempre sera 1,
	IF v_moneda_codigo_costo = v_moneda_codigo_producto
	THEN
		v_tipo_cambio_tasa_compra = 1.00;
		v_tipo_cambio_tasa_venta  = 1.00;
	ELSE
		SELECT tipo_cambio_tasa_compra,
			tipo_cambio_tasa_venta
		INTO   v_tipo_cambio_tasa_compra, v_tipo_cambio_tasa_venta
		FROM   tb_tipo_cambio
		WHERE  moneda_codigo_origen = v_moneda_codigo_costo
					 AND moneda_codigo_destino = v_moneda_codigo_producto
					 AND p_a_fecha BETWEEN tipo_cambio_fecha_desde AND tipo_cambio_fecha_hasta;
	END IF;
	--RAISE NOTICE 'v_moneda_codigo_costo %',v_moneda_codigo_costo;
	--RAISE NOTICE 'v_moneda_codigo_producto %',v_moneda_codigo_producto;

	--RAISE NOTICE 'v_tipo_cambio_tasa_compra %',v_tipo_cambio_tasa_compra;
	--RAISE NOTICE 'v_tipo_cambio_tasa_venta %',v_tipo_cambio_tasa_venta;

	-- Si no se ha encotrado tipo de cambio retornamos -1 como costo
	IF v_tipo_cambio_tasa_compra IS NULL or v_tipo_cambio_tasa_venta IS NULL
	THEN
		v_costo := -1.0000;
	ELSE
		-- Procedemos a buscar la conversion de unidades entre el insumo o producto original y el especificado
		-- en el item a grabar.
		--	SELECT unidad_medida_codigo_costo
		--		INTO v_unidad_medida_codigo_costo
		--	FROM
		--		tb_insumo
		--	WHERE insumo_id = v_insumo_id_origen;

		-- Si el producto principal y el insumo son distintos buscamos la conversiom
		-- de lo contrario simepre sera 1.
		IF v_unidad_medida_codigo_costo != v_unidad_medida_codigo
		THEN
			select unidad_medida_conversion_factor
			into v_unidad_medida_conversion_factor
			from
				tb_unidad_medida_conversion
			where unidad_medida_origen = v_unidad_medida_codigo AND
						unidad_medida_destino = v_unidad_medida_codigo_costo ;
		ELSE
			v_unidad_medida_conversion_factor := 1;
		END IF;
		--RAISE NOTICE 'v_producto_detalle_cantidad %',v_producto_detalle_cantidad;
		--RAISE NOTICE 'v_unidad_medida_conversion_factor %',v_unidad_medida_conversion_factor;
		--RAISE NOTICE 'v_producto_detalle_merma %',v_producto_detalle_merma;
		--RAISE NOTICE 'v_tipo_cambio_tasa_compra %',v_tipo_cambio_tasa_compra;
		--RAISE NOTICE 'v_insumo_costo %',v_insumo_costo;

		-- Si la conversion de medidas no existe retornamos como costo -2
		IF v_unidad_medida_conversion_factor IS NULL
		THEN
			v_costo := -2.0000;
		ELSE
			IF v_insumo_costo >= 0
			THEN
				-- Calculamos tomando en cuenta el % de merma
				IF v_unidad_medida_conversion_factor = 1
				THEN
					v_costo := (v_producto_detalle_cantidad*(1+v_producto_detalle_merma/100.00000))*v_tipo_cambio_tasa_compra*v_insumo_costo;
				ELSE
					-- Esto es para ver si se retira todo lo relativo a cambio de unidad ya que parece no ser necesario
					v_costo := (v_producto_detalle_cantidad*(1+v_producto_detalle_merma/100.00000))*v_unidad_medida_conversion_factor*v_tipo_cambio_tasa_compra*v_insumo_costo;
				END IF;
			ELSE
				v_costo:= v_insumo_costo;
			END IF;
		END IF;
	END IF;

	--RAISE NOTICE 'v_costo %',v_costo;
	-- RAISE NOTICE 'v_insumo_id %',v_insumo_id;
	-- RAISE NOTICE 'v_producto_detalle_id %',v_producto_detalle_id;

	RETURN v_costo;

END;
$$;


ALTER FUNCTION public.fn_get_producto_detalle_costo(p_producto_detalle_id integer, p_a_fecha date) OWNER TO clabsuser;

--
-- TOC entry 212 (class 1255 OID 58417)
-- Name: sp_asigperfiles_save_record(integer, integer, integer, boolean, character varying, integer, bit); Type: FUNCTION; Schema: public; Owner: atluser
--

CREATE FUNCTION sp_asigperfiles_save_record(p_asigperfiles_id integer, p_perfil_id integer, p_usuarios_id integer, p_activo boolean, p_usuario character varying, p_version_id integer, p_is_update bit) RETURNS integer
LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 08-10-2013

Stored procedure que agrega o actualiza los registros de aisgnacion de perfiles.

El parametro p_version_id indica el campo xmin de control para cambios externos y solo se usara
durante un update , de la misma forma el parametro id sera ignorado durante un insert.

IMPORTANTE : Esta procedure function devuelve un entero siempre que el update o el insert
	se hayan realizado y devuelve null si no se realizo el update. Esta extraña forma
	se debe a que en pgsql las funciones se ejecutan con select funct_name() , esto quiere
	decir que al margen si el update se realizo o no siempre devolvera un registro afectado.
	En realidad lo que esta diciendo es que el select de la funcion se ha ejecutado , pero no
	es eso lo que deseamos si no saber si el update se realizo o no , para poder simular el
	comportamiento standard de otras bases de datos he realizado un truco , determinando si existio
	o no el update usando la variable postgres FOUND y retornando 1 si lo hzo y null si no lo hizo.

	Esta forma permite realizar el siguiente select cuando se trata de un UPDATE :

	select * from ( select sp_asigperfiles_save_record(?,?,etc) as updins) as ans where updins is not null;

	de tal forma que retornara un registro si el update funciono o el insert , y 0 registros si no se realizo
	el uodate. sto es conveniente cuando se usa por ejemplo el affected_rows de algunos drivers.
	EN OTRAS BASES ESTO NO ES NECESARIO.

Historia : Creado 08-10-2013
*/
BEGIN

	IF p_is_update = '1'
	THEN
		UPDATE
			tb_sys_asigperfiles
		SET
			asigperfiles_id=p_asigperfiles_id,
			perfil_id=p_perfil_id,
			usuarios_id=p_usuarios_id,
			activo=p_activo,
			usuario_mod=p_usuario
		WHERE asgper_id = p_asgper_id and xmin =p_version_id ;
		--RAISE NOTICE  'COUNT ID --> %', FOUND;

		IF FOUND THEN
			RETURN 1;
		ELSE
			RETURN null;
		END IF;
	ELSE
		INSERT INTO
			tb_sys_asigperfiles
			(perfil_id,usuarios_id,activo,usuario)
		VALUES(p_perfil_id,
					 usuarios_id,
					 p_activo,
					 p_usuario);

		RETURN 1;

	END IF;
END;
$$;


ALTER FUNCTION public.sp_asigperfiles_save_record(p_asigperfiles_id integer, p_perfil_id integer, p_usuarios_id integer, p_activo boolean, p_usuario character varying, p_version_id integer, p_is_update bit) OWNER TO atluser;

--
-- TOC entry 229 (class 1255 OID 84061)
-- Name: sp_insumo_delete_record(integer, character varying, integer); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION sp_insumo_delete_record(p_insumo_id integer, p_usuario_mod character varying, p_version_id integer) RETURNS integer
LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 03-02-2014

Stored procedure que elimina un isumo o produco eliminando todos las asociaciones a sus clubes,
NO ELIMINA LOS CLUBES SOLO LAS ASOCIASIONES A LOS MISMO.

El parametro p_version_id indica el campo xmin de control para cambios externos .

Esta procedure function devuelve un entero siempre que el delete
	se haya realizado y devuelve null si no se realizo el delete. Esta extraña forma
	se debe a que en pgsql las funciones se ejecutan con select funct_name() , esto quiere
	decir que al margen si el delete se realizo o no siempre devolvera un registro afectado.
	En realidad lo que esta diciendo es que el select de la funcion se ha ejecutado , pero no
	es eso lo que deseamos si no saber si el delete se realizo o no , para poder simular el
	comportamiento standard de otras bases de datos he realizado un truco , determinando si existio
	o no el delete usando la variable postgres FOUND y retornando 1 si lo hzo y null si no lo hizo.

	Esta forma permite realizar el siguiente select :

	select * from ( select sp_insumo_delete_record(?,?,etc) as updins) as ans where updins is not null;

	de tal forma que retornara un registro si el delete funciono , y 0 registros si no se realizo
	el delete. Esto es conveniente cuando se usa por ejemplo el affected_rows de algunos drivers.
	EN OTRAS BASES ESTO NO ES NECESARIO.
Historia : Creado 03-02-2014
*/
BEGIN

	-- Verificacion previa que el registro no esta modificado
	--
	-- Existe una pequeñisima oportunidad que el registro sea alterado entre el exist y el delete
	-- pero dado que es intranscendente no es importante crear una sub transaccion para solo
	-- verificar eso , por ende es mas que suficiente solo esta previa verificacion por exist.
	IF EXISTS (SELECT 1 FROM tb_insumo WHERE insumo_id = p_insumo_id and xmin=p_version_id) THEN
		-- Eliminamos si es que tiene componentes
		DELETE FROM
			tb_producto_detalle
		WHERE insumo_id_origen = p_insumo_id;

		DELETE FROM
			tb_insumo
		WHERE insumo_id = p_insumo_id and xmin=p_version_id;

		-- SI SE PUDO ELIMINAR SE INDICA 1 DE LO CONTRARIO NULL
		-- VER DOCUMENTACION DE LA FUNCION
		IF FOUND THEN
			RETURN 1;
		ELSE
			RETURN null;
		END IF;
	ELSE
		RETURN null;
	END IF;

END;
$$;


ALTER FUNCTION public.sp_insumo_delete_record(p_insumo_id integer, p_usuario_mod character varying, p_version_id integer) OWNER TO clabsuser;

--
-- TOC entry 213 (class 1255 OID 58453)
-- Name: sp_perfil_delete_record(integer, character varying, integer); Type: FUNCTION; Schema: public; Owner: atluser
--

CREATE FUNCTION sp_perfil_delete_record(p_perfil_id integer, p_usuario_mod character varying, p_version_id integer) RETURNS integer
LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 01-01-2014

Stored procedure que elimina un perfil de menu eliminando todos los registros de perfil detalle asociados.

El parametro p_version_id indica el campo xmin de control para cambios externos .

Esta procedure function devuelve un entero siempre que el delete
	se haya realizado y devuelve null si no se realizo el delete. Esta extraña forma
	se debe a que en pgsql las funciones se ejecutan con select funct_name() , esto quiere
	decir que al margen si el delete se realizo o no siempre devolvera un registro afectado.
	En realidad lo que esta diciendo es que el select de la funcion se ha ejecutado , pero no
	es eso lo que deseamos si no saber si el delete se realizo o no , para poder simular el
	comportamiento standard de otras bases de datos he realizado un truco , determinando si existio
	o no el delete usando la variable postgres FOUND y retornando 1 si lo hzo y null si no lo hizo.

	Esta forma permite realizar el siguiente select :

	select * from ( select sp_perfil_delete_record(?,?,etc) as updins) as ans where updins is not null;

	de tal forma que retornara un registro si el delete funciono , y 0 registros si no se realizo
	el delete. Esto es conveniente cuando se usa por ejemplo el affected_rows de algunos drivers.
	EN OTRAS BASES ESTO NO ES NECESARIO.
Historia : Creado 05-01-2014
*/
BEGIN

	-- Verificacion previa que el registro no esgta modificado
	--
	-- Existe una pequeñisima oportunidad que el registro sea alterado entre el exist y el delete
	-- pero dado que es intranscendente no es importante crear una sub transaccion para solo
	-- verificar eso , por ende es mas que suficiente solo esta previa verificacion por exist.
	IF EXISTS (SELECT 1 FROM tb_sys_perfil WHERE perfil_id = p_perfil_id and xmin=p_version_id) THEN
		-- Eliminamos
		DELETE FROM
			tb_sys_perfil_detalle
		WHERE perfil_id = p_perfil_id ;

		DELETE FROM
			tb_sys_perfil
		WHERE perfil_id = p_perfil_id and xmin =p_version_id;

		--RAISE NOTICE  'COUNT ID --> %', FOUND;
		-- SI SE PUDO ELIMINAR SE INDICA 1 DE LO CONTRARIO NULL
		-- VER DOCUMENTACION DE LA FUNCION
		IF FOUND THEN
			RETURN 1;
		ELSE
			RETURN null;
		END IF;
	ELSE
		RETURN null;
	END IF;

END;
$$;


ALTER FUNCTION public.sp_perfil_delete_record(p_perfil_id integer, p_usuario_mod character varying, p_version_id integer) OWNER TO atluser;

--
-- TOC entry 210 (class 1255 OID 58454)
-- Name: sp_perfil_detalle_save_record(integer, integer, integer, boolean, boolean, boolean, boolean, boolean, boolean, character varying, integer); Type: FUNCTION; Schema: public; Owner: atluser
--

CREATE FUNCTION sp_perfil_detalle_save_record(p_perfdet_id integer, p_perfil_id integer, p_menu_id integer, p_acc_leer boolean, p_acc_agregar boolean, p_acc_actualizar boolean, p_acc_eliminar boolean, p_acc_imprimir boolean, p_activo boolean, p_usuario character varying, p_version_id integer) RETURNS integer
LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 01-01-2014

Stored procedure que actualiza los registros de un detalle de perfil. Si este registro es un menu o submenu
aplicara los accesos a toda la ruta desde el nivel de este registro a todos los subniveles de menu
por debajo de este. Por ahora solo soporta el acceso de leer para el caso de grabacion multiple
de tal forma que si se indca que se puede leer se dara acceso total a sus hijos y si deniega se retira el acceso
total a dichos hijos.
Si el caso es que es una opcion de un menu o submenu aplicara los cambios de acceso solo a ese registro.

El parametro p_version_id indica el campo xmin de control para cambios externos y solo se usara
durante un update de registro unico.

IMPORTANTE : Esta procedure function devuelve un entero siempre que el update o el insert
	se hayan realizado y devuelve null si no se realizo el update. Esta extraña forma
	se debe a que en pgsql las funciones se ejecutan con select funct_name() , esto quiere
	decir que al margen si el update se realizo o no siempre devolvera un registro afectado.
	En realidad lo que esta diciendo es que el select de la funcion se ha ejecutado , pero no
	es eso lo que deseamos si no saber si el update se realizo o no , para poder simular el
	comportamiento standard de otras bases de datos he realizado un truco , determinando si existio
	o no el update usando la variable postgres FOUND y retornando 1 si lo hzo y null si no lo hizo.

	Esta forma permite realizar el siguiente select cuando se trata de un UPDATE :

	select * from ( select sp_perfil_detalle_save_record(?,?,etc) as updins) as ans where updins is not null;

	de tal forma que retornara un registro si el update funciono o el insert , y 0 registros si no se realizo
	el uodate. sto es conveniente cuando se usa por ejemplo el affected_rows de algunos drivers.
	EN OTRAS BASES ESTO NO ES NECESARIO.

Historia : Creado 08-10-2013
*/
DECLARE v_isRoot BOOLEAN := 'F';
BEGIN
	-- Si no hay acceso de lectura los demas son desactivados
	IF p_acc_leer = 'F'
	THEN
		p_acc_agregar 	= 'F';
		p_acc_actualizar 	= 'F';
		p_acc_eliminar 	= 'F';
		p_acc_imprimir 	= 'F';

	END IF;

	-- Primero vemos si es un menu o submenu (root de arbol)
	-- PAra esto vemos si algun parent id apunta a este menu , si es asi es un menu
	-- o submenu.
	IF EXISTS (SELECT 1 FROM tb_sys_menu WHERE menu_parent_id = p_menu_id)
	THEN
		v_isRoot := 'T';
		-- Si es root y acceso de lectura es true a todos true
		IF p_acc_leer = 'T'
		THEN
			p_acc_agregar 	= 'T';
			p_acc_actualizar= 'T';
			p_acc_eliminar 	= 'T';
			p_acc_imprimir 	= 'T';

		END IF;
	END IF;

	-- Si es root (menu o submenu) se hace unn update a todas las opciones
	-- debajo del menu o submenu a setear en el perfil.
	IF v_isRoot = 'T'
	THEN
		-- Este metodo es recursivo y existe en otras bases de datos
		-- revisar documentacion de las mismas.
		WITH RECURSIVE rootMenus(menu_id,menu_parent_id)
		AS (
			SELECT menu_id,menu_parent_id
			FROM tb_sys_menu
			WHERE menu_id = p_menu_id

			UNION ALL

			SELECT
				r.menu_id,r.menu_parent_id
			FROM tb_sys_menu r, rootMenus as t
			WHERE r.menu_parent_id = t.menu_id
		)

		-- Update a todo el path a partir de menu o submenu raiz.
		UPDATE tb_sys_perfil_detalle
		SET perfdet_accleer=p_acc_leer,perfdet_accagregar=p_acc_agregar,
			perfdet_accactualizar=p_acc_actualizar,perfdet_accimprimir=p_acc_imprimir,
			perfdet_acceliminar=p_acc_eliminar,
			usuario_mod=p_usuario
		WHERE perfil_id = p_perfil_id-- and xmin=p_version_id
					and menu_id in (
			SELECT menu_id FROM rootMenus
		);

		RAISE NOTICE  'COUNT ID --> %', FOUND;

		IF FOUND THEN
			RETURN 1;
		ELSE
			RETURN null;
		END IF;
	ELSE
		-- UPDATE PARA EL CASO DE UNA OPCION QUE NO ES DE MENU O SUBMENU
		UPDATE tb_sys_perfil_detalle
		SET perfdet_accleer=p_acc_leer,perfdet_accagregar=p_acc_agregar,
			perfdet_accactualizar=p_acc_actualizar,perfdet_accimprimir=p_acc_imprimir,
			perfdet_acceliminar=p_acc_eliminar,
			usuario_mod=p_usuario
		WHERE perfil_id = p_perfil_id
					and menu_id = p_menu_id and xmin=p_version_id;

		RAISE NOTICE  'COUNT ID --> %', FOUND;

		IF FOUND THEN
			RETURN 1;
		ELSE
			RETURN null;
		END IF;

	END IF;
END;
$$;


ALTER FUNCTION public.sp_perfil_detalle_save_record(p_perfdet_id integer, p_perfil_id integer, p_menu_id integer, p_acc_leer boolean, p_acc_agregar boolean, p_acc_actualizar boolean, p_acc_eliminar boolean, p_acc_imprimir boolean, p_activo boolean, p_usuario character varying, p_version_id integer) OWNER TO atluser;

--
-- TOC entry 214 (class 1255 OID 58480)
-- Name: sp_sysperfil_add_record(character varying, character varying, character varying, integer, boolean, character varying); Type: FUNCTION; Schema: public; Owner: atluser
--

CREATE FUNCTION sp_sysperfil_add_record(p_sys_systemcode character varying, p_perfil_codigo character varying, p_perfil_descripcion character varying, p_copyfrom integer, p_activo boolean, p_usuario character varying) RETURNS integer
LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 26-09-2013

Stored procedure que agrega o actualiza los registros de personal.
Previo a la grabacion forma el nombre completo del personal.

El parametro p_version_id indica el campo xmin de control para cambios externos y solo se usara
durante un update , de la misma forma el parametro id sera ignorado durante un insert.

IMPORTANTE : Esta procedure function devuelve un entero siempre que el update o el insert
	se hayan realizado y devuelve null si no se realizo el update. Esta extraña forma
	se debe a que en pgsql las funciones se ejecutan con select funct_name() , esto quiere
	decir que al margen si el update se realizo o no siempre devolvera un registro afectado.
	En realidad lo que esta diciendo es que el select de la funcion se ha ejecutado , pero no
	es eso lo que deseamos si no saber si el update se realizo o no , para poder simular el
	comportamiento standard de otras bases de datos he realizado un truco , determinando si existio
	o no el update usando la variable postgres FOUND y retornando 1 si lo hzo y null si no lo hizo.

	Esta forma permite realizar el siguiente select cuando se trata de un UPDATE :

	select * from ( select sp_personal_save_record(?,?,etc) as updins) as ans where updins is not null;

	de tal forma que retornara un registro si el update funciono o el insert , y 0 registros si no se realizo
	el uodate. sto es conveniente cuando se usa por ejemplo el affected_rows de algunos drivers.
	EN OTRAS BASES ESTO NO ES NECESARIO.

Historia : Creado 26-09-2013
*/

BEGIN

	-- Insertamos primero el header
	INSERT INTO
		tb_sys_perfil
		(sys_systemcode,perfil_codigo,perfil_descripcion,activo,usuario)
	VALUES (p_sys_systemcode,
					p_perfil_codigo,
					p_perfil_descripcion,
					p_activo,
					p_usuario);

	IF (p_copyFrom IS NOT NULL)
	THEN
		-- Verificamos exista el origen de copia
		IF EXISTS (SELECT 1 FROM tb_sys_perfil WHERE sys_systemcode = p_sys_systemcode and perfil_id=p_copyFrom)
		THEN
			-- De sys menu copiamos todas las opciones desabilitadas en el acceso para
			-- crear el perfil default.
			INSERT INTO
				tb_sys_perfil_detalle
				(perfil_id,perfdet_accessdef,perfdet_accleer,perfdet_accagregar,perfdet_accactualizar,perfdet_acceliminar,perfdet_accimprimir,menu_id,activo,usuario)
				SELECT  currval('tb_sys_perfil_id_seq'),perfdet_accessdef,perfdet_accleer,perfdet_accagregar,perfdet_accactualizar,perfdet_acceliminar,perfdet_accimprimir,menu_id,p_activo,p_usuario
				FROM tb_sys_perfil_detalle pd
				WHERE pd.perfil_id=p_copyFrom;
			RETURN 1;

		ELSE
			-- Excepcion de integridad referencial
			RAISE 'El perfil origen para copiar no existe' USING ERRCODE = 'no_data_found';
		END IF;
	ELSE
		-- De sys menu copiamos todas las opciones desabilitadas en el acceso para
		-- crear el perfil default.
		INSERT INTO
			tb_sys_perfil_detalle
			(perfil_id,perfdet_accessdef,perfdet_accleer,perfdet_accagregar,perfdet_accactualizar,perfdet_acceliminar,perfdet_accimprimir,menu_id,activo,usuario)
			SELECT  currval('tb_sys_perfil_id_seq'),null,'N','N','N','N','N',m.menu_id,p_activo,p_usuario
			FROM tb_sys_menu m
			WHERE m.sys_systemcode = p_sys_systemcode
			ORDER BY menu_orden;

		RETURN 1;
	END IF;

END;
$$;


ALTER FUNCTION public.sp_sysperfil_add_record(p_sys_systemcode character varying, p_perfil_codigo character varying, p_perfil_descripcion character varying, p_copyfrom integer, p_activo boolean, p_usuario character varying) OWNER TO atluser;

--
-- TOC entry 225 (class 1255 OID 59436)
-- Name: sptrg_insumo_validate_save(); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION sptrg_insumo_validate_save() RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE v_insumo_codigo character varying(15);
				DECLARE v_insumo_tipo character varying(2) := NULL;
				DECLARE v_insumo_descripcion character varying(60);

	-------------------------------------------------------------------------------------------
	--
	-- Funcion para trigger que verifica durante un update que para el tipo
	-- de insumo , que no exista un tipo de insumo con diferente codigo pero el mismo nombre.
	--
	-- Author :Carlos Arana R
	-- Fecha: 10/07/2016
	-- Version 1.00
	-------------------------------------------------------------------------------------------
BEGIN
	IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN

		-- Cuando se trata de un producto ciertos valores siempre deben ser los mismos , por ende
		-- seteamos default. Recordar que para un PRODUCTO ('PR') el costo es calculado
		-- on line por ende no se debe grabar costo.
		IF NEW.insumo_tipo = 'PR'
		THEN
			NEW.tinsumo_codigo = 'NING';
			NEW.tcostos_codigo = 'NING';
			NEW.unidad_medida_codigo_ingreso = 'NING';
			NEW.insumo_costo = NULL;
		END IF;

		-- Verificamos si alguno con el mismo nombre existe e indicamos el error.
		SELECT insumo_codigo INTO v_insumo_codigo FROM tb_insumo
		where UPPER(LTRIM(RTRIM(insumo_descripcion))) = UPPER(LTRIM(RTRIM(NEW.insumo_descripcion)));

		IF NEW.insumo_codigo != v_insumo_codigo
		THEN
			-- Excepcion de region con ese nombre existe
			RAISE 'Ya existe una insumo con ese nombre en el insumo [%]',v_insumo_codigo USING ERRCODE = 'restrict_violation';
		END IF;

		-- Validamos que no exista otro producto o insumo con el mismo codigo.
		IF TG_OP = 'INSERT'
		THEN
			SELECT insumo_tipo,insumo_descripcion INTO v_insumo_tipo,v_insumo_descripcion FROM tb_insumo
			where insumo_codigo = NEW.insumo_codigo;
		ELSE
			IF OLD.insumo_codigo != NEW.insumo_codigo
			THEN
				SELECT insumo_tipo,insumo_descripcion INTO v_insumo_tipo,v_insumo_descripcion FROM tb_insumo
				where insumo_codigo = NEW.insumo_codigo;
			END IF;
		END IF;

		IF v_insumo_tipo IS NOT NULL
		THEN
			-- El mismo codigo no debe existri nunca sea producto o insumo.
			IF v_insumo_tipo = 'IN'
			THEN
				RAISE 'Ya existe una insumo con ese codigo [%]',v_insumo_descripcion USING ERRCODE = 'restrict_violation';
			ELSE
				RAISE 'Ya existe un producto con ese codigo [%]',v_insumo_descripcion USING ERRCODE = 'restrict_violation';
			END IF;
		END IF;

		-- Validamos que exista la  conversion entre medidas siempre que sea insumo no producto , ya que los productos
		-- no tienen unidad de ingreso.
		IF v_insumo_tipo = 'IN' AND NOT EXISTS(select 1 from tb_unidad_medida_conversion
		where unidad_medida_origen = NEW.unidad_medida_codigo_ingreso AND unidad_medida_destino = NEW.unidad_medida_codigo_costo LIMIT 1)
		THEN
			RAISE 'Debera existir la conversion entre las unidades de medidas indicadas [% - %]',NEW.unidad_medida_codigo_ingreso,NEW.unidad_medida_codigo_costo  USING ERRCODE = 'restrict_violation';
		END IF;

	END IF;
	RETURN NEW;
END;
$$;


ALTER FUNCTION public.sptrg_insumo_validate_save() OWNER TO clabsuser;

--
-- TOC entry 219 (class 1255 OID 59408)
-- Name: sptrg_moneda_validate_save(); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION sptrg_moneda_validate_save() RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE v_moneda_codigo_s character varying(8);
				DECLARE v_moneda_codigo_d character varying(8);

	-------------------------------------------------------------------------------------------
	--
	-- Funcion para trigger que verifica durante un add o update que no exista otra moneda con las
	-- mismas siglas o descripcion.
	-- No he usado unique index o constraint ya que prefiero indicar que moneda es la que tiene
	-- la sigla o descripcion duplicada. En este caso no habra muchos registros por lo que el impacto
	-- es minimo.
	--
	-- Author :Carlos Arana R
	-- Fecha: 10/07/2016
	-- Version 1.00
	-------------------------------------------------------------------------------------------
BEGIN
	IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
		-- buscamos si existe un codigo que ya tenga las mismas siglas
		SELECT moneda_codigo INTO v_moneda_codigo_s FROM tb_moneda
		where moneda_simbolo = NEW.moneda_simbolo;

		-- buscamos si existe un codigo que ya tenga la misma descripcion
		SELECT moneda_codigo INTO v_moneda_codigo_d FROM tb_moneda
		where UPPER(LTRIM(RTRIM(moneda_descripcion))) = UPPER(LTRIM(RTRIM(NEW.moneda_descripcion)));

		IF NEW.moneda_codigo != v_moneda_codigo_s
		THEN
			-- Excepcion de region con ese nombre existe
			RAISE 'Las siglas de la moneda existe en otro codigo [%]',v_moneda_codigo_s USING ERRCODE = 'restrict_violation';
		END IF;

		IF NEW.moneda_codigo != v_moneda_codigo_d
		THEN
			-- Excepcion de region con ese nombre existe
			RAISE 'La descripcion de la moneda existe en otro codigo [%]',v_moneda_codigo_d USING ERRCODE = 'restrict_violation';
		END IF;
	END IF;
	RETURN NEW;
END;
$$;


ALTER FUNCTION public.sptrg_moneda_validate_save() OWNER TO clabsuser;

--
-- TOC entry 226 (class 1255 OID 75870)
-- Name: sptrg_producto_detalle_validate_save(); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION sptrg_producto_detalle_validate_save() RETURNS trigger
LANGUAGE plpgsql
AS $$

-------------------------------------------------------------------------------------------
--
-- Funcion para trigger que verifica durante un add o update que no permite agregar un producto
-- detalle cuyo id es el mismo que el producto principal al cual perteneceria., ni si este item a agregar
-- esta coneniendo a otro que lo contiene.
--
-- Author :Carlos Arana R
-- Fecha: 10/07/2016
-- Version 1.00
-------------------------------------------------------------------------------------------
DECLARE v_unidad_medida_codigo_costo character varying(8);

BEGIN
	IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
		IF NEW.insumo_id = NEW.insumo_id_origen
		THEN
			RAISE 'Un componente no puede ser igual al producto principal' USING ERRCODE = 'restrict_violation';
		END IF;

	END IF;

	--No se puede agregar un producto como item si es que este mismo contiene al producto
	-- principal.
	IF EXISTS(select 1 from tb_producto_detalle where insumo_id_origen = NEW.insumo_id and insumo_id = NEW.insumo_id_origen LIMIT 1)
	THEN
		RAISE 'Este item contiene a este producto lo cual no es posible' USING ERRCODE = 'restrict_violation';
	END IF;

	-- Validamos que el tipo de unidad del item exista conversion entre medidas siempre que sea insumo no producto , ya que los productos
	-- no tienen unidad de ingreso.
	SELECT unidad_medida_codigo_costo
	INTO v_unidad_medida_codigo_costo
	FROM
		tb_insumo
	WHERE insumo_id = NEW.insumo_id;
	-- Si las unidades son iguales no requiere validacion ya que la conversion es 1
	IF v_unidad_medida_codigo_costo != NEW.unidad_medida_codigo
	THEN
		IF NOT EXISTS(
				select 1
				from tb_unidad_medida_conversion
				where unidad_medida_origen = v_unidad_medida_codigo_costo AND
							unidad_medida_destino = NEW.unidad_medida_codigo LIMIT 1)
		THEN
			RAISE 'No existe conversion entre la unidad de costo y la unidad indicada en el item , indicadas por [% - %]',v_unidad_medida_codigo_costo,NEW.unidad_medida_codigo  USING ERRCODE = 'restrict_violation';
		END IF;
	END IF;

	RETURN NEW;
END;
$$;


ALTER FUNCTION public.sptrg_producto_detalle_validate_save() OWNER TO clabsuser;

--
-- TOC entry 215 (class 1255 OID 58510)
-- Name: sptrg_records_save(); Type: FUNCTION; Schema: public; Owner: atluser
--

CREATE FUNCTION sptrg_records_save() RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE v_pruebas_descripcion character varying(100);
				DECLARE v_atletas_codigo character varying(15);
				DECLARE v_competencias_codigo character varying(15);
				DECLARE v_pruebas_generica_codigo character varying(15);

	-------------------------------------------------------------------------------------------
	--
	-- Funcion para trigger que verifica durante un update que para el tipo
	-- de record , categoria, prueba y competencia no se repita un record
	-- que ya tiene otro atleta.
	--
	-- DROP TRIGGER tr_records_save ON tb_records;
	--
	-- CREATE  TRIGGER tr_records_save
	-- BEFORE INSERT OR UPDATE ON tr_records_save
	--     FOR EACH ROW EXECUTE PROCEDURE public.sptrg_records_save();
	--
	-- Author :Carlos Arana R
	-- Fecha: 26/06/2014
	-- Version 1.00
	-------------------------------------------------------------------------------------------
BEGIN
	IF (TG_OP = 'INSERT') THEN
		SELECT
			atletas_codigo,pruebas_generica_codigo,apppruebas_descripcion,competencias_codigo
		INTO  	v_atletas_codigo,v_pruebas_generica_codigo,v_pruebas_descripcion,v_competencias_codigo
		FROM tb_atletas_resultados atl
			inner join tb_competencias_pruebas cp on cp.competencias_pruebas_id = atl.competencias_pruebas_id
			inner join tb_pruebas pr on pr.pruebas_codigo = cp.pruebas_codigo
			inner join tb_app_pruebas_values pv on pv.apppruebas_codigo = pr.pruebas_generica_codigo
		where atl.atletas_resultados_id = NEW.atletas_resultados_id ;

		IF EXISTS(
				select
					1
				from
					tb_records re
					inner join tb_atletas_resultados atl on atl.atletas_resultados_id = re.atletas_resultados_id
					inner join tb_competencias_pruebas cp on cp.competencias_pruebas_id = atl.competencias_pruebas_id
					inner join tb_pruebas pr on pr.pruebas_codigo = cp.pruebas_codigo
				where atletas_codigo != v_atletas_codigo and
							re.categorias_codigo = NEW.categorias_codigo and
							pruebas_generica_codigo = v_pruebas_generica_codigo and
							records_tipo_codigo= NEW.records_tipo_codigo and
							cp.competencias_codigo = v_competencias_codigo
		)
		THEN
			RAISE 'Ya existe un record para la categoria % del tipo % y prueba %, en la competencia indicada',NEW.categorias_codigo, NEW.records_tipo_codigo,v_pruebas_descripcion USING ERRCODE = 'restrict_violation';
		END IF ;
	END IF;

	RETURN NEW;
END;
$$;


ALTER FUNCTION public.sptrg_records_save() OWNER TO atluser;

--
-- TOC entry 220 (class 1255 OID 75920)
-- Name: sptrg_tcostos_validate_delete(); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION sptrg_tcostos_validate_delete() RETURNS trigger
LANGUAGE plpgsql
AS $$

-------------------------------------------------------------------------------------------
--
-- Funcion para trigger que verifica que no se pueda eliminar un tipo de cosoto que es del sistema
-- osea que el campo tcostos_protected sea TRUE.
--
-- Author :Carlos Arana R
-- Fecha: 14/08/2016
-- Version 1.00
-------------------------------------------------------------------------------------------
BEGIN
	IF (TG_OP = 'DELETE') THEN
		IF OLD.tcostos_protected = TRUE
		THEN
			-- Excepcion de region con ese nombre existe
			RAISE 'No puede eliminarse un tipo de costos de sistema' USING ERRCODE = 'restrict_violation';
		END IF;
	END IF;
	RETURN OLD;
END;
$$;


ALTER FUNCTION public.sptrg_tcostos_validate_delete() OWNER TO clabsuser;

--
-- TOC entry 223 (class 1255 OID 59493)
-- Name: sptrg_tcostos_validate_save(); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION sptrg_tcostos_validate_save() RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE v_tcostos_codigo character varying(5);

	-------------------------------------------------------------------------------------------
	--
	-- Funcion para trigger que verifica durante un update que para el tipo
	-- de costo , que no exista un tipo de costo con diferente codigo pero el mismo nombre.
	--
	-- Author :Carlos Arana R
	-- Fecha: 10/07/2016
	-- Version 1.00
	-------------------------------------------------------------------------------------------
BEGIN
	IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
		IF TG_OP = 'UPDATE'
		THEN
			IF OLD.tcostos_protected = TRUE
			THEN
				RAISE 'No puede modificarse un registro protegido o de sistema' USING ERRCODE = 'restrict_violation';
			END IF;
		END IF;

		-- Verificamos si alguno con el mismo nombre existe e indicamos el error.
		SELECT tcostos_codigo INTO v_tcostos_codigo FROM tb_tcostos
		where UPPER(LTRIM(RTRIM(tcostos_descripcion))) = UPPER(LTRIM(RTRIM(NEW.tcostos_descripcion)));

		IF NEW.tcostos_codigo != v_tcostos_codigo
		THEN
			RAISE 'Ya existe una tipo de costo con ese nombre en el tipo de costos [%]',v_tcostos_codigo USING ERRCODE = 'restrict_violation';
		END IF;
	END IF;
	RETURN NEW;
END;
$$;


ALTER FUNCTION public.sptrg_tcostos_validate_save() OWNER TO clabsuser;

--
-- TOC entry 222 (class 1255 OID 75922)
-- Name: sptrg_tinsumo_validate_delete(); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION sptrg_tinsumo_validate_delete() RETURNS trigger
LANGUAGE plpgsql
AS $$

-------------------------------------------------------------------------------------------
--
-- Funcion para trigger que verifica que no se pueda eliminar un tipo de insumo que es del sistema
-- osea que el campo tinsumo_protected sea TRUE.
--
-- Author :Carlos Arana R
-- Fecha: 14/08/2016
-- Version 1.00
-------------------------------------------------------------------------------------------
BEGIN
	IF (TG_OP = 'DELETE') THEN
		IF OLD.tinsumo_protected = TRUE
		THEN
			-- Excepcion de region con ese nombre existe
			RAISE 'No puede eliminarse un tipo de insumo de sistema' USING ERRCODE = 'restrict_violation';
		END IF;
	END IF;
	RETURN OLD;
END;
$$;


ALTER FUNCTION public.sptrg_tinsumo_validate_delete() OWNER TO clabsuser;

--
-- TOC entry 209 (class 1255 OID 59257)
-- Name: sptrg_tinsumo_validate_save(); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION sptrg_tinsumo_validate_save() RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE v_tinsumo_codigo character varying(15);

	-------------------------------------------------------------------------------------------
	--
	-- Funcion para trigger que verifica durante un update que para el tipo
	-- de insumo , que no exista un tipo de insumo con diferente codigo pero el mismo nombre.
	--
	-- Author :Carlos Arana R
	-- Fecha: 10/07/2016
	-- Version 1.00
	-------------------------------------------------------------------------------------------
BEGIN
	IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
		IF TG_OP = 'UPDATE'
		THEN
			IF OLD.tinsumo_protected = TRUE
			THEN
				RAISE 'No puede modificarse un registro protegido o de sistema' USING ERRCODE = 'restrict_violation';
			END IF;
		END IF;

		-- Verificamos si alguno con el mismo nombre existe e indicamos el error.
		SELECT tinsumo_codigo INTO v_tinsumo_codigo FROM tb_tinsumo
		where UPPER(LTRIM(RTRIM(tinsumo_descripcion))) = UPPER(LTRIM(RTRIM(NEW.tinsumo_descripcion)));

		IF NEW.tinsumo_codigo != v_tinsumo_codigo
		THEN
			-- Excepcion de region con ese nombre existe
			RAISE 'Ya existe una tipo de insumo con ese nombre en el tipo de insumo [%]',v_tinsumo_codigo USING ERRCODE = 'restrict_violation';
		END IF;
	END IF;
	RETURN NEW;
END;
$$;


ALTER FUNCTION public.sptrg_tinsumo_validate_save() OWNER TO clabsuser;

--
-- TOC entry 221 (class 1255 OID 59481)
-- Name: sptrg_tipo_cambio_validate_save(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sptrg_tipo_cambio_validate_save() RETURNS trigger
LANGUAGE plpgsql
AS $$

-------------------------------------------------------------------------------------------
--
-- Funcion para trigger que verifica durante un add o update que los valores sean
-- consistentes , por ejemplo el rango de fechas y que las momedas sean diferentes entre
--- otras.
---
-- Author :Carlos Arana R
-- Fecha: 10/07/2016
-- Version 1.00
-------------------------------------------------------------------------------------------
BEGIN
	IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
		IF NEW.moneda_codigo_origen = NEW.moneda_codigo_destino
		THEN
			RAISE 'La moneda origen no puede ser la misma que la de destino' USING ERRCODE = 'restrict_violation';
		END IF;

		IF NEW.tipo_cambio_fecha_desde > NEW.tipo_cambio_fecha_hasta
		THEN
			RAISE 'La fecha inicial no puede ser mayor que la fecha final' USING ERRCODE = 'restrict_violation';
		END IF;

		IF TG_OP = 'UPDATE'
		THEN
			-- Validamos que no haya un tipo de cambio entre las fechas indicadas, pero que no sea el mismo
			-- registro al que hacemos update.
			-- Algoritmo , si es tru entonces las fechas se cruzan( start1 <= end2 and start2 <= end1 )
			IF EXISTS( SELECT 1 from tb_tipo_cambio tc
			where (tc.moneda_codigo_origen = NEW.moneda_codigo_origen and
						 tc.moneda_codigo_destino = NEW.moneda_codigo_destino) and
						tc.tipo_cambio_fecha_desde <= NEW.tipo_cambio_fecha_hasta and
						tc.tipo_cambio_fecha_hasta >= NEW.tipo_cambio_fecha_desde and
						tc.tipo_cambio_id != NEW.tipo_cambio_id)
			THEN
				RAISE 'Ya existe un tipo de cambio en ese rango de fechas' USING ERRCODE = 'restrict_violation';
			END IF;
		ELSE
			-- Validamos que no haya un tipo de cambio entre las fechas indicadas.
			-- Algoritmo , si es tru entonces las fechas se cruzan( start1 <= end2 and start2 <= end1 )
			IF EXISTS( SELECT 1 from tb_tipo_cambio tc
			where (tc.moneda_codigo_origen = NEW.moneda_codigo_origen and
						 tc.moneda_codigo_destino = NEW.moneda_codigo_destino) and
						tc.tipo_cambio_fecha_desde <= NEW.tipo_cambio_fecha_hasta and
						tc.tipo_cambio_fecha_hasta >= NEW.tipo_cambio_fecha_desde)
			THEN
				RAISE 'Ya existe un tipo de cambio en ese rango de fechas' USING ERRCODE = 'restrict_violation';
			END IF;
		END IF;
	END IF;
	RETURN NEW;
END;
$$;


ALTER FUNCTION public.sptrg_tipo_cambio_validate_save() OWNER TO postgres;

--
-- TOC entry 211 (class 1255 OID 59370)
-- Name: sptrg_unidad_medida_conversion_validate_save(); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION sptrg_unidad_medida_conversion_validate_save() RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE v_unidad_medida_origen_tipo CHARACTER(1);
				DECLARE v_unidad_medida_destino_tipo CHARACTER(1);

	-------------------------------------------------------------------------------------------
	--
	-- Funcion para trigger que verifica durante un add o update que los valores sean
	-- consistentes , las unidades de medida no deben ser las mismas y asi mismo deben de ser del
	-- mismo tipo por ejemplo VOLUMEN.

	-- Author :Carlos Arana R
	-- Fecha: 10/07/2016
	-- Version 1.00
	-------------------------------------------------------------------------------------------
BEGIN
	IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
		IF NEW.unidad_medida_origen = NEW.unidad_medida_destino
		THEN
			-- Excepcion de region con ese nombre existe
			RAISE 'LA unidad de medida origen no puede ser la misma que la de destino' USING ERRCODE = 'restrict_violation';
		END IF;

		-- Verificamos si alguno con el mismo nombre existe e indicamos el error.
		SELECT unidad_medida_tipo INTO v_unidad_medida_origen_tipo
		FROM tb_unidad_medida
		WHERE unidad_medida_codigo = NEW.unidad_medida_origen;

		SELECT unidad_medida_tipo INTO v_unidad_medida_destino_tipo
		FROM tb_unidad_medida
		WHERE unidad_medida_codigo = NEW.unidad_medida_destino;

		IF v_unidad_medida_origen_tipo != v_unidad_medida_destino_tipo
		THEN
			-- Excepcion de region con ese nombre existe
			RAISE 'Ambas unidades de medida deben de ser del mismo tipo' USING ERRCODE = 'restrict_violation';
		END IF;
	END IF;
	RETURN NEW;
END;
$$;


ALTER FUNCTION public.sptrg_unidad_medida_conversion_validate_save() OWNER TO clabsuser;

--
-- TOC entry 218 (class 1255 OID 75961)
-- Name: sptrg_unidad_medida_validate_delete(); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION sptrg_unidad_medida_validate_delete() RETURNS trigger
LANGUAGE plpgsql
AS $$

-------------------------------------------------------------------------------------------
--
-- Funcion para trigger que verifica que no se pueda eliminar un tipo de cosoto que es del sistema
-- osea que el campo tcostos_protected sea TRUE.
--
-- Author :Carlos Arana R
-- Fecha: 14/08/2016
-- Version 1.00
-------------------------------------------------------------------------------------------
BEGIN
	IF (TG_OP = 'DELETE') THEN
		IF OLD.unidad_medida_protected = TRUE
		THEN
			-- Excepcion de region con ese nombre existe
			RAISE 'No puede eliminarse una unidad de medida de sistema' USING ERRCODE = 'restrict_violation';
		END IF;
	END IF;
	RETURN OLD;
END;
$$;


ALTER FUNCTION public.sptrg_unidad_medida_validate_delete() OWNER TO clabsuser;

--
-- TOC entry 224 (class 1255 OID 59400)
-- Name: sptrg_unidad_medida_validate_save(); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION sptrg_unidad_medida_validate_save() RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE v_unidad_medida_codigo_s character varying(8);
				DECLARE v_unidad_medida_codigo_d character varying(8);

	-------------------------------------------------------------------------------------------
	--
	-- Funcion para trigger que verifica durante un add o update que no exista otra undad de media con las
	-- mismas siglas o descripcion.
	-- No he usado unique index o constraint ya que prefiero indicar que unidad de medida es la que tiene
	-- la sigla o descripcion duplicada. En este caso no habra muchos registros por lo que el impacto
	-- es minimo.
	--
	-- Author :Carlos Arana R
	-- Fecha: 10/07/2016
	-- Version 1.00
	-------------------------------------------------------------------------------------------
BEGIN
	IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
		IF TG_OP = 'UPDATE'
		THEN
			IF OLD.unidad_medida_protected = TRUE
			THEN
				RAISE 'No puede modificarse un registro protegido o de sistema' USING ERRCODE = 'restrict_violation';
			END IF;
		END IF;

		-- buscamos si existe un codigo que ya tenga las mismas siglas
		SELECT unidad_medida_codigo INTO v_unidad_medida_codigo_s FROM tb_unidad_medida
		where unidad_medida_siglas = NEW.unidad_medida_siglas;

		-- buscamos si existe un codigo que ya tenga la misma descripcion
		SELECT unidad_medida_codigo INTO v_unidad_medida_codigo_d FROM tb_unidad_medida
		where UPPER(LTRIM(RTRIM(unidad_medida_descripcion))) = UPPER(LTRIM(RTRIM(NEW.unidad_medida_descripcion)));

		IF NEW.unidad_medida_codigo != v_unidad_medida_codigo_s
		THEN
			-- Excepcion de region con ese nombre existe
			RAISE 'Las siglas de la unidad de medida existe en otro codigo [%]',v_unidad_medida_codigo_s USING ERRCODE = 'restrict_violation';
		END IF;

		IF NEW.unidad_medida_codigo != v_unidad_medida_codigo_d
		THEN
			-- Excepcion de region con ese nombre existe
			RAISE 'La descripcion de la unidad de medida existe en otro codigo [%]',v_unidad_medida_codigo_d USING ERRCODE = 'restrict_violation';
		END IF;
	END IF;
	RETURN NEW;
END;
$$;


ALTER FUNCTION public.sptrg_unidad_medida_validate_save() OWNER TO clabsuser;

--
-- TOC entry 216 (class 1255 OID 58511)
-- Name: sptrg_update_log_fields(); Type: FUNCTION; Schema: public; Owner: atluser
--

CREATE FUNCTION sptrg_update_log_fields() RETURNS trigger
LANGUAGE plpgsql
AS $$
-------------------------------------------------------------------------------------------
--
-- Funcion para trigger que hace update a los campos usuario,fecha_creacion,usuario_mod,
-- fecha_modificacion.
-- Esta funcion es usada para todas las tablas del sistema que tienen dichos campos
-- obviamente debe crearse el trigger para cada caso . por ejemplo :
--
-- DROP TRIGGER tr_tipoDocumento ON tramite.tb_tm_tdocumento;
--
-- CREATE  TRIGGER tr_tipoDocumento
-- BEFORE INSERT OR UPDATE ON tramite.tb_tm_tdocumento
--     FOR EACH ROW EXECUTE PROCEDURE public.sptrg_update_log_fields();
--
-- Author :Carlos Arana R
-- Fecha: 26/08/2013
-- Version 1.00
-------------------------------------------------------------------------------------------
BEGIN
	IF (TG_OP = 'INSERT') THEN
		NEW.FECHA_CREACION := now();
		IF (NEW.usuario is null) THEN
			NEW.usuario := current_user;
		END IF;
	END IF;

	IF (TG_OP = 'UPDATE') THEN
		-- Solo si hay cambio en el registro
		IF (OLD != NEW) THEN
			NEW.fecha_modificacion := now();
			IF (NEW.usuario_mod is null) THEN
				NEW.usuario_mod := current_user;
			END IF;
		END IF;
	END IF;

	RETURN NEW;
END;
$$;


ALTER FUNCTION public.sptrg_update_log_fields() OWNER TO atluser;

--
-- TOC entry 217 (class 1255 OID 58512)
-- Name: sptrg_verify_usuario_code_change(); Type: FUNCTION; Schema: public; Owner: atluser
--

CREATE FUNCTION sptrg_verify_usuario_code_change() RETURNS trigger
LANGUAGE plpgsql
AS $$
-------------------------------------------------------------------------------------------
--
-- Funcion para trigger que verifica que no pueda eliminarse un registro de usuario
-- que es referenciada por una tabla con el codigo de usuario usado.
-- En el caso de update no permitira cambios ni en el usuarios_code o el usuarios_nombre_completo
-- si alguna tabla referencia al usuario.
--
-- Author :Carlos Arana R
-- Fecha: 17/08/2015
-- Version 1.00
-------------------------------------------------------------------------------------------
DECLARE v_TABLENAME_ROW RECORD;
				DECLARE v_queryfield CHARACTER VARYING;
				DECLARE v_found integer;

BEGIN

	IF (TG_OP = 'UPDATE' OR TG_OP = 'DELETE') THEN
		-- Verificamos si ha habido cambio de codigo de usuario o nombre o si se trata de un delete
		IF TG_OP = 'DELETE' OR (OLD.usuarios_code <> NEW.usuarios_code OR OLD.usuarios_nombre_completo <> NEW.usuarios_nombre_completo)
		THEN
			-- Busco todas las tablas en el esquema public ya que pertenecen solo al sistema
			FOR v_TABLENAME_ROW IN
			SELECT  table_name
			from information_schema.tables
			where table_Schema = 'public'
			LOOP
				--raise notice '%', v_TABLENAME_ROW.table_name;
				-- Armo sql query de busqueda usando la metadata del postgress
				v_queryfield := 'SELECT 1
				 FROM
				     pg_catalog.pg_attribute a
				 WHERE
				     a.attnum > 0
				     AND NOT a.attisdropped
				     AND a.attrelid = (
					 SELECT c.oid
					 FROM pg_catalog.pg_class c
					     LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
					 WHERE c.relname = ' || quote_literal(v_TABLENAME_ROW.table_name) || ' AND pg_catalog.pg_table_is_visible(c.oid)
				     )
				     AND (a.attname =''usuario'')';

				-- Ejexuto y verfico que tenga resultados , aqui parto de la idea que siempre
				-- deben existir los campos usuario y usuario_mod juntos , por eso para hacer la busqueda
				-- mas rapida lo ejecuto solo buscando el campo usuario
				EXECUTE v_queryfield;
				GET DIAGNOSTICS v_found = ROW_COUNT;

				IF v_found > 0 THEN
					-- Verifico si en la tabla actual del loop esta usado ya sea en el campo usuario o el campo usuario_mod
					v_queryfield := 'SELECT 1 FROM ' || v_TABLENAME_ROW.table_name || ' WHERE usuario=' || quote_literal(OLD.usuarios_code)
													|| ' or usuario_mod=' || quote_literal(OLD.usuarios_code);

					EXECUTE v_queryfield;
					GET DIAGNOSTICS v_found = ROW_COUNT;
					--raise notice 'nueva %',v_found;
					IF v_found > 0 THEN
						RAISE 'No puede modificarse o eliminarse el codigo ya que el usuario tiene transacciones' USING ERRCODE = 'restrict_violation';
					END IF;
				END IF;
			END LOOP;
		END IF;

	END IF;

	-- Colocamos en mayuscula siempre el codigo de usuario si no ha habido problemas
	IF (TG_OP = 'UPDATE' OR TG_OP = 'INSERT') THEN
		NEW.usuarios_code := UPPER(NEW.usuarios_code);
		RETURN NEW;
	ELSE
		RETURN OLD; -- Para delete siempre se retorna old
	END IF;

END;
$$;


ALTER FUNCTION public.sptrg_verify_usuario_code_change() OWNER TO atluser;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 171 (class 1259 OID 58623)
-- Name: tb_entidad; Type: TABLE; Schema: public; Owner: atluser; Tablespace:
--

CREATE TABLE tb_entidad (
	entidad_id integer NOT NULL,
	entidad_razon_social character varying(200) NOT NULL,
	entidad_ruc character varying(15) NOT NULL,
	entidad_direccion character varying(200) NOT NULL,
	entidad_telefonos character varying(60),
	entidad_fax character varying(10),
	entidad_correo character varying(100),
	activo boolean DEFAULT true NOT NULL,
	usuario character varying(15) NOT NULL,
	fecha_creacion timestamp without time zone NOT NULL,
	usuario_mod character varying(15),
	fecha_modificacion timestamp without time zone
);


ALTER TABLE public.tb_entidad OWNER TO atluser;

--
-- TOC entry 2291 (class 0 OID 0)
-- Dependencies: 171
-- Name: TABLE tb_entidad; Type: COMMENT; Schema: public; Owner: atluser
--

COMMENT ON TABLE tb_entidad IS 'Datos generales de la entidad que usa el sistema';


--
-- TOC entry 172 (class 1259 OID 58630)
-- Name: tb_entidad_entidad_id_seq; Type: SEQUENCE; Schema: public; Owner: atluser
--

CREATE SEQUENCE tb_entidad_entidad_id_seq
START WITH 1
INCREMENT BY 1
NO MINVALUE
NO MAXVALUE
CACHE 1;


ALTER TABLE public.tb_entidad_entidad_id_seq OWNER TO atluser;

--
-- TOC entry 2292 (class 0 OID 0)
-- Dependencies: 172
-- Name: tb_entidad_entidad_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: atluser
--

ALTER SEQUENCE tb_entidad_entidad_id_seq OWNED BY tb_entidad.entidad_id;


--
-- TOC entry 193 (class 1259 OID 75997)
-- Name: tb_insumo; Type: TABLE; Schema: public; Owner: clabsuser; Tablespace:
--

CREATE TABLE tb_insumo (
	insumo_id integer NOT NULL,
	insumo_tipo character varying(2) NOT NULL,
	insumo_codigo character varying(15) NOT NULL,
	insumo_descripcion character varying(60) NOT NULL,
	tinsumo_codigo character varying(15) NOT NULL,
	tcostos_codigo character varying(5) NOT NULL,
	unidad_medida_codigo_ingreso character varying(8) NOT NULL,
	unidad_medida_codigo_costo character varying(8) NOT NULL,
	insumo_merma numeric(10,4) DEFAULT 0.00 NOT NULL,
	insumo_costo numeric(10,4) DEFAULT 0.00,
	moneda_codigo_costo character varying(8) NOT NULL,
	activo boolean,
	usuario character varying(15),
	fecha_creacion timestamp without time zone,
	usuario_mod character varying(15),
	fecha_modificacion timestamp without time zone,
	CONSTRAINT chk_insumo_costo CHECK (
		CASE
		WHEN ((insumo_tipo)::text = 'IN'::text) THEN (insumo_costo IS NOT NULL)
		ELSE (insumo_costo = NULL::numeric)
		END),
	CONSTRAINT chk_insumo_field_len CHECK (((length(rtrim((insumo_codigo)::text)) > 0) AND (length(rtrim((insumo_descripcion)::text)) > 0))),
	CONSTRAINT chk_insumo_merma CHECK ((insumo_merma > 0.00)),
	CONSTRAINT chk_insumo_tipo CHECK ((((insumo_tipo)::text = 'IN'::text) OR ((insumo_tipo)::text = 'PR'::text)))
);


ALTER TABLE public.tb_insumo OWNER TO clabsuser;

--
-- TOC entry 192 (class 1259 OID 75995)
-- Name: tb_insumo_insumo_id_seq; Type: SEQUENCE; Schema: public; Owner: clabsuser
--

CREATE SEQUENCE tb_insumo_insumo_id_seq
START WITH 1
INCREMENT BY 1
NO MINVALUE
NO MAXVALUE
CACHE 1;


ALTER TABLE public.tb_insumo_insumo_id_seq OWNER TO clabsuser;

--
-- TOC entry 2293 (class 0 OID 0)
-- Dependencies: 192
-- Name: tb_insumo_insumo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: clabsuser
--

ALTER SEQUENCE tb_insumo_insumo_id_seq OWNED BY tb_insumo.insumo_id;


--
-- TOC entry 185 (class 1259 OID 59242)
-- Name: tb_moneda; Type: TABLE; Schema: public; Owner: clabsuser; Tablespace:
--

CREATE TABLE tb_moneda (
	moneda_codigo character varying(8) NOT NULL,
	moneda_simbolo character varying(6) NOT NULL,
	moneda_descripcion character varying(80) NOT NULL,
	moneda_protected boolean DEFAULT false NOT NULL,
	activo boolean DEFAULT true NOT NULL,
	usuario character varying(15) NOT NULL,
	fecha_creacion timestamp without time zone NOT NULL,
	usuario_mod character varying(15),
	fecha_modificacion timestamp without time zone,
	CONSTRAINT chk_moneda_field_len CHECK ((((length(rtrim((moneda_codigo)::text)) > 0) AND (length(rtrim((moneda_simbolo)::text)) > 0)) AND (length(rtrim((moneda_descripcion)::text)) > 0)))
);


ALTER TABLE public.tb_moneda OWNER TO clabsuser;

--
-- TOC entry 195 (class 1259 OID 76037)
-- Name: tb_producto_detalle; Type: TABLE; Schema: public; Owner: clabsuser; Tablespace:
--

CREATE TABLE tb_producto_detalle (
	producto_detalle_id integer NOT NULL,
	insumo_id_origen integer NOT NULL,
	insumo_id integer NOT NULL,
	unidad_medida_codigo character varying(8) NOT NULL,
	producto_detalle_cantidad numeric(10,4) DEFAULT 0.00 NOT NULL,
	producto_detalle_merma numeric(10,4) DEFAULT 0.00 NOT NULL,
	activo boolean,
	usuario character varying(15),
	fecha_creacion timestamp without time zone,
	usuario_mod character varying(15),
	fecha_modificacion timestamp without time zone,
	CONSTRAINT chk_producto_detalle_cantidad CHECK ((producto_detalle_cantidad > 0.00)),
	CONSTRAINT chk_producto_detalle_merma CHECK ((producto_detalle_merma >= 0.00))
);


ALTER TABLE public.tb_producto_detalle OWNER TO clabsuser;

--
-- TOC entry 194 (class 1259 OID 76035)
-- Name: tb_producto_detalle_producto_detalle_id_seq; Type: SEQUENCE; Schema: public; Owner: clabsuser
--

CREATE SEQUENCE tb_producto_detalle_producto_detalle_id_seq
START WITH 1
INCREMENT BY 1
NO MINVALUE
NO MAXVALUE
CACHE 1;


ALTER TABLE public.tb_producto_detalle_producto_detalle_id_seq OWNER TO clabsuser;

--
-- TOC entry 2294 (class 0 OID 0)
-- Dependencies: 194
-- Name: tb_producto_detalle_producto_detalle_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: clabsuser
--

ALTER SEQUENCE tb_producto_detalle_producto_detalle_id_seq OWNED BY tb_producto_detalle.producto_detalle_id;


--
-- TOC entry 173 (class 1259 OID 58731)
-- Name: tb_sys_menu; Type: TABLE; Schema: public; Owner: atluser; Tablespace:
--

CREATE TABLE tb_sys_menu (
	sys_systemcode character varying(10),
	menu_id integer NOT NULL,
	menu_codigo character varying(30) NOT NULL,
	menu_descripcion character varying(100) NOT NULL,
	menu_accesstype character(10) NOT NULL,
	menu_parent_id integer,
	menu_orden integer DEFAULT 0,
	activo boolean DEFAULT true NOT NULL,
	usuario character varying(15) NOT NULL,
	fecha_creacion timestamp without time zone NOT NULL,
	usuario_mod character varying(15),
	fecha_modificacion timestamp without time zone
);


ALTER TABLE public.tb_sys_menu OWNER TO atluser;

--
-- TOC entry 174 (class 1259 OID 58736)
-- Name: tb_sys_menu_menu_id_seq; Type: SEQUENCE; Schema: public; Owner: atluser
--

CREATE SEQUENCE tb_sys_menu_menu_id_seq
START WITH 1
INCREMENT BY 1
NO MINVALUE
NO MAXVALUE
CACHE 1;


ALTER TABLE public.tb_sys_menu_menu_id_seq OWNER TO atluser;

--
-- TOC entry 2295 (class 0 OID 0)
-- Dependencies: 174
-- Name: tb_sys_menu_menu_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: atluser
--

ALTER SEQUENCE tb_sys_menu_menu_id_seq OWNED BY tb_sys_menu.menu_id;


--
-- TOC entry 175 (class 1259 OID 58738)
-- Name: tb_sys_perfil; Type: TABLE; Schema: public; Owner: atluser; Tablespace:
--

CREATE TABLE tb_sys_perfil (
	perfil_id integer NOT NULL,
	sys_systemcode character varying(10) NOT NULL,
	perfil_codigo character varying(15) NOT NULL,
	perfil_descripcion character varying(120),
	activo boolean DEFAULT true NOT NULL,
	usuario character varying(15) NOT NULL,
	fecha_creacion timestamp without time zone NOT NULL,
	usuario_mod character varying(15),
	fecha_modificacion timestamp without time zone
);


ALTER TABLE public.tb_sys_perfil OWNER TO atluser;

--
-- TOC entry 176 (class 1259 OID 58742)
-- Name: tb_sys_perfil_detalle; Type: TABLE; Schema: public; Owner: atluser; Tablespace:
--

CREATE TABLE tb_sys_perfil_detalle (
	perfdet_id integer NOT NULL,
	perfdet_accessdef character varying(10),
	perfdet_accleer boolean DEFAULT false NOT NULL,
	perfdet_accagregar boolean DEFAULT false NOT NULL,
	perfdet_accactualizar boolean DEFAULT false NOT NULL,
	perfdet_acceliminar boolean DEFAULT false NOT NULL,
	perfdet_accimprimir boolean DEFAULT false NOT NULL,
	perfil_id integer,
	menu_id integer NOT NULL,
	activo boolean DEFAULT true NOT NULL,
	usuario character varying(15) NOT NULL,
	fecha_creacion timestamp without time zone NOT NULL,
	usuario_mod character varying(15),
	fecha_modificacion timestamp without time zone
);


ALTER TABLE public.tb_sys_perfil_detalle OWNER TO atluser;

--
-- TOC entry 177 (class 1259 OID 58751)
-- Name: tb_sys_perfil_detalle_perfdet_id_seq; Type: SEQUENCE; Schema: public; Owner: atluser
--

CREATE SEQUENCE tb_sys_perfil_detalle_perfdet_id_seq
START WITH 1
INCREMENT BY 1
NO MINVALUE
NO MAXVALUE
CACHE 1;


ALTER TABLE public.tb_sys_perfil_detalle_perfdet_id_seq OWNER TO atluser;

--
-- TOC entry 2296 (class 0 OID 0)
-- Dependencies: 177
-- Name: tb_sys_perfil_detalle_perfdet_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: atluser
--

ALTER SEQUENCE tb_sys_perfil_detalle_perfdet_id_seq OWNED BY tb_sys_perfil_detalle.perfdet_id;


--
-- TOC entry 178 (class 1259 OID 58753)
-- Name: tb_sys_perfil_id_seq; Type: SEQUENCE; Schema: public; Owner: atluser
--

CREATE SEQUENCE tb_sys_perfil_id_seq
START WITH 1
INCREMENT BY 1
NO MINVALUE
NO MAXVALUE
CACHE 1;


ALTER TABLE public.tb_sys_perfil_id_seq OWNER TO atluser;

--
-- TOC entry 2297 (class 0 OID 0)
-- Dependencies: 178
-- Name: tb_sys_perfil_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: atluser
--

ALTER SEQUENCE tb_sys_perfil_id_seq OWNED BY tb_sys_perfil.perfil_id;


--
-- TOC entry 179 (class 1259 OID 58755)
-- Name: tb_sys_sistemas; Type: TABLE; Schema: public; Owner: atluser; Tablespace:
--

CREATE TABLE tb_sys_sistemas (
	sys_systemcode character varying(10) NOT NULL,
	sistema_descripcion character varying(100) NOT NULL,
	activo boolean DEFAULT true NOT NULL,
	usuario character varying(15) NOT NULL,
	fecha_creacion timestamp without time zone NOT NULL,
	usuario_mod character varying(15),
	fecha_modificacion timestamp without time zone
);


ALTER TABLE public.tb_sys_sistemas OWNER TO atluser;

--
-- TOC entry 180 (class 1259 OID 58759)
-- Name: tb_sys_usuario_perfiles; Type: TABLE; Schema: public; Owner: atluser; Tablespace:
--

CREATE TABLE tb_sys_usuario_perfiles (
	usuario_perfil_id integer NOT NULL,
	perfil_id integer NOT NULL,
	usuarios_id integer NOT NULL,
	activo boolean DEFAULT true NOT NULL,
	usuario character varying(15) NOT NULL,
	fecha_creacion timestamp without time zone NOT NULL,
	usuario_mod character varying(15),
	fecha_modificacion timestamp without time zone
);


ALTER TABLE public.tb_sys_usuario_perfiles OWNER TO atluser;

--
-- TOC entry 181 (class 1259 OID 58763)
-- Name: tb_sys_usuario_perfiles_usuario_perfil_id_seq; Type: SEQUENCE; Schema: public; Owner: atluser
--

CREATE SEQUENCE tb_sys_usuario_perfiles_usuario_perfil_id_seq
START WITH 1
INCREMENT BY 1
NO MINVALUE
NO MAXVALUE
CACHE 1;


ALTER TABLE public.tb_sys_usuario_perfiles_usuario_perfil_id_seq OWNER TO atluser;

--
-- TOC entry 2298 (class 0 OID 0)
-- Dependencies: 181
-- Name: tb_sys_usuario_perfiles_usuario_perfil_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: atluser
--

ALTER SEQUENCE tb_sys_usuario_perfiles_usuario_perfil_id_seq OWNED BY tb_sys_usuario_perfiles.usuario_perfil_id;


--
-- TOC entry 191 (class 1259 OID 75910)
-- Name: tb_tcostos; Type: TABLE; Schema: public; Owner: clabsuser; Tablespace:
--

CREATE TABLE tb_tcostos (
	tcostos_codigo character varying(5) NOT NULL,
	tcostos_descripcion character varying(60) NOT NULL,
	tcostos_protected boolean DEFAULT false NOT NULL,
	activo boolean DEFAULT true NOT NULL,
	usuario character varying(15) NOT NULL,
	fecha_creacion timestamp without time zone NOT NULL,
	usuario_mod character varying(15),
	fecha_modificacion timestamp without time zone,
	CONSTRAINT chk_tcostos_field_len CHECK (((length(rtrim((tcostos_codigo)::text)) > 0) AND (length(rtrim((tcostos_descripcion)::text)) > 0)))
);


ALTER TABLE public.tb_tcostos OWNER TO clabsuser;

--
-- TOC entry 190 (class 1259 OID 75898)
-- Name: tb_tinsumo; Type: TABLE; Schema: public; Owner: clabsuser; Tablespace:
--

CREATE TABLE tb_tinsumo (
	tinsumo_codigo character varying(15) NOT NULL,
	tinsumo_descripcion character varying(60) NOT NULL,
	tinsumo_protected boolean DEFAULT false NOT NULL,
	activo boolean DEFAULT true NOT NULL,
	usuario character varying(15) NOT NULL,
	fecha_creacion timestamp without time zone NOT NULL,
	usuario_mod character varying(15),
	fecha_modificacion timestamp without time zone,
	CONSTRAINT chk_tinsumo_field_len CHECK (((length(rtrim((tinsumo_codigo)::text)) > 0) AND (length(rtrim((tinsumo_descripcion)::text)) > 0)))
);


ALTER TABLE public.tb_tinsumo OWNER TO clabsuser;

--
-- TOC entry 189 (class 1259 OID 75877)
-- Name: tb_tipo_cambio; Type: TABLE; Schema: public; Owner: clabsuser; Tablespace:
--

CREATE TABLE tb_tipo_cambio (
	tipo_cambio_id integer NOT NULL,
	moneda_codigo_origen character varying(8) NOT NULL,
	moneda_codigo_destino character varying(8) NOT NULL,
	tipo_cambio_fecha_desde date NOT NULL,
	tipo_cambio_fecha_hasta date NOT NULL,
	tipo_cambio_tasa_compra numeric(8,4) NOT NULL,
	tipo_cambio_tasa_venta numeric(8,4) NOT NULL,
	activo boolean DEFAULT true NOT NULL,
	usuario character varying(15) NOT NULL,
	fecha_creacion timestamp without time zone NOT NULL,
	usuario_mod character varying(15),
	fecha_modificacion timestamp without time zone,
	CONSTRAINT ckk_tipo_cambio_tasa_compra CHECK ((tipo_cambio_tasa_compra > 0.00)),
	CONSTRAINT ckk_tipo_cambio_tasa_venta CHECK ((tipo_cambio_tasa_venta > 0.00))
);


ALTER TABLE public.tb_tipo_cambio OWNER TO clabsuser;

--
-- TOC entry 188 (class 1259 OID 75875)
-- Name: tb_tipo_cambio_tipo_cambio_id_seq; Type: SEQUENCE; Schema: public; Owner: clabsuser
--

CREATE SEQUENCE tb_tipo_cambio_tipo_cambio_id_seq
START WITH 1
INCREMENT BY 1
NO MINVALUE
NO MAXVALUE
CACHE 1;


ALTER TABLE public.tb_tipo_cambio_tipo_cambio_id_seq OWNER TO clabsuser;

--
-- TOC entry 2299 (class 0 OID 0)
-- Dependencies: 188
-- Name: tb_tipo_cambio_tipo_cambio_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: clabsuser
--

ALTER SEQUENCE tb_tipo_cambio_tipo_cambio_id_seq OWNED BY tb_tipo_cambio.tipo_cambio_id;


--
-- TOC entry 184 (class 1259 OID 59224)
-- Name: tb_unidad_medida; Type: TABLE; Schema: public; Owner: clabsuser; Tablespace:
--

CREATE TABLE tb_unidad_medida (
	unidad_medida_codigo character varying(8) NOT NULL,
	unidad_medida_siglas character varying(6) NOT NULL,
	unidad_medida_descripcion character varying(80) NOT NULL,
	unidad_medida_tipo character(1) NOT NULL,
	unidad_medida_protected boolean DEFAULT false NOT NULL,
	activo boolean DEFAULT true NOT NULL,
	usuario character varying(15) NOT NULL,
	fecha_creacion timestamp without time zone NOT NULL,
	usuario_mod character varying(15),
	fecha_modificacion timestamp without time zone,
	CONSTRAINT chk_unidad_medida_field_len CHECK ((((length(rtrim((unidad_medida_codigo)::text)) > 0) AND (length(rtrim((unidad_medida_siglas)::text)) > 0)) AND (length(rtrim((unidad_medida_descripcion)::text)) > 0))),
	CONSTRAINT chk_unidad_medida_tipo CHECK ((unidad_medida_tipo = ANY (ARRAY['P'::bpchar, 'V'::bpchar, 'L'::bpchar])))
);


ALTER TABLE public.tb_unidad_medida OWNER TO clabsuser;

--
-- TOC entry 187 (class 1259 OID 59377)
-- Name: tb_unidad_medida_conversion; Type: TABLE; Schema: public; Owner: clabsuser; Tablespace:
--

CREATE TABLE tb_unidad_medida_conversion (
	unidad_medida_conversion_id integer NOT NULL,
	unidad_medida_origen character varying(8) NOT NULL,
	unidad_medida_destino character varying(8) NOT NULL,
	unidad_medida_conversion_factor numeric(12,5) NOT NULL,
	activo boolean DEFAULT true NOT NULL,
	usuario character varying(15) NOT NULL,
	fecha_creacion timestamp without time zone NOT NULL,
	usuario_mod character varying(15),
	fecha_modificacion timestamp without time zone,
	CONSTRAINT chk_unidad_medida_conversion_factor CHECK ((unidad_medida_conversion_factor > 0.00))
);


ALTER TABLE public.tb_unidad_medida_conversion OWNER TO clabsuser;

--
-- TOC entry 186 (class 1259 OID 59375)
-- Name: tb_unidad_medida_conversion_unidad_medida_conversion_id_seq; Type: SEQUENCE; Schema: public; Owner: clabsuser
--

CREATE SEQUENCE tb_unidad_medida_conversion_unidad_medida_conversion_id_seq
START WITH 1
INCREMENT BY 1
NO MINVALUE
NO MAXVALUE
CACHE 1;


ALTER TABLE public.tb_unidad_medida_conversion_unidad_medida_conversion_id_seq OWNER TO clabsuser;

--
-- TOC entry 2300 (class 0 OID 0)
-- Dependencies: 186
-- Name: tb_unidad_medida_conversion_unidad_medida_conversion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: clabsuser
--

ALTER SEQUENCE tb_unidad_medida_conversion_unidad_medida_conversion_id_seq OWNED BY tb_unidad_medida_conversion.unidad_medida_conversion_id;


--
-- TOC entry 182 (class 1259 OID 58771)
-- Name: tb_usuarios; Type: TABLE; Schema: public; Owner: atluser; Tablespace:
--

CREATE TABLE tb_usuarios (
	usuarios_id integer NOT NULL,
	usuarios_code character varying(15) NOT NULL,
	usuarios_password character varying(20) NOT NULL,
	usuarios_nombre_completo character varying(250) NOT NULL,
	usuarios_admin boolean DEFAULT false NOT NULL,
	activo boolean DEFAULT true NOT NULL,
	usuario character varying(15) NOT NULL,
	fecha_creacion timestamp without time zone NOT NULL,
	usuario_mod character varying(15),
	fecha_modificacion time without time zone
);


ALTER TABLE public.tb_usuarios OWNER TO atluser;

--
-- TOC entry 183 (class 1259 OID 58776)
-- Name: tb_usuarios_usuarios_id_seq; Type: SEQUENCE; Schema: public; Owner: atluser
--

CREATE SEQUENCE tb_usuarios_usuarios_id_seq
START WITH 1
INCREMENT BY 1
NO MINVALUE
NO MAXVALUE
CACHE 1;


ALTER TABLE public.tb_usuarios_usuarios_id_seq OWNER TO atluser;

--
-- TOC entry 2301 (class 0 OID 0)
-- Dependencies: 183
-- Name: tb_usuarios_usuarios_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: atluser
--

ALTER SEQUENCE tb_usuarios_usuarios_id_seq OWNED BY tb_usuarios.usuarios_id;


--
-- TOC entry 196 (class 1259 OID 76095)
-- Name: v_costo; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

CREATE TABLE v_costo (
	costo numeric
);


ALTER TABLE public.v_costo OWNER TO postgres;

--
-- TOC entry 2009 (class 2604 OID 58792)
-- Name: entidad_id; Type: DEFAULT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_entidad ALTER COLUMN entidad_id SET DEFAULT nextval('tb_entidad_entidad_id_seq'::regclass);


--
-- TOC entry 2048 (class 2604 OID 76000)
-- Name: insumo_id; Type: DEFAULT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY tb_insumo ALTER COLUMN insumo_id SET DEFAULT nextval('tb_insumo_insumo_id_seq'::regclass);


--
-- TOC entry 2055 (class 2604 OID 76040)
-- Name: producto_detalle_id; Type: DEFAULT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY tb_producto_detalle ALTER COLUMN producto_detalle_id SET DEFAULT nextval('tb_producto_detalle_producto_detalle_id_seq'::regclass);


--
-- TOC entry 2012 (class 2604 OID 58799)
-- Name: menu_id; Type: DEFAULT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_sys_menu ALTER COLUMN menu_id SET DEFAULT nextval('tb_sys_menu_menu_id_seq'::regclass);


--
-- TOC entry 2014 (class 2604 OID 58800)
-- Name: perfil_id; Type: DEFAULT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_sys_perfil ALTER COLUMN perfil_id SET DEFAULT nextval('tb_sys_perfil_id_seq'::regclass);


--
-- TOC entry 2021 (class 2604 OID 58801)
-- Name: perfdet_id; Type: DEFAULT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_sys_perfil_detalle ALTER COLUMN perfdet_id SET DEFAULT nextval('tb_sys_perfil_detalle_perfdet_id_seq'::regclass);


--
-- TOC entry 2024 (class 2604 OID 58802)
-- Name: usuario_perfil_id; Type: DEFAULT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_sys_usuario_perfiles ALTER COLUMN usuario_perfil_id SET DEFAULT nextval('tb_sys_usuario_perfiles_usuario_perfil_id_seq'::regclass);


--
-- TOC entry 2038 (class 2604 OID 75880)
-- Name: tipo_cambio_id; Type: DEFAULT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY tb_tipo_cambio ALTER COLUMN tipo_cambio_id SET DEFAULT nextval('tb_tipo_cambio_tipo_cambio_id_seq'::regclass);


--
-- TOC entry 2035 (class 2604 OID 59380)
-- Name: unidad_medida_conversion_id; Type: DEFAULT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY tb_unidad_medida_conversion ALTER COLUMN unidad_medida_conversion_id SET DEFAULT nextval('tb_unidad_medida_conversion_unidad_medida_conversion_id_seq'::regclass);


--
-- TOC entry 2027 (class 2604 OID 58803)
-- Name: usuarios_id; Type: DEFAULT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_usuarios ALTER COLUMN usuarios_id SET DEFAULT nextval('tb_usuarios_usuarios_id_seq'::regclass);


--
-- TOC entry 2257 (class 0 OID 58623)
-- Dependencies: 171
-- Data for Name: tb_entidad; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY tb_entidad (entidad_id, entidad_razon_social, entidad_ruc, entidad_direccion, entidad_telefonos, entidad_fax, entidad_correo, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
3	Laboratoris Martin Hernandez	10088090867	La casa de MARTIN - Miraflores	993786532,993786533		mhernandez@hotmai.com	t	TESTUSER	2016-07-09 00:08:18.69851	TESTUSER	2016-07-09 14:39:22.946464
\.


--
-- TOC entry 2302 (class 0 OID 0)
-- Dependencies: 172
-- Name: tb_entidad_entidad_id_seq; Type: SEQUENCE SET; Schema: public; Owner: atluser
--

SELECT pg_catalog.setval('tb_entidad_entidad_id_seq', 3, true);


--
-- TOC entry 2279 (class 0 OID 75997)
-- Dependencies: 193
-- Data for Name: tb_insumo; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY tb_insumo (insumo_id, insumo_tipo, insumo_codigo, insumo_descripcion, tinsumo_codigo, tcostos_codigo, unidad_medida_codigo_ingreso, unidad_medida_codigo_costo, insumo_merma, insumo_costo, moneda_codigo_costo, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
25	PR	YYYYYYY	YYYYYY	NING	NING	NING	LITROS	2.0000	\N	USD	t	TESTUSER	2016-08-24 04:19:10.261562	TESTUSER	2016-08-29 00:31:42.417255
26	PR	DDDD	ddddeee	NING	NING	NING	GALON	3.0000	\N	USD	t	TESTUSER	2016-08-28 23:58:35.272671	TESTUSER	2016-08-29 00:46:17.159564
23	IN	PRODUNO	Producto 1	SOLUCION	DIRC	GALON	GALON	0.2000	2.0000	EURO	t	TESTUSER	2016-08-21 16:01:43.197581	TESTUSER	2016-08-29 01:20:44.896992
22	PR	XXXXXX	XXXXXXY	NING	NING	NING	GALON	2.0000	\N	USD	t	TESTUSER	2016-08-21 15:00:50.942708	TESTUSER	2016-08-26 15:20:24.049768
24	IN	ALCOHOL	Alcohol	SOLUCION	INDR	GALON	LITROS	2.0000	1.2000	PEN	t	TESTUSER	2016-08-21 16:10:34.428604	\N	\N
\.


--
-- TOC entry 2303 (class 0 OID 0)
-- Dependencies: 192
-- Name: tb_insumo_insumo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: clabsuser
--

SELECT pg_catalog.setval('tb_insumo_insumo_id_seq', 26, true);


--
-- TOC entry 2271 (class 0 OID 59242)
-- Dependencies: 185
-- Data for Name: tb_moneda; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY tb_moneda (moneda_codigo, moneda_simbolo, moneda_descripcion, moneda_protected, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
PEN	S/.	Nuevos Soles	f	t	TESTUSER	2016-07-10 18:16:12.815048	\N	\N
USD	$	Dolares	f	t	TESTUSER	2016-07-10 18:20:47.857316	TESTUSER	2016-07-10 18:22:59.862666
JPY	Yen	Yen Japones	f	t	TESTUSER	2016-07-14 00:40:58.095941	\N	\N
EURO	â¬	Euro	f	t	TESTUSER	2016-08-21 23:36:32.726364	TESTUSER	2016-08-21 23:36:46.781843
\.


--
-- TOC entry 2281 (class 0 OID 76037)
-- Dependencies: 195
-- Data for Name: tb_producto_detalle; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY tb_producto_detalle (producto_detalle_id, insumo_id_origen, insumo_id, unidad_medida_codigo, producto_detalle_cantidad, producto_detalle_merma, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
76	22	23	LITROS	4.0000	0.2000	t	TESTUSER	2016-08-21 16:06:47.975614	TESTUSER	2016-08-26 04:31:29.695819
79	22	24	LITROS	3.0000	2.0000	t	TESTUSER	2016-08-24 01:15:48.772564	TESTUSER	2016-08-27 01:08:56.983857
83	26	24	LITROS	1.0000	2.0000	t	TESTUSER	2016-08-29 00:03:22.248185	TESTUSER	2016-08-29 00:24:31.440659
80	25	22	GALON	1.0000	2.0000	t	TESTUSER	2016-08-24 17:50:01.012066	TESTUSER	2016-08-29 00:47:09.464986
82	25	24	LITROS	1.0000	2.0000	t	TESTUSER	2016-08-24 22:46:35.611217	TESTUSER	2016-08-30 00:17:35.457051
\.


--
-- TOC entry 2304 (class 0 OID 0)
-- Dependencies: 194
-- Name: tb_producto_detalle_producto_detalle_id_seq; Type: SEQUENCE SET; Schema: public; Owner: clabsuser
--

SELECT pg_catalog.setval('tb_producto_detalle_producto_detalle_id_seq', 83, true);


--
-- TOC entry 2259 (class 0 OID 58731)
-- Dependencies: 173
-- Data for Name: tb_sys_menu; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY tb_sys_menu (sys_systemcode, menu_id, menu_codigo, menu_descripcion, menu_accesstype, menu_parent_id, menu_orden, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
labcostos	60	smn_tipocambio	Tipo De Cambio	A         	11	165	t	ADMIN	2016-07-15 03:24:37.087685	\N	\N
labcostos	61	smn_tcostos	Tipo De Costos	A         	11	155	t	ADMIN	2016-07-19 03:17:27.948919	\N	\N
labcostos	62	smn_producto	Producto	A         	11	165	t	ADMIN	2016-08-06 15:02:59.319601	\N	\N
labcostos	4	mn_menu	Menu	A         	\N	0	t	ADMIN	2014-01-14 17:51:30.074514	\N	\N
labcostos	11	mn_generales	Datos Generales	A         	4	10	t	ADMIN	2014-01-14 17:53:10.656624	\N	\N
labcostos	12	smn_entidad	Entidad	A         	11	100	t	ADMIN	2014-01-14 17:54:38.907518	\N	\N
labcostos	15	smn_unidadmedida	Unidades De Medida	A         	11	130	t	ADMIN	2014-01-15 23:45:38.848008	\N	\N
labcostos	58	smn_perfiles	Perfiles	A         	56	110	t	ADMIN	2015-10-04 15:01:00.279735	\N	\N
labcostos	57	smn_usuarios	Usuarios	A         	56	100	t	ADMIN	2015-10-04 15:00:26.551082	\N	\N
labcostos	56	mn_admin	Administrador	A         	4	5	t	ADMIN	2015-10-04 14:59:17.331335	\N	\N
labcostos	16	smn_monedas	Monedas	A         	11	140	t	ADMIN	2014-01-16 04:57:32.87322	\N	\N
labcostos	17	smn_tinsumo	Tipo De Insumos	A         	11	150	t	ADMIN	2014-01-17 15:35:42.866956	\N	\N
labcostos	21	smn_umconversion	Conversion de Unidades de Medida	A         	11	135	t	ADMIN	2014-01-17 15:36:35.894364	\N	\N
labcostos	59	smn_insumo	Insumos	A         	11	160	t	ADMIN	2014-01-17 15:35:42.866956	\N	\N
\.


--
-- TOC entry 2305 (class 0 OID 0)
-- Dependencies: 174
-- Name: tb_sys_menu_menu_id_seq; Type: SEQUENCE SET; Schema: public; Owner: atluser
--

SELECT pg_catalog.setval('tb_sys_menu_menu_id_seq', 62, true);


--
-- TOC entry 2261 (class 0 OID 58738)
-- Dependencies: 175
-- Data for Name: tb_sys_perfil; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY tb_sys_perfil (perfil_id, sys_systemcode, perfil_codigo, perfil_descripcion, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
4	labcostos	ADMIN	Perfil Administrador	t	TESTUSER	2015-10-04 21:34:18.153993	postgres	2016-07-08 23:54:58.365768
5	labcostos	POWERUSER	Power User	t	TESTUSER	2015-10-04 21:41:49.702143	TESTUSER	2016-07-08 23:55:02.519651
\.


--
-- TOC entry 2262 (class 0 OID 58742)
-- Dependencies: 176
-- Data for Name: tb_sys_perfil_detalle; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY tb_sys_perfil_detalle (perfdet_id, perfdet_accessdef, perfdet_accleer, perfdet_accagregar, perfdet_accactualizar, perfdet_acceliminar, perfdet_accimprimir, perfil_id, menu_id, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
77	\N	t	t	t	t	t	5	4	t	TESTUSER	2015-10-04 21:41:49.702143	TESTUSER	2015-10-04 21:42:02.265457
79	\N	t	t	t	t	t	5	11	t	TESTUSER	2015-10-04 21:41:49.702143	TESTUSER	2015-10-04 21:42:02.265457
80	\N	t	t	t	t	t	5	25	t	TESTUSER	2015-10-04 21:41:49.702143	TESTUSER	2015-10-04 21:42:02.265457
81	\N	t	t	t	t	t	5	23	t	TESTUSER	2015-10-04 21:41:49.702143	TESTUSER	2015-10-04 21:42:02.265457
82	\N	t	t	t	t	t	5	29	t	TESTUSER	2015-10-04 21:41:49.702143	TESTUSER	2015-10-04 21:42:02.265457
83	\N	t	t	t	t	t	5	31	t	TESTUSER	2015-10-04 21:41:49.702143	TESTUSER	2015-10-04 21:42:02.265457
84	\N	t	t	t	t	t	5	35	t	TESTUSER	2015-10-04 21:41:49.702143	TESTUSER	2015-10-04 21:42:02.265457
85	\N	t	t	t	t	t	5	12	t	TESTUSER	2015-10-04 21:41:49.702143	TESTUSER	2015-10-04 21:42:02.265457
39	\N	t	t	t	t	t	4	4	t	TESTUSER	2015-10-04 21:34:18.153993	TESTUSER	2015-10-04 21:41:08.030972
40	\N	t	t	t	t	t	4	56	t	TESTUSER	2015-10-04 21:34:18.153993	TESTUSER	2015-10-04 21:41:08.030972
41	\N	t	t	t	t	t	4	11	t	TESTUSER	2015-10-04 21:34:18.153993	TESTUSER	2015-10-04 21:41:08.030972
42	\N	t	t	t	t	t	4	25	t	TESTUSER	2015-10-04 21:34:18.153993	TESTUSER	2016-01-26 16:27:54.909082
43	\N	t	t	t	t	t	4	23	t	TESTUSER	2015-10-04 21:34:18.153993	TESTUSER	2015-10-04 21:41:08.030972
44	\N	t	t	t	t	t	4	29	t	TESTUSER	2015-10-04 21:34:18.153993	TESTUSER	2015-10-04 21:41:08.030972
45	\N	t	t	t	t	t	4	31	t	TESTUSER	2015-10-04 21:34:18.153993	TESTUSER	2015-10-04 21:41:08.030972
46	\N	t	t	t	t	t	4	35	t	TESTUSER	2015-10-04 21:34:18.153993	TESTUSER	2015-10-04 21:41:08.030972
47	\N	t	t	t	t	t	4	12	t	TESTUSER	2015-10-04 21:34:18.153993	TESTUSER	2015-10-04 21:41:08.030972
48	\N	t	t	t	t	t	4	24	t	TESTUSER	2015-10-04 21:34:18.153993	TESTUSER	2015-10-04 21:41:08.030972
49	\N	t	t	t	t	t	4	17	t	TESTUSER	2015-10-04 21:34:18.153993	TESTUSER	2016-01-26 16:27:54.909082
50	\N	t	t	t	t	t	4	30	t	TESTUSER	2015-10-04 21:34:18.153993	TESTUSER	2015-10-04 21:41:08.030972
51	\N	t	t	t	t	t	4	32	t	TESTUSER	2015-10-04 21:34:18.153993	TESTUSER	2015-10-04 21:41:08.030972
52	\N	t	t	t	t	t	4	45	t	TESTUSER	2015-10-04 21:34:18.153993	TESTUSER	2015-10-04 21:41:08.030972
53	\N	t	t	t	t	t	4	46	t	TESTUSER	2015-10-04 21:34:18.153993	TESTUSER	2015-10-04 21:41:08.030972
54	\N	t	t	t	t	t	4	55	t	TESTUSER	2015-10-04 21:34:18.153993	TESTUSER	2015-10-04 21:41:08.030972
55	\N	t	t	t	t	t	4	57	t	TESTUSER	2015-10-04 21:34:18.153993	TESTUSER	2015-10-04 21:41:08.030972
56	\N	t	t	t	t	t	4	43	t	TESTUSER	2015-10-04 21:34:18.153993	TESTUSER	2015-10-04 21:41:08.030972
57	\N	t	t	t	t	t	4	44	t	TESTUSER	2015-10-04 21:34:18.153993	TESTUSER	2015-10-04 21:41:08.030972
59	\N	t	t	t	t	t	4	36	t	TESTUSER	2015-10-04 21:34:18.153993	TESTUSER	2015-10-04 21:41:08.030972
60	\N	t	t	t	t	t	4	38	t	TESTUSER	2015-10-04 21:34:18.153993	TESTUSER	2015-10-04 21:41:08.030972
61	\N	t	t	t	t	t	4	13	t	TESTUSER	2015-10-04 21:34:18.153993	TESTUSER	2015-10-04 21:41:08.030972
62	\N	t	t	t	t	t	4	33	t	TESTUSER	2015-10-04 21:34:18.153993	TESTUSER	2015-10-04 21:41:08.030972
63	\N	t	t	t	t	t	4	58	t	TESTUSER	2015-10-04 21:34:18.153993	TESTUSER	2015-10-04 21:41:08.030972
64	\N	t	t	t	t	t	4	40	t	TESTUSER	2015-10-04 21:34:18.153993	TESTUSER	2015-10-04 21:41:08.030972
65	\N	t	t	t	t	t	4	14	t	TESTUSER	2015-10-04 21:34:18.153993	TESTUSER	2015-10-04 21:41:08.030972
66	\N	t	t	t	t	t	4	37	t	TESTUSER	2015-10-04 21:34:18.153993	TESTUSER	2015-10-04 21:41:08.030972
67	\N	t	t	t	t	t	4	39	t	TESTUSER	2015-10-04 21:34:18.153993	TESTUSER	2015-10-04 21:41:08.030972
86	\N	t	t	t	t	t	5	24	t	TESTUSER	2015-10-04 21:41:49.702143	TESTUSER	2015-10-04 21:42:02.265457
87	\N	t	t	t	t	t	5	17	t	TESTUSER	2015-10-04 21:41:49.702143	TESTUSER	2015-10-04 21:42:02.265457
88	\N	t	t	t	t	t	5	30	t	TESTUSER	2015-10-04 21:41:49.702143	TESTUSER	2015-10-04 21:42:02.265457
89	\N	t	t	t	t	t	5	32	t	TESTUSER	2015-10-04 21:41:49.702143	TESTUSER	2015-10-04 21:42:02.265457
90	\N	t	t	t	t	t	5	45	t	TESTUSER	2015-10-04 21:41:49.702143	TESTUSER	2015-10-04 21:42:02.265457
91	\N	t	t	t	t	t	5	46	t	TESTUSER	2015-10-04 21:41:49.702143	TESTUSER	2015-10-04 21:42:02.265457
92	\N	t	t	t	t	t	5	55	t	TESTUSER	2015-10-04 21:41:49.702143	TESTUSER	2015-10-04 21:42:02.265457
94	\N	t	t	t	t	t	5	43	t	TESTUSER	2015-10-04 21:41:49.702143	TESTUSER	2015-10-04 21:42:02.265457
95	\N	t	t	t	t	t	5	44	t	TESTUSER	2015-10-04 21:41:49.702143	TESTUSER	2015-10-04 21:42:02.265457
96	\N	t	t	t	t	t	5	21	t	TESTUSER	2015-10-04 21:41:49.702143	TESTUSER	2015-10-04 21:42:02.265457
97	\N	t	t	t	t	t	5	36	t	TESTUSER	2015-10-04 21:41:49.702143	TESTUSER	2015-10-04 21:42:02.265457
98	\N	t	t	t	t	t	5	38	t	TESTUSER	2015-10-04 21:41:49.702143	TESTUSER	2015-10-04 21:42:02.265457
99	\N	t	t	t	t	t	5	13	t	TESTUSER	2015-10-04 21:41:49.702143	TESTUSER	2015-10-04 21:42:02.265457
100	\N	t	t	t	t	t	5	33	t	TESTUSER	2015-10-04 21:41:49.702143	TESTUSER	2015-10-04 21:42:02.265457
102	\N	t	t	t	t	t	5	40	t	TESTUSER	2015-10-04 21:41:49.702143	TESTUSER	2015-10-04 21:42:02.265457
103	\N	t	t	t	t	t	5	14	t	TESTUSER	2015-10-04 21:41:49.702143	TESTUSER	2015-10-04 21:42:02.265457
104	\N	t	t	t	t	t	5	37	t	TESTUSER	2015-10-04 21:41:49.702143	TESTUSER	2015-10-04 21:42:02.265457
78	\N	f	f	f	f	f	5	56	t	TESTUSER	2015-10-04 21:41:49.702143	TESTUSER	2016-01-25 16:53:28.983914
93	\N	f	f	f	f	f	5	57	t	TESTUSER	2015-10-04 21:41:49.702143	TESTUSER	2016-01-25 16:53:28.983914
101	\N	f	f	f	f	f	5	58	t	TESTUSER	2015-10-04 21:41:49.702143	TESTUSER	2016-01-25 16:53:28.983914
68	\N	t	t	t	t	t	4	42	t	TESTUSER	2015-10-04 21:34:18.153993	TESTUSER	2015-10-04 21:41:08.030972
69	\N	t	t	t	t	t	4	15	t	TESTUSER	2015-10-04 21:34:18.153993	TESTUSER	2015-10-04 21:41:08.030972
70	\N	t	t	t	t	t	4	16	t	TESTUSER	2015-10-04 21:34:18.153993	TESTUSER	2015-10-04 21:41:08.030972
71	\N	t	t	t	t	t	4	34	t	TESTUSER	2015-10-04 21:34:18.153993	TESTUSER	2015-10-04 21:41:08.030972
72	\N	t	t	t	t	t	4	48	t	TESTUSER	2015-10-04 21:34:18.153993	TESTUSER	2015-10-04 21:41:08.030972
73	\N	t	t	t	t	t	4	49	t	TESTUSER	2015-10-04 21:34:18.153993	TESTUSER	2015-10-04 21:41:08.030972
74	\N	t	t	t	t	t	4	27	t	TESTUSER	2015-10-04 21:34:18.153993	TESTUSER	2015-10-04 21:41:08.030972
75	\N	t	t	t	t	t	4	51	t	TESTUSER	2015-10-04 21:34:18.153993	TESTUSER	2015-10-04 21:41:08.030972
76	\N	t	t	t	t	t	4	54	t	TESTUSER	2015-10-04 21:34:18.153993	TESTUSER	2015-10-04 21:41:08.030972
105	\N	t	t	t	t	t	5	39	t	TESTUSER	2015-10-04 21:41:49.702143	TESTUSER	2015-10-04 21:42:02.265457
106	\N	t	t	t	t	t	5	42	t	TESTUSER	2015-10-04 21:41:49.702143	TESTUSER	2015-10-04 21:42:02.265457
107	\N	t	t	t	t	t	5	15	t	TESTUSER	2015-10-04 21:41:49.702143	TESTUSER	2015-10-04 21:42:02.265457
108	\N	t	t	t	t	t	5	16	t	TESTUSER	2015-10-04 21:41:49.702143	TESTUSER	2015-10-04 21:42:02.265457
109	\N	t	t	t	t	t	5	34	t	TESTUSER	2015-10-04 21:41:49.702143	TESTUSER	2015-10-04 21:42:02.265457
110	\N	t	t	t	t	t	5	48	t	TESTUSER	2015-10-04 21:41:49.702143	TESTUSER	2015-10-04 21:42:02.265457
111	\N	t	t	t	t	t	5	49	t	TESTUSER	2015-10-04 21:41:49.702143	TESTUSER	2015-10-04 21:42:02.265457
112	\N	t	t	t	t	t	5	27	t	TESTUSER	2015-10-04 21:41:49.702143	TESTUSER	2015-10-04 21:42:02.265457
113	\N	t	t	t	t	t	5	51	t	TESTUSER	2015-10-04 21:41:49.702143	TESTUSER	2015-10-04 21:42:02.265457
114	\N	t	t	t	t	t	5	54	t	TESTUSER	2015-10-04 21:41:49.702143	TESTUSER	2015-10-04 21:42:02.265457
58	\N	t	t	t	t	t	4	21	t	TESTUSER	2015-10-04 21:34:18.153993	TESTUSER	2016-01-26 16:27:54.909082
\.


--
-- TOC entry 2306 (class 0 OID 0)
-- Dependencies: 177
-- Name: tb_sys_perfil_detalle_perfdet_id_seq; Type: SEQUENCE SET; Schema: public; Owner: atluser
--

SELECT pg_catalog.setval('tb_sys_perfil_detalle_perfdet_id_seq', 646, true);


--
-- TOC entry 2307 (class 0 OID 0)
-- Dependencies: 178
-- Name: tb_sys_perfil_id_seq; Type: SEQUENCE SET; Schema: public; Owner: atluser
--

SELECT pg_catalog.setval('tb_sys_perfil_id_seq', 19, true);


--
-- TOC entry 2265 (class 0 OID 58755)
-- Dependencies: 179
-- Data for Name: tb_sys_sistemas; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY tb_sys_sistemas (sys_systemcode, sistema_descripcion, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
labcostos	Sistema De Costos Laboratorios	t	ADMIN	2016-07-08 23:47:11.960862	\N	\N
\.


--
-- TOC entry 2266 (class 0 OID 58759)
-- Dependencies: 180
-- Data for Name: tb_sys_usuario_perfiles; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY tb_sys_usuario_perfiles (usuario_perfil_id, perfil_id, usuarios_id, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
1	4	2	t	TESTUSER	2015-10-05 00:03:41.563698	TESTUSER	2016-01-26 16:22:00.235152
3	4	1	t	TESTUSER	2016-01-26 13:17:46.032845	TESTUSER	2016-02-01 15:09:50.479604
\.


--
-- TOC entry 2308 (class 0 OID 0)
-- Dependencies: 181
-- Name: tb_sys_usuario_perfiles_usuario_perfil_id_seq; Type: SEQUENCE SET; Schema: public; Owner: atluser
--

SELECT pg_catalog.setval('tb_sys_usuario_perfiles_usuario_perfil_id_seq', 6, true);


--
-- TOC entry 2277 (class 0 OID 75910)
-- Dependencies: 191
-- Data for Name: tb_tcostos; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY tb_tcostos (tcostos_codigo, tcostos_descripcion, tcostos_protected, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
NING	Ninguno	t	t	TESTUSER	2016-08-14 23:59:55.231596	TESTUSER	2016-08-15 00:41:51.103947
DIRC	Directos	f	t	TESTUSER	2016-08-21 15:59:06.197418	\N	\N
INDR	Indirectos	f	t	TESTUSER	2016-08-21 15:59:18.394665	\N	\N
\.


--
-- TOC entry 2276 (class 0 OID 75898)
-- Dependencies: 190
-- Data for Name: tb_tinsumo; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY tb_tinsumo (tinsumo_codigo, tinsumo_descripcion, tinsumo_protected, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
NING	Ninguno	t	t	TESTUSER	2016-08-14 20:56:05.183355	TESTUSER	2016-08-14 22:30:01.597852
MOBRA	Mano de Obra	f	t	TESTUSER	2016-08-20 14:47:22.327818	\N	\N
SOLUCION	Solucion	f	t	TESTUSER	2016-08-21 15:59:38.091692	\N	\N
\.


--
-- TOC entry 2275 (class 0 OID 75877)
-- Dependencies: 189
-- Data for Name: tb_tipo_cambio; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY tb_tipo_cambio (tipo_cambio_id, moneda_codigo_origen, moneda_codigo_destino, tipo_cambio_fecha_desde, tipo_cambio_fecha_hasta, tipo_cambio_tasa_compra, tipo_cambio_tasa_venta, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
1	USD	JPY	2016-08-18	2016-08-19	3.0000	3.5000	t	TESTUSER	2016-08-13 15:41:24.405659	TESTUSER	2016-08-13 15:47:08.433642
2	USD	JPY	2016-08-22	2016-08-22	3.1000	3.2000	t	TESTUSER	2016-08-22 15:35:06.442191	\N	\N
5	PEN	USD	2016-08-22	2016-08-22	3.2400	3.2900	t	TESTUSER	2016-08-24 16:18:47.669771	\N	\N
4	PEN	USD	2016-08-30	2016-08-30	3.2500	3.3000	t	TESTUSER	2016-08-23 14:31:00.466178	TESTUSER	2016-08-30 00:16:53.177232
3	EURO	USD	2016-08-30	2016-08-30	4.0000	4.2000	t	TESTUSER	2016-08-22 15:58:06.566396	TESTUSER	2016-08-30 00:17:00.608724
\.


--
-- TOC entry 2309 (class 0 OID 0)
-- Dependencies: 188
-- Name: tb_tipo_cambio_tipo_cambio_id_seq; Type: SEQUENCE SET; Schema: public; Owner: clabsuser
--

SELECT pg_catalog.setval('tb_tipo_cambio_tipo_cambio_id_seq', 5, true);


--
-- TOC entry 2270 (class 0 OID 59224)
-- Dependencies: 184
-- Data for Name: tb_unidad_medida; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY tb_unidad_medida (unidad_medida_codigo, unidad_medida_siglas, unidad_medida_descripcion, unidad_medida_tipo, unidad_medida_protected, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
KILOS	Kgs.	Kilogramos	P	f	t	TESTUSER	2016-07-09 14:30:43.815942	TESTUSER	2016-07-12 01:24:15.740215
TONELAD	Ton.	Toneladas	P	f	t	TESTUSER	2016-07-11 17:17:40.095483	TESTUSER	2016-07-12 03:24:58.438822
GALON	Gls.	Galones	V	f	t	TESTUSER	2016-07-17 15:07:47.744565	TESTUSER	2016-07-18 04:56:08.667067
NING	Ning	Ninguna	P	t	t	TESTUSER	2016-08-15 02:29:09.264036	postgres	2016-08-15 02:29:30.986832
LITROS	Ltrs.	Litros	V	f	t	TESTUSER	2016-07-09 14:13:29.603714	TESTUSER	2016-08-30 01:34:11.801158
\.


--
-- TOC entry 2273 (class 0 OID 59377)
-- Dependencies: 187
-- Data for Name: tb_unidad_medida_conversion; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY tb_unidad_medida_conversion (unidad_medida_conversion_id, unidad_medida_origen, unidad_medida_destino, unidad_medida_conversion_factor, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
10	TONELAD	KILOS	1000.00000	t	TESTUSER	2016-07-11 17:18:02.132735	\N	\N
60	GALON	LITROS	3.78540	t	TESTUSER	2016-07-18 04:44:20.861417	TESTUSER	2016-08-27 14:47:27.766392
70	LITROS	GALON	0.26420	t	TESTUSER	2016-07-30 00:33:37.114577	TESTUSER	2016-08-27 14:47:33.986013
24	KILOS	TONELAD	0.00100	t	TESTUSER	2016-07-12 15:58:35.930938	TESTUSER	2016-07-16 04:13:48.158402
\.


--
-- TOC entry 2310 (class 0 OID 0)
-- Dependencies: 186
-- Name: tb_unidad_medida_conversion_unidad_medida_conversion_id_seq; Type: SEQUENCE SET; Schema: public; Owner: clabsuser
--

SELECT pg_catalog.setval('tb_unidad_medida_conversion_unidad_medida_conversion_id_seq', 71, true);


--
-- TOC entry 2268 (class 0 OID 58771)
-- Dependencies: 182
-- Data for Name: tb_usuarios; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY tb_usuarios (usuarios_id, usuarios_code, usuarios_password, usuarios_nombre_completo, usuarios_admin, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
1	ADMIN	melivane100	Carlos Arana Reategui	f	t	TESTUSER	2015-10-04 18:18:38.522948	TESTUSER	18:33:24.640328
2	TEST	testx1	Soy el Test User	f	t	TESTUSER	2015-10-04 19:20:13.66406	TESTUSER	01:09:30.537483
\.


--
-- TOC entry 2311 (class 0 OID 0)
-- Dependencies: 183
-- Name: tb_usuarios_usuarios_id_seq; Type: SEQUENCE SET; Schema: public; Owner: atluser
--

SELECT pg_catalog.setval('tb_usuarios_usuarios_id_seq', 14, true);


--
-- TOC entry 2282 (class 0 OID 76095)
-- Dependencies: 196
-- Data for Name: v_costo; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY v_costo (costo) FROM stdin;
5.3535
\.


--
-- TOC entry 2061 (class 2606 OID 59214)
-- Name: pk_entidad; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_entidad
ADD CONSTRAINT pk_entidad PRIMARY KEY (entidad_id);


--
-- TOC entry 2101 (class 2606 OID 76007)
-- Name: pk_insumo; Type: CONSTRAINT; Schema: public; Owner: clabsuser; Tablespace:
--

ALTER TABLE ONLY tb_insumo
ADD CONSTRAINT pk_insumo PRIMARY KEY (insumo_id);


--
-- TOC entry 2065 (class 2606 OID 58841)
-- Name: pk_menu; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_sys_menu
ADD CONSTRAINT pk_menu PRIMARY KEY (menu_id);


--
-- TOC entry 2089 (class 2606 OID 59248)
-- Name: pk_moneda; Type: CONSTRAINT; Schema: public; Owner: clabsuser; Tablespace:
--

ALTER TABLE ONLY tb_moneda
ADD CONSTRAINT pk_moneda PRIMARY KEY (moneda_codigo);


--
-- TOC entry 2076 (class 2606 OID 58845)
-- Name: pk_perfdet_id; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_sys_perfil_detalle
ADD CONSTRAINT pk_perfdet_id PRIMARY KEY (perfdet_id);


--
-- TOC entry 2103 (class 2606 OID 76048)
-- Name: pk_producto_detalle; Type: CONSTRAINT; Schema: public; Owner: clabsuser; Tablespace:
--

ALTER TABLE ONLY tb_producto_detalle
ADD CONSTRAINT pk_producto_detalle PRIMARY KEY (producto_detalle_id);


--
-- TOC entry 2078 (class 2606 OID 58859)
-- Name: pk_sistemas; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_sys_sistemas
ADD CONSTRAINT pk_sistemas PRIMARY KEY (sys_systemcode);


--
-- TOC entry 2070 (class 2606 OID 58861)
-- Name: pk_sys_perfil; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_sys_perfil
ADD CONSTRAINT pk_sys_perfil PRIMARY KEY (perfil_id);


--
-- TOC entry 2099 (class 2606 OID 75917)
-- Name: pk_tcostos; Type: CONSTRAINT; Schema: public; Owner: clabsuser; Tablespace:
--

ALTER TABLE ONLY tb_tcostos
ADD CONSTRAINT pk_tcostos PRIMARY KEY (tcostos_codigo);


--
-- TOC entry 2097 (class 2606 OID 75905)
-- Name: pk_tinsumo; Type: CONSTRAINT; Schema: public; Owner: clabsuser; Tablespace:
--

ALTER TABLE ONLY tb_tinsumo
ADD CONSTRAINT pk_tinsumo PRIMARY KEY (tinsumo_codigo);


--
-- TOC entry 2095 (class 2606 OID 75885)
-- Name: pk_tipo_cambio; Type: CONSTRAINT; Schema: public; Owner: clabsuser; Tablespace:
--

ALTER TABLE ONLY tb_tipo_cambio
ADD CONSTRAINT pk_tipo_cambio PRIMARY KEY (tipo_cambio_id);


--
-- TOC entry 2091 (class 2606 OID 59384)
-- Name: pk_unidad_conversion; Type: CONSTRAINT; Schema: public; Owner: clabsuser; Tablespace:
--

ALTER TABLE ONLY tb_unidad_medida_conversion
ADD CONSTRAINT pk_unidad_conversion PRIMARY KEY (unidad_medida_conversion_id);


--
-- TOC entry 2087 (class 2606 OID 59231)
-- Name: pk_unidad_medida; Type: CONSTRAINT; Schema: public; Owner: clabsuser; Tablespace:
--

ALTER TABLE ONLY tb_unidad_medida
ADD CONSTRAINT pk_unidad_medida PRIMARY KEY (unidad_medida_codigo);


--
-- TOC entry 2082 (class 2606 OID 58865)
-- Name: pk_usuarioperfiles; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_sys_usuario_perfiles
ADD CONSTRAINT pk_usuarioperfiles PRIMARY KEY (usuario_perfil_id);


--
-- TOC entry 2085 (class 2606 OID 58867)
-- Name: pk_usuarios; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_usuarios
ADD CONSTRAINT pk_usuarios PRIMARY KEY (usuarios_id);


--
-- TOC entry 2067 (class 2606 OID 58885)
-- Name: unq_codigomenu; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_sys_menu
ADD CONSTRAINT unq_codigomenu UNIQUE (menu_codigo);


--
-- TOC entry 2072 (class 2606 OID 58889)
-- Name: unq_perfil_syscode_codigo; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_sys_perfil
ADD CONSTRAINT unq_perfil_syscode_codigo UNIQUE (sys_systemcode, perfil_codigo);


--
-- TOC entry 2074 (class 2606 OID 58891)
-- Name: unq_perfil_syscode_perfil_id; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_sys_perfil
ADD CONSTRAINT unq_perfil_syscode_perfil_id UNIQUE (sys_systemcode, perfil_id);


--
-- TOC entry 2105 (class 2606 OID 76069)
-- Name: unq_producto_detalle; Type: CONSTRAINT; Schema: public; Owner: clabsuser; Tablespace:
--

ALTER TABLE ONLY tb_producto_detalle
ADD CONSTRAINT unq_producto_detalle UNIQUE (insumo_id_origen, insumo_id);


--
-- TOC entry 2093 (class 2606 OID 59386)
-- Name: uq_unidad_conversion; Type: CONSTRAINT; Schema: public; Owner: clabsuser; Tablespace:
--

ALTER TABLE ONLY tb_unidad_medida_conversion
ADD CONSTRAINT uq_unidad_conversion UNIQUE (unidad_medida_origen, unidad_medida_destino);


--
-- TOC entry 2062 (class 1259 OID 58916)
-- Name: fki_menu_parent_id; Type: INDEX; Schema: public; Owner: atluser; Tablespace:
--

CREATE INDEX fki_menu_parent_id ON tb_sys_menu USING btree (menu_parent_id);


--
-- TOC entry 2063 (class 1259 OID 58917)
-- Name: fki_menu_sistemas; Type: INDEX; Schema: public; Owner: atluser; Tablespace:
--

CREATE INDEX fki_menu_sistemas ON tb_sys_menu USING btree (sys_systemcode);


--
-- TOC entry 2068 (class 1259 OID 58918)
-- Name: fki_perfil_sistema; Type: INDEX; Schema: public; Owner: atluser; Tablespace:
--

CREATE INDEX fki_perfil_sistema ON tb_sys_perfil USING btree (sys_systemcode);


--
-- TOC entry 2079 (class 1259 OID 58919)
-- Name: fki_perfil_usuario; Type: INDEX; Schema: public; Owner: atluser; Tablespace:
--

CREATE INDEX fki_perfil_usuario ON tb_sys_usuario_perfiles USING btree (perfil_id);


--
-- TOC entry 2080 (class 1259 OID 58932)
-- Name: fki_usuarioperfiles; Type: INDEX; Schema: public; Owner: atluser; Tablespace:
--

CREATE INDEX fki_usuarioperfiles ON tb_sys_usuario_perfiles USING btree (usuarios_id);


--
-- TOC entry 2083 (class 1259 OID 58937)
-- Name: idx_unique_usuarios; Type: INDEX; Schema: public; Owner: atluser; Tablespace:
--

CREATE UNIQUE INDEX idx_unique_usuarios ON tb_usuarios USING btree (upper((usuarios_code)::text));


--
-- TOC entry 2129 (class 2620 OID 58944)
-- Name: sptrg_verify_usuario_code_change; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER sptrg_verify_usuario_code_change BEFORE INSERT OR DELETE OR UPDATE ON tb_usuarios FOR EACH ROW EXECUTE PROCEDURE sptrg_verify_usuario_code_change();


--
-- TOC entry 2124 (class 2620 OID 58961)
-- Name: tr_entidad; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_entidad BEFORE INSERT OR UPDATE ON tb_entidad FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2146 (class 2620 OID 76033)
-- Name: tr_insumo_validate_save; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_insumo_validate_save BEFORE INSERT OR UPDATE ON tb_insumo FOR EACH ROW EXECUTE PROCEDURE sptrg_insumo_validate_save();


--
-- TOC entry 2134 (class 2620 OID 59409)
-- Name: tr_moneda_validate_save; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_moneda_validate_save BEFORE INSERT OR UPDATE ON tb_moneda FOR EACH ROW EXECUTE PROCEDURE sptrg_moneda_validate_save();


--
-- TOC entry 2148 (class 2620 OID 76064)
-- Name: tr_producto_detalle_validate_save; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_producto_detalle_validate_save BEFORE INSERT OR UPDATE ON tb_producto_detalle FOR EACH ROW EXECUTE PROCEDURE sptrg_producto_detalle_validate_save();


--
-- TOC entry 2125 (class 2620 OID 58977)
-- Name: tr_sys_perfil; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_sys_perfil BEFORE INSERT OR UPDATE ON tb_sys_perfil FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2126 (class 2620 OID 58978)
-- Name: tr_sys_perfil_detalle; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_sys_perfil_detalle BEFORE INSERT OR UPDATE ON tb_sys_perfil_detalle FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2127 (class 2620 OID 58979)
-- Name: tr_sys_sistemas; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_sys_sistemas BEFORE INSERT OR UPDATE ON tb_sys_sistemas FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2128 (class 2620 OID 58980)
-- Name: tr_sys_usuario_perfiles; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_sys_usuario_perfiles BEFORE INSERT OR UPDATE ON tb_sys_usuario_perfiles FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2143 (class 2620 OID 75921)
-- Name: tr_tcostos_validate_delete; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_tcostos_validate_delete BEFORE DELETE ON tb_tcostos FOR EACH ROW EXECUTE PROCEDURE sptrg_tcostos_validate_delete();


--
-- TOC entry 2144 (class 2620 OID 75918)
-- Name: tr_tcostos_validate_save; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_tcostos_validate_save BEFORE INSERT OR UPDATE ON tb_tcostos FOR EACH ROW EXECUTE PROCEDURE sptrg_tcostos_validate_save();


--
-- TOC entry 2142 (class 2620 OID 75923)
-- Name: tr_tinsumo_validate_delete; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_tinsumo_validate_delete BEFORE DELETE ON tb_tinsumo FOR EACH ROW EXECUTE PROCEDURE sptrg_tinsumo_validate_delete();


--
-- TOC entry 2140 (class 2620 OID 75906)
-- Name: tr_tinsumo_validate_save; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_tinsumo_validate_save BEFORE INSERT OR UPDATE ON tb_tinsumo FOR EACH ROW EXECUTE PROCEDURE sptrg_tinsumo_validate_save();


--
-- TOC entry 2138 (class 2620 OID 75896)
-- Name: tr_tipo_cambio; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_tipo_cambio BEFORE INSERT OR UPDATE ON tb_tipo_cambio FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2139 (class 2620 OID 75897)
-- Name: tr_tipo_cambio_validate_save; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_tipo_cambio_validate_save BEFORE INSERT OR UPDATE ON tb_tipo_cambio FOR EACH ROW EXECUTE PROCEDURE sptrg_tipo_cambio_validate_save();


--
-- TOC entry 2136 (class 2620 OID 59398)
-- Name: tr_unidad_medida_conversion_validate_save; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_unidad_medida_conversion_validate_save BEFORE INSERT OR UPDATE ON tb_unidad_medida_conversion FOR EACH ROW EXECUTE PROCEDURE sptrg_unidad_medida_conversion_validate_save();


--
-- TOC entry 2131 (class 2620 OID 75962)
-- Name: tr_unidad_medida_validate_delete; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_unidad_medida_validate_delete BEFORE DELETE ON tb_unidad_medida FOR EACH ROW EXECUTE PROCEDURE sptrg_unidad_medida_validate_delete();


--
-- TOC entry 2132 (class 2620 OID 59401)
-- Name: tr_unidad_medida_validate_save; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_unidad_medida_validate_save BEFORE INSERT OR UPDATE ON tb_unidad_medida FOR EACH ROW EXECUTE PROCEDURE sptrg_unidad_medida_validate_save();


--
-- TOC entry 2133 (class 2620 OID 59233)
-- Name: tr_update_log_fields; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_update_log_fields BEFORE INSERT OR UPDATE ON tb_unidad_medida FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2135 (class 2620 OID 59249)
-- Name: tr_update_log_fields; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_update_log_fields BEFORE INSERT OR UPDATE ON tb_moneda FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2137 (class 2620 OID 59397)
-- Name: tr_update_log_fields; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_update_log_fields BEFORE INSERT OR UPDATE ON tb_unidad_medida_conversion FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2141 (class 2620 OID 75907)
-- Name: tr_update_log_fields; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_update_log_fields BEFORE INSERT OR UPDATE ON tb_tinsumo FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2145 (class 2620 OID 75919)
-- Name: tr_update_log_fields; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_update_log_fields BEFORE INSERT OR UPDATE ON tb_tcostos FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2147 (class 2620 OID 76034)
-- Name: tr_update_log_fields; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_update_log_fields BEFORE INSERT OR UPDATE ON tb_insumo FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2149 (class 2620 OID 76065)
-- Name: tr_update_log_fields; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_update_log_fields BEFORE INSERT OR UPDATE ON tb_producto_detalle FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2130 (class 2620 OID 58981)
-- Name: tr_usuarios; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_usuarios BEFORE INSERT OR UPDATE ON tb_usuarios FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2116 (class 2606 OID 76008)
-- Name: fk_insumo_moneda_costo; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY tb_insumo
ADD CONSTRAINT fk_insumo_moneda_costo FOREIGN KEY (moneda_codigo_costo) REFERENCES tb_moneda(moneda_codigo);


--
-- TOC entry 2117 (class 2606 OID 76013)
-- Name: fk_insumo_tcostos; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY tb_insumo
ADD CONSTRAINT fk_insumo_tcostos FOREIGN KEY (tcostos_codigo) REFERENCES tb_tcostos(tcostos_codigo);


--
-- TOC entry 2118 (class 2606 OID 76018)
-- Name: fk_insumo_tinsumo; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY tb_insumo
ADD CONSTRAINT fk_insumo_tinsumo FOREIGN KEY (tinsumo_codigo) REFERENCES tb_tinsumo(tinsumo_codigo);


--
-- TOC entry 2119 (class 2606 OID 76023)
-- Name: fk_insumo_unidad_medida_costo; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY tb_insumo
ADD CONSTRAINT fk_insumo_unidad_medida_costo FOREIGN KEY (unidad_medida_codigo_costo) REFERENCES tb_unidad_medida(unidad_medida_codigo);


--
-- TOC entry 2120 (class 2606 OID 76028)
-- Name: fk_insumo_unidad_medida_ingreso; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY tb_insumo
ADD CONSTRAINT fk_insumo_unidad_medida_ingreso FOREIGN KEY (unidad_medida_codigo_ingreso) REFERENCES tb_unidad_medida(unidad_medida_codigo);


--
-- TOC entry 2106 (class 2606 OID 59107)
-- Name: fk_menu_parent; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_sys_menu
ADD CONSTRAINT fk_menu_parent FOREIGN KEY (menu_parent_id) REFERENCES tb_sys_menu(menu_id);


--
-- TOC entry 2107 (class 2606 OID 59112)
-- Name: fk_menu_sistemas; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_sys_menu
ADD CONSTRAINT fk_menu_sistemas FOREIGN KEY (sys_systemcode) REFERENCES tb_sys_sistemas(sys_systemcode);


--
-- TOC entry 2114 (class 2606 OID 75886)
-- Name: fk_moneda_destino; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY tb_tipo_cambio
ADD CONSTRAINT fk_moneda_destino FOREIGN KEY (moneda_codigo_destino) REFERENCES tb_moneda(moneda_codigo);


--
-- TOC entry 2115 (class 2606 OID 75891)
-- Name: fk_moneda_origen; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY tb_tipo_cambio
ADD CONSTRAINT fk_moneda_origen FOREIGN KEY (moneda_codigo_origen) REFERENCES tb_moneda(moneda_codigo);


--
-- TOC entry 2109 (class 2606 OID 59122)
-- Name: fk_perfdet_perfil; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_sys_perfil_detalle
ADD CONSTRAINT fk_perfdet_perfil FOREIGN KEY (perfil_id) REFERENCES tb_sys_perfil(perfil_id);


--
-- TOC entry 2108 (class 2606 OID 59127)
-- Name: fk_perfil_sistema; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_sys_perfil
ADD CONSTRAINT fk_perfil_sistema FOREIGN KEY (sys_systemcode) REFERENCES tb_sys_sistemas(sys_systemcode);


--
-- TOC entry 2121 (class 2606 OID 76049)
-- Name: fk_producto_detalle_insumo_id; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY tb_producto_detalle
ADD CONSTRAINT fk_producto_detalle_insumo_id FOREIGN KEY (insumo_id) REFERENCES tb_insumo(insumo_id);


--
-- TOC entry 2122 (class 2606 OID 76054)
-- Name: fk_producto_detalle_insumo_id_origen; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY tb_producto_detalle
ADD CONSTRAINT fk_producto_detalle_insumo_id_origen FOREIGN KEY (insumo_id_origen) REFERENCES tb_insumo(insumo_id);


--
-- TOC entry 2123 (class 2606 OID 76059)
-- Name: fk_producto_detalle_unidad_medida; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY tb_producto_detalle
ADD CONSTRAINT fk_producto_detalle_unidad_medida FOREIGN KEY (unidad_medida_codigo) REFERENCES tb_unidad_medida(unidad_medida_codigo);


--
-- TOC entry 2112 (class 2606 OID 59387)
-- Name: fk_unidad_conversion_medida_destino; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY tb_unidad_medida_conversion
ADD CONSTRAINT fk_unidad_conversion_medida_destino FOREIGN KEY (unidad_medida_destino) REFERENCES tb_unidad_medida(unidad_medida_codigo);


--
-- TOC entry 2113 (class 2606 OID 59392)
-- Name: fk_unidad_conversion_medida_origen; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY tb_unidad_medida_conversion
ADD CONSTRAINT fk_unidad_conversion_medida_origen FOREIGN KEY (unidad_medida_origen) REFERENCES tb_unidad_medida(unidad_medida_codigo);


--
-- TOC entry 2110 (class 2606 OID 59172)
-- Name: fk_usuarioperfiles; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_sys_usuario_perfiles
ADD CONSTRAINT fk_usuarioperfiles FOREIGN KEY (perfil_id) REFERENCES tb_sys_perfil(perfil_id);


--
-- TOC entry 2111 (class 2606 OID 59177)
-- Name: fk_usuarioperfiles_usuario; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_sys_usuario_perfiles
ADD CONSTRAINT fk_usuarioperfiles_usuario FOREIGN KEY (usuarios_id) REFERENCES tb_usuarios(usuarios_id);


--
-- TOC entry 2289 (class 0 OID 0)
-- Dependencies: 7
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2016-08-30 01:41:29 PET

--
-- PostgreSQL database dump complete
--

