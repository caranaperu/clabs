--
-- PostgreSQL database dump
--

-- Dumped from database version 9.3.13
-- Dumped by pg_dump version 9.3.13
-- Started on 2016-05-28 03:21:03 PET

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
-- TOC entry 2673 (class 0 OID 0)
-- Dependencies: 1
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner:
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- TOC entry 631 (class 1247 OID 16390)
-- Name: sexo_full_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE sexo_full_type AS ENUM (
	'F',
	'M',
	'A'
);


ALTER TYPE public.sexo_full_type OWNER TO postgres;

--
-- TOC entry 634 (class 1247 OID 16398)
-- Name: sexo_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE sexo_type AS ENUM (
	'F',
	'M'
);


ALTER TYPE public.sexo_type OWNER TO postgres;

--
-- TOC entry 293 (class 1255 OID 37520)
-- Name: fn_can_modify_manual_status(integer, integer, character varying); Type: FUNCTION; Schema: public; Owner: atluser
--

CREATE FUNCTION fn_can_modify_manual_status(p_competencias_pruebas_id integer, p_atletas_resultados_id integer, p_mode character varying) RETURNS integer
LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 01-04-2014

Funcion que verifica si s posible cambiar el statius manual de la prueba.
el parametro  p_mode debe ser 'strict', 'add' , 'update'  si no se envia ni add o update se asumira strict

IMPORTANTE: debe ser llamado antes de agregar o modificar la prueba en la tabla tb_atletas_resultados
de lo contrario dara falso positivo o negativo.

Historia : Creado 28-03-2016
*/
DECLARE v_count integer;
				DECLARE v_return integer = 1;

BEGIN


	IF p_mode  != 'add' AND p_mode != 'update'
	THEN
		SELECT COUNT(1) INTO v_count
		FROM tb_atletas_resultados
		where competencias_pruebas_id = p_competencias_pruebas_id;

		IF v_count > 0
		THEN
			v_return := 0;
		END IF;
	ELSE
		IF p_mode = 'add'
		THEN
			SELECT COUNT(1) INTO v_count
			FROM tb_atletas_resultados
			where competencias_pruebas_id = p_competencias_pruebas_id;

			IF v_count >  0
			THEN
				v_return := 0;
			END IF;
		ELSE
			IF p_mode = 'update'
			THEN
				SELECT COUNT(1) INTO v_count
				FROM tb_atletas_resultados
				where competencias_pruebas_id = p_competencias_pruebas_id
							and atletas_resultados_id != p_atletas_resultados_id;

				IF v_count >= 1
				THEN
					v_return := 0;
				END IF;
			END IF;
		END IF;
	END IF;

	RETURN v_return;

END;
$$;


ALTER FUNCTION public.fn_can_modify_manual_status(p_competencias_pruebas_id integer, p_atletas_resultados_id integer, p_mode character varying) OWNER TO atluser;

--
-- TOC entry 241 (class 1255 OID 16403)
-- Name: fn_get_combinada_resultados_as_text(integer, character varying, character varying); Type: FUNCTION; Schema: public; Owner: atluser
--

CREATE FUNCTION fn_get_combinada_resultados_as_text(p_competencia_id integer, p_atleta_codigo character varying, p_categoria_codigo character varying) RETURNS character varying
LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 27-12-2014

Funcion que retorna como una cadena varchar el resumen de resultados de una prueba combinada.


PARAMETROS :
p_competencia_id - El id de la competencia donde se realizo la prueba
p_atleta_codigo - codigo del atleta
p_categoria_codigo - codigo de la categoria en el caso que el record de combinada corresponda a mas de una.

Historia : Creado 27-12-2014
*/
DECLARE
	v_Temp  VARCHAR := '';
	v_count	INTEGER := 0;
	ar RECORD;
BEGIN
	FOR ar IN
	select 	atletas_resultados_resultado,
		atletas_resultados_puntos,
		(case when pv.apppruebas_verifica_viento = TRUE and cp.competencias_pruebas_anemometro = TRUE
			then (case when apppruebas_viento_individual = TRUE then coalesce(eatl.atletas_resultados_viento,0) else coalesce(cp.competencias_pruebas_viento,0) end)
		 when pv.apppruebas_verifica_viento = TRUE and cp.competencias_pruebas_anemometro = FALSE
			 then -100.00 -- si tiene error de anemometro
		 else null
		 end)::numeric as viento,
		competencias_pruebas_manual,
		competencias_pruebas_material_reglamentario,
		pruebas_detalle_orden
	from tb_competencias_pruebas cp
		inner join tb_atletas_resultados eatl on eatl.competencias_pruebas_id=cp.competencias_pruebas_id
		inner join tb_atletas atl on atl.atletas_codigo = eatl.atletas_codigo
		inner join  tb_pruebas_detalle pdet on pdet.pruebas_detalle_prueba_codigo = cp.pruebas_codigo
		inner join tb_pruebas pru on pru.pruebas_codigo = cp.pruebas_codigo
		inner join tb_app_pruebas_values pv on pv.apppruebas_codigo = pru.pruebas_generica_codigo
	where competencias_pruebas_origen_id = p_competencia_id and atl.atletas_codigo= p_atleta_codigo and categorias_codigo = p_categoria_codigo
	order by competencias_pruebas_origen_id,categorias_codigo,pruebas_detalle_orden

	LOOP

		IF (v_count > 0) THEN
			v_temp := v_temp  || ' / ';
		END IF;

		v_Temp := v_Temp || ar.atletas_resultados_resultado;
		v_Temp := v_Temp || (case when ar.competencias_pruebas_manual = true then  '(m)' else '' end);
		v_Temp := v_Temp || (case when ar.competencias_pruebas_material_reglamentario = false then  '(*)' else '' end);
		v_Temp := v_Temp || (case when ar.viento is not null and ar.viento > -100 then  ' (' || ar.viento::TEXT  || ')' else '' end);
		v_Temp := v_Temp || (case when ar.viento is not null and ar.viento = -100 then  ' (*)' else '' end);

		v_count := v_count+1;
		--RAISE NOTICE '   v_Temp =% ', v_Temp;
	END LOOP;

	RETURN v_Temp;
END;

$$;


ALTER FUNCTION public.fn_get_combinada_resultados_as_text(p_competencia_id integer, p_atleta_codigo character varying, p_categoria_codigo character varying) OWNER TO atluser;

--
-- TOC entry 245 (class 1255 OID 16404)
-- Name: fn_get_marca_normalizada(character varying, character varying, boolean, numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fn_get_marca_normalizada(p_timetotest character varying, p_type character varying, p_ismanual boolean, p_adjustmanualtime numeric) RETURNS integer
LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 11-04-2013

Funcion que normaliza los resultados o marcas basadas en tiempo , de tal forma que podamos determinar
que marca es menor que otra.

IMPORTANTE : No tiene la mas minima intencion de convertir a milisegundos formalmente solo determina
que marca o resultado es mayor o menor que otra.

PARAMETROS :
p_timetotest - La mar o resultado en formato de texto pero que representa el tiempo a evaluar.
p_ismanual - Si la marca es manual
p_adjustmanualtime - monto en centesimas de la correcion de maual a lectronico.

Historia : Creado 11-04-2014
*/
DECLARE a character varying[];
				DECLARE v_timeTotest VARCHAR(20);
				DECLARE v_aLength INTEGER;
				DECLARE v_factor INTEGER;
BEGIN
	-- Paso 0 , si la marca es 0 se retorna cero
	IF p_timetotest = '0' OR p_timetotest = '0.00' OR p_timetotest = ''
		 OR p_timetotest IS NULL
	THEN
		RETURN 0;
	END IF;

	-- Paso 1 los puntos los convertimos a dos puntos para igualar todo
	-- Lo separamos en partes para procesarlo
	-- Tomamos la longitud del areglo para validar.
	v_timeToTest := replace(p_timeTotest, '.', ':');
	a := regexp_split_to_array(v_timeToTest, E'\\:+');
	v_aLength := array_length(a,1);


	-- Validamos si es correcto el tamaño del arreglo
	-- En seg se considera minutos tambien ya que las pruebas de mas
	-- de 200 siendo de velocidad pueden pasar a los minutos.
	IF (p_type = 'SEG' AND (v_aLength != 2 AND v_aLength != 3)) OR
		 (p_type = 'HMS' AND v_aLength != 4) OR
		 (p_type = 'MS' AND v_aLength != 3) OR
		 (p_type = 'PUNT' AND v_aLength != 1) OR
		 (p_type = '"MTSCM"' AND v_aLength != 2)
	THEN
		RAISE  'El Formato de % , no corresponde al tipo %',p_timeTotest,p_type USING ERRCODE = 'restrict_violation';
		RETURN 0;
	END IF;

	-- Si el tipo es segundos pero el arreglo es de 3
	-- sera tratado como Minutos/Segundos
	IF p_type = 'SEG' and v_alength = 3
	THEN
		p_type='MS';
	END IF;

	-- CONVERTIMOS A MILISEGUNDOS
	v_factor := 1;

	IF p_type = 'SEG'
	THEN
		IF  p_ismanual = TRUE
		THEN
			-- Usamos factor de correccion
			IF p_adjustManualTime IS NOT NULL AND  p_adjustManualTime > 0.00
			THEN
				a[2] = ROUND(((p_adjustManualTime+a[2]::NUMERIC /10.00)*100.00),0)::CHARACTER VARYING;
			ELSE
				v_factor := 100;
			END IF;
		END IF;
		RETURN a[1]::INTEGER * 1000 + a[2]::INTEGER*v_factor;
	ELSIF p_type = 'HMS'
		THEN
			IF  p_ismanual = TRUE
			THEN
				-- Usamos factor de correccion
				IF p_adjustManualTime IS NOT NULL AND  p_adjustManualTime > 0.00
				THEN
					a[4] = ROUND(((p_adjustManualTime+a[4]::NUMERIC /10.00)*100.00),0)::CHARACTER VARYING;
				ELSE
					v_factor := 100;
				END IF;
			END IF;
			RETURN a[1]::INTEGER * 3600000 + a[2]::INTEGER * 60000 + a[3]::INTEGER * 1000 + a[4]::INTEGER * v_factor;

	ELSIF p_type = 'MS'
		THEN
			IF  p_ismanual = TRUE
			THEN
				-- Usamos factor de correccion
				IF p_adjustManualTime IS NOT NULL AND  p_adjustManualTime > 0.00
				THEN
					a[3] = ROUND(((p_adjustManualTime+a[3]::NUMERIC /10.00)*100.00),0)::CHARACTER VARYING;
				ELSE
					v_factor := 100;
				END IF;
			END IF;
			RETURN a[1]::INTEGER * 60000 + a[2]::INTEGER * 1000 + a[3]::INTEGER * v_factor;

	ELSIF p_type = 'PUNT'
		THEN
			RETURN a[1]::INTEGER;
	ELSIF p_type = 'MTSCM'
		THEN
			RETURN a[1]::INTEGER * 100 +  a[2]::INTEGER;
	END IF;

	RAISE  'Existio un problema durante la conversion , se retorna 0 , PARAMS : % %',p_timetotest, p_type USING ERRCODE = 'restrict_violation';
	RETURN 0;
END;
$$;


ALTER FUNCTION public.fn_get_marca_normalizada(p_timetotest character varying, p_type character varying, p_ismanual boolean, p_adjustmanualtime numeric) OWNER TO postgres;

--
-- TOC entry 246 (class 1255 OID 16405)
-- Name: fn_get_marca_normalizada_tonumber(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fn_get_marca_normalizada_tonumber(p_marca character varying, p_type character varying) RETURNS numeric
LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 11-04-2013

Funcion que normaliza los resultados o marcas  , de tal forma que podamos determinar
que marca es menor que otra. Las tiempos todos pasan a segundos, las distancias a centimetros
y los puntos se develven como enteros

IMPORTANTE : Los datos en texto a procesar deben estar normalizados , osea los tiempos ya
deben considerar la parte manual y el formato correcto , para ser procesados correctamente.

La funcion fn_get_marca_normalizada_totext() puede ser llamada previamente para tener el
formato de texto normalizado antes de entrar a esta funcion.

PARAMETROS :
p_marca - La mar o resultado en formato de texto pero que representa el tiempo a evaluar.


Historia : Creado 11-04-2014
*/
DECLARE a character varying[];
				DECLARE v_timeTotest VARCHAR(20);
				DECLARE v_aLength INTEGER;
BEGIN
	-- Paso 0 , si la marca es 0 se retorna cero
	IF p_marca = '0' OR p_marca = '0.00' OR p_marca = ''
		 OR p_marca IS NULL
	THEN
		RETURN 0;
	END IF;

	-- Paso 1 los puntos los convertimos a dos puntos para igualar todo
	-- Lo separamos en partes para procesarlo
	-- Tomamos la longitud del areglo para validar.
	v_timeToTest := replace(p_marca, '.', ':');
	a := regexp_split_to_array(v_timeToTest, E'\\:+');
	v_aLength := array_length(a,1);


	-- Validamos si es correcto el tamaño del arreglo
	-- En seg se considera minutos tambien ya que las pruebas de mas
	-- de 200 siendo de velocidad pueden pasar a los minutos.
	IF (p_type = 'SEG' AND (v_aLength != 2 AND v_aLength != 3)) OR
		 (p_type = 'HMS' AND v_aLength != 4) OR
		 (p_type = 'MS' AND v_aLength != 3) OR
		 (p_type = 'PUNT' AND v_aLength != 1) OR
		 (p_type = '"MTSCM"' AND v_aLength != 2)
	THEN
		RAISE  'El Formato de % , no corresponde al tipo %',p_marca,p_type USING ERRCODE = 'restrict_violation';
		RETURN 0;
	END IF;

	-- Si el tipo es segundos pero el arreglo es de 3
	-- sera tratado como Minutos/Segundos
	IF p_type = 'SEG' and v_alength = 3
	THEN
		p_type='MS';
	END IF;

	-- CONVERTIMOS A SEGUNDOS,CENTIMETROS O PUNTOS
	IF p_type = 'SEG'
	THEN
		RETURN ROUND(a[1]::NUMERIC+a[2]::NUMERIC / 100.00,2);
	ELSIF p_type = 'HMS'
		THEN
			RETURN ROUND(a[1]::NUMERIC * 60*60 + a[2]::NUMERIC * 60 + a[3]::NUMERIC + a[4]::NUMERIC / 100.00,2);

	ELSIF p_type = 'MS'
		THEN
			RETURN ROUND(a[1]::NUMERIC * 60 + a[2]::NUMERIC  + a[3]::NUMERIC / 100.00,2);

	ELSIF p_type = 'PUNT'
		THEN
			RETURN a[1]::NUMERIC;
	ELSIF p_type = 'MTSCM'
		THEN
			RETURN a[1]::NUMERIC * 100 +  a[2]::NUMERIC;
	END IF;

	RAISE  'Existio un problema durante la conversion , se retorna 0 , PARAMS : % %',p_marca, p_type USING ERRCODE = 'restrict_violation';
	RETURN 0;
END;
$$;


ALTER FUNCTION public.fn_get_marca_normalizada_tonumber(p_marca character varying, p_type character varying) OWNER TO postgres;

--
-- TOC entry 247 (class 1255 OID 16406)
-- Name: fn_get_marca_normalizada_totext(character varying, character varying, boolean, numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fn_get_marca_normalizada_totext(p_timetotest character varying, p_type character varying, p_ismanual boolean, p_adjustmanualtime numeric) RETURNS character varying
LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 11-06-2014

Funcion que normaliza los resultados o marcas basadas en tiempo , de tal forma que podamos determinar
que marca es menor que otra.

IMPORTANTE : El resultado es apropiado para que se ordene en forma textual.

PARAMETROS :
p_timetotest - La mar o resultado en formato de texto pero que representa el tiempo a evaluar.
p_ismanual - Si la marca es manual
p_adjustmanualtime - monto en centesimas de la correcion de maual a lectronico.

Historia : Creado 11-04-2014
*/
DECLARE a character varying[];
				DECLARE v_timeTotest VARCHAR(20);
				DECLARE v_aLength INTEGER;
				DECLARE v_centesimas INTEGER;
				DECLARE v_segundos INTEGER;
				DECLARE v_minutos INTEGER;
				DECLARE v_horas INTEGER;

BEGIN
	-- Paso 0 , si la marca es 0 se retorna cero
	IF p_timetotest = '0' OR p_timetotest = '0.00' OR p_timetotest = ''
		 OR p_timetotest IS NULL
	THEN
		RETURN 0;
	END IF;

	-- Paso 1 los puntos los convertimos a dos puntos para igualar todo
	-- Lo separamos en partes para procesarlo
	-- Tomamos la longitud del areglo para validar.
	v_timeToTest := replace(p_timeTotest, '.', ':');
	a := regexp_split_to_array(v_timeToTest, E'\\:+');
	v_aLength := array_length(a,1);


	-- Validamos si es correcto el tamaño del arreglo
	-- En seg se considera minutos tambien ya que las pruebas de mas
	-- de 200 siendo de velocidad pueden pasar a los minutos.
	IF (p_type = 'SEG' AND (v_aLength != 2 AND v_aLength != 3)) OR
		 (p_type = 'HMS' AND v_aLength != 4) OR
		 (p_type = 'MS' AND v_aLength != 3) OR
		 (p_type = 'PUNT' AND v_aLength != 1) OR
		 (p_type = '"MTSCM"' AND v_aLength != 2)
	THEN
		RAISE  'El Formato de % , no corresponde al tipo %',p_timeTotest,p_type USING ERRCODE = 'restrict_violation';
		RETURN 0;
	END IF;

	-- Si el tipo es segundos pero el arreglo es de 3
	-- sera tratado como Minutos/Segundos
	IF p_type = 'SEG' and v_alength = 3
	THEN
		p_type='MS';
	END IF;

	IF p_type = 'SEG'
	THEN
		IF p_ismanual = TRUE
		THEN
			v_centesimas := (a[2]::INTEGER*10 +  (coalesce(p_adjustManualTime,0.00)*100)::INTEGER);

			if v_centesimas > 99
			then
				v_centesimas := v_centesimas-100;
				v_segundos := a[1]::INTEGER +1;
			else
				v_segundos := a[1];
			end if;
		ELSE
			v_centesimas := a[2]::INTEGER;
			v_segundos := a[1];
		END IF;
		RETURN 	right('00' || v_segundos::character varying,2) || '.' || right('00' || v_centesimas::character varying,2);

	ELSIF p_type = 'HMS'
		THEN
			--RAISE NOTICE '% % % %',a[1],a[2],a[3],a[4];

			IF p_ismanual = TRUE
			THEN
				v_centesimas := (a[4]::INTEGER*10 +  (coalesce(p_adjustManualTime,0.00)*100)::INTEGER);
				RAISE NOTICE '%',v_centesimas;
				if v_centesimas > 99
				then
					v_centesimas := v_centesimas-100;
					v_segundos := a[3]::INTEGER +1;
				else
					v_segundos := a[3];
				end if;

				if v_segundos > 59
				then
					v_segundos := v_segundos-60;
					v_minutos := a[2]::INTEGER +1;
				else
					v_minutos := a[2];
				end if;

				if v_minutos > 59
				then
					v_minutos := v_minutos-60;
					v_horas := a[1]::INTEGER +1;
				else
					v_horas := a[1];
				end if;

			ELSE
				v_centesimas := a[4]::INTEGER;
				v_segundos := a[3]::INTEGER;
				v_minutos := a[2]::INTEGER;
				v_horas := a[1]::INTEGER;
			END IF;

			RETURN 	right('00' || v_horas::character varying,2) || ':' || right('00' || v_minutos::character varying,2) || ':' || right('00' || v_segundos::character varying,2) || '.' || right('00' || v_centesimas::character varying,2);

	ELSIF p_type = 'MS'
		THEN
			--RAISE NOTICE '% % %',a[1],a[2],a[3];

			IF p_ismanual = TRUE
			THEN
				v_centesimas := (a[3]::INTEGER*10 +  (coalesce(p_adjustManualTime,0.00)*100)::INTEGER);
				RAISE NOTICE '%',v_centesimas;
				if v_centesimas > 99
				then
					v_centesimas := v_centesimas-100;
					v_segundos := a[2]::INTEGER +1;
				else
					v_segundos := a[2];
				end if;

				if v_segundos > 59
				then
					v_segundos := v_segundos-60;
					v_minutos := a[1]::INTEGER +1;
				else
					v_minutos := a[1];
				end if;

			ELSE
				v_centesimas := a[3]::INTEGER;
				v_segundos := a[2]::INTEGER;
				v_minutos := a[1]::INTEGER;
			END IF;

			RETURN 	right('00' || v_minutos::character varying,2) || ':' || right('00' || v_segundos::character varying,2) || '.' || right('00' || v_centesimas::character varying,2);


	ELSIF p_type = 'PUNT'
		THEN
			RETURN  right('00000' || a[1],5);
	ELSIF p_type = 'MTSCM'
		THEN
			RETURN right('00' || a[1],2) || '.' ||  right('00' || a[2],2);
	END IF;

	RAISE  'Existio un problema durante la conversion , se retorna 0 , PARAMS : % %',p_timetotest, p_type USING ERRCODE = 'restrict_violation';
	RETURN 0;
END;
$$;


ALTER FUNCTION public.fn_get_marca_normalizada_totext(p_timetotest character varying, p_type character varying, p_ismanual boolean, p_adjustmanualtime numeric) OWNER TO postgres;

--
-- TOC entry 248 (class 1255 OID 16408)
-- Name: fn_get_records_for_result_as_text(integer, integer); Type: FUNCTION; Schema: public; Owner: atluser
--

CREATE FUNCTION fn_get_records_for_result_as_text(p_atletas_resultados_id integer, p_min_records_tipo_peso integer) RETURNS character varying
LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 27-12-2014

Funcion que retorna como una cadena varchar el resumen de resultados de una prueba combinada.


PARAMETROS :
p_competencia_id - El id de la competencia donde se realizo la prueba
p_atleta_codigo - codigo del atleta
p_categoria_codigo - codigo de la categoria en el caso que el record de combinada corresponda a mas de una.

Historia : Creado 27-12-2014
*/
DECLARE
	v_Temp  VARCHAR := '';
	v_count	INTEGER := 0;
	ar RECORD;
BEGIN
	FOR ar IN
	select records_tipo_abreviatura,categorias_codigo from
		tb_records rec
		inner join tb_atletas_resultados eatl  on rec.atletas_resultados_id=eatl.atletas_resultados_id
		inner join tb_records_tipo rt on rt.records_tipo_codigo=rec.records_tipo_codigo
	where rec.atletas_resultados_id  = p_atletas_resultados_id and rt.records_tipo_peso >=  coalesce(p_min_records_tipo_peso,100)
	order by rt.records_tipo_peso desc

	LOOP

		IF (v_count > 0) THEN
			v_temp := v_temp  || ' / ';
		END IF;

		v_Temp := v_Temp || ar.records_tipo_abreviatura || '(' || ar.categorias_codigo || ')';


		v_count := v_count+1;
		--RAISE NOTICE '   v_Temp =% ', v_Temp;
	END LOOP;

	IF (LENGTH(v_Temp) = 0) THEN
		v_Temp := NULL;
	END IF;

	RETURN v_Temp;
END;

$$;


ALTER FUNCTION public.fn_get_records_for_result_as_text(p_atletas_resultados_id integer, p_min_records_tipo_peso integer) OWNER TO atluser;

--
-- TOC entry 253 (class 1255 OID 16428)
-- Name: old_sp_atletas_resultados_delete_for_atleta(character varying, character varying); Type: FUNCTION; Schema: public; Owner: atluser
--

CREATE FUNCTION old_sp_atletas_resultados_delete_for_atleta(p_atletas_codigo character varying, p_usuario_mod character varying) RETURNS void
LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 01-04-2014

Stored procedure que elimina todos los resultados de un atleta previa verificacion que exista.

El parametro p_version_id indica el campo xmin de control para cambios externos .

Historia : Creado 03-04-2014
*/

BEGIN

	IF EXISTS( select 1 from tb_atletas where atletas_codigo = p_atletas_codigo)
	THEN
		DELETE FROM tb_atletas_resultados where atletas_codigo = p_atletas_codigo;
	ELSE
		-- La prueba no existe
		RAISE 'No se puede eliminar los resultados del atleta de codigo % ya que no existe',p_atletas_codigo USING ERRCODE = 'restrict_violation';
	END IF;
END;
$$;


ALTER FUNCTION public.old_sp_atletas_resultados_delete_for_atleta(p_atletas_codigo character varying, p_usuario_mod character varying) OWNER TO atluser;

--
-- TOC entry 254 (class 1255 OID 16429)
-- Name: old_sp_atletas_resultados_delete_for_competencia(character varying, character varying); Type: FUNCTION; Schema: public; Owner: atluser
--

CREATE FUNCTION old_sp_atletas_resultados_delete_for_competencia(p_competencias_codigo character varying, p_usuario_mod character varying) RETURNS void
LANGUAGE plpgsql
AS $$
/**
Elimina todos los resultados que petenecen a una competencia.

Autor : Carlos arana Reategui
Fecha : 01-04-2014

Stored procedure que elimina todos los resultados que corresponden a una competencia.
Historia : Creado 03-04-2014
*/
BEGIN

	IF EXISTS( select 1 from tb_competencias where competencias_codigo = p_competencias_codigo)
	THEN
		DELETE FROM tb_atletas_resultados where atletas_resultados_id in
																						(
																							select atletas_resultados_id from tb_competencias_pruebas co
																								inner join tb_atletas_resultados ar on ar.competencias_pruebas_id = co.competencias_pruebas_id
																							where competencias_codigo = p_competencias_codigo
																						);
	ELSE
		-- La competencia no existe
		RAISE 'No se puede eliminar los resultados de las pruebas para la competencia % ya que no existe',p_competencias_codigo USING ERRCODE = 'restrict_violation';
	END IF;
END;
$$;


ALTER FUNCTION public.old_sp_atletas_resultados_delete_for_competencia(p_competencias_codigo character varying, p_usuario_mod character varying) OWNER TO atluser;

--
-- TOC entry 249 (class 1255 OID 16409)
-- Name: old_sp_atletas_resultados_detalle_save_record_old(integer, integer, character varying, character varying, numeric, boolean, integer, boolean, character varying, integer, bit); Type: FUNCTION; Schema: public; Owner: atluser
--

CREATE FUNCTION old_sp_atletas_resultados_detalle_save_record_old(p_atletas_resultados_detalle_id integer, p_atletas_resultados_id integer, p_pruebas_codigo character varying, p_atletas_resultados_detalle_resultado character varying, p_atletas_resultados_detalle_viento numeric, p_atletas_resultados_detalle_manual boolean, p_atletas_resultados_detalle_puntos integer, p_activo boolean, p_usuario character varying, p_version_id integer, p_is_update bit) RETURNS integer
LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 08-10-2013

Stored procedure que agrega o actualiza los registros de los resultados de las pruebas.
Previamente hace todas las validaciones necesarias para garantizar que los datos sean grabados
consistentemente,

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

	select * from ( select sp_atletas_resultados_detalle_save_record(?,?,etc) as updins) as ans where updins is not null;

	de tal forma que retornara un registro si el update funciono o el insert , y 0 registros si no se realizo
	el uodate. sto es conveniente cuando se usa por ejemplo el affected_rows de algunos drivers.
	EN OTRAS BASES ESTO NO ES NECESARIO.

Historia : Creado 15-01-2014
*/
DECLARE v_apppruebas_marca_menor_new character varying(12);
				DECLARE v_apppruebas_marca_mayor_new character varying(12);
				DECLARE v_apppruebas_verifica_viento_new BOOLEAN = FALSE;
				DECLARE v_marca_test integer;
				DECLARE v_marcaMenorValida integer;
				DECLARE v_marcaMayorValida integer;
				DECLARE v_unidad_medida_tipo_new character(1);
				DECLARE v_unidad_medida_codigo_new character(8);
	-- Datos para la verificacion del header de la combinada
				DECLARE v_prueba_multiple_combinada boolean= FALSE;
				DECLARE v_unidad_medida_codigo_combinada character(8);
				DECLARE v_apppruebas_marca_menor_combinada character varying(12);
				DECLARE v_apppruebas_marca_mayor_combinada character varying(12);
				DECLARE v_current_puntos_combinada integer;

BEGIN
	-----------------------------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------------
	-- VALIDACIONES PRIMARIAS DE INTEGRIDAD LOGICA
	-----------------------------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------------
	-- EL primero antes de hacer cualquier cosa , es que si se indica marca mayor que cero debe haber puntaje.
	IF LENGTH(LTRIM(RTRIM(p_atletas_resultados_detalle_resultado))) > 0 AND p_atletas_resultados_detalle_resultado!='0' AND
		 p_atletas_resultados_detalle_resultado!='0.00' AND
		 p_atletas_resultados_detalle_puntos <= 0
	THEN
		RAISE 'Si la prueba tiene resultado debe existir puntaje' USING ERRCODE =  'restrict_violation';
	END IF;


	IF LENGTH(LTRIM(RTRIM(p_atletas_resultados_detalle_resultado))) > 0 AND
		 (p_atletas_resultados_detalle_resultado='0' OR p_atletas_resultados_detalle_resultado='0.00') AND
		 p_atletas_resultados_detalle_puntos > 0
	THEN
		RAISE 'Si la prueba indica puntaje de tener un resultado que no sea cero' USING ERRCODE =  'restrict_violation';
	END IF;

	-- Buscamos los datos de la prueba principal es realmente una prueba combinada o multiple
	-- y para validar si la marca esta en el rango debido al acumular un nuevo registro.
	SELECT apppruebas_multiple,apppruebas_marca_menor,
		apppruebas_marca_mayor,c.unidad_medida_codigo INTO
		v_prueba_multiple_combinada,v_apppruebas_marca_menor_combinada,v_apppruebas_marca_mayor_combinada,
		v_unidad_medida_codigo_combinada
	FROM tb_pruebas pr
		INNER JOIN tb_app_pruebas_values p ON p.apppruebas_codigo = pr.pruebas_generica_codigo
		INNER JOIN tb_pruebas_clasificacion c ON c.pruebas_clasificacion_codigo = p.pruebas_clasificacion_codigo
		inner join tb_unidad_medida um on um.unidad_medida_codigo = c.unidad_medida_codigo
	where pr.pruebas_codigo = (select ar.pruebas_codigo from tb_atletas_resultados ar where ar.atletas_resultados_id = p_atletas_resultados_id);


	IF v_prueba_multiple_combinada = false
	THEN
		-- La prueba principal no es multiple
		RAISE 'La prueba principal debe ser una prueba multiple (combinada) y no lo es' USING ERRCODE =  'restrict_violation';

	END IF;


	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	-- Varificamos si el limite general de marcas validas se cumple para la cuenta principal , para esto
	-- verficamos el actual acumulado.
	IF p_is_update = '1'
	THEN
		-- Si es update sumamos todos los items actuales menos el que estamos grabando para no acumularlo
		-- 2 veces.
		select coalesce(sum(atletas_resultados_detalle_puntos),0)
		INTO v_current_puntos_combinada
		from tb_atletas_resultados_detalle  where atletas_resultados_id = p_atletas_resultados_id
																							and atletas_resultados_detalle_id != p_atletas_resultados_detalle_id;
	ELSE
		-- Si es add sumamos los actuales existenetes.
		select coalesce(sum(atletas_resultados_detalle_puntos),0)
		INTO v_current_puntos_combinada
		from tb_atletas_resultados_detalle  where atletas_resultados_id = p_atletas_resultados_id;
	END IF;

	-- Determinamos cual seria el nuevo valor en puntos.
	v_current_puntos_combinada := v_current_puntos_combinada + p_atletas_resultados_detalle_puntos;

	v_marcaMenorValida := fn_get_marca_normalizada(v_apppruebas_marca_menor_combinada, v_unidad_medida_codigo_combinada, false, 0);
	v_marcaMayorValida := fn_get_marca_normalizada(v_apppruebas_marca_mayor_combinada, v_unidad_medida_codigo_combinada, false, 0);
	v_marca_test := fn_get_marca_normalizada(v_current_puntos_combinada::character varying, v_unidad_medida_codigo_combinada, false, 0);

	IF v_marca_test < v_marcaMenorValida OR v_marca_test > v_marcaMayorValida
	THEN
		--La marca indicada esta fuera del rango permitido
		RAISE 'El total de % esta fuera del rango permitido para la prueba combinada que esta entre % y % ', v_current_puntos_combinada,v_apppruebas_marca_menor_combinada,v_apppruebas_marca_mayor_combinada USING ERRCODE = 'restrict_violation';
	END IF;
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------

	-- ahora leemos los datos requeridos de la prueba actual del detalle para validaciones
	-- posteriores.
	SELECT apppruebas_multiple,apppruebas_marca_menor,
		apppruebas_marca_mayor,apppruebas_verifica_viento,unidad_medida_tipo,c.unidad_medida_codigo INTO
		v_prueba_multiple_combinada,v_apppruebas_marca_menor_new,
		v_apppruebas_marca_mayor_new,v_apppruebas_verifica_viento_new,
		v_unidad_medida_tipo_new,v_unidad_medida_codigo_new
	FROM tb_pruebas pr
		INNER JOIN tb_app_pruebas_values p ON p.apppruebas_codigo = pr.pruebas_generica_codigo
		INNER JOIN tb_pruebas_clasificacion c ON c.pruebas_clasificacion_codigo = p.pruebas_clasificacion_codigo
		inner join tb_unidad_medida um on um.unidad_medida_codigo = c.unidad_medida_codigo
	where pr.pruebas_codigo = p_pruebas_codigo;


	-- Si el resultado de la prueba esta dentro de los valores validos
	------------------------------------------------------------------------------------
	-- Normalizamos a milisegundos , sin importar si es manual o no ya que ambas medidas deben estar en las mismas
	-- tipo de unidad o ambas son manuales o ambas electronicas. Los otros tipos de puntaje a centimetros o puntos
	-- normalizados.
	v_marcaMenorValida := 0;
	v_marcaMayorValida := 0;
	v_marca_test := 0;

	v_marcaMenorValida := fn_get_marca_normalizada(v_apppruebas_marca_menor_new, v_unidad_medida_codigo_new, false, 0);
	v_marcaMayorValida := fn_get_marca_normalizada(v_apppruebas_marca_mayor_new, v_unidad_medida_codigo_new, false, 0);
	v_marca_test := fn_get_marca_normalizada(p_atletas_resultados_detalle_resultado, v_unidad_medida_codigo_new, false, 0);

	IF v_marca_test < v_marcaMenorValida OR v_marca_test > v_marcaMayorValida
	THEN
		--La marca indicada esta fuera del rango permitido
		RAISE 'La marca indicada de % esta fuera del rango permitido entre % y % ', p_atletas_resultados_detalle_resultado,v_apppruebas_marca_menor_new,v_apppruebas_marca_mayor_new USING ERRCODE = 'restrict_violation';
	END IF;


	-----------------------------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------------
	-- OK paso todas las validaciones basicas , ahora veamos si la prueba tiene control de viento y ver si el viento esta indicado.
	IF v_apppruebas_verifica_viento_new = TRUE
	THEN
		IF p_atletas_resultados_detalle_viento is null
		THEN
			-- La prueba requiere se indique el viento
			RAISE 'La prueba requiere se indique el limite de viento'  USING ERRCODE = 'restrict_violation';
		END IF;
	ELSE
		-- Si no requiere viento lo ponemos en null , por si acaso se envie dato por gusto.
		p_atletas_resultados_detalle_viento := NULL;
	END IF;

	-- Si la unidad de medida de la prueba no es tiempo
	-- se blanquea (false) al campo que indica si la medida manual.
	IF v_unidad_medida_tipo_new != 'T'
	THEN
		p_atletas_resultados_detalle_manual := false;
	END IF;

	IF p_is_update = '1'
	THEN

		-- El  update
		UPDATE
			tb_atletas_resultados_detalle
		SET
			atletas_resultados_id = p_atletas_resultados_id,
			pruebas_codigo = p_pruebas_codigo,
			atletas_resultados_detalle_resultado=p_atletas_resultados_detalle_resultado,
			atletas_resultados_detalle_viento = p_atletas_resultados_detalle_viento,
			atletas_resultados_detalle_manual = p_atletas_resultados_detalle_manual,
			atletas_resultados_detalle_puntos = p_atletas_resultados_detalle_puntos
		WHERE atletas_resultados_detalle_id = p_atletas_resultados_detalle_id;

		RAISE NOTICE  'COUNT ID --> %', FOUND;

		-- Todo ok ,
		IF FOUND THEN
			-- Ponemos el nuevo acumulado en el header
			UPDATE
				tb_atletas_resultados
			SET
				atletas_resultados_resultado =  (select sum(atletas_resultados_detalle_puntos) from tb_atletas_resultados_detalle  where atletas_resultados_id = p_atletas_resultados_id),
				usuario = p_usuario
			WHERE atletas_resultados_id = p_atletas_resultados_id ;
			RETURN 1;
		ELSE
			RAISE '' USING ERRCODE = 'record modified';
			RETURN null;
		END IF;
	ELSE
		INSERT INTO
			tb_atletas_resultados_detalle
			(
				atletas_resultados_id,
				pruebas_codigo,
				atletas_resultados_detalle_resultado,
				atletas_resultados_detalle_viento,
				atletas_resultados_detalle_manual,
				activo,
				usuario)
		VALUES(
			p_atletas_resultados_id,
			p_pruebas_codigo,
			p_atletas_resultados_detalle_resultado,
			p_atletas_resultados_detalle_viento,
			p_atletas_resultados_detalle_manual,
			p_activo,
			p_usuario);

		-- Ponemos el nuevo acumulado en el header
		UPDATE
			tb_atletas_resultados
		SET
			atletas_resultados_detalle_resultado =  (select sum(atletas_resultados_detalle_puntos) from tb_atletas_resultados_detalle  where atletas_resultados_id = p_atletas_resultados_id),
			usuario = p_usuario
		WHERE atletas_resultados_id = p_atletas_resultados_id ;


		RETURN 1;

	END IF;
END;
$$;


ALTER FUNCTION public.old_sp_atletas_resultados_detalle_save_record_old(p_atletas_resultados_detalle_id integer, p_atletas_resultados_id integer, p_pruebas_codigo character varying, p_atletas_resultados_detalle_resultado character varying, p_atletas_resultados_detalle_viento numeric, p_atletas_resultados_detalle_manual boolean, p_atletas_resultados_detalle_puntos integer, p_activo boolean, p_usuario character varying, p_version_id integer, p_is_update bit) OWNER TO atluser;

--
-- TOC entry 242 (class 1255 OID 16412)
-- Name: old_sp_atletas_resultados_save_record(integer, character varying, character varying, character varying, date, character varying, numeric, integer, boolean, boolean, character varying, character, boolean, boolean, character varying, integer, bit); Type: FUNCTION; Schema: public; Owner: atluser
--

CREATE FUNCTION old_sp_atletas_resultados_save_record(p_atletas_resultados_id integer, p_atletas_codigo character varying, p_competencias_codigo character varying, p_pruebas_codigo character varying, p_atletas_resultados_fecha date, p_atletas_resultados_resultado character varying, p_atletas_resultados_viento numeric, p_atletas_resultados_puesto integer, p_atletas_resultados_manual boolean, p_atletas_resultados_invalida boolean, p_atletas_resultados_observaciones character varying, p_atletas_resultados_origen character, p_atletas_resultados_protected boolean, p_activo boolean, p_usuario character varying, p_version_id integer, p_is_update bit) RETURNS integer
LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 08-10-2013

Stored procedure que agrega o actualiza los registros de los resultados de las pruebas.
Previamente hace todas las validaciones necesarias para garantizar que los datos sean grabados
consistentemente,


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

	select * from ( select sp_atletas_resultados_save_record(?,?,etc) as updins) as ans where updins is not null;

	de tal forma que retornara un registro si el update funciono o el insert , y 0 registros si no se realizo
	el uodate. sto es conveniente cuando se usa por ejemplo el affected_rows de algunos drivers.
	EN OTRAS BASES ESTO NO ES NECESARIO.

Historia : Creado 15-01-2014
*/
DECLARE v_prueba_multiple_new boolean= FALSE;
				DECLARE v_prueba_multiple_old boolean= FALSE;
				DECLARE v_pruebas_codigo_orig character varying(15);
				DECLARE v_categorias_codigo_orig character varying(15);
				DECLARE v_categorias_codigo_new character varying(15);
				DECLARE v_categorias_codigo_competencia character varying(15);
				DECLARE v_pruebas_sexo_orig  character(1);
				DECLARE v_pruebas_sexo_new  character(1);
				DECLARE v_atletas_sexo_new  character(1);
				DECLARE v_need_reconstruct boolean= FALSE;
				DECLARE v_currid integer=0;
				DECLARE v_atletas_fecha_nacimiento_new DATE;
				DECLARE v_apppruebas_marca_menor_new character varying(12);
				DECLARE v_apppruebas_marca_mayor_new character varying(12);
				DECLARE v_apppruebas_verifica_viento_new BOOLEAN = FALSE;
				DECLARE v_agnos INT;
				DECLARE v_marca_test integer;
				DECLARE v_unidad_medida_tipo_new character(1);
				DECLARE v_unidad_medida_codigo character varying(8);
				DECLARE v_competencias_fecha_inicio date;
				DECLARE v_competencias_fecha_final date;
				DECLARE v_atletas_resultados_resultado_old character varying(12);
				DECLARE v_marcaMenorValida integer;
				DECLARE v_marcaMayorValida integer;

BEGIN

	-----------------------------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------------
	-- VALIDACIONES PRIMARIAS DE INTEGRIDAD LOGICA
	-----------------------------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------------

	-- Busxcamos la categoria de la competencia, los datos de la prueba y del atleta
	-- basados en los datos actuales a grabar, esto no permitira saber si la relacion
	-- COmPETencia,PrueBA;ATLETA es correcta , digase si la competencia es de mayores
	-- la prueba debe ser de mayores y el atleta debe ser mayor, asi mismo si la prueba es para
	-- el sexo femenino , el atleta debe ser mujer
	SELECT categorias_codigo,competencias_fecha_inicio,competencias_fecha_final INTO
		v_categorias_codigo_competencia,v_competencias_fecha_inicio,v_competencias_fecha_final
	FROM tb_competencias where competencias_codigo=p_competencias_codigo;

	-- Verificamos primero si la fecha enviada esta entre las fechas de la competencia.
	IF p_atletas_resultados_fecha < v_competencias_fecha_inicio OR p_atletas_resultados_fecha > v_competencias_fecha_final
	THEN
		-- Excepcion La fecha esta fuera del rango de la competencia
		RAISE 'LA fecha indicada (%) no corresponde al rango de fechas de la competencia % - %',p_atletas_resultados_fecha,v_competencias_fecha_inicio,v_competencias_fecha_final USING ERRCODE = 'restrict_violation';
	END If;

	-- Buscamos los datos de la prueba que actualmente se quiere grabar para saber si tambien sera multiple.
	SELECT apppruebas_multiple,pr.categorias_codigo,pruebas_sexo,apppruebas_marca_menor,
		apppruebas_marca_mayor,apppruebas_verifica_viento,unidad_medida_tipo,c.unidad_medida_codigo INTO
		v_prueba_multiple_new,v_categorias_codigo_new,v_pruebas_sexo_new,v_apppruebas_marca_menor_new,
		v_apppruebas_marca_mayor_new,v_apppruebas_verifica_viento_new,v_unidad_medida_tipo_new,v_unidad_medida_codigo
	FROM tb_pruebas pr
		INNER JOIN tb_app_pruebas_values p ON p.apppruebas_codigo = pr.pruebas_generica_codigo
		INNER JOIN tb_pruebas_clasificacion c ON c.pruebas_clasificacion_codigo = p.pruebas_clasificacion_codigo
		inner join tb_unidad_medida um on um.unidad_medida_codigo = c.unidad_medida_codigo
	where pr.pruebas_codigo = p_pruebas_codigo;

	SELECT atletas_sexo,atletas_fecha_nacimiento INTO
		v_atletas_sexo_new,v_atletas_fecha_nacimiento_new
	FROM tb_atletas at
	where at.atletas_codigo = p_atletas_codigo;

	-- OBTENIDOS LOS DATOS VERIFICAMOS LA RELACION
	-- Primero si la  categoria de la prueba y competencia son validas.
	IF v_categorias_codigo_competencia != v_categorias_codigo_new
	THEN
		-- Excepcion no correspondencia de la categorias
		RAISE 'LA categoria de la competencia (%) no corresponde a la de la prueba (%) , ambas deben ser iguales',v_categorias_codigo_competencia,v_categorias_codigo_new USING ERRCODE = 'restrict_violation';
	END IF;

	-- Luego si el sexo del atleta y el sexo de la prueba corresponden.
	IF coalesce(v_atletas_sexo_new,'X') != coalesce(v_pruebas_sexo_new,'Y')
	THEN
		RAISE 'El sexo del atleta no corresponde a la de la prueba indicada, ambos deben ser iguales ' USING ERRCODE = 'restrict_violation';
	END IF;

	-- La mas dificil , si en la fecha de la prueba el atleta pertenecia a la categoria de
	-- la competencia. Para esto
	-- a) Que edad tenia el atleta en la fecha de la competencia.
	-- b) hasta que edad permite la categoria.
	select date_part( 'year'::text,p_atletas_resultados_fecha::date)-date_part( 'year'::text,v_atletas_fecha_nacimiento_new::date) INTO
		v_agnos;

	-- Veamos en la categoria si esta dentro del rango
	IF NOT EXISTS(SELECT 1 from tb_categorias WHERE categorias_codigo = v_categorias_codigo_competencia AND
																									v_agnos >= categorias_edad_inicial AND v_agnos <= categorias_edad_final )
	THEN
		-- Excepcion el atleta no esta dentro de la categoria
		RAISE 'Para la fecha % en que se realizo la prueba el atleta nacido el % , tendria % años no podria haber competido dentro de la categoria %',p_atletas_resultados_fecha,v_atletas_fecha_nacimiento_new,v_agnos,v_categorias_codigo_competencia USING ERRCODE = 'restrict_violation';
	END IF;

	-- Si el resultado de la prueba esta dentro de los valores validos
	------------------------------------------------------------------------------------
	-- Si la prueba a grabar no es multiple , esto ya que las combinadas no conocen el resultado
	-- hasta que se ingrese su detalle y es alli donde se valida, es por esto que este campo de resultado es
	-- actualizado durante la insercion de los detalles.
	IF v_prueba_multiple_new != TRUE -- OR (v_prueba_multiple_new = TRUE and p_is_update = '1')
	THEN
		-- Normalizamos a milisegundos , sin importar si es manual o no ya que ambas medidas deben estar en las mismas
		-- tipo de unidad o ambas son manuales o ambas electronicas. Los otros tipos de puntaje a centimetros o puntos
		-- normalizados.
		v_marcaMenorValida := fn_get_marca_normalizada(v_apppruebas_marca_menor_new, v_unidad_medida_codigo, false, 0);
		v_marcaMayorValida := fn_get_marca_normalizada(v_apppruebas_marca_mayor_new, v_unidad_medida_codigo, false, 0);
		v_marca_test := fn_get_marca_normalizada(p_atletas_resultados_resultado, v_unidad_medida_codigo, false, 0);

		IF v_marca_test < v_marcaMenorValida OR v_marca_test > v_marcaMayorValida
		THEN
			--La marca indicada esta fuera del rango permitido
			RAISE 'La marca indicada de % esta fuera del rango permitido entre % y % ', p_atletas_resultados_resultado,v_apppruebas_marca_menor_new,v_apppruebas_marca_mayor_new USING ERRCODE = 'restrict_violation';
		END IF;
	END IF;


	-----------------------------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------------
	-- OK paso todas las validaciones basicas , ahora veamos si la prueba tiene control de viento y ver si el viento esta indicado.
	IF v_apppruebas_verifica_viento_new = TRUE
	THEN
		IF p_atletas_resultados_viento is null
		THEN
			-- La prueba requiere se indique el viento
			RAISE 'La prueba requiere se indique el limite de viento'  USING ERRCODE = 'restrict_violation';
		END IF;
	ELSE
		-- Si no requiere viento lo ponemos en null , por si acaso se envie dato por gusto.
		p_atletas_resultados_viento := NULL;
	END IF;

	-- Si la unidad de medida de la prueba no es tiempo
	-- se blanquea (false) al campo que indica si la medida manual.
	IF v_unidad_medida_tipo_new != 'T'
	THEN
		p_atletas_resultados_manual := false;
	END IF;

	IF p_is_update = '1'
	THEN
		-- Durante un update si La prueba deja de ser multiple , se eliminan
		-- los detalles.
		IF coalesce(v_prueba_multiple_new,false) = FALSE
		THEN
			-- Si la prueba no es multiple eliminamos cualquier prueba asociada , para el caso
			-- que pase de multiple a simple.
			DELETE FROM tb_atletas_resultados_detalle where  atletas_resultados_id = p_atletas_resultados_id;
		ELSE

			-- Buscamos los datos actualmente grabado.
			SELECT pr.pruebas_codigo,pr.categorias_codigo,pr.pruebas_sexo,apppruebas_multiple,atletas_resultados_resultado INTO
				v_pruebas_codigo_orig,v_categorias_codigo_orig,v_pruebas_sexo_orig,v_prueba_multiple_old,
				v_atletas_resultados_resultado_old
			FROM tb_atletas_resultados ar
				INNER JOIN tb_pruebas pr on pr.pruebas_codigo = ar.pruebas_codigo
				INNER JOIN tb_app_pruebas_values p ON p.apppruebas_codigo = pr.pruebas_generica_codigo
			WHERE atletas_resultados_id = p_atletas_resultados_id;


			-- A ver:
			-- 1) Si la prueba anterior era multiple y la actual es multiple, verificamos que sean el mismo codigo
			--    de no serlo hay que eliminar los detalles previos e insertar los correspondientes a la nueva prueba
			--    multiple.
			-- 2) Si la antigua no era multiple y la actual es multiple debemos tambien insertar los que
			-- corresponden a la nueva combinada.
			IF v_prueba_multiple_old= TRUE AND v_prueba_multiple_new = TRUE AND v_pruebas_codigo_orig != p_pruebas_codigo
			THEN
				v_need_reconstruct := TRUE;
			ELSE IF v_prueba_multiple_old= FALSE AND v_prueba_multiple_new = TRUE
			THEN
				v_need_reconstruct := TRUE;
			END IF;

			END IF;



			-- 2) Si la categoria o sexo han cambiado y es multiple deberemos eliminar lo anterior y agregar los nuevos
			--    que corresponden.
			IF v_categorias_codigo_orig !=v_categorias_codigo_new OR v_pruebas_sexo_orig != v_pruebas_sexo_new
			THEN
				v_need_reconstruct := TRUE;
			END IF;

		END IF;

		-- El  update
		-- Si aun no tienen items , hacemos el update con verificacion si ha cambios externos
		-- (uso el xmin) de lo ocontrario no , el caso es que cuando se agrega un item el total de la prueba
		-- es modificado sobre este registro , por ende el xmin estara cambiado si desde una misma pantalla
		-- se actualizan los detalles y luego se quiere actualizar el header, como esto no es predecible
		-- en este momento he decidido relajar el chequeo de modificacion cuando ya existan detalles de resultado
		-- . esto solo se da en el caso de pruebas multiples.
		IF NOT EXISTS (SELECT 1 FROM tb_atletas_resultados_detalle WHERE atletas_resultados_id = p_atletas_resultados_id)
		THEN
			UPDATE
				tb_atletas_resultados
			SET
				atletas_resultados_id = p_atletas_resultados_id,
				atletas_codigo =  p_atletas_codigo,
				competencias_codigo =  p_competencias_codigo,
				pruebas_codigo =  p_pruebas_codigo,
				atletas_resultados_fecha =  p_atletas_resultados_fecha,
				-- Si la prueba es multiple el update no modifica el valor del resultado ya que este es actualizado
				-- cada vez que se inserta o modifica un detalle , de lo contrario si se actualiza de acuerdo al parametro
				atletas_resultados_resultado =  (case when v_prueba_multiple_new = true then v_atletas_resultados_resultado_old else p_atletas_resultados_resultado end),
				atletas_resultados_viento =  p_atletas_resultados_viento,
				atletas_resultados_puesto =  p_atletas_resultados_puesto,
				atletas_resultados_manual =  p_atletas_resultados_manual,
				atletas_resultados_invalida =  p_atletas_resultados_invalida,
				atletas_resultados_observaciones =  p_atletas_resultados_observaciones,
				atletas_resultados_origen =  p_atletas_resultados_origen,
				atletas_resultados_protected =  p_atletas_resultados_protected,
				activo = p_activo,
				usuario = p_usuario
			WHERE atletas_resultados_id = p_atletas_resultados_id and xmin =p_version_id ;
		ELSE
			UPDATE
				tb_atletas_resultados
			SET
				atletas_resultados_id = p_atletas_resultados_id,
				atletas_codigo =  p_atletas_codigo,
				competencias_codigo =  p_competencias_codigo,
				pruebas_codigo =  p_pruebas_codigo,
				atletas_resultados_fecha =  p_atletas_resultados_fecha,
				-- Si la prueba es multiple el update no modifica el valor del resultado ya que este es actualizado
				-- cada vez que se inserta o modifica un detalle , de lo contrario si se actualiza de acuerdo al parametro
				atletas_resultados_resultado =  (case when v_prueba_multiple_new = true then v_atletas_resultados_resultado_old else p_atletas_resultados_resultado end),
				atletas_resultados_viento =  p_atletas_resultados_viento,
				atletas_resultados_puesto =  p_atletas_resultados_puesto,
				atletas_resultados_manual =  p_atletas_resultados_manual,
				atletas_resultados_invalida =  p_atletas_resultados_invalida,
				atletas_resultados_observaciones =  p_atletas_resultados_observaciones,
				atletas_resultados_origen =  p_atletas_resultados_origen,
				atletas_resultados_protected =  p_atletas_resultados_protected,
				activo = p_activo,
				usuario = p_usuario
			WHERE atletas_resultados_id = p_atletas_resultados_id ;
		END IF;
		RAISE NOTICE  'COUNT ID --> %', FOUND;

		-- Todo ok , si se necesita agregar los detalles lo hacemos
		IF FOUND THEN
			-- Se grabo , vemos el tema de los detalles
			-- OK si se necesita reconstruccion , eliminamos primero y liego agregamos al detalle las nuevas pruebas
			-- correspondientes a la nueva prueba combinada.
			IF v_need_reconstruct = TRUE
			THEN
				DELETE FROM tb_atletas_resultados_detalle where  atletas_resultados_id = p_atletas_resultados_id;

				-- Iniciamos el insert de todas las pruebas
				INSERT INTO tb_atletas_resultados_detalle (
					atletas_resultados_id,
					pruebas_codigo,
					atletas_resultados_detalle_resultado,
					atletas_resultados_detalle_viento,
					atletas_resultados_detalle_manual,
					atletas_resultados_detalle_puntos)
					SELECT
						p_atletas_resultados_id,
						pd.pruebas_detalle_prueba_codigo,
						0,
						0,
						false,
						0
					FROM tb_pruebas_detalle pd
					WHERE pd.pruebas_codigo = p_pruebas_codigo
					ORDER by pd.pruebas_detalle_orden;
			END IF;

			RETURN 1;
		ELSE
			RAISE '' USING ERRCODE = 'record modified';
			RETURN null;
		END IF;
	ELSE
		INSERT INTO
			tb_atletas_resultados
			(
				atletas_codigo,
				competencias_codigo,
				pruebas_codigo,
				atletas_resultados_fecha,
				atletas_resultados_resultado,
				atletas_resultados_viento,
				atletas_resultados_puesto,
				atletas_resultados_manual,
				atletas_resultados_invalida,
				atletas_resultados_observaciones,
				atletas_resultados_origen,
				atletas_resultados_protected,
				activo,
				usuario)
		VALUES(
			p_atletas_codigo,
			p_competencias_codigo,
			p_pruebas_codigo,
			p_atletas_resultados_fecha,
			p_atletas_resultados_resultado,
			p_atletas_resultados_viento,
			p_atletas_resultados_puesto,
			p_atletas_resultados_manual,
			p_atletas_resultados_invalida,
			p_atletas_resultados_observaciones,
			p_atletas_resultados_origen,
			p_atletas_resultados_protected,
			p_activo,
			p_usuario);


		SELECT currval(pg_get_serial_sequence('tb_atletas_resultados', 'atletas_resultados_id'))
		INTO v_currid;

		-- Durante un add si La prueba es multiple , se agregan los detalles correspondientes.
		IF coalesce(v_prueba_multiple_new,false) = TRUE
		THEN
			-- Iniciamos el insert de todas las pruebas que componen la mltiple o combinada
			INSERT INTO tb_atletas_resultados_detalle (
				atletas_resultados_id,
				pruebas_codigo,
				atletas_resultados_detalle_resultado,
				atletas_resultados_detalle_viento,
				atletas_resultados_detalle_manual,
				atletas_resultados_detalle_puntos)
				SELECT
					v_currid,
					pd.pruebas_detalle_prueba_codigo,
					0,
					0,
					false,
					0
				FROM tb_pruebas_detalle pd
				WHERE pd.pruebas_codigo = p_pruebas_codigo
				ORDER BY pd.pruebas_detalle_orden;
		END IF;

		RETURN 1;

	END IF;
END;
$$;


ALTER FUNCTION public.old_sp_atletas_resultados_save_record(p_atletas_resultados_id integer, p_atletas_codigo character varying, p_competencias_codigo character varying, p_pruebas_codigo character varying, p_atletas_resultados_fecha date, p_atletas_resultados_resultado character varying, p_atletas_resultados_viento numeric, p_atletas_resultados_puesto integer, p_atletas_resultados_manual boolean, p_atletas_resultados_invalida boolean, p_atletas_resultados_observaciones character varying, p_atletas_resultados_origen character, p_atletas_resultados_protected boolean, p_activo boolean, p_usuario character varying, p_version_id integer, p_is_update bit) OWNER TO atluser;

--
-- TOC entry 243 (class 1255 OID 16415)
-- Name: old_sp_atletas_resultados_save_record_old(integer, character varying, character varying, character varying, date, character varying, numeric, integer, boolean, boolean, boolean, character varying, character, boolean, boolean, character varying, integer, bit); Type: FUNCTION; Schema: public; Owner: atluser
--

CREATE FUNCTION old_sp_atletas_resultados_save_record_old(p_atletas_resultados_id integer, p_atletas_codigo character varying, p_competencias_codigo character varying, p_pruebas_codigo character varying, p_atletas_resultados_fecha date, p_atletas_resultados_resultado character varying, p_atletas_resultados_viento numeric, p_atletas_resultados_puesto integer, p_atletas_resultados_manual boolean, p_atletas_resultados_altura boolean, p_atletas_resultados_invalida boolean, p_atletas_resultados_observaciones character varying, p_atletas_resultados_origen character, p_atletas_resultados_protected boolean, p_activo boolean, p_usuario character varying, p_version_id integer, p_is_update bit) RETURNS integer
LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 08-10-2013

Stored procedure que agrega o actualiza los registros de los resultados de las pruebas.
Previamente hace todas las validaciones necesarias para garantizar que los datos sean grabados
consistentemente,


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

	select * from ( select sp_atletas_resultados_save_record(?,?,etc) as updins) as ans where updins is not null;

	de tal forma que retornara un registro si el update funciono o el insert , y 0 registros si no se realizo
	el uodate. sto es conveniente cuando se usa por ejemplo el affected_rows de algunos drivers.
	EN OTRAS BASES ESTO NO ES NECESARIO.

Historia : Creado 15-01-2014
*/
DECLARE v_prueba_multiple_new boolean= FALSE;
				DECLARE v_prueba_multiple_old boolean= FALSE;
				DECLARE v_pruebas_codigo_orig character varying(15);
				DECLARE v_categorias_codigo_orig character varying(15);
				DECLARE v_categorias_codigo_new character varying(15);
				DECLARE v_categorias_codigo_competencia character varying(15);
				DECLARE v_pruebas_sexo_orig  character(1);
				DECLARE v_pruebas_sexo_new  character(1);
				DECLARE v_atletas_sexo_new  character(1);
				DECLARE v_need_reconstruct boolean= FALSE;
				DECLARE v_currid integer=0;
				DECLARE v_atletas_fecha_nacimiento_new DATE;
				DECLARE v_apppruebas_marca_menor_new character varying(12);
				DECLARE v_apppruebas_marca_mayor_new character varying(12);
				DECLARE v_apppruebas_verifica_viento_new BOOLEAN = FALSE;
				DECLARE v_agnos INT;
				DECLARE v_marca_test integer;
				DECLARE v_unidad_medida_tipo_new character(1);
				DECLARE v_unidad_medida_codigo character varying(8);
				DECLARE v_competencias_fecha_inicio date;
				DECLARE v_competencias_fecha_final date;
				DECLARE v_atletas_resultados_resultado_old character varying(12);
				DECLARE v_marcaMenorValida integer;
				DECLARE v_marcaMayorValida integer;

BEGIN

	-----------------------------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------------
	-- VALIDACIONES PRIMARIAS DE INTEGRIDAD LOGICA
	-----------------------------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------------

	-- Busxcamos la categoria de la competencia, los datos de la prueba y del atleta
	-- basados en los datos actuales a grabar, esto no permitira saber si la relacion
	-- COmPETencia,PrueBA;ATLETA es correcta , digase si la competencia es de mayores
	-- la prueba debe ser de mayores y el atleta debe ser mayor, asi mismo si la prueba es para
	-- el sexo femenino , el atleta debe ser mujer
	SELECT categorias_codigo,competencias_fecha_inicio,competencias_fecha_final INTO
		v_categorias_codigo_competencia,v_competencias_fecha_inicio,v_competencias_fecha_final
	FROM tb_competencias where competencias_codigo=p_competencias_codigo;

	-- Verificamos primero si la fecha enviada esta entre las fechas de la competencia.
	IF p_atletas_resultados_fecha < v_competencias_fecha_inicio OR p_atletas_resultados_fecha > v_competencias_fecha_final
	THEN
		-- Excepcion La fecha esta fuera del rango de la competencia
		RAISE 'LA fecha indicada (%) no corresponde al rango de fechas de la competencia % - %',p_atletas_resultados_fecha,v_competencias_fecha_inicio,v_competencias_fecha_final USING ERRCODE = 'restrict_violation';
	END If;

	-- Buscamos los datos de la prueba que actualmente se quiere grabar para saber si tambien sera multiple.
	SELECT apppruebas_multiple,pr.categorias_codigo,pruebas_sexo,apppruebas_marca_menor,
		apppruebas_marca_mayor,apppruebas_verifica_viento,unidad_medida_tipo,c.unidad_medida_codigo INTO
		v_prueba_multiple_new,v_categorias_codigo_new,v_pruebas_sexo_new,v_apppruebas_marca_menor_new,
		v_apppruebas_marca_mayor_new,v_apppruebas_verifica_viento_new,v_unidad_medida_tipo_new,v_unidad_medida_codigo
	FROM tb_pruebas pr
		INNER JOIN tb_app_pruebas_values p ON p.apppruebas_codigo = pr.pruebas_generica_codigo
		INNER JOIN tb_pruebas_clasificacion c ON c.pruebas_clasificacion_codigo = p.pruebas_clasificacion_codigo
		inner join tb_unidad_medida um on um.unidad_medida_codigo = c.unidad_medida_codigo
	where pr.pruebas_codigo = p_pruebas_codigo;

	SELECT atletas_sexo,atletas_fecha_nacimiento INTO
		v_atletas_sexo_new,v_atletas_fecha_nacimiento_new
	FROM tb_atletas at
	where at.atletas_codigo = p_atletas_codigo;

	-- OBTENIDOS LOS DATOS VERIFICAMOS LA RELACION
	-- Primero si la  categoria de la prueba y competencia son validas.
	IF v_categorias_codigo_competencia != v_categorias_codigo_new
	THEN
		-- Excepcion no correspondencia de la categorias
		RAISE 'LA categoria de la competencia (%) no corresponde a la de la prueba (%) , ambas deben ser iguales',v_categorias_codigo_competencia,v_categorias_codigo_new USING ERRCODE = 'restrict_violation';
	END IF;

	-- Luego si el sexo del atleta y el sexo de la prueba corresponden.
	IF coalesce(v_atletas_sexo_new,'X') != coalesce(v_pruebas_sexo_new,'Y')
	THEN
		RAISE 'El sexo del atleta no corresponde a la de la prueba indicada, ambos deben ser iguales ' USING ERRCODE = 'restrict_violation';
	END IF;

	-- La mas dificil , si en la fecha de la prueba el atleta pertenecia a la categoria de
	-- la competencia. Para esto
	-- a) Que edad tenia el atleta en la fecha de la competencia.
	-- b) hasta que edad permite la categoria.
	select date_part( 'year'::text,p_atletas_resultados_fecha::date)-date_part( 'year'::text,v_atletas_fecha_nacimiento_new::date) INTO
		v_agnos;

	-- Veamos en la categoria si esta dentro del rango
	IF NOT EXISTS(SELECT 1 from tb_categorias WHERE categorias_codigo = v_categorias_codigo_competencia AND
																									v_agnos >= categorias_edad_inicial AND v_agnos <= categorias_edad_final )
	THEN
		-- Excepcion el atleta no esta dentro de la categoria
		RAISE 'Para la fecha % en que se realizo la prueba el atleta nacido el % , tendria % años no podria haber competido dentro de la categoria %',p_atletas_resultados_fecha,v_atletas_fecha_nacimiento_new,v_agnos,v_categorias_codigo_competencia USING ERRCODE = 'restrict_violation';
	END IF;

	-- Si el resultado de la prueba esta dentro de los valores validos
	------------------------------------------------------------------------------------
	-- Si la prueba a grabar no es multiple , esto ya que las combinadas no conocen el resultado
	-- hasta que se ingrese su detalle y es alli donde se valida, es por esto que este campo de resultado es
	-- actualizado durante la insercion de los detalles.
	IF v_prueba_multiple_new != TRUE -- OR (v_prueba_multiple_new = TRUE and p_is_update = '1')
	THEN
		-- Normalizamos a milisegundos , sin importar si es manual o no ya que ambas medidas deben estar en las mismas
		-- tipo de unidad o ambas son manuales o ambas electronicas. Los otros tipos de puntaje a centimetros o puntos
		-- normalizados.
		v_marcaMenorValida := fn_get_marca_normalizada(v_apppruebas_marca_menor_new, v_unidad_medida_codigo, false, 0);
		v_marcaMayorValida := fn_get_marca_normalizada(v_apppruebas_marca_mayor_new, v_unidad_medida_codigo, false, 0);
		v_marca_test := fn_get_marca_normalizada(p_atletas_resultados_resultado, v_unidad_medida_codigo, false, 0);
		RAISE 'La marca indicada de % esta fuera del rango permitido entre % y % ', p_atletas_resultados_resultado,v_apppruebas_marca_menor_new,v_apppruebas_marca_mayor_new USING ERRCODE = 'restrict_violation';

		IF v_marca_test < v_marcaMenorValida OR v_marca_test > v_marcaMayorValida
		THEN
			--La marca indicada esta fuera del rango permitido
			RAISE 'La marca indicada de % esta fuera del rango permitido entre % y % ', p_atletas_resultados_resultado,v_apppruebas_marca_menor_new,v_apppruebas_marca_mayor_new USING ERRCODE = 'restrict_violation';
		END IF;
	END IF;


	-----------------------------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------------
	-- OK paso todas las validaciones basicas , ahora veamos si la prueba tiene control de viento y ver si el viento esta indicado.
	IF v_apppruebas_verifica_viento_new = TRUE
	THEN
		IF p_atletas_resultados_viento is null
		THEN
			-- La prueba requiere se indique el viento
			RAISE 'La prueba requiere se indique el limite de viento'  USING ERRCODE = 'restrict_violation';
		END IF;
	ELSE
		-- Si no requiere viento lo ponemos en null , por si acaso se envie dato por gusto.
		p_atletas_resultados_viento := NULL;
	END IF;

	-- Si la unidad de medida de la prueba no es tiempo
	-- se blanquea (false) al campo que indica si la medida manual.
	IF v_unidad_medida_tipo_new != 'T'
	THEN
		p_atletas_resultados_manual := false;
	END IF;

	IF p_is_update = '1'
	THEN
		-- Durante un update si La prueba deja de ser multiple , se eliminan
		-- los detalles.
		IF coalesce(v_prueba_multiple_new,false) = FALSE
		THEN
			-- Si la prueba no es multiple eliminamos cualquier prueba asociada , para el caso
			-- que pase de multiple a simple.
			DELETE FROM tb_atletas_resultados_detalle where  atletas_resultados_id = p_atletas_resultados_id;
		ELSE

			-- Buscamos los datos actualmente grabado.
			SELECT pr.pruebas_codigo,pr.categorias_codigo,pr.pruebas_sexo,apppruebas_multiple,atletas_resultados_resultado INTO
				v_pruebas_codigo_orig,v_categorias_codigo_orig,v_pruebas_sexo_orig,v_prueba_multiple_old,
				v_atletas_resultados_resultado_old
			FROM tb_atletas_resultados ar
				INNER JOIN tb_pruebas pr on pr.pruebas_codigo = ar.pruebas_codigo
				INNER JOIN tb_app_pruebas_values p ON p.apppruebas_codigo = pr.pruebas_generica_codigo
			WHERE atletas_resultados_id = p_atletas_resultados_id;


			-- A ver:
			-- 1) Si la prueba anterior era multiple y la actual es multiple, verificamos que sean el mismo codigo
			--    de no serlo hay que eliminar los detalles previos e insertar los correspondientes a la nueva prueba
			--    multiple.
			-- 2) Si la antigua no era multiple y la actual es multiple debemos tambien insertar los que
			-- corresponden a la nueva combinada.
			IF v_prueba_multiple_old= TRUE AND v_prueba_multiple_new = TRUE AND v_pruebas_codigo_orig != p_pruebas_codigo
			THEN
				v_need_reconstruct := TRUE;
			ELSE IF v_prueba_multiple_old= FALSE AND v_prueba_multiple_new = TRUE
			THEN
				v_need_reconstruct := TRUE;
			END IF;

			END IF;



			-- 2) Si la categoria o sexo han cambiado y es multiple deberemos eliminar lo anterior y agregar los nuevos
			--    que corresponden.
			IF v_categorias_codigo_orig !=v_categorias_codigo_new OR v_pruebas_sexo_orig != v_pruebas_sexo_new
			THEN
				v_need_reconstruct := TRUE;
			END IF;

		END IF;

		-- El  update
		-- Si aun no tienen items , hacemos el update con verificacion si ha cambios externos
		-- (uso el xmin) de lo ocontrario no , el caso es que cuando se agrega un item el total de la prueba
		-- es modificado sobre este registro , por ende el xmin estara cambiado si desde una misma pantalla
		-- se actualizan los detalles y luego se quiere actualizar el header, como esto no es predecible
		-- en este momento he decidido relajar el chequeo de modificacion cuando ya existan detalles de resultado
		-- . esto solo se da en el caso de pruebas multiples.
		IF NOT EXISTS (SELECT 1 FROM tb_atletas_resultados_detalle WHERE atletas_resultados_id = p_atletas_resultados_id)
		THEN
			UPDATE
				tb_atletas_resultados
			SET
				atletas_resultados_id = p_atletas_resultados_id,
				atletas_codigo =  p_atletas_codigo,
				competencias_codigo =  p_competencias_codigo,
				pruebas_codigo =  p_pruebas_codigo,
				atletas_resultados_fecha =  p_atletas_resultados_fecha,
				-- Si la prueba es multiple el update no modifica el valor del resultado ya que este es actualizado
				-- cada vez que se inserta o modifica un detalle , de lo contrario si se actualiza de acuerdo al parametro
				atletas_resultados_resultado =  (case when v_prueba_multiple_new = true then v_atletas_resultados_resultado_old else p_atletas_resultados_resultado end),
				atletas_resultados_viento =  p_atletas_resultados_viento,
				atletas_resultados_puesto =  p_atletas_resultados_puesto,
				atletas_resultados_manual =  p_atletas_resultados_manual,
				atletas_resultados_altura =  p_atletas_resultados_altura,
				atletas_resultados_invalida =  p_atletas_resultados_invalida,
				atletas_resultados_observaciones =  p_atletas_resultados_observaciones,
				atletas_resultados_origen =  p_atletas_resultados_origen,
				atletas_resultados_protected =  p_atletas_resultados_protected,
				activo = p_activo,
				usuario = p_usuario
			WHERE atletas_resultados_id = p_atletas_resultados_id and xmin =p_version_id ;
		ELSE
			UPDATE
				tb_atletas_resultados
			SET
				atletas_resultados_id = p_atletas_resultados_id,
				atletas_codigo =  p_atletas_codigo,
				competencias_codigo =  p_competencias_codigo,
				pruebas_codigo =  p_pruebas_codigo,
				atletas_resultados_fecha =  p_atletas_resultados_fecha,
				-- Si la prueba es multiple el update no modifica el valor del resultado ya que este es actualizado
				-- cada vez que se inserta o modifica un detalle , de lo contrario si se actualiza de acuerdo al parametro
				atletas_resultados_resultado =  (case when v_prueba_multiple_new = true then v_atletas_resultados_resultado_old else p_atletas_resultados_resultado end),
				atletas_resultados_viento =  p_atletas_resultados_viento,
				atletas_resultados_puesto =  p_atletas_resultados_puesto,
				atletas_resultados_manual =  p_atletas_resultados_manual,
				atletas_resultados_altura =  p_atletas_resultados_altura,
				atletas_resultados_invalida =  p_atletas_resultados_invalida,
				atletas_resultados_observaciones =  p_atletas_resultados_observaciones,
				atletas_resultados_origen =  p_atletas_resultados_origen,
				atletas_resultados_protected =  p_atletas_resultados_protected,
				activo = p_activo,
				usuario = p_usuario
			WHERE atletas_resultados_id = p_atletas_resultados_id ;
		END IF;
		RAISE NOTICE  'COUNT ID --> %', FOUND;

		-- Todo ok , si se necesita agregar los detalles lo hacemos
		IF FOUND THEN
			-- Se grabo , vemos el tema de los detalles
			-- OK si se necesita reconstruccion , eliminamos primero y liego agregamos al detalle las nuevas pruebas
			-- correspondientes a la nueva prueba combinada.
			IF v_need_reconstruct = TRUE
			THEN
				DELETE FROM tb_atletas_resultados_detalle where  atletas_resultados_id = p_atletas_resultados_id;

				-- Iniciamos el insert de todas las pruebas
				INSERT INTO tb_atletas_resultados_detalle (
					atletas_resultados_id,
					pruebas_codigo,
					atletas_resultados_detalle_resultado,
					atletas_resultados_detalle_viento,
					atletas_resultados_detalle_manual,
					atletas_resultados_detalle_puntos)
					SELECT
						p_atletas_resultados_id,
						pd.pruebas_detalle_prueba_codigo,
						0,
						0,
						false,
						0
					FROM tb_pruebas_detalle pd
					WHERE pd.pruebas_codigo = p_pruebas_codigo
					ORDER by pd.pruebas_detalle_orden;
			END IF;

			RETURN 1;
		ELSE
			RAISE '' USING ERRCODE = 'record modified';
			RETURN null;
		END IF;
	ELSE
		INSERT INTO
			tb_atletas_resultados
			(
				atletas_codigo,
				competencias_codigo,
				pruebas_codigo,
				atletas_resultados_fecha,
				atletas_resultados_resultado,
				atletas_resultados_viento,
				atletas_resultados_puesto,
				atletas_resultados_manual,
				atletas_resultados_altura,
				atletas_resultados_invalida,
				atletas_resultados_observaciones,
				atletas_resultados_origen,
				atletas_resultados_protected,
				activo,
				usuario)
		VALUES(
			p_atletas_codigo,
			p_competencias_codigo,
			p_pruebas_codigo,
			p_atletas_resultados_fecha,
			p_atletas_resultados_resultado,
			p_atletas_resultados_viento,
			p_atletas_resultados_puesto,
			p_atletas_resultados_manual,
			p_atletas_resultados_altura,
			p_atletas_resultados_invalida,
			p_atletas_resultados_observaciones,
			p_atletas_resultados_origen,
			p_atletas_resultados_protected,
			p_activo,
			p_usuario);


		SELECT currval(pg_get_serial_sequence('tb_atletas_resultados', 'atletas_resultados_id'))
		INTO v_currid;

		-- Durante un add si La prueba es multiple , se agregan los detalles correspondientes.
		IF coalesce(v_prueba_multiple_new,false) = TRUE
		THEN
			-- Iniciamos el insert de todas las pruebas que componen la mltiple o combinada
			INSERT INTO tb_atletas_resultados_detalle (
				atletas_resultados_id,
				pruebas_codigo,
				atletas_resultados_detalle_resultado,
				atletas_resultados_detalle_viento,
				atletas_resultados_detalle_manual,
				atletas_resultados_detalle_puntos)
				SELECT
					v_currid,
					pd.pruebas_detalle_prueba_codigo,
					0,
					0,
					false,
					0
				FROM tb_pruebas_detalle pd
				WHERE pd.pruebas_codigo = p_pruebas_codigo
				ORDER BY pd.pruebas_detalle_orden;
		END IF;

		RETURN 1;

	END IF;
END;
$$;


ALTER FUNCTION public.old_sp_atletas_resultados_save_record_old(p_atletas_resultados_id integer, p_atletas_codigo character varying, p_competencias_codigo character varying, p_pruebas_codigo character varying, p_atletas_resultados_fecha date, p_atletas_resultados_resultado character varying, p_atletas_resultados_viento numeric, p_atletas_resultados_puesto integer, p_atletas_resultados_manual boolean, p_atletas_resultados_altura boolean, p_atletas_resultados_invalida boolean, p_atletas_resultados_observaciones character varying, p_atletas_resultados_origen character, p_atletas_resultados_protected boolean, p_activo boolean, p_usuario character varying, p_version_id integer, p_is_update bit) OWNER TO atluser;

--
-- TOC entry 272 (class 1255 OID 16460)
-- Name: old_sp_pruebas_atletas_resultados_save_record(integer, character varying, character varying, character varying, boolean, date, numeric, character varying, integer, boolean, boolean, boolean, character varying, character varying, integer, integer, boolean, boolean, boolean, character varying, integer, bit); Type: FUNCTION; Schema: public; Owner: atluser
--

CREATE FUNCTION old_sp_pruebas_atletas_resultados_save_record(p_atletas_resultados_id integer, p_atletas_codigo character varying, p_competencias_codigo character varying, p_pruebas_codigo character varying, p_competencias_pruebas_origen_combinada boolean, p_competencias_pruebas_fecha date, p_competencias_pruebas_viento numeric, p_competencias_pruebas_tipo_serie character varying, p_competencias_pruebas_nro_serie integer, p_competencias_pruebas_anemometro boolean, p_competencias_pruebas_material_reglamentario boolean, p_competencias_pruebas_manual boolean, p_competencias_pruebas_observaciones character varying, p_atletas_resultados_resultado character varying, p_atletas_resultados_puntos integer, p_atletas_resultados_puesto integer, p_atletas_resultados_invalida boolean, p_atletas_resultados_protected boolean, p_activo boolean, p_usuario character varying, p_version_id integer, p_is_update bit) RETURNS integer
LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 08-10-2013

Stored procedure que agrega o actualiza los registros de los resultados de las pruebas, pero
ADEMAS agrega las pruebas de no existir, basicamente debe ser usado si se desea agregar o actualizar
un resultado de un atleta , pero condicionado a que la prueba exista , en otras palabras
para agregar un resultado este sp asegura que la prueba deba existir.

ALGUNOS DATOS DE LA PRUEBA PUEDEN TAMBIEN SER MODIFICADOS, ESTE SP ES UTIL CUANDO LOS RESULTADOS
SE AGREGAN DIRECTAMENTE A UN ATLETA, Y NO POR EL LADO DE LAS COMPETENCIAS.

Previamente hace todas las validaciones necesarias para garantizar que los datos sean grabados
consistentemente,


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

	select * from ( select sp_pruebas_atletas_resultados_save_record(?,?,etc) as updins) as ans where updins is not null;

	de tal forma que retornara un registro si el update funciono o el insert , y 0 registros si no se realizo
	el uodate. sto es conveniente cuando se usa por ejemplo el affected_rows de algunos drivers.
	EN OTRAS BASES ESTO NO ES NECESARIO.

Historia : Creado 15-01-2014
*/
DECLARE v_prueba_multiple_new boolean= FALSE;
				DECLARE v_prueba_multiple_old boolean= FALSE;
				DECLARE v_pruebas_codigo_orig character varying(15);
				DECLARE v_categorias_codigo_competencia character varying(15);
				DECLARE v_pruebas_sexo_new  character(1);
				DECLARE v_atletas_sexo_new  character(1);
				DECLARE v_currid integer=0;
				DECLARE v_atletas_fecha_nacimiento_new DATE;
				DECLARE v_apppruebas_marca_menor_new character varying(12);
				DECLARE v_apppruebas_marca_mayor_new character varying(12);
				DECLARE v_agnos INT;
				DECLARE v_marca_test integer;
				DECLARE v_unidad_medida_codigo character varying(8);
				DECLARE v_atletas_resultados_resultado_old character varying(12);
				DECLARE v_marcaMenorValida integer;
				DECLARE v_marcaMayorValida integer;
				DECLARE v_competencias_pruebas_origen_id integer;
				DECLARE v_competencias_pruebas_id integer;
				DECLARE v_prueba_saved integer=0;
				DECLARE v_isFromCombinada boolean := false;

BEGIN

	-----------------------------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------------
	-- VALIDACIONES PRIMARIAS DE INTEGRIDAD LOGICA
	-----------------------------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------------

	-- Busxcamos la categoria de la competencia, los datos de la prueba y del atleta
	-- basados en los datos actuales a grabar, esto no permitira saber si la relacion
	-- COmPETencia,PrueBA;ATLETA es correcta , digase si la competencia es de mayores
	-- la prueba debe ser de mayores y el atleta debe ser mayor, asi mismo si la prueba es para
	-- el sexo femenino , el atleta debe ser mujer
	SELECT categorias_codigo,competencias_fecha_inicio,competencias_fecha_final INTO
		v_categorias_codigo_competencia
	FROM tb_competencias where competencias_codigo=p_competencias_codigo;


	-- Buscamos los datos de la gnerica de prueba que actualmente se quiere grabar para saber si tambien sera multiple.
	SELECT apppruebas_multiple,pruebas_sexo,apppruebas_marca_menor,
		apppruebas_marca_mayor,c.unidad_medida_codigo
	INTO
		v_prueba_multiple_new,v_pruebas_sexo_new,v_apppruebas_marca_menor_new,
		v_apppruebas_marca_mayor_new,v_unidad_medida_codigo
	FROM tb_pruebas pr
		INNER JOIN tb_app_pruebas_values p ON p.apppruebas_codigo = pr.pruebas_generica_codigo
		INNER JOIN tb_pruebas_clasificacion c ON c.pruebas_clasificacion_codigo = p.pruebas_clasificacion_codigo
	where pr.pruebas_codigo = p_pruebas_codigo;

	-- Se busca el sexo del atleta
	SELECT atletas_sexo,atletas_fecha_nacimiento INTO
		v_atletas_sexo_new,v_atletas_fecha_nacimiento_new
	FROM tb_atletas at
	where at.atletas_codigo = p_atletas_codigo;

	--	raise notice 'v_atletas_sexo_new: %',v_atletas_sexo_new;
	--	raise notice 'v_pruebas_sexo_new: %',v_pruebas_sexo_new;

	-- Luego si el sexo del atleta y el sexo de la prueba corresponden.
	IF coalesce(v_atletas_sexo_new,'X') != coalesce(v_pruebas_sexo_new,'Y')
	THEN
		RAISE 'El sexo del atleta no corresponde a la de la prueba indicada, ambos deben ser iguales ' USING ERRCODE = 'restrict_violation';
	END IF;

	-- La mas dificil , si en la fecha de la prueba el atleta pertenecia a la categoria de
	-- la competencia. Para esto
	-- a) Que edad tenia el atleta en la fecha de la competencia.
	-- b) hasta que edad permite la categoria.
	select date_part( 'year'::text,p_competencias_pruebas_fecha::date)-date_part( 'year'::text,v_atletas_fecha_nacimiento_new::date) INTO
		v_agnos;

	-- Veamos en la categoria si esta dentro del rango
	IF NOT EXISTS(SELECT 1 from tb_categorias WHERE categorias_codigo = v_categorias_codigo_competencia AND
																									v_agnos >= categorias_edad_inicial AND v_agnos <= categorias_edad_final )
	THEN
		-- Excepcion el atleta no esta dentro de la categoria
		RAISE 'Para la fecha % en que se realizo la prueba el atleta nacido el % , tendria % años no podria haber competido dentro de la categoria %',p_competencias_pruebas_fecha,v_atletas_fecha_nacimiento_new,v_agnos,v_categorias_codigo_competencia USING ERRCODE = 'restrict_violation';
	END IF;

	-- Si el resultado de la prueba esta dentro de los valores validos
	------------------------------------------------------------------------------------
	-- Si la prueba a grabar no es multiple , esto ya que las combinadas no conocen el resultado
	-- hasta que se ingrese su detalle y es alli donde se valida, es por esto que este campo de resultado es
	-- actualizado durante la insercion de los detalles.
	IF v_prueba_multiple_new != TRUE -- OR (v_prueba_multiple_new = TRUE and p_is_update = '1')
	THEN
		-- Normalizamos a milisegundos , sin importar si es manual o no ya que ambas medidas deben estar en las mismas
		-- tipo de unidad o ambas son manuales o ambas electronicas. Los otros tipos de puntaje a centimetros o puntos
		-- normalizados.
		--raise notice 'marca menor : %',v_apppruebas_marca_menor_new;
		--raise notice 'marca mayor : %',v_apppruebas_marca_mayor_new;
		--raise notice 'unidad_medida : %',v_unidad_medida_codigo;
		--raise notice 'p_atletas_resultados_resultado : %',p_atletas_resultados_resultado;

		v_marcaMenorValida := fn_get_marca_normalizada(v_apppruebas_marca_menor_new, v_unidad_medida_codigo, false, 0);
		v_marcaMayorValida := fn_get_marca_normalizada(v_apppruebas_marca_mayor_new, v_unidad_medida_codigo, false, 0);
		v_marca_test := fn_get_marca_normalizada(p_atletas_resultados_resultado, v_unidad_medida_codigo, false, 0);

		IF v_marca_test < v_marcaMenorValida OR v_marca_test > v_marcaMayorValida
		THEN
			--La marca indicada esta fuera del rango permitido
			RAISE 'La marca indicada de % esta fuera del rango permitido entre % y % ', p_atletas_resultados_resultado,v_apppruebas_marca_menor_new,v_apppruebas_marca_mayor_new USING ERRCODE = 'restrict_violation';
		END IF;
	END IF;



	IF p_is_update = '1'
	THEN
		-- La prueba debe existir (tb_competencias_pruebas) antes de actualizar
		-- de lo contrario es imposible hacer un update.
		-- Solo busca aquellas que no son parte de una combinada.
		SELECT competencias_pruebas_id,competencias_pruebas_origen_id
		INTO v_competencias_pruebas_id,v_competencias_pruebas_origen_id
		FROM tb_competencias_pruebas cp
		WHERE cp.competencias_pruebas_id =  (select competencias_pruebas_id from tb_atletas_resultados where atletas_resultados_id = p_atletas_resultados_id);


		--RAISE NOTICE 'v_competencias_pruebas_id %',v_competencias_pruebas_id;
		--RAISE NOTICE 'v_competencias_pruebas_origen_id %',v_competencias_pruebas_origen_id;

		IF v_competencias_pruebas_id IS  NULL
		THEN
			-- La prueba no existe
			RAISE 'Para la competencia , la prueba no se ha encontrado , esto es incorrecto durante una actualizacion de resultados'  USING ERRCODE = 'restrict_violation';
		END IF;

		IF v_competencias_pruebas_origen_id IS NOT NULL
		THEN
			-- La prueba no existe
			v_isFromCombinada := true;
		END IF;


		--RAISE NOTICE 'v_isFromCombinada %',v_isFromCombinada;

		-- Grabamos cambios a la prueba
		select * from (
										select sp_competencias_pruebas_save_record(
															 v_competencias_pruebas_id::integer,
															 p_competencias_codigo,
															 p_pruebas_codigo,
															 NULL::integer,
															 p_competencias_pruebas_fecha,
															 p_competencias_pruebas_viento,
															 p_competencias_pruebas_manual,
															 p_competencias_pruebas_tipo_serie,
															 p_competencias_pruebas_nro_serie,
															 p_competencias_pruebas_anemometro,
															 p_competencias_pruebas_material_reglamentario,
															 p_competencias_pruebas_observaciones,
															 p_atletas_resultados_protected,
															 p_activo ,
															 p_usuario,
															 NULL::integer,
															 1::bit) as updins) as ans
		into v_prueba_saved
		where updins is not null;

		IF v_prueba_saved != 1
		THEN
			-- La prueba no existe
			RAISE 'Error actualizando la prueba....'  USING ERRCODE = 'restrict_violation';
		END IF;

		-- El  update
		-- Se hace el update del resultado , de ser un resultado de una prueba que es parte de una prueba
		-- combinada o multiple se hace el update de la principal con la nueva suma total de puntos acumulados.
		UPDATE
			tb_atletas_resultados
		SET
			atletas_resultados_id = p_atletas_resultados_id,
			atletas_codigo =  p_atletas_codigo,
			-- Si la prueba es multiple el update no modifica el valor del resultado ya que este es actualizado
			-- cada vez que se inserta o modifica un detalle , de lo contrario si se actualiza de acuerdo al parametro
			atletas_resultados_resultado =  (case when v_prueba_multiple_new = true then atletas_resultados_resultado else p_atletas_resultados_resultado end),
			atletas_resultados_puntos =  (case when v_prueba_multiple_new = false and v_isFromCombinada = true then p_atletas_resultados_puntos else atletas_resultados_puntos end),
			atletas_resultados_puesto =  p_atletas_resultados_puesto,
			atletas_resultados_protected =  p_atletas_resultados_protected,
			activo = p_activo,
			usuario_mod = p_usuario
		WHERE atletas_resultados_id = p_atletas_resultados_id and xmin =p_version_id ;

		RAISE NOTICE  'COUNT ID --> %', FOUND;

		-- Todo ok , si es una prueba parte de una combinada actualizamos el total de puntos
		-- en la principal.
		IF FOUND THEN
			-- Si es parte de una combinada actualizo el resultado de la principal.
			IF v_isFromCombinada = TRUE
			THEN
				UPDATE
					tb_atletas_resultados
				SET
					atletas_resultados_resultado =  (
						select sum(atletas_resultados_puntos) from tb_atletas_resultados
						where competencias_pruebas_id in  (
							select competencias_pruebas_id from tb_competencias_pruebas where competencias_pruebas_origen_id=v_competencias_pruebas_origen_id)
					)
				WHERE competencias_pruebas_id = v_competencias_pruebas_origen_id;
			END IF;

			RETURN 1;
		ELSE
			RAISE '' USING ERRCODE = 'record modified';
			RETURN null;
		END IF;

	ELSE
		-- En el caso de agregar un resultado , verificamos si ya existe la prueba , de existir usamo el id
		-- de lo ocntrario creamos la prueba, en la competencia reqquerida.
		-- La prueba debe existir (tb_competencias_pruebas) antes de actualizar
		-- de lo contrario es imposible hacer un update.
		-- Asi mismo no puede ser parte de una combinada (cp.competencias_pruebas_origen_combinada = FALSE)
		--RAISE NOTICE 'El origen combinada a chequear es %',p_competencias_pruebas_origen_combinada;
		--RAISE NOTICE 'v_competencias_pruebas_id %',v_competencias_pruebas_id;

		SELECT competencias_pruebas_id ,competencias_pruebas_origen_id
		INTO v_competencias_pruebas_id ,v_competencias_pruebas_origen_id
		FROM tb_competencias_pruebas cp
		WHERE cp.competencias_codigo =  p_competencias_codigo AND
					cp.pruebas_codigo =  p_pruebas_codigo AND
					cp.competencias_pruebas_tipo_serie = p_competencias_pruebas_tipo_serie AND
					cp.competencias_pruebas_nro_serie = p_competencias_pruebas_nro_serie AND
					cp.competencias_pruebas_origen_combinada = p_competencias_pruebas_origen_combinada;


		--RAISE NOTICE 'v_competencias_pruebas_id %',v_competencias_pruebas_id;

		IF v_competencias_pruebas_origen_id IS NOT NULL
		THEN
			-- La prueba requiere se indique el viento
			RAISE 'Los resultados para las pruebas que componen una combinada no pueden agregarse  por esta funcion'  USING ERRCODE = 'restrict_violation';
		END IF;

		-- Si la prueba no existe la creamos
		IF v_competencias_pruebas_id IS NULL
		THEN
			-- La prueba multiple usara siempre estos defaults, para grabarse
			IF coalesce(v_prueba_multiple_new,false) = TRUE
			THEN
				p_competencias_pruebas_tipo_serie := 'SU';
				p_competencias_pruebas_nro_serie := 1;

			END IF;

			-- Debemos agregar la prueba a la competencia ya que no existe.
			PERFORM  sp_competencias_pruebas_save_record(
					NULL::integer,
					p_competencias_codigo,
					p_pruebas_codigo,
					NULL::integer,
					p_competencias_pruebas_fecha,
					p_competencias_pruebas_viento,
					p_competencias_pruebas_manual,
					p_competencias_pruebas_tipo_serie,
					p_competencias_pruebas_nro_serie,
					p_competencias_pruebas_anemometro,
					p_competencias_pruebas_material_reglamentario,
					p_competencias_pruebas_observaciones,
					p_atletas_resultados_protected,
					p_activo ,
					p_usuario,
					NULL::integer,
					0::bit);

			-- La prueba multiple usara siempre estos defaults.
			IF coalesce(v_prueba_multiple_new,false) = TRUE
			THEN
				p_competencias_pruebas_viento := NULL;
				p_competencias_pruebas_manual := FALSE;
				p_competencias_pruebas_anemometro := TRUE;
				p_competencias_pruebas_material_reglamentario := TRUE;

			END IF;

			-- Si se ha grabado obtenemos el id.
			SELECT competencias_pruebas_id INTO v_competencias_pruebas_id
			FROM tb_competencias_pruebas cp
			WHERE cp.competencias_codigo =  p_competencias_codigo AND
						cp.pruebas_codigo =  p_pruebas_codigo AND
						cp.competencias_pruebas_tipo_serie = p_competencias_pruebas_tipo_serie AND
						cp.competencias_pruebas_nro_serie = competencias_pruebas_nro_serie AND
						cp.competencias_pruebas_origen_combinada = p_competencias_pruebas_origen_combinada;

			--RAISE NOTICE 'v_competencias_pruebas_id %',v_competencias_pruebas_id;


		END IF;

		--RAISE notice 'El id de la competencia prueba es %',v_competencias_pruebas_id;

		-- Con el id de la prueba creada o existente grabamos el resultado.
		INSERT INTO
			tb_atletas_resultados
			(
				competencias_pruebas_id,
				atletas_codigo,
				atletas_resultados_resultado,
				atletas_resultados_puesto,
				atletas_resultados_puntos,
				atletas_resultados_protected,
				activo,
				usuario)
		VALUES(
			v_competencias_pruebas_id,
			p_atletas_codigo,
			(case when coalesce(v_prueba_multiple_new,false) = TRUE then  '' else p_atletas_resultados_resultado end),
			p_atletas_resultados_puesto,
			0,
			p_atletas_resultados_protected,
			p_activo,
			p_usuario);


		-- Durante un add si La prueba es multiple , se agregan los detalles correspondientes.
		-- y las pruebas de la competencia.
		IF coalesce(v_prueba_multiple_new,false) = TRUE
		THEN

			-- Iniciamos el insert de todas las pruebas que componen la mltiple o combinada
			INSERT INTO
				tb_atletas_resultados
				(
					competencias_pruebas_id,
					atletas_codigo,
					atletas_resultados_resultado,
					atletas_resultados_puesto,
					atletas_resultados_puntos,
					atletas_resultados_protected,
					activo,
					usuario)
				SELECT
					cp.competencias_pruebas_id,
					p_atletas_codigo,
					0,
					0,
					0,
					p_atletas_resultados_protected,
					p_activo,
					p_usuario
				FROM tb_competencias_pruebas cp
					INNER JOIN tb_pruebas_detalle p on p.pruebas_detalle_prueba_codigo  = cp.pruebas_codigo
				WHERE cp.competencias_pruebas_origen_id = v_competencias_pruebas_id
				order by pruebas_detalle_orden;
		END IF;

		RETURN 1;

	END IF;
END;
$$;


ALTER FUNCTION public.old_sp_pruebas_atletas_resultados_save_record(p_atletas_resultados_id integer, p_atletas_codigo character varying, p_competencias_codigo character varying, p_pruebas_codigo character varying, p_competencias_pruebas_origen_combinada boolean, p_competencias_pruebas_fecha date, p_competencias_pruebas_viento numeric, p_competencias_pruebas_tipo_serie character varying, p_competencias_pruebas_nro_serie integer, p_competencias_pruebas_anemometro boolean, p_competencias_pruebas_material_reglamentario boolean, p_competencias_pruebas_manual boolean, p_competencias_pruebas_observaciones character varying, p_atletas_resultados_resultado character varying, p_atletas_resultados_puntos integer, p_atletas_resultados_puesto integer, p_atletas_resultados_invalida boolean, p_atletas_resultados_protected boolean, p_activo boolean, p_usuario character varying, p_version_id integer, p_is_update bit) OWNER TO atluser;

--
-- TOC entry 250 (class 1255 OID 16418)
-- Name: sp_apppruebas_save_record(character varying, character varying, character varying, character varying, character varying, boolean, boolean, boolean, numeric, numeric, integer, numeric, boolean, character varying, integer, bit); Type: FUNCTION; Schema: public; Owner: atluser
--

CREATE FUNCTION sp_apppruebas_save_record(p_apppruebas_codigo character varying, p_apppruebas_descripcion character varying, p_pruebas_clasificacion_codigo character varying, p_apppruebas_marca_menor character varying, p_apppruebas_marca_mayor character varying, p_apppruebas_multiple boolean, p_apppruebas_verifica_viento boolean, p_apppruebas_viento_individual boolean, p_apppruebas_viento_limite_normal numeric, p_apppruebas_viento_limite_multiple numeric, p_apppruebas_nro_atletas integer, p_apppruebas_factor_manual numeric, p_activo boolean, p_usuario character varying, p_version_id integer, p_is_update bit) RETURNS integer
LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 08-10-2013

Stored procedure que agrega o actualiza los registros de los pruebas genericas.
Previo verifica que no se definan limies de viento innecesriamente y asi mismo que la marca menor
sea siempre menor que la marca mayor.

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

	select * from ( select sp_apppruebas_save_record(?,?,etc) as updins) as ans where updins is not null;

	de tal forma que retornara un registro si el update funciono o el insert , y 0 registros si no se realizo
	el uodate. sto es conveniente cuando se usa por ejemplo el affected_rows de algunos drivers.
	EN OTRAS BASES ESTO NO ES NECESARIO.

Historia : Creado 15-01-2014
*/
DECLARE v_apppruebas_multiple BOOLEAN = FALSE;
				DECLARE v_unidad_medida_codigo CHARACTER VARYING(8);
				DECLARE v_marcaMenorValida INTEGER;
				DECLARE v_marcaMayorValida INTEGER;

BEGIN
	IF p_apppruebas_multiple = TRUE
	THEN
		IF p_apppruebas_verifica_viento = true OR
			 p_apppruebas_viento_limite_normal IS NOT NULL OR
			 p_apppruebas_viento_limite_multiple IS NOT NULL
		THEN
			RAISE 'Las pruebas multiples no pueden tener control de viento' USING ERRCODE = 'restrict_violation';
		END IF;
	ELSE IF p_apppruebas_verifica_viento = true
	THEN
		IF  p_apppruebas_viento_limite_normal IS NULL
		THEN
			RAISE 'Indique al menos el  limite de viento standard para la prueba' USING ERRCODE = 'restrict_violation';
		END IF;
	END IF;
	END IF;

	-- Verificamos si alguno con el mismo nombre existe e indicamos el error.
	IF EXISTS (SELECT 1 FROM tb_app_pruebas_values
	where apppruebas_codigo != p_apppruebas_codigo and UPPER(LTRIM(RTRIM(apppruebas_descripcion))) = UPPER(LTRIM(RTRIM(p_apppruebas_descripcion))))
	THEN
		-- Excepcion de prueba con ese nombre existe
		RAISE 'Ya existe un prueba con ese nombre pero diferente codigo' USING ERRCODE = 'restrict_violation';
	END IF;

	-- Se verifica que el numero de atletas sea 1 o 4 , en el caso de null el default sera 1
	IF p_apppruebas_nro_atletas is not null AND p_apppruebas_nro_atletas != 1 and p_apppruebas_nro_atletas != 4
	THEN
		-- Excepcion de numero de atletas incorecto.
		RAISE 'Las pruebas pueden ser de uno o 4 atletas' USING ERRCODE = 'restrict_violation';
	END IF;


	-- Leemos el tipo de prueba para saber la unidad de medida para la prueba
	SELECT unidad_medida_codigo INTO
		v_unidad_medida_codigo
	FROM tb_pruebas_clasificacion c
	WHERE c.pruebas_clasificacion_codigo = p_pruebas_clasificacion_codigo;

	-- No lo pongo como constraint ya que por ahora es un string y requiere tratamiento especial
	-- posiblemente estos campos requieran cambios.
	-- Normalizamos a milisegundos , sin iportar si es manual o no ya que ambas medidas deben estar en las mismas
	-- tipo de unidad o ambas son manuales o ambas electronicas. Los otros tipos de puntaje a centimetros o puntos
	-- normalizados.
	v_marcaMenorValida := fn_get_marca_normalizada(p_apppruebas_marca_menor, v_unidad_medida_codigo, false, 0);
	v_marcaMayorValida := fn_get_marca_normalizada(p_apppruebas_marca_mayor, v_unidad_medida_codigo, false, 0);

	IF v_marcaMenorValida >= v_marcaMayorValida
	THEN
		RAISE 'EL limite de menor para la marca de la prueba no puede ser mayor o igual que el limite mayor' USING ERRCODE = 'restrict_violation';
	END IF;


	IF p_is_update = '1'
	THEN

		-- Leemos el status actual de la prueba , si es multiple o no
		SELECT apppruebas_multiple INTO
			v_apppruebas_multiple
		FROM tb_app_pruebas_values p
		WHERE p.apppruebas_codigo = p_apppruebas_codigo;

		-- SI actualmente es una prueba multiple y se desea pasar a prueba simple
		-- verificamos si alguna prueba en la tabla de pruebas tiene ya definido la subpruebas
		-- de ser asi no se permitira ,mientras no se elimine la prueba o se retire los detalles.
		IF v_apppruebas_multiple = TRUE and p_apppruebas_multiple = FALSE
		THEN
			IF EXISTS (SELECT 1 FROM tb_pruebas pr
				INNER JOIN tb_app_pruebas_values pv on pv.apppruebas_codigo = pr.pruebas_generica_codigo
				INNER JOIN tb_pruebas_detalle pd  on pd.pruebas_codigo = pr.pruebas_codigo
			WHERE pv.apppruebas_codigo = p_apppruebas_codigo LIMIT 1)
			THEN
				RAISE 'Esta prueba generica es actualmente multiple y ya tiene pruebas combinadas especificas con sus respectivas pruebas.<br>Corriga primero las pruebas especificas si es que no es un error de digitacion.' USING ERRCODE = 'restrict_violation';
			END IF;
		END IF;

		-- HACEMOS EL UPDATE
		UPDATE
			tb_app_pruebas_values
		SET
			apppruebas_descripcion=p_apppruebas_descripcion,
			pruebas_clasificacion_codigo=p_pruebas_clasificacion_codigo,
			apppruebas_marca_menor=p_apppruebas_marca_menor,
			apppruebas_marca_mayor=p_apppruebas_marca_mayor,
			apppruebas_multiple=p_apppruebas_multiple,
			apppruebas_verifica_viento=p_apppruebas_verifica_viento,
			apppruebas_viento_individual=p_apppruebas_viento_individual,
			apppruebas_viento_limite_normal=p_apppruebas_viento_limite_normal,
			apppruebas_viento_limite_multiple=p_apppruebas_viento_limite_multiple,
			apppruebas_nro_atletas=p_apppruebas_nro_atletas,
			apppruebas_factor_manual=p_apppruebas_factor_manual,
			activo=p_activo,
			usuario_mod=p_usuario
		WHERE apppruebas_codigo = p_apppruebas_codigo and xmin =p_version_id ;
		RAISE NOTICE  'COUNT ID --> %', FOUND;

		IF FOUND THEN
			RETURN 1;
		ELSE
			RAISE '' USING ERRCODE = 'record modified';
			RETURN null;
		END IF;
	ELSE
		INSERT INTO
			tb_app_pruebas_values
			(apppruebas_codigo,apppruebas_descripcion,pruebas_clasificacion_codigo,apppruebas_marca_menor,
			 apppruebas_marca_mayor,apppruebas_multiple,apppruebas_verifica_viento,apppruebas_viento_individual,
			 apppruebas_viento_limite_normal,
			 apppruebas_viento_limite_multiple,apppruebas_nro_atletas,apppruebas_factor_manual,activo,usuario)
		VALUES(p_apppruebas_codigo,
			p_apppruebas_descripcion,
			p_pruebas_clasificacion_codigo,
			p_apppruebas_marca_menor,
			p_apppruebas_marca_mayor,
			p_apppruebas_multiple,
			p_apppruebas_verifica_viento,
			p_apppruebas_viento_individual,
			p_apppruebas_viento_limite_normal,
			p_apppruebas_viento_limite_multiple,
			p_apppruebas_nro_atletas,
					 p_apppruebas_factor_manual,
					 p_activo,
					 p_usuario);

		RETURN 1;

	END IF;
END;
$$;


ALTER FUNCTION public.sp_apppruebas_save_record(p_apppruebas_codigo character varying, p_apppruebas_descripcion character varying, p_pruebas_clasificacion_codigo character varying, p_apppruebas_marca_menor character varying, p_apppruebas_marca_mayor character varying, p_apppruebas_multiple boolean, p_apppruebas_verifica_viento boolean, p_apppruebas_viento_individual boolean, p_apppruebas_viento_limite_normal numeric, p_apppruebas_viento_limite_multiple numeric, p_apppruebas_nro_atletas integer, p_apppruebas_factor_manual numeric, p_activo boolean, p_usuario character varying, p_version_id integer, p_is_update bit) OWNER TO atluser;

--
-- TOC entry 251 (class 1255 OID 16421)
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
-- TOC entry 291 (class 1255 OID 37501)
-- Name: sp_atletas_pruebas_resultado_clear_viento(integer, boolean, boolean, character varying); Type: FUNCTION; Schema: public; Owner: atluser
--

CREATE FUNCTION sp_atletas_pruebas_resultado_clear_viento(p_competencias_pruebas_id integer, p_competencias_pruebas_anemometro boolean, p_apppruebas_viento_individual boolean, p_usuario character varying) RETURNS integer
LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 08-10-2013

Stored procedure que pone en blanco el viento de todos los resultudados asociado a la prueba x de una competencia
especificada por su id.

Retorna 1 si hizo update y 0 si no fue necesario ya que la prueba no requiere viento individual.

Historia : Creado 27-03-2016
*/
BEGIN
	-- solo si no hay anemometro y se requiere viento individual
	IF p_competencias_pruebas_anemometro = FALSE AND p_apppruebas_viento_individual = TRUE
	THEN
		-- Requerimos limpiar el viento en los resultados individuales de la prueba?
		UPDATE
			tb_atletas_resultados
		SET
			atletas_resultados_viento = null,
			usuario_mod = p_usuario
		WHERE competencias_pruebas_id = p_competencias_pruebas_id;
		RETURN 1;
	ELSE
		RETURN 0;
	END IF;

END;
$$;


ALTER FUNCTION public.sp_atletas_pruebas_resultado_clear_viento(p_competencias_pruebas_id integer, p_competencias_pruebas_anemometro boolean, p_apppruebas_viento_individual boolean, p_usuario character varying) OWNER TO atluser;

--
-- TOC entry 252 (class 1255 OID 16422)
-- Name: sp_atletas_pruebas_resultados_detalle_save_record(integer, integer, character varying, date, numeric, boolean, boolean, boolean, character varying, character varying, integer, integer, boolean, boolean, character varying, integer); Type: FUNCTION; Schema: public; Owner: atluser
--

CREATE FUNCTION sp_atletas_pruebas_resultados_detalle_save_record(p_atletas_resultados_id integer, p_competencias_pruebas_id integer, p_atletas_codigo character varying, p_competencias_pruebas_fecha date, p_competencias_pruebas_viento numeric, p_competencias_pruebas_anemometro boolean, p_competencias_pruebas_material_reglamentario boolean, p_competencias_pruebas_manual boolean, p_competencias_pruebas_observaciones character varying, p_atletas_resultados_resultado character varying, p_atletas_resultados_puntos integer, p_atletas_resultados_puesto integer, p_atletas_resultados_protected boolean, p_activo boolean, p_usuario character varying, p_version_id integer) RETURNS integer
LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 08-10-2013

Stored procedure que agrega o actualiza un resultado de alguna prueba componente de una combinada sea
heptatlon, decatlon , etc.

Este stored procedure trata los registos de la tb_competencias_pruebas y tb_atletas_resultado a la vez ,
pero solo permitira agregar o modificar a los rsuultados , a la otra tabla solo podra actualizarla , POR
LO QUE SE REQUIERE QUE EXISTA EL REGISTRO DE LA PRUEBA SIEMPRE.


DADO QUE ALGUNOS DATOS DE LA PRUEBA PUEDEN TAMBIEN SER MODIFICADOS, ESTE SP ES UTIL CUANDO LOS RESULTADOS
SE AGREGAN DIRECTAMENTE A UN ATLETA, Y NO POR EL LADO DE LAS COMPETENCIAS.

En la tabla tb_competencias_pruebas solo podra modificarse lo que respecta a lasc condiciones de
la prueba , digase viento,material,puntosfecha , observaciones , nada mas.

El registro de la competencia principal solo sera actualizado en lo que respecta a los puntos acumulados y lo que es viento,material,anemometro.


Previamente hace todas las validaciones necesarias para garantizar que los datos sean grabados
consistentemente,


El parametro p_version_id indica el campo xmin de control para cambios externos y solo se usara
durante un update , de la misma forma el parametro id sera ignorado durante un insert.

SI EL PARAMETRO p_atletas_resultados_id es null se asumira es un add de lo contrario se asumira un update.

IMPORTANTE : Esta procedure function devuelve un entero siempre que el update o el insert
	se hayan realizado y devuelve null si no se realizo el update. Esta extraña forma
	se debe a que en pgsql las funciones se ejecutan con select funct_name() , esto quiere
	decir que al margen si el update se realizo o no siempre devolvera un registro afectado.
	En realidad lo que esta diciendo es que el select de la funcion se ha ejecutado , pero no
	es eso lo que deseamos si no saber si el update se realizo o no , para poder simular el
	comportamiento standard de otras bases de datos he realizado un truco , determinando si existio
	o no el update usando la variable postgres FOUND y retornando 1 si lo hzo y null si no lo hizo.

	Esta forma permite realizar el siguiente select cuando se trata de un UPDATE :

	select * from ( select sp_pruebas_atletas_resultados_save_record(?,?,etc) as updins) as ans where updins is not null;

	de tal forma que retornara un registro si el update funciono o el insert , y 0 registros si no se realizo
	el uodate. sto es conveniente cuando se usa por ejemplo el affected_rows de algunos drivers.
	EN OTRAS BASES ESTO NO ES NECESARIO.

Historia : Creado 15-01-2014
*/
DECLARE v_categorias_codigo_competencia character varying(15);
				DECLARE v_pruebas_codigo character varying(15);
				DECLARE v_competencias_codigo character varying(15);
				DECLARE v_pruebas_sexo_new  character(1);
				DECLARE v_atletas_sexo_new  character(1);
				DECLARE v_atletas_fecha_nacimiento_new DATE;
				DECLARE v_apppruebas_marca_menor_new character varying(12);
				DECLARE v_apppruebas_marca_mayor_new character varying(12);
				DECLARE v_apppruebas_verifica_viento boolean;
				DECLARE v_agnos INT;
				DECLARE v_marca_test integer;
				DECLARE v_unidad_medida_codigo character varying(8);
				DECLARE v_marcaMenorValida integer;
				DECLARE v_marcaMayorValida integer;
				DECLARE v_competencias_pruebas_origen_id integer;
				DECLARE v_competencias_pruebas_id integer;
				DECLARE v_prueba_saved integer=0;
				DECLARE v_unidad_medida_tipo character(1);
				DECLARE v_apppruebas_viento_individual boolean;
				DECLARE v_competencias_pruebas_anemometro_old boolean;
				DECLARE v_check_update_resultados_viento boolean = FALSE;

BEGIN

	-- VERIFICACIONES PARA LA COMPETENCIA / PRUEBA ENVIADA.

	-- La prueba debe existir (tb_competencias_pruebas) antes de actualizar
	-- de lo contrario es imposible hacer un update.
	-- Solo busca aquellas que no son parte de una combinada.
	SELECT competencias_pruebas_id,competencias_pruebas_origen_id,pruebas_codigo,competencias_codigo,competencias_pruebas_anemometro
	INTO v_competencias_pruebas_id,v_competencias_pruebas_origen_id,v_pruebas_codigo,v_competencias_codigo,v_competencias_pruebas_anemometro_old
	FROM tb_competencias_pruebas cp
	WHERE cp.competencias_pruebas_id =  p_competencias_pruebas_id;

	--RAISE NOTICE 'v_competencias_pruebas_id %',v_competencias_pruebas_id;
	--RAISE NOTICE 'v_competencias_pruebas_origen_id %',v_competencias_pruebas_origen_id;

	IF v_competencias_pruebas_id IS  NULL
	THEN
		-- La prueba no existe
		RAISE 'Para la competencia , la prueba no se ha encontrado , esto es incorrecto durante una actualizacion de resultados'  USING ERRCODE = 'restrict_violation';
	END IF;

	IF v_competencias_pruebas_origen_id IS NULL
	THEN
		-- La prueba no existe
		RAISE 'Solo resultados para pruebas dentro de una combinada son permitidos'  USING ERRCODE = 'restrict_violation';
	END IF;

	-- En las combinadas un atleta solo puede realizar una vez la prueba ya que no existin semifinales y finales sino
	-- solo se agrupan pero el resultado es consolidado. (solo durante add osea p_atletas_resultados_id IS NULL)
	IF v_competencias_pruebas_origen_id IS NOT NULL and p_atletas_resultados_id IS NULL
	THEN
		IF EXISTS(SELECT 1 FROM tb_competencias_pruebas  cp
			INNER JOIN tb_atletas_resultados ar on ar.competencias_pruebas_id = cp.competencias_pruebas_id
		WHERE cp.pruebas_codigo = v_pruebas_codigo AND
					competencias_pruebas_origen_id = v_competencias_pruebas_origen_id AND
					atletas_codigo=p_atletas_codigo)
		THEN
			RAISE 'El atleta ya registra resultado para dicha prueba, en el caso de las combinadas no puede realizar una prueba mas de una vez'  USING ERRCODE = 'restrict_violation';
		END IF;
	END IF;

	-- Validamos que para esta prueba no existan otros atletas con el mismo puesto pero diferente resultado ,
	-- lo cual no es logico. Si el puesto es 0 no se valida ya que se toma como no conocido
	IF p_atletas_resultados_puesto > 0
	THEN
		IF EXISTS(SELECT 1
							FROM tb_competencias_pruebas pr
								inner join tb_atletas_resultados ar on pr.competencias_pruebas_id  =  ar.competencias_pruebas_id
							where   atletas_resultados_puesto=p_atletas_resultados_puesto and
											atletas_resultados_resultado != p_atletas_resultados_resultado and
											pr.competencias_pruebas_id = p_competencias_pruebas_id  and
											atletas_codigo != p_atletas_codigo)
		THEN
			RAISE 'Ya existe al menos un atleta con el mismo puesto pero diferente resultado , verifique por favor'  USING ERRCODE = 'restrict_violation';
		END IF;
	END IF;

	-----------------------------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------------
	-- VALIDACIONES PRIMARIAS DE INTEGRIDAD LOGICA
	-----------------------------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------------

	-- Busxcamos la categoria de la competencia, los datos de la prueba y del atleta
	-- basados en los datos actuales a grabar, esto no permitira saber si la relacion
	-- COmPETencia,PrueBA;ATLETA es correcta , digase si la competencia es de mayores
	-- la prueba debe ser de mayores y el atleta debe ser mayor, asi mismo si la prueba es para
	-- el sexo femenino , el atleta debe ser mujer
	SELECT categorias_codigo,competencias_fecha_inicio,competencias_fecha_final INTO
		v_categorias_codigo_competencia
	FROM tb_competencias where competencias_codigo=v_competencias_codigo;


	-- Buscamos los datos de la gnerica de prueba que actualmente se quiere grabar para saber si tambien sera multiple.
	SELECT pruebas_sexo,apppruebas_marca_menor,
		apppruebas_marca_mayor,c.unidad_medida_codigo,apppruebas_verifica_viento,unidad_medida_tipo,
		apppruebas_viento_individual
	INTO
		v_pruebas_sexo_new,v_apppruebas_marca_menor_new,
		v_apppruebas_marca_mayor_new,v_unidad_medida_codigo,v_apppruebas_verifica_viento,v_unidad_medida_tipo,
		v_apppruebas_viento_individual
	FROM tb_pruebas pr
		INNER JOIN tb_app_pruebas_values p ON p.apppruebas_codigo = pr.pruebas_generica_codigo
		INNER JOIN tb_pruebas_clasificacion c ON c.pruebas_clasificacion_codigo = p.pruebas_clasificacion_codigo
		INNER JOIN tb_unidad_medida um on um.unidad_medida_codigo = c.unidad_medida_codigo
	where pr.pruebas_codigo = v_pruebas_codigo;

	-- Se busca el sexo del atleta
	SELECT atletas_sexo,atletas_fecha_nacimiento INTO
		v_atletas_sexo_new,v_atletas_fecha_nacimiento_new
	FROM tb_atletas at
	where at.atletas_codigo = p_atletas_codigo;

	raise notice 'v_atletas_sexo_new: %',v_atletas_sexo_new;
	raise notice 'v_pruebas_sexo_new: %',v_pruebas_sexo_new;

	-- Luego si el sexo del atleta y el sexo de la prueba corresponden.
	IF coalesce(v_atletas_sexo_new,'X') != coalesce(v_pruebas_sexo_new,'Y')
	THEN
		RAISE 'El sexo del atleta no corresponde a la de la prueba indicada, ambos deben ser iguales ' USING ERRCODE = 'restrict_violation';
	END IF;

	-- La mas dificil , si en la fecha de la prueba el atleta pertenecia a la categoria de
	-- la competencia. Para esto
	-- a) Que edad tenia el atleta en la fecha de la competencia.
	-- b) hasta que edad permite la categoria.
	select date_part( 'year'::text,p_competencias_pruebas_fecha::date)-date_part( 'year'::text,v_atletas_fecha_nacimiento_new::date) INTO
		v_agnos;

	-- Veamos en la categoria si esta dentro del rango
	IF NOT EXISTS(SELECT 1 from tb_categorias WHERE categorias_codigo = v_categorias_codigo_competencia AND
																									v_agnos >= categorias_edad_inicial AND v_agnos <= categorias_edad_final )
	THEN
		-- Excepcion el atleta no esta dentro de la categoria
		RAISE 'Para la fecha % en que se realizo la prueba el atleta nacido el % , tendria % años no podria haber competido dentro de la categoria %',p_competencias_pruebas_fecha,v_atletas_fecha_nacimiento_new,v_agnos,v_categorias_codigo_competencia USING ERRCODE = 'restrict_violation';
	END IF;

	-- Si el resultado de la prueba esta dentro de los valores validos
	------------------------------------------------------------------------------------

	-- Normalizamos a milisegundos , sin importar si es manual o no ya que ambas medidas deben estar en las mismas
	-- tipo de unidad o ambas son manuales o ambas electronicas. Los otros tipos de puntaje a centimetros o puntos
	-- normalizados.
	raise notice 'marca menor : %',v_apppruebas_marca_menor_new;
	raise notice 'marca mayor : %',v_apppruebas_marca_mayor_new;
	raise notice 'unidad_medida : %',v_unidad_medida_codigo;
	raise notice 'p_atletas_resultados_resultado : %',p_atletas_resultados_resultado;

	v_marcaMenorValida := fn_get_marca_normalizada(v_apppruebas_marca_menor_new, v_unidad_medida_codigo, false, 0);
	v_marcaMayorValida := fn_get_marca_normalizada(v_apppruebas_marca_mayor_new, v_unidad_medida_codigo, false, 0);
	v_marca_test := fn_get_marca_normalizada(p_atletas_resultados_resultado, v_unidad_medida_codigo, false, 0);

	IF v_marca_test < v_marcaMenorValida OR v_marca_test > v_marcaMayorValida
	THEN
		--La marca indicada esta fuera del rango permitido
		RAISE 'La marca indicada de % esta fuera del rango permitido entre % y % ', p_atletas_resultados_resultado,v_apppruebas_marca_menor_new,v_apppruebas_marca_mayor_new USING ERRCODE = 'restrict_violation';
	END IF;

	-- Si se indica marca , deben indicarse puntos , por aqui solo se graban los componentes de la
	-- conmbinada o pruebas normales, dado validacion anterior
	IF v_competencias_pruebas_origen_id IS NOT NULL
	THEN
		IF v_marca_test != 0 AND coalesce(p_atletas_resultados_puntos,0) = 0 OR
			 v_marca_test = 0 AND coalesce(p_atletas_resultados_puntos,0) != 0
		THEN
			RAISE 'Si la marca o puntos son mayores que cero , ambos deben estar indicados ' USING ERRCODE = 'restrict_violation';
		END IF;
	END IF;


	--	IF v_apppruebas_verifica_viento = TRUE AND p_competencias_pruebas_anemometro = TRUE --AND v_apppruebas_viento_individual = TRUE
	--	THEN
	--		IF p_competencias_pruebas_viento is null
	--		THEN
	--			-- La prueba requiere se indique el viento
	--			RAISE 'La prueba requiere se indique el limite de viento'  USING ERRCODE = 'restrict_violation';
	--		END IF;
	--	ELSE
	--		-- Si no requiere viento lo ponemos en null , por si acaso se envie dato por gusto.
	--		p_competencias_pruebas_viento := NULL;
	--	END IF;

	-- Se ha tomado la decision que el viento pueda ser null en cualquier caso ya que en la preactica muchas veces este
	-- no se conoce sobre todo en pruebas hitoricas.
	IF v_apppruebas_verifica_viento = TRUE --AND v_apppruebas_viento_individual = TRUE
	THEN
		IF p_competencias_pruebas_anemometro = FALSE
		THEN
			-- No habra viento en el caso que el anemometro no este encendido.
			p_competencias_pruebas_viento := NULL;
		END IF;
	ELSE
		-- Si no requiere viento lo ponemos en null , por si acaso se envie dato por gusto.
		p_competencias_pruebas_viento := NULL;
	END IF;

	-- Si la unidad de medida de la prueba no es tiempo
	-- se blanquea (false) al campo que indica si la medida manual.
	IF v_unidad_medida_tipo != 'T'
	THEN
		p_competencias_pruebas_manual := false;
	END IF;


	---------------------------------------------------------------------
	-- FIN VALIDACIONES PRIMARIAS - AHORA GRABACION.
	----------------------------------------------------------------------

	-- Grabamos cambios a la prueba
	select * from (
									select sp_competencias_pruebas_save_record(
														 v_competencias_pruebas_id::integer,
														 v_competencias_codigo,
														 v_pruebas_codigo,
														 NULL::integer,
														 p_competencias_pruebas_fecha,
														 p_competencias_pruebas_viento,
														 p_competencias_pruebas_manual,
														 'FI', -- NO ES VARIABLE PARA ESTE CASO
														 1,  -- N ES VARIABLE PARA ESTE CASO
														 p_competencias_pruebas_anemometro,
														 p_competencias_pruebas_material_reglamentario,
														 p_competencias_pruebas_observaciones,
														 p_atletas_resultados_protected,
														 false,
														 true,
														 p_activo ,
														 p_usuario,
														 NULL::integer,
														 1::bit) as updins) as ans
	into v_prueba_saved
	where updins is not null;

	IF v_prueba_saved != 1
	THEN
		-- La prueba no existe
		RAISE 'Error actualizando la prueba....'  USING ERRCODE = 'restrict_violation';
	END IF;

	v_check_update_resultados_viento := TRUE;

	-- Si se conoce la id del resultado se trata de un update.
	IF p_atletas_resultados_id IS NOT NULL
	THEN
		IF NOT EXISTS(SELECT 1 FROM tb_atletas_resultados where atletas_resultados_id = p_atletas_resultados_id
																														AND atletas_codigo =  p_atletas_codigo)
		THEN
			-- La prueba no existe
			RAISE 'Al actualizar un resultado no puede cambiarse el atleta o el registro fue eliminado, verifique por favor...'  USING ERRCODE = 'restrict_violation';
		END IF;

		-- Dado que durante un update no se actualiza el codigo del del atleta , y este parametro podria ser null o cualquier valor
		-- no valido , obtenemos el atleta del registro correspondiente , para uso posterior , en al caso de un add el atleta
		-- en el parametro debe ser obviamente validoy se tomara del parametroo mismo.
		select atletas_codigo into p_atletas_codigo from tb_atletas_resultados where atletas_resultados_id = p_atletas_resultados_id;

		-- El  update
		-- Se hace el update del resultado , en este caso todos son parte de una combinada.
		UPDATE
			tb_atletas_resultados
		SET
			-- Aqui solo llegan pruebas parte de una combinada
			atletas_resultados_resultado =  p_atletas_resultados_resultado,
			atletas_resultados_puntos =  p_atletas_resultados_puntos,
			atletas_resultados_puesto =  coalesce(p_atletas_resultados_puesto,0),
			atletas_resultados_protected =  p_atletas_resultados_protected,
			atletas_resultados_viento = (case when v_apppruebas_viento_individual = TRUE then p_competencias_pruebas_viento else NULL end),
			activo = p_activo,
			usuario_mod = p_usuario
		WHERE atletas_resultados_id = p_atletas_resultados_id and xmin =p_version_id ;
	ELSE
		-- Con el id de la prueba creada o existente grabamos el resultado.
		INSERT INTO
			tb_atletas_resultados
			(
				competencias_pruebas_id,
				atletas_codigo,
				atletas_resultados_resultado,
				atletas_resultados_puesto,
				atletas_resultados_puntos,
				atletas_resultados_viento,
				atletas_resultados_protected,
				activo,
				usuario)
		VALUES(
			v_competencias_pruebas_id,
			p_atletas_codigo,
			p_atletas_resultados_resultado,
			coalesce(p_atletas_resultados_puesto,0),
			p_atletas_resultados_puntos,
			(case when v_apppruebas_viento_individual = TRUE then p_competencias_pruebas_viento else NULL end),
			p_atletas_resultados_protected,
			p_activo,
			p_usuario);

		-- esta por gusto nadie la usa
		--SELECT currval(pg_get_serial_sequence('tb_atletas_resultados', 'atletas_resultados_id'))
		--	INTO p_atletas_resultados_id;

	END IF;

	-- Todo ok , si es una prueba parte de una combinada actualizamos el total de puntos
	-- en la principal.
	IF FOUND THEN
		-- Vemos si alguna prueba de esta competencia tiene datos que invalidan la prueba , ya sea anemometro , material , o si
		-- el resultado es manual , para asi actualizar la prueba principal.
		UPDATE tb_competencias_pruebas t1
		SET
			competencias_pruebas_manual = (case when t2.cpm > 0 then TRUE else FALSE end),
			competencias_pruebas_anemometro = (case when t2.cpa > 0 then FALSE else TRUE end),
			competencias_pruebas_material_reglamentario = (case when t2.cpmr > 0 then FALSE else TRUE end)
		FROM (
					 select
						 max(competencias_pruebas_origen_id) as competencias_pruebas_origen_id,
						 sum((case when competencias_pruebas_manual = TRUE then 1 else 0 end)) as cpm,
						 sum((case when competencias_pruebas_anemometro = FALSE then 1 else 0 end)) as cpa,
						 sum((case when competencias_pruebas_material_reglamentario = FALSE then 1 else 0 end)) as cpmr
					 from tb_competencias_pruebas where competencias_pruebas_origen_id=v_competencias_pruebas_origen_id
				 ) t2
		WHERE  t1.competencias_pruebas_id=t2.competencias_pruebas_origen_id;

		-- Aqui todas son parte de una combinada.
		-- actualizamos el resultado de la principal con el nuevo acumulado de puntos
		UPDATE
			tb_atletas_resultados
		SET
			atletas_resultados_resultado =  (
				select sum(atletas_resultados_puntos) from tb_atletas_resultados
				where competencias_pruebas_id in  (
					select competencias_pruebas_id from tb_competencias_pruebas where competencias_pruebas_origen_id=v_competencias_pruebas_origen_id and atletas_codigo=p_atletas_codigo)
			)
		WHERE competencias_pruebas_id = v_competencias_pruebas_origen_id and atletas_codigo = p_atletas_codigo;

		IF v_check_update_resultados_viento = TRUE AND v_competencias_pruebas_anemometro_old != p_competencias_pruebas_anemometro
		THEN
			PERFORM sp_atletas_pruebas_resultado_clear_viento(v_competencias_pruebas_id, p_competencias_pruebas_anemometro,v_apppruebas_viento_individual, p_usuario);
		END IF;

		RETURN 1;
	ELSE
		--RAISE '' USING ERRCODE = 'record modified';
		RETURN null;
	END IF;

END;
$$;


ALTER FUNCTION public.sp_atletas_pruebas_resultados_detalle_save_record(p_atletas_resultados_id integer, p_competencias_pruebas_id integer, p_atletas_codigo character varying, p_competencias_pruebas_fecha date, p_competencias_pruebas_viento numeric, p_competencias_pruebas_anemometro boolean, p_competencias_pruebas_material_reglamentario boolean, p_competencias_pruebas_manual boolean, p_competencias_pruebas_observaciones character varying, p_atletas_resultados_resultado character varying, p_atletas_resultados_puntos integer, p_atletas_resultados_puesto integer, p_atletas_resultados_protected boolean, p_activo boolean, p_usuario character varying, p_version_id integer) OWNER TO atluser;

--
-- TOC entry 290 (class 1255 OID 20999)
-- Name: sp_atletas_pruebas_resultados_save_record(integer, character varying, character varying, character varying, date, numeric, character varying, integer, boolean, boolean, boolean, character varying, character varying, integer, integer, boolean, boolean, character varying, integer, bit); Type: FUNCTION; Schema: public; Owner: atluser
--

CREATE FUNCTION sp_atletas_pruebas_resultados_save_record(p_atletas_resultados_id integer, p_atletas_codigo character varying, p_competencias_codigo character varying, p_pruebas_codigo character varying, p_competencias_pruebas_fecha date, p_competencias_pruebas_viento numeric, p_competencias_pruebas_tipo_serie character varying, p_competencias_pruebas_nro_serie integer, p_competencias_pruebas_anemometro boolean, p_competencias_pruebas_material_reglamentario boolean, p_competencias_pruebas_manual boolean, p_competencias_pruebas_observaciones character varying, p_atletas_resultados_resultado character varying, p_atletas_resultados_puntos integer, p_atletas_resultados_puesto integer, p_atletas_resultados_protected boolean, p_activo boolean, p_usuario character varying, p_version_id integer, p_is_update bit) RETURNS integer
LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 08-10-2013

Stored procedure que agrega o actualiza los registros de los resultados de las pruebas, pero
ADEMAS agrega las pruebas de no existir, basicamente debe ser usado si se desea agregar o actualizar
un resultado de un atleta , pero condicionado a que la prueba exista , en otras palabras
para agregar un resultado este sp asegura que la prueba deba existir.

ALGUNOS DATOS DE LA PRUEBA PUEDEN TAMBIEN SER MODIFICADOS, ESTE SP ES UTIL CUANDO LOS RESULTADOS
SE AGREGAN DIRECTAMENTE A UN ATLETA, Y NO POR EL LADO DE LAS COMPETENCIAS.

Previamente hace todas las validaciones necesarias para garantizar que los datos sean grabados
consistentemente,


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

	select * from ( select sp_pruebas_atletas_resultados_save_record(?,?,etc) as updins) as ans where updins is not null;

	de tal forma que retornara un registro si el update funciono o el insert , y 0 registros si no se realizo
	el uodate. sto es conveniente cuando se usa por ejemplo el affected_rows de algunos drivers.
	EN OTRAS BASES ESTO NO ES NECESARIO.

Historia : Creado 15-01-2014
*/
DECLARE v_prueba_multiple_new boolean= FALSE;
				DECLARE v_categorias_codigo_competencia character varying(15);
				DECLARE v_pruebas_sexo_new  character(1);
				DECLARE v_atletas_sexo_new  character(1);
				DECLARE v_atletas_fecha_nacimiento_new DATE;
				DECLARE v_apppruebas_marca_menor_new character varying(12);
				DECLARE v_apppruebas_marca_mayor_new character varying(12);
				DECLARE v_agnos INT;
				DECLARE v_marca_test integer;
				DECLARE v_unidad_medida_codigo character varying(8);
				DECLARE v_marcaMenorValida integer;
				DECLARE v_marcaMayorValida integer;
				DECLARE v_competencias_pruebas_origen_id integer;
				DECLARE v_competencias_pruebas_id integer;
				DECLARE v_competencias_pruebas_changed_id integer;
				DECLARE v_prueba_saved integer=0;
				DECLARE v_isFromCombinada boolean := false;
				DECLARE v_competencias_pruebas_tipo_serie_old character varying(2);
				DECLARE v_competencias_pruebas_nro_serie_old integer;
				DECLARE v_apppruebas_viento_individual BOOLEAN;
				DECLARE v_check_update_resultados_viento BOOLEAN = FALSE;
				DECLARE v_competencias_pruebas_anemometro_old BOOLEAN;
				DECLARE v_competencias_pruebas_manual_old BOOLEAN;
				DECLARE v_can_modify INTEGER;

BEGIN
	--RAISE NOTICE 'sp_atletas_pruebas_resultados_save_record';
	-----------------------------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------------
	-- VALIDACIONES PRIMARIAS DE INTEGRIDAD LOGICA
	-----------------------------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------------

	-- Busxcamos la categoria de la competencia, los datos de la prueba y del atleta
	-- basados en los datos actuales a grabar, esto no permitira saber si la relacion
	-- COmPETencia,PrueBA;ATLETA es correcta , digase si la competencia es de mayores
	-- la prueba debe ser de mayores y el atleta debe ser mayor, asi mismo si la prueba es para
	-- el sexo femenino , el atleta debe ser mujer
	SELECT categorias_codigo,competencias_fecha_inicio,competencias_fecha_final INTO
		v_categorias_codigo_competencia
	FROM tb_competencias where competencias_codigo=p_competencias_codigo;


	-- Buscamos los datos de la gnerica de prueba que actualmente se quiere grabar para saber si tambien sera multiple.
	SELECT apppruebas_multiple,pruebas_sexo,apppruebas_marca_menor,
		apppruebas_marca_mayor,c.unidad_medida_codigo,apppruebas_viento_individual
	INTO
		v_prueba_multiple_new,v_pruebas_sexo_new,v_apppruebas_marca_menor_new,
		v_apppruebas_marca_mayor_new,v_unidad_medida_codigo,v_apppruebas_viento_individual
	FROM tb_pruebas pr
		INNER JOIN tb_app_pruebas_values p ON p.apppruebas_codigo = pr.pruebas_generica_codigo
		INNER JOIN tb_pruebas_clasificacion c ON c.pruebas_clasificacion_codigo = p.pruebas_clasificacion_codigo
	where pr.pruebas_codigo = p_pruebas_codigo;

	-- Se busca el sexo del atleta
	SELECT atletas_sexo,atletas_fecha_nacimiento INTO
		v_atletas_sexo_new,v_atletas_fecha_nacimiento_new
	FROM tb_atletas at
	where at.atletas_codigo = p_atletas_codigo;

	--	raise notice 'v_atletas_sexo_new: %',v_atletas_sexo_new;
	--	raise notice 'v_pruebas_sexo_new: %',v_pruebas_sexo_new;

	-- Luego si el sexo del atleta y el sexo de la prueba corresponden.
	IF coalesce(v_atletas_sexo_new,'X') != coalesce(v_pruebas_sexo_new,'Y')
	THEN
		RAISE 'El sexo del atleta no corresponde a la de la prueba indicada, ambos deben ser iguales ' USING ERRCODE = 'restrict_violation';
	END IF;

	-- La mas dificil , si en la fecha de la prueba el atleta pertenecia a la categoria de
	-- la competencia. Para esto
	-- a) Que edad tenia el atleta en la fecha de la competencia.
	-- b) hasta que edad permite la categoria.
	select date_part( 'year'::text,p_competencias_pruebas_fecha::date)-date_part( 'year'::text,v_atletas_fecha_nacimiento_new::date) INTO
		v_agnos;

	-- Veamos en la categoria si esta dentro del rango
	-- Importante , basta que la atleta sea menor para la categoria que compitio , ya que una juvenil o menor
	-- podrian competir en una prueba de mayores , por ende si se toma como rango no
	-- funcionaria.
	IF NOT  EXISTS(SELECT 1 from tb_categorias WHERE categorias_codigo = v_categorias_codigo_competencia AND
																									 v_agnos <= categorias_edad_final )
	THEN
		-- Excepcion el atleta no esta dentro de la categoria
		RAISE 'Para la fecha % en que se realizo la prueba el atleta nacido el % , tendria % años no podria haber competido dentro de la categoria %',p_competencias_pruebas_fecha,v_atletas_fecha_nacimiento_new,v_agnos,v_categorias_codigo_competencia USING ERRCODE = 'restrict_violation';
	END IF;

	-- Si el resultado de la prueba esta dentro de los valores validos
	------------------------------------------------------------------------------------
	-- Si la prueba a grabar no es multiple , esto ya que las combinadas no conocen el resultado
	-- hasta que se ingrese su detalle y es alli donde se valida, es por esto que este campo de resultado es
	-- actualizado durante la insercionse de los detalles.
	IF v_prueba_multiple_new != TRUE -- OR (v_prueba_multiple_new = TRUE and p_is_update = '1')
	THEN
		-- Normalizamos a milisegundos , sin importar si es manual o no ya que ambas medidas deben estar en las mismas
		-- tipo de unidad o ambas son manuales o ambas electronicas. Los otros tipos de puntaje a centimetros o puntos
		-- normalizados.
		--raise notice 'marca menor : %',v_apppruebas_marca_menor_new;
		--raise notice 'marca mayor : %',v_apppruebas_marca_mayor_new;
		--raise notice 'unidad_medida : %',v_unidad_medida_codigo;
		--raise notice 'p_atletas_resultados_resultado : %',p_atletas_resultados_resultado;

		v_marcaMenorValida := fn_get_marca_normalizada(v_apppruebas_marca_menor_new, v_unidad_medida_codigo, false, 0);
		v_marcaMayorValida := fn_get_marca_normalizada(v_apppruebas_marca_mayor_new, v_unidad_medida_codigo, false, 0);
		v_marca_test := fn_get_marca_normalizada(p_atletas_resultados_resultado, v_unidad_medida_codigo, false, 0);

		IF v_marca_test < v_marcaMenorValida OR v_marca_test > v_marcaMayorValida
		THEN
			--La marca indicada esta fuera del rango permitido
			RAISE 'La marca indicada de % esta fuera del rango permitido entre % y % ', p_atletas_resultados_resultado,v_apppruebas_marca_menor_new,v_apppruebas_marca_mayor_new USING ERRCODE = 'restrict_violation';
		END IF;
	END IF;



	IF p_is_update = '1'
	THEN
		-- RAISE NOTICE 'sp_atletas_pruebas_resultados_save_record - UPDATE';

		-- La prueba debe existir (tb_competencias_pruebas) antes de actualizar
		-- de lo contrario es imposible hacer un update.
		-- Solo busca aquellas que no son parte de una combinada.
		SELECT competencias_pruebas_id,competencias_pruebas_origen_id,competencias_pruebas_tipo_serie,competencias_pruebas_nro_serie,competencias_pruebas_anemometro,
			competencias_pruebas_manual
		INTO v_competencias_pruebas_id,v_competencias_pruebas_origen_id,
			v_competencias_pruebas_tipo_serie_old,v_competencias_pruebas_nro_serie_old,v_competencias_pruebas_anemometro_old,v_competencias_pruebas_manual_old
		FROM tb_competencias_pruebas cp
		WHERE cp.competencias_pruebas_id =  (select competencias_pruebas_id from tb_atletas_resultados where atletas_resultados_id = p_atletas_resultados_id);


		--RAISE NOTICE 'v_competencias_pruebas_id %',v_competencias_pruebas_id;
		--RAISE NOTICE 'v_competencias_pruebas_origen_id %',v_competencias_pruebas_origen_id;

		IF v_competencias_pruebas_id IS  NULL
		THEN
			-- La prueba no existe
			RAISE 'Para la competencia , la prueba no se ha encontrado , esto es incorrecto durante una actualizacion de resultados'  USING ERRCODE = 'restrict_violation';
		ELSE
			-- Si la competencia existe validamos si el puesto otorgado es el correcto.
			-- Validamos que para esta prueba no existan otros atletas con el mismo puesto pero diferente resultado ,
			-- lo cual no es logico. Si el puesto es 0 no se valida ya que se toma como no conocido
			IF p_atletas_resultados_puesto > 0
			THEN
				IF EXISTS(SELECT 1
									FROM tb_competencias_pruebas pr
										inner join tb_atletas_resultados ar on pr.competencias_pruebas_id  =  ar.competencias_pruebas_id
									where   atletas_resultados_puesto=p_atletas_resultados_puesto and
													atletas_resultados_resultado != p_atletas_resultados_resultado and
													pr.competencias_pruebas_id = v_competencias_pruebas_id  and
													atletas_codigo != p_atletas_codigo)
				THEN
					RAISE 'Ya existe al menos un atleta con el mismo puesto pero diferente resultado , verifique por favor'  USING ERRCODE = 'restrict_violation';
				END IF;
			END IF;
		END IF;

		IF v_competencias_pruebas_origen_id IS NOT NULL
		THEN
			-- es parte de una combinada
			v_isFromCombinada := true;
		END IF;

		--Si es null el numero de serie le ponemos 1
		p_competencias_pruebas_nro_serie := coalesce(p_competencias_pruebas_nro_serie,1);


		-- en este caso necesitamos agregar la prueba o hacerle update si ya existe.
		-- Debemos recordar que el tipo y nro de serie hacen unica una prueba por ende si estos valores han cmbiado
		-- en realidad estamos cambiando de prueba al resultado, por ende haremos 2 cosas.
		-- 1 Tratar de agregar la prueba (se creara si no existe).
		-- Trataremos de eliminar la anterior prueba siempre que no tenga resultados adjuntos.
		IF v_competencias_pruebas_tipo_serie_old != p_competencias_pruebas_tipo_serie OR v_competencias_pruebas_nro_serie_old != p_competencias_pruebas_nro_serie
		THEN
			--RAISE NOTICE 'sp_atletas_pruebas_resultados_save_record - UPDATE - MODIFICADO COMPETENCIA PRUEBA';

			--RAISE NOTICE 'ESTA MODIFICADO';
			-- Buscamos si esta posible nueva prueba ya existe
			SELECT competencias_pruebas_id INTO v_competencias_pruebas_changed_id
			FROM tb_competencias_pruebas cp
			WHERE cp.competencias_codigo =  p_competencias_codigo AND
						cp.pruebas_codigo =  p_pruebas_codigo AND
						cp.competencias_pruebas_tipo_serie = p_competencias_pruebas_tipo_serie AND
						cp.competencias_pruebas_nro_serie = p_competencias_pruebas_nro_serie; --AND
			--cp.competencias_pruebas_origen_combinada = p_competencias_pruebas_origen_combinada;

			--Si existe un id , ya existe y actualizamos de lo contrario agregamos.
			IF v_competencias_pruebas_changed_id IS NOT NULL
			THEN
				--RAISE NOTICE 'sp_atletas_pruebas_resultados_save_record - UPDATE - MODIFICADO COMPETENCIA PRUEBA - EXISTE';


				-- Debemos actualizar la prueba
				-- Ejecutamos sin interesarnos el retorno ya que no chequearemos
				-- si fue cambiada por exo xemin (versionId) es null.
				PERFORM  sp_competencias_pruebas_save_record(
						v_competencias_pruebas_changed_id::integer,
						p_competencias_codigo,
						p_pruebas_codigo,
						NULL::integer,
						p_competencias_pruebas_fecha,
						p_competencias_pruebas_viento,
						p_competencias_pruebas_manual,
						p_competencias_pruebas_tipo_serie,
						p_competencias_pruebas_nro_serie,
						p_competencias_pruebas_anemometro,
						p_competencias_pruebas_material_reglamentario,
						p_competencias_pruebas_observaciones,
						p_atletas_resultados_protected,
						FALSE,
						TRUE, -- Aqui si debe validar el cambio de automatico/manual o viceversa ya que se esta actualizando la prueba y esto afectaria a los demas resultados.
						p_activo ,
						p_usuario,
						NULL::integer,
						1::bit);

				v_check_update_resultados_viento := TRUE;
				v_competencias_pruebas_id := v_competencias_pruebas_changed_id;
			ELSE
				--RAISE NOTICE 'sp_atletas_pruebas_resultados_save_record - UPDATE - MODIFICADO COMPETENCIA PRUEBA - NO EXISTE';

				-- Debemos agregar la prueba a la competencia ya que no existe.
				PERFORM  sp_competencias_pruebas_save_record(
						NULL::integer,
						p_competencias_codigo,
						p_pruebas_codigo,
						NULL::integer,
						p_competencias_pruebas_fecha,
						p_competencias_pruebas_viento,
						p_competencias_pruebas_manual,
						p_competencias_pruebas_tipo_serie,
						p_competencias_pruebas_nro_serie,
						p_competencias_pruebas_anemometro,
						p_competencias_pruebas_material_reglamentario,
						p_competencias_pruebas_observaciones,
						p_atletas_resultados_protected,
						FALSE,
						FALSE,
						p_activo ,
						p_usuario,
						NULL::integer,
						0::bit);

				-- Si se ha grabado obtenemos el id.
				SELECT competencias_pruebas_id INTO v_competencias_pruebas_id
				FROM tb_competencias_pruebas cp
				WHERE cp.competencias_codigo =  p_competencias_codigo AND
							cp.pruebas_codigo =  p_pruebas_codigo AND
							cp.competencias_pruebas_tipo_serie = p_competencias_pruebas_tipo_serie AND
							cp.competencias_pruebas_nro_serie = p_competencias_pruebas_nro_serie; --AND
				--cp.competencias_pruebas_origen_combinada = p_competencias_pruebas_origen_combinada;


			END IF;

		ELSE
			--RAISE NOTICE 'NOOOOOOO ESTA MODIFICADO';
			-- Grabamos cambios a la prueba
			select * from (
											select sp_competencias_pruebas_save_record(
																 v_competencias_pruebas_id::integer,
																 p_competencias_codigo,
																 p_pruebas_codigo,
																 NULL::integer,
																 p_competencias_pruebas_fecha,
																 p_competencias_pruebas_viento,
																 p_competencias_pruebas_manual,
																 p_competencias_pruebas_tipo_serie,
																 p_competencias_pruebas_nro_serie,
																 p_competencias_pruebas_anemometro,
																 p_competencias_pruebas_material_reglamentario,
																 p_competencias_pruebas_observaciones,
																 p_atletas_resultados_protected,
																 FALSE,
																 FALSE,
																 p_activo ,
																 p_usuario,
																 NULL::integer,
																 1::bit) as updins) as ans
			into v_prueba_saved
			where updins is not null;

			--RAISE NOTICE 'GRABO LA COMPETENCIA';

			IF v_prueba_saved != 1
			THEN
				-- La prueba no existe
				RAISE 'Error actualizando la prueba....'  USING ERRCODE = 'restrict_violation';
			END IF;

			v_check_update_resultados_viento := TRUE;
		END IF;

		-- Si el tipo de de cronometraje manual cambia de estado solo se permitira cambiarlo si solo existe un resultaodo qe seria
		-- justo este que vamos a hacer update.
		IF v_competencias_pruebas_manual_old != p_competencias_pruebas_manual
		THEN
			v_can_modify := (select fn_can_modify_manual_status(v_competencias_pruebas_id,p_atletas_resultados_id,'update'))::INTEGER;
			IF v_can_modify = 0
			THEN
				IF v_competencias_pruebas_manual_old = TRUE
				THEN
					RAISE 'No puede cambiarse el estado manual de la prueba ya que existen mas resultados ya con resultados asignados con el cronometraje manual'  USING ERRCODE = 'restrict_violation';
				ELSE
					RAISE 'No puede cambiarse el estado manual de la prueba ya que existen mas resultados ya con resultados asignados con el cronometraje electronico'  USING ERRCODE = 'restrict_violation';
				END IF;
			END IF;
		END IF;

		-- El  update
		-- Se hace el update del resultado , de ser un resultado de una prueba que es parte de una prueba
		-- combinada o multiple se hace el update de la principal con la nueva suma total de puntos acumulados.
		UPDATE
			tb_atletas_resultados
		SET
			atletas_resultados_id = p_atletas_resultados_id,
			competencias_pruebas_id = v_competencias_pruebas_id,
			atletas_codigo =  p_atletas_codigo,
			-- Si la prueba es multiple el update no modifica el valor del resultado ya que este es actualizado
			-- cada vez que se inserta o modifica un detalle , de lo contrario si se actualiza de acuerdo al parametro
			atletas_resultados_resultado =  (case when v_prueba_multiple_new = true then atletas_resultados_resultado else p_atletas_resultados_resultado end),
			atletas_resultados_puntos =  (case when v_prueba_multiple_new = false and v_isFromCombinada = true then p_atletas_resultados_puntos else atletas_resultados_puntos end),
			atletas_resultados_puesto =  p_atletas_resultados_puesto,
			-- el viento solo si es una prueba que la requiera individualmente y no sea la principal combinada.
			-- Si requiere viento pero no tiene anemomentro se colocara null ya que no se conoce el viento.
			atletas_resultados_viento = (case when coalesce(v_prueba_multiple_new,false) = TRUE
				THEN NULL
																	 ELSE (case when v_apppruebas_viento_individual = TRUE AND p_competencias_pruebas_anemometro = true then p_competencias_pruebas_viento else NULL end)
																	 END),
			atletas_resultados_protected =  p_atletas_resultados_protected,
			activo = p_activo,
			usuario_mod = p_usuario
		WHERE atletas_resultados_id = p_atletas_resultados_id  and xmin =p_version_id ;

		--RAISE NOTICE  'COUNT ID --> %', FOUND;

		-- Todo ok , si es una prueba parte de una combinada actualizamos el total de puntos
		-- en la principal.
		IF FOUND THEN
			--RAISE NOTICE  'ACTUALIZA EL RESULTADO';
			--RAISE NOTICE 'sp_atletas_pruebas_resultados_save_record - UPDATE tb_competencias_pruebas t1';

			-- Vemos si alguna prueba de esta competencia tiene datos que invalidan la prueba , ya sea anemometro , material , o si
			-- el resultado es manual , para asi actualizar la prueba principal.
			UPDATE tb_competencias_pruebas t1
			SET
				competencias_pruebas_manual = (case when t2.cpm > 0 then TRUE else FALSE end),
				competencias_pruebas_anemometro = (case when t2.cpa > 0 then FALSE else TRUE end),
				competencias_pruebas_material_reglamentario = (case when t2.cpmr > 0 then FALSE else TRUE end)
			FROM (
						 select
							 max(competencias_pruebas_origen_id) as competencias_pruebas_origen_id,
							 sum((case when competencias_pruebas_manual = TRUE then 1 else 0 end)) as cpm,
							 sum((case when competencias_pruebas_anemometro = FALSE then 1 else 0 end)) as cpa,
							 sum((case when competencias_pruebas_material_reglamentario = FALSE then 1 else 0 end)) as cpmr
						 from tb_competencias_pruebas where competencias_pruebas_origen_id=v_competencias_pruebas_origen_id

					 ) t2
			WHERE  t1.competencias_pruebas_id=t2.competencias_pruebas_origen_id;

			-- Si es parte de una combinada actualizo el resultado de la principal.
			IF v_isFromCombinada = TRUE
			THEN
				UPDATE
					tb_atletas_resultados
				SET
					atletas_resultados_resultado =  (
						select sum(atletas_resultados_puntos) from tb_atletas_resultados
						where competencias_pruebas_id in  (
							select distinct competencias_pruebas_id from tb_competencias_pruebas
							where competencias_pruebas_origen_id=v_competencias_pruebas_origen_id))
				WHERE competencias_pruebas_id = v_competencias_pruebas_origen_id AND atletas_codigo = p_atletas_codigo;
			END IF;

			IF v_check_update_resultados_viento = TRUE AND v_competencias_pruebas_anemometro_old != p_competencias_pruebas_anemometro
			THEN
				PERFORM sp_atletas_pruebas_resultado_clear_viento(v_competencias_pruebas_id, p_competencias_pruebas_anemometro,v_apppruebas_viento_individual, p_usuario);
			END IF;

			RETURN 1;
		ELSE
			--RAISE '' USING ERRCODE = 'record modified';
			RETURN null;
		END IF;

	ELSE
		-- En el caso de agregar un resultado , verificamos si ya existe la prueba , de existir usamo el id
		-- de lo ocntrario creamos la prueba, en la competencia reqquerida.
		-- La prueba debe existir (tb_competencias_pruebas) antes de actualizar
		-- de lo contrario es imposible hacer un update.
		-- Asi mismo no puede ser parte de una combinada (cp.competencias_pruebas_origen_combinada = FALSE)
		--RAISE NOTICE 'El origen combinada a chequear es %',p_competencias_pruebas_origen_combinada;
		--RAISE NOTICE 'v_competencias_pruebas_id %',v_competencias_pruebas_id;

		--RAISE NOTICE 'sp_atletas_pruebas_resultados_save_record - ADD';

		SELECT competencias_pruebas_id ,competencias_pruebas_origen_id ,competencias_pruebas_anemometro,competencias_pruebas_manual
		INTO v_competencias_pruebas_id ,v_competencias_pruebas_origen_id,v_competencias_pruebas_anemometro_old,v_competencias_pruebas_manual_old
		FROM tb_competencias_pruebas cp
		WHERE cp.competencias_codigo =  p_competencias_codigo AND
					cp.pruebas_codigo =  p_pruebas_codigo AND
					cp.competencias_pruebas_tipo_serie = p_competencias_pruebas_tipo_serie AND
					cp.competencias_pruebas_nro_serie = p_competencias_pruebas_nro_serie; --AND
		--cp.competencias_pruebas_origen_combinada = p_competencias_pruebas_origen_combinada;


		--RAISE NOTICE 'v_competencias_pruebas_id %',v_competencias_pruebas_id;

		-- Si  la prueba es parte de una combinada ya sea porque tiene un origen o la misma prueba sea parte de una combinada
		-- verificado a traves de si esta en algun detalle de combinada (tb_pruebas_detalle)
		-- No se permite ingresar por este lado.
		IF v_competencias_pruebas_origen_id IS NOT NULL OR EXISTS(select 1 from tb_pruebas_detalle where pruebas_detalle_prueba_codigo = p_pruebas_codigo)
		THEN
			-- La prueba requiere se indique el viento
			RAISE 'Los resultados para las pruebas que componen una combinada no pueden agregarse  individualmente, agregue la prueba combinada'  USING ERRCODE = 'restrict_violation';
		END IF;

		-- Si la prueba no existe la creamos
		IF v_competencias_pruebas_id IS NULL
		THEN

			--RAISE NOTICE 'sp_atletas_pruebas_resultados_save_record - ADD - v_competencias_pruebas_id __ISNULL';

			-- La prueba multiple usara siempre estos defaults, para grabarse
			IF coalesce(v_prueba_multiple_new,false) = TRUE
			THEN
				p_competencias_pruebas_tipo_serie := 'FI';
				p_competencias_pruebas_nro_serie := 1;

				-- La prueba multiple usara siempre estos defaults.
				p_competencias_pruebas_viento := NULL;
				p_competencias_pruebas_manual := FALSE;
				p_competencias_pruebas_anemometro := TRUE;
				p_competencias_pruebas_material_reglamentario := TRUE;

			END IF;

			-- Si es null el numero de serie le ponemos 1
			p_competencias_pruebas_nro_serie := coalesce(p_competencias_pruebas_nro_serie,1);

			-- Debemos agregar la prueba a la competencia ya que no existe.
			PERFORM  sp_competencias_pruebas_save_record(
					NULL::integer,
					p_competencias_codigo,
					p_pruebas_codigo,
					NULL::integer,
					p_competencias_pruebas_fecha,
					p_competencias_pruebas_viento,
					p_competencias_pruebas_manual,
					p_competencias_pruebas_tipo_serie,
					p_competencias_pruebas_nro_serie,
					p_competencias_pruebas_anemometro,
					p_competencias_pruebas_material_reglamentario,
					p_competencias_pruebas_observaciones,
					p_atletas_resultados_protected,
					FALSE,
					FALSE,
					p_activo ,
					p_usuario,
					NULL::integer,
					0::bit);


			v_competencias_pruebas_manual_old := p_competencias_pruebas_manual;

			-- Si se ha grabado obtenemos el id.
			SELECT competencias_pruebas_id INTO v_competencias_pruebas_id
			FROM tb_competencias_pruebas cp
			WHERE cp.competencias_codigo =  p_competencias_codigo AND
						cp.pruebas_codigo =  p_pruebas_codigo AND
						cp.competencias_pruebas_tipo_serie = p_competencias_pruebas_tipo_serie AND
						cp.competencias_pruebas_nro_serie = p_competencias_pruebas_nro_serie; --AND
			-- cp.competencias_pruebas_origen_combinada = p_competencias_pruebas_origen_combinada;
			--
			-- 			RAISE NOTICE 'v_competencias_pruebas_id %',v_competencias_pruebas_id;
			-- 			RAISE NOTICE 'p_competencias_codigo %',p_competencias_codigo;
			-- 			RAISE NOTICE 'p_pruebas_codigo %',p_pruebas_codigo;
			-- 			RAISE NOTICE 'p_competencias_pruebas_tipo_serie %',p_competencias_pruebas_tipo_serie;
			-- 			RAISE NOTICE 'p_competencias_pruebas_nro_serie %',p_competencias_pruebas_nro_serie;
			-- 			RAISE NOTICE 'p_competencias_pruebas_origen_combinada %',p_competencias_pruebas_origen_combinada;

		ELSE
			-- EXISTE LA COMPETENCIA PERO EL RESULTADO DEL ATLETA ES NUEVO
			----------------------------------------------------------------------------------------------

			-- Si la competencia existe validamos si el puesto otorgado es el correcto.
			-- Validamos que para esta prueba no existan otros atletas con el mismo puesto pero diferente resultado ,
			-- lo cual no es logico. Si el puesto es 0 no se valida ya que se toma como no conocido
			IF p_atletas_resultados_puesto > 0
			THEN
				IF EXISTS(SELECT 1
									FROM tb_competencias_pruebas pr
										inner join tb_atletas_resultados ar on pr.competencias_pruebas_id  =  ar.competencias_pruebas_id
									where   atletas_resultados_puesto=p_atletas_resultados_puesto and
													atletas_resultados_resultado != p_atletas_resultados_resultado and
													pr.competencias_pruebas_id = v_competencias_pruebas_id  and
													atletas_codigo != p_atletas_codigo)
				THEN
					RAISE 'Ya existe al menos un atleta con el mismo puesto pero diferente resultado , verifique por favor'  USING ERRCODE = 'restrict_violation';
				END IF;
			END IF;


			-- Si la prueba existe entonces vemos si debemos actualizarla , para esto ya que podria
			-- haber cambiado el status de manual , material reglamentario,viento si la prueba
			-- requiere viento general, etc

			--RAISE NOTICE 'REGRABANDO LA COMPETENCIA';
			-- Grabamos cambios a la prueba
			select * from (
											select sp_competencias_pruebas_save_record(
																 v_competencias_pruebas_id::integer,
																 p_competencias_codigo,
																 p_pruebas_codigo,
																 NULL::integer,
																 p_competencias_pruebas_fecha,
																 p_competencias_pruebas_viento,
																 p_competencias_pruebas_manual,
																 p_competencias_pruebas_tipo_serie,
																 p_competencias_pruebas_nro_serie,
																 p_competencias_pruebas_anemometro,
																 p_competencias_pruebas_material_reglamentario,
																 p_competencias_pruebas_observaciones,
																 p_atletas_resultados_protected,
																 FALSE,
																 FALSE,
																 p_activo ,
																 p_usuario,
																 NULL::integer,
																 1::bit) as updins) as ans
			into v_prueba_saved
			where updins is not null;

			--RAISE NOTICE 'REGRABO LA COMPETENCIA';

			IF v_prueba_saved != 1
			THEN
				-- La prueba no existe
				RAISE 'Error actualizando la prueba....'  USING ERRCODE = 'restrict_violation';
			END IF;

			v_check_update_resultados_viento := TRUE;

		END IF;


		-- Si el tipo de de cronometraje manual cambia de estado solo se permitira cambiarlo si no exiten resultados asignados antes del add
		IF v_competencias_pruebas_manual_old != p_competencias_pruebas_manual
		THEN
			--RAISE 'cpid = % , arid = %',v_competencias_pruebas_id,p_atletas_resultados_id  USING ERRCODE = 'restrict_violation';
			v_can_modify := (select fn_can_modify_manual_status(v_competencias_pruebas_id,null,'add'))::INTEGER;
			IF v_can_modify = 0
			THEN
				IF v_competencias_pruebas_manual_old = TRUE
				THEN
					RAISE 'No puede cambiarse el estado manual de la prueba ya que existen mas resultados ya con resultados asignados con el cronometraje manual'  USING ERRCODE = 'restrict_violation';
				ELSE
					RAISE 'No puede cambiarse el estado manual de la prueba ya que existen mas resultados ya con resultados asignados con el cronometraje electronico'  USING ERRCODE = 'restrict_violation';
				END IF;
			END IF;
		END IF;


		--RAISE notice 'El id de la competencia prueba es %',v_competencias_pruebas_id;
		--RAISE NOTICE 'sp_atletas_pruebas_resultados_save_record - ADD - tb_atletas_resultados ';

		-- Con el id de la prueba creada o existente grabamos el resultado.
		INSERT INTO
			tb_atletas_resultados
			(
				competencias_pruebas_id,
				atletas_codigo,
				atletas_resultados_resultado,
				atletas_resultados_puesto,
				atletas_resultados_puntos,
				atletas_resultados_viento,
				atletas_resultados_protected,
				activo,
				usuario)
		VALUES(
			v_competencias_pruebas_id,
			p_atletas_codigo,
			(case when coalesce(v_prueba_multiple_new,false) = TRUE then  '' else p_atletas_resultados_resultado end),
			p_atletas_resultados_puesto,
			0,
			-- el viento solo si es una prueba que la requiera individualmente y no sea la principal combinada.
			-- si requiere el viento debe estar prendido el anemometro de lo contrario el viento sera null
			(case when coalesce(v_prueba_multiple_new,false) = TRUE
				THEN NULL
			 ELSE (case when v_apppruebas_viento_individual = TRUE AND p_competencias_pruebas_anemometro = true then p_competencias_pruebas_viento else NULL end)
			 END),
			p_atletas_resultados_protected,
			p_activo,
			p_usuario);


		-- Durante un add si La prueba es multiple , se agregan los detalles correspondientes.
		-- y las pruebas de la competencia.
		IF coalesce(v_prueba_multiple_new,false) = TRUE
		THEN

			-- Iniciamos el insert de todas las pruebas que componen la mltiple o combinada
			INSERT INTO
				tb_atletas_resultados
				(
					competencias_pruebas_id,
					atletas_codigo,
					atletas_resultados_resultado,
					atletas_resultados_puesto,
					atletas_resultados_puntos,
					atletas_resultados_viento,
					atletas_resultados_protected,
					activo,
					usuario)
				SELECT
					cp.competencias_pruebas_id,
					p_atletas_codigo,
					0,
					0,
					0,
					NULL,
					p_atletas_resultados_protected,
					p_activo,
					p_usuario
				FROM tb_competencias_pruebas cp
					INNER JOIN tb_pruebas_detalle p on p.pruebas_detalle_prueba_codigo  = cp.pruebas_codigo
				WHERE cp.competencias_pruebas_origen_id = v_competencias_pruebas_id
				order by pruebas_detalle_orden;
		END IF;

		-- Si debe chequearse , entonces si se dan las condiciones debemos poner en blanco todas las pruebas individuales que tenian viento.
		IF v_check_update_resultados_viento = TRUE AND v_competencias_pruebas_anemometro_old != p_competencias_pruebas_anemometro
		THEN
			PERFORM sp_atletas_pruebas_resultado_clear_viento(v_competencias_pruebas_id, p_competencias_pruebas_anemometro,v_apppruebas_viento_individual, p_usuario);
		END IF;

		RETURN 1;

	END IF;
END;
$$;


ALTER FUNCTION public.sp_atletas_pruebas_resultados_save_record(p_atletas_resultados_id integer, p_atletas_codigo character varying, p_competencias_codigo character varying, p_pruebas_codigo character varying, p_competencias_pruebas_fecha date, p_competencias_pruebas_viento numeric, p_competencias_pruebas_tipo_serie character varying, p_competencias_pruebas_nro_serie integer, p_competencias_pruebas_anemometro boolean, p_competencias_pruebas_material_reglamentario boolean, p_competencias_pruebas_manual boolean, p_competencias_pruebas_observaciones character varying, p_atletas_resultados_resultado character varying, p_atletas_resultados_puntos integer, p_atletas_resultados_puesto integer, p_atletas_resultados_protected boolean, p_activo boolean, p_usuario character varying, p_version_id integer, p_is_update bit) OWNER TO atluser;

--
-- TOC entry 255 (class 1255 OID 16430)
-- Name: sp_atletas_resultados_delete_record(integer, boolean, character varying, integer); Type: FUNCTION; Schema: public; Owner: atluser
--

CREATE FUNCTION sp_atletas_resultados_delete_record(p_atletas_resultados_id integer, p_include_prueba boolean, p_usuario_mod character varying, p_version_id integer) RETURNS integer
LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 01-04-2014

Stored procedure que elimina un resultado de atleta , si es una prueba combinada elimina
tambien los resultados de las pruebas asociadas.
Si el paramtero p_include_prueba es TRUE debemos eliminar tambien la prueba de la competencia , pero si  y solo si
no tiene otros resultados adjuntos.

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

	select * from ( select sp_atletas_resultados_delete_record(?,?,etc) as updins) as ans where updins is not null;

	de tal forma que retornara un registro si el delete funciono , y 0 registros si no se realizo
	el delete. Esto es conveniente cuando se usa por ejemplo el affected_rows de algunos drivers.
	EN OTRAS BASES ESTO NO ES NECESARIO.
Historia : Creado 03-02-2014
*/
DECLARE v_competencias_pruebas_origen_id integer;
				DECLARE v_competencias_pruebas_id integer;
				DECLARE v_atletas_codigo character varying(15);

BEGIN

	-- Busco a que atleta pertenece el resultado.
	SELECT atletas_codigo INTO
		v_atletas_codigo
	FROM tb_atletas_resultados WHERE atletas_resultados_id = p_atletas_resultados_id and xmin=p_version_id;

	-- Verificacion previa que el registro no esgta modificado, con esto basta si v_atletas_codigo es no null
	-- a que significaria que ha encontrado el registro.
	--
	-- Existe una pequeñisima oportunidad que el registro sea alterado entre el exist y el delete
	-- pero dado que es intranscendente no es importante crear una sub transaccion para solo
	-- verificar eso , por ende es mas que suficiente solo esta previa verificacion por exist.
	IF  v_atletas_codigo IS NOT NULL THEN

		-- Vemos si esta resultado es parte de una prueba combinada
		-- o si es el resultado de una prueba combinada.
		SELECT competencias_pruebas_id,competencias_pruebas_origen_id
		INTO v_competencias_pruebas_id,v_competencias_pruebas_origen_id
		FROM tb_competencias_pruebas cp
		WHERE cp.competencias_pruebas_id =  (select competencias_pruebas_id from tb_atletas_resultados where atletas_resultados_id = p_atletas_resultados_id);

		--
		IF v_competencias_pruebas_origen_id IS NOT NULL
		THEN
			-- La prueba no existe
			RAISE 'Un resultado que es parte de una prueba combinada no puede eliminarse independientemente , borre los resultados de la prueba principal' USING ERRCODE = 'restrict_violation';
		END IF;

		-- Eliminamosla pricipal y las asociadas en caso de que a prueba sea multiple
		DELETE FROM
			tb_atletas_resultados
		WHERE (atletas_resultados_id = p_atletas_resultados_id
					 OR competencias_pruebas_id in (
			select competencias_pruebas_id
			from tb_competencias_pruebas
			where competencias_pruebas_origen_id=v_competencias_pruebas_id
		))
					AND atletas_codigo =v_atletas_codigo;

		IF FOUND THEN
			-- Si se requiere que se elimine a prueba tambien , entonces se hara si y solo si
			-- dicha prueba o las adjuntas en caso de combinadas no tienen otros resultados adjuntos.
			IF p_include_prueba = TRUE
			THEN
				IF NOT EXISTS(select 1 from tb_atletas_resultados where competencias_pruebas_id = v_competencias_pruebas_id OR
																																competencias_pruebas_id
																																in(select competencias_pruebas_id from tb_competencias_pruebas where competencias_pruebas_origen_id=v_competencias_pruebas_id))
				THEN
					DELETE FROM
						tb_competencias_pruebas
					WHERE competencias_pruebas_id = v_competencias_pruebas_id OR
								competencias_pruebas_origen_id=v_competencias_pruebas_id;
				END IF;
			END IF;

			RETURN 1;
		ELSE
			RETURN null;
		END IF;

	ELSE
		RETURN null;
	END IF;

END;
$$;


ALTER FUNCTION public.sp_atletas_resultados_delete_record(p_atletas_resultados_id integer, p_include_prueba boolean, p_usuario_mod character varying, p_version_id integer) OWNER TO atluser;

--
-- TOC entry 295 (class 1255 OID 37746)
-- Name: sp_atletas_resultados_save_record(integer, character varying, integer, integer, character varying, integer, integer, numeric, boolean, boolean, character varying, integer, bit); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_atletas_resultados_save_record(p_atletas_resultados_id integer, p_atletas_codigo character varying, p_competencias_pruebas_id integer, p_postas_id integer, p_atletas_resultados_resultado character varying, p_atletas_resultados_puntos integer, p_atletas_resultados_puesto integer, p_atletas_resultados_viento numeric, p_atletas_resultados_protected boolean, p_activo boolean, p_usuario character varying, p_version_id integer, p_is_update bit) RETURNS integer
LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 08-10-2013

Stored procedure que agrega o actualiza los registros de los resultados de las pruebas.
Previamente hace todas las validaciones necesarias para garantizar que los datos sean grabados
consistentemente,


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

select * from ( select sp_atletas_resultados_save_record(?,?,etc) as updins) as ans where updins is not null;

de tal forma que retornara un registro si el update funciono o el insert , y 0 registros si no se realizo
el uodate. sto es conveniente cuando se usa por ejemplo el affected_rows de algunos drivers.
EN OTRAS BASES ESTO NO ES NECESARIO.

Historia : Creado 15-01-2014
*/
DECLARE v_prueba_multiple BOOLEAN = FALSE;
				DECLARE           v_categorias_codigo CHARACTER VARYING (15);
				DECLARE           v_pruebas_sexo_new CHARACTER(1);
				DECLARE           v_atletas_sexo_new CHARACTER(1);
				DECLARE           v_atletas_fecha_nacimiento_new DATE;
				DECLARE           v_apppruebas_marca_menor_new CHARACTER VARYING (12);
				DECLARE           v_apppruebas_marca_mayor_new CHARACTER VARYING (12);
				DECLARE           v_apppruebas_verifica_viento BOOLEAN = FALSE;
				DECLARE           v_agnos INT;
				DECLARE           v_marca_test INTEGER;
				DECLARE           v_unidad_medida_codigo CHARACTER VARYING (8);
				DECLARE           v_marcaMenorValida INTEGER;
				DECLARE           v_marcaMayorValida INTEGER;
				DECLARE           v_competencias_pruebas_id INTEGER;
				DECLARE           v_competencias_pruebas_origen_id INTEGER;
				DECLARE           v_apppruebas_viento_individual BOOLEAN;
				DECLARE           v_pruebas_codigo CHARACTER VARYING (15);
				DECLARE           v_competencias_pruebas_fecha DATE;
				DECLARE           v_competencias_pruebas_anemometro BOOLEAN;
				DECLARE           v_apppruebas_nro_atletas INTEGER;
BEGIN
	-----------------------------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------------
	-- VALIDACIONES PRIMARIAS DE INTEGRIDAD LOGICA
	-----------------------------------------------------------------------------------------------------------
	-- Si es posta , esta esta ascoiada a la competencia?
	IF p_postas_id IS NOT NULL
	THEN
		IF NOT EXISTS(SELECT 1
									FROM tb_postas
									WHERE postas_id = p_postas_id AND competencias_pruebas_id = p_competencias_pruebas_id)
		THEN
			RAISE 'La posta no pertenece a la esta competencia / prueba'
			USING ERRCODE = 'restrict_violation';
		END IF;
	END IF;

	-- La prueba debe existir (tb_competencias_pruebas) antes de actualizar
	-- de lo contrario es imposible hacer un update.
	-- Solo busca aquellas que no son parte de una combinada.
	SELECT
		competencias_pruebas_id,
		competencias_pruebas_origen_id,
		pruebas_codigo,
		competencias_pruebas_fecha,
		categorias_codigo,
		competencias_pruebas_anemometro
	INTO
		v_competencias_pruebas_id, v_competencias_pruebas_origen_id, v_pruebas_codigo, v_competencias_pruebas_fecha,
		v_categorias_codigo, v_competencias_pruebas_anemometro
	FROM tb_competencias_pruebas cp
		INNER JOIN tb_competencias c ON c.competencias_codigo = cp.competencias_codigo
	WHERE cp.competencias_pruebas_id = p_competencias_pruebas_id;


	IF v_competencias_pruebas_id IS NULL
	THEN
		-- La prueba no existe
		RAISE 'La prueba no se ha encontrado en la competencia indicada, los resultados solo pueden agregarse a competencias existentes'
		USING ERRCODE = 'restrict_violation';
	END IF;

	-- En las combinadas un atleta solo puede realizar una vez la prueba ya que no existin semifinales y finales sino
	-- solo se agrupan pero el resultado es consolidado. Solo se verifica al agregar no al actualizar
	IF v_competencias_pruebas_origen_id IS NOT NULL AND p_is_update != '1'
	THEN
		IF EXISTS(SELECT 1
							FROM tb_competencias_pruebas cp
								INNER JOIN tb_atletas_resultados ar ON ar.competencias_pruebas_id = cp.competencias_pruebas_id
							WHERE cp.pruebas_codigo = v_pruebas_codigo AND
										competencias_pruebas_origen_id = v_competencias_pruebas_origen_id AND
										atletas_codigo = p_atletas_codigo)
		THEN
			RAISE 'El atleta ya registra resultado para dicha prueba, en el caso de las combinadas no puede realizar una prueba mas de una vez'
			USING ERRCODE = 'restrict_violation';
		END IF;
	END IF;

	-- Buscamos los datos de la prueba que actualmente se quiere grabar para otras validaciones.
	SELECT
		pruebas_sexo,
		apppruebas_marca_menor,
		apppruebas_marca_mayor,
		apppruebas_verifica_viento,
		c.unidad_medida_codigo,
		apppruebas_viento_individual,
		apppruebas_multiple,
		apppruebas_nro_atletas
	INTO
		v_pruebas_sexo_new, v_apppruebas_marca_menor_new,
		v_apppruebas_marca_mayor_new, v_apppruebas_verifica_viento,
		v_unidad_medida_codigo, v_apppruebas_viento_individual, v_prueba_multiple,
		v_apppruebas_nro_atletas
	FROM tb_pruebas pr
		INNER JOIN tb_app_pruebas_values p ON p.apppruebas_codigo = pr.pruebas_generica_codigo
		INNER JOIN tb_pruebas_clasificacion c ON c.pruebas_clasificacion_codigo = p.pruebas_clasificacion_codigo
	WHERE pr.pruebas_codigo = v_pruebas_codigo;

	-- Seteamos el codigo de atleta si es una posta ya que en ese caso para cumplir con
	-- la integridad referencial forzamos un atleta reservado para cada sexo.
	IF p_postas_id IS NOT NULL
	THEN
		IF v_pruebas_sexo_new = 'F'
		THEN
			p_atletas_codigo := 'POSTAF';
		ELSE
			p_atletas_codigo :='POSTAM';
		END IF;
	END IF;

	-- Si es el registro de la prueba principal de una combinada , no permitimos
	-- agregar ya que esta es dependiente de las pruebas que la componen y
	-- depende de los cambios en sus componentes para modificarse.
	-- La actualizacion solo actualizara el puesto
	IF coalesce(v_prueba_multiple, FALSE) = TRUE AND p_is_update != '1'
	THEN
		-- La prueba no existe
		RAISE 'Solo resultados para pruebas dentro de una combinada son permitidos'
		USING ERRCODE = 'restrict_violation';
	END IF;

	-- Busco el sexo del atleta
	SELECT
		atletas_sexo,
		atletas_fecha_nacimiento
	INTO
		v_atletas_sexo_new, v_atletas_fecha_nacimiento_new
	FROM tb_atletas at
	WHERE at.atletas_codigo = p_atletas_codigo;

	-- Luego si el sexo del atleta y el sexo de la prueba corresponden.
	IF coalesce(v_atletas_sexo_new, 'X') != coalesce(v_pruebas_sexo_new, 'Y')
	THEN
		RAISE 'El sexo del atleta no corresponde a la de la prueba indicada, ambos deben ser iguales '
		USING ERRCODE = 'restrict_violation';
	END IF;

	-- Solo validamos la edad en el caso que no sea posta ya que para las postas
	-- se usa un atleta generico.
	IF p_postas_id IS NULL
	THEN
		-- La mas dificil , si en la fecha de la prueba el atleta pertenecia a la categoria de
		-- la competencia. Para esto
		-- a) Que edad tenia el atleta en la fecha de la competencia.
		-- b) hasta que edad permite la categoria.
		SELECT date_part('year' :: TEXT, v_competencias_pruebas_fecha :: DATE) -
					 date_part('year' :: TEXT, v_atletas_fecha_nacimiento_new :: DATE)
		INTO
			v_agnos;

		-- Veamos en la categoria si esta dentro del rango
		-- Importante , basta que la atleta sea menor para la categoria que compitio , ya que una juvenil o menor
		-- podrian competir en una prueba de mayores , por ende si se toma como rango no
		-- funcionaria.
		IF NOT EXISTS(SELECT 1
									FROM tb_categorias
									WHERE categorias_codigo = v_categorias_codigo AND
												v_agnos <= categorias_edad_final)
		THEN
			-- Excepcion el atleta no esta dentro de la categoria
			RAISE 'Para la fecha % en que se realizo la prueba el atleta nacido el % , tendria % años no podria haber competido dentro de la categoria %', v_competencias_pruebas_fecha, v_atletas_fecha_nacimiento_new, v_agnos, v_categorias_codigo
			USING ERRCODE = 'restrict_violation';
		END IF;
	END IF;
	-- Si el resultado de la prueba esta dentro de los valores validos
	------------------------------------------------------------------------------------

	-- Normalizamos a milisegundos , sin importar si es manual o no ya que ambas medidas deben estar en las mismas
	-- tipo de unidad o ambas son manuales o ambas electronicas. Los otros tipos de puntaje a centimetros o puntos
	-- normalizados.
	v_marcaMenorValida := fn_get_marca_normalizada(v_apppruebas_marca_menor_new, v_unidad_medida_codigo, FALSE, 0);
	v_marcaMayorValida := fn_get_marca_normalizada(v_apppruebas_marca_mayor_new, v_unidad_medida_codigo, FALSE, 0);
	v_marca_test := fn_get_marca_normalizada(p_atletas_resultados_resultado, v_unidad_medida_codigo, FALSE, 0);

	IF v_marca_test < v_marcaMenorValida OR v_marca_test > v_marcaMayorValida
	THEN
		--La marca indicada esta fuera del rango permitido
		RAISE 'La marca indicada de % esta fuera del rango permitido entre % y % ', p_atletas_resultados_resultado, v_apppruebas_marca_menor_new, v_apppruebas_marca_mayor_new
		USING ERRCODE = 'restrict_violation';
	END IF;

	-- Si se indica marca , deben indicarse puntos , por aqui solo se graban los componentes de la
	-- conmbinada o pruebas normales, dado validacion anterior
	IF v_competencias_pruebas_origen_id IS NOT NULL
	THEN
		IF v_marca_test != 0 AND coalesce(p_atletas_resultados_puntos, 0) = 0 OR
			 v_marca_test = 0 AND coalesce(p_atletas_resultados_puntos, 0) != 0
		THEN
			RAISE 'Si la marca o puntos son mayores que cero , ambos deben estar indicados '
			USING ERRCODE = 'restrict_violation';
		END IF;
	END IF;

	-- Validamos si se indica posta y es en realidad una.
	IF v_apppruebas_nro_atletas > 1
	THEN
		IF p_postas_id IS NULL
		THEN
			RAISE 'La prueba es de postas y no se indica la posta asociada al resultado'
			USING ERRCODE = 'restrict_violation';
		END IF;
	ELSE
		IF p_postas_id IS NOT NULL
		THEN
			RAISE 'La prueba no es una posta y el resultado indica una posta'
			USING ERRCODE = 'restrict_violation';
		END IF;
	END IF;

	-----------------------------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------------
	-- OK paso todas las validaciones basicas , ahora veamos si la prueba tiene control de viento
	-- y ver si el viento esta indicado, hay que recordar que en los resultados de atletas el viento
	-- solo sera indicado si la prueba requiere viento individual por atleta , digase el saltor largo, triple,etc
	-- en otros casos no es aplicable.
	IF v_apppruebas_verifica_viento = TRUE AND v_apppruebas_viento_individual = TRUE
	THEN
		IF p_atletas_resultados_viento IS NULL
		THEN
			IF v_competencias_pruebas_anemometro = TRUE
			THEN
				-- La prueba requiere se indique el viento
				RAISE 'La prueba requiere se indique el limite de viento'
				USING ERRCODE = 'restrict_violation';
			ELSE
				-- Sin anemometro no hay viento tomado.
				p_atletas_resultados_viento := NULL;
			END IF;
		END IF;
	ELSE
		-- Si no requiere viento lo ponemos en null , por si acaso se envie dato por gusto.
		p_atletas_resultados_viento := NULL;
	END IF;

	-- Validamos que para esta prueba no existan otros atletas con el mismo puesto pero diferente resultado ,
	-- lo cual no es logico. el puesto 0 no necesita verificarse ya que se asume que no se conoce.
	IF v_apppruebas_nro_atletas > 1
	THEN
		IF EXISTS(SELECT 1
							FROM tb_competencias_pruebas pr
								INNER JOIN tb_atletas_resultados ar ON pr.competencias_pruebas_id = ar.competencias_pruebas_id
							WHERE atletas_resultados_puesto = p_atletas_resultados_puesto AND
										atletas_resultados_resultado != p_atletas_resultados_resultado AND
										pr.competencias_pruebas_id = p_competencias_pruebas_id AND
										atletas_codigo = p_atletas_codigo)

		THEN
			RAISE 'Ya existe al menos un atleta con el mismo puesto pero diferente resultado , verifique por favor'
			USING ERRCODE = 'restrict_violation';
		END IF;
	END IF;

	IF p_atletas_resultados_puesto > 0
	THEN
		IF v_apppruebas_nro_atletas > 1
		THEN
			IF EXISTS(SELECT 1
								FROM tb_competencias_pruebas pr
									INNER JOIN tb_atletas_resultados ar ON pr.competencias_pruebas_id = ar.competencias_pruebas_id
								WHERE atletas_resultados_puesto = p_atletas_resultados_puesto AND
											atletas_resultados_resultado != p_atletas_resultados_resultado AND
											pr.competencias_pruebas_id = p_competencias_pruebas_id AND
											atletas_codigo = p_atletas_codigo)

			THEN
				RAISE 'Ya existe al menos un atleta con el mismo puesto pero diferente resultado , verifique por favor'
				USING ERRCODE = 'restrict_violation';
			END IF;
		ELSE
			IF EXISTS(SELECT 1
								FROM tb_competencias_pruebas pr
									INNER JOIN tb_atletas_resultados ar ON pr.competencias_pruebas_id = ar.competencias_pruebas_id
								WHERE atletas_resultados_puesto = p_atletas_resultados_puesto AND
											atletas_resultados_resultado != p_atletas_resultados_resultado AND
											pr.competencias_pruebas_id = p_competencias_pruebas_id AND
											atletas_codigo != p_atletas_codigo)
			THEN
				RAISE 'Ya existe al menos un atleta con el mismo puesto pero diferente resultado , verifique por favor'
				USING ERRCODE = 'restrict_violation';
			END IF;
		END IF;
	END IF;

	IF p_is_update = '1'
	THEN
		IF coalesce(v_prueba_multiple, FALSE) = TRUE
		THEN
			-- El  update para la principal de una combinada solo se hace con el puesto.
			UPDATE
				tb_atletas_resultados
			SET
				atletas_resultados_puesto = p_atletas_resultados_puesto,
				usuario                   = p_usuario
			WHERE atletas_resultados_id = p_atletas_resultados_id AND xmin = p_version_id;
		ELSE
			-- El  update
			UPDATE
				tb_atletas_resultados
			SET
				atletas_codigo               = p_atletas_codigo,
				competencias_pruebas_id      = p_competencias_pruebas_id,
				postas_id                    = p_postas_id,
				atletas_resultados_resultado = p_atletas_resultados_resultado,
				atletas_resultados_viento    = p_atletas_resultados_viento,
				atletas_resultados_puesto    = p_atletas_resultados_puesto,
				atletas_resultados_puntos    = p_atletas_resultados_puntos,
				atletas_resultados_protected = p_atletas_resultados_protected,
				activo                       = p_activo,
				usuario                      = p_usuario
			WHERE atletas_resultados_id = p_atletas_resultados_id AND xmin = p_version_id;
		END IF;


		RAISE NOTICE 'COUNT ID --> %', FOUND;

		IF NOT FOUND
		THEN
			RETURN NULL;
		END IF;

	ELSE
		IF v_competencias_pruebas_origen_id IS NOT NULL
		THEN
			IF NOT EXISTS(SELECT 1
										FROM tb_atletas_resultados
										WHERE
											competencias_pruebas_id = v_competencias_pruebas_origen_id AND atletas_codigo = p_atletas_codigo)

			THEN
				INSERT INTO
					tb_atletas_resultados
					(
						atletas_codigo,
						competencias_pruebas_id,
						postas_id,
						atletas_resultados_resultado,
						atletas_resultados_viento,
						atletas_resultados_puesto,
						atletas_resultados_puntos,
						atletas_resultados_protected,
						activo,
						usuario)
				VALUES (
					p_atletas_codigo,
					v_competencias_pruebas_origen_id,
					NULL,
					'',
					NULL,
					0,
					0,
					p_atletas_resultados_protected,
					p_activo,
					p_usuario);

				IF NOT FOUND
				THEN
					RAISE 'Error creando el resultado para la prueba principal, comuniquese con el administrador'
					USING ERRCODE = 'restrict_violation';
				END IF;
			END IF;
		END IF;

		INSERT INTO
			tb_atletas_resultados
			(
				atletas_codigo,
				competencias_pruebas_id,
				postas_id,
				atletas_resultados_resultado,
				atletas_resultados_viento,
				atletas_resultados_puesto,
				atletas_resultados_puntos,
				atletas_resultados_protected,
				activo,
				usuario)
		VALUES (
			p_atletas_codigo,
			p_competencias_pruebas_id,
			p_postas_id,
			p_atletas_resultados_resultado,
			p_atletas_resultados_viento,
			p_atletas_resultados_puesto,
			p_atletas_resultados_puntos,
			p_atletas_resultados_protected,
			p_activo,
			p_usuario);
	END IF;

	-- Si es parte de una combinada.
	-- actualizamos el resultado de la principal con el nuevo acumulado de puntos
	IF v_competencias_pruebas_origen_id IS NOT NULL
	THEN
		UPDATE
			tb_atletas_resultados
		SET
			atletas_resultados_resultado = (
				SELECT sum(atletas_resultados_puntos)
				FROM tb_atletas_resultados
				WHERE competencias_pruebas_id IN (
					SELECT competencias_pruebas_id
					FROM tb_competencias_pruebas
					WHERE competencias_pruebas_origen_id = v_competencias_pruebas_origen_id AND atletas_codigo = p_atletas_codigo)
			)
		WHERE competencias_pruebas_id = v_competencias_pruebas_origen_id AND atletas_codigo = p_atletas_codigo;

		-- Ahora actualizamos los pustos en la principal de acuerdo a los actuales puntajes acumulados
		UPDATE tb_atletas_resultados ar
		SET atletas_resultados_puesto = res.x
		FROM (
					 SELECT
						 x,
						 atletas_resultados_id
					 FROM (
									SELECT
										(row_number()
										OVER (
											ORDER BY (CASE WHEN atletas_resultados_resultado = ''
												THEN '0'
																ELSE atletas_resultados_resultado END) :: INTEGER DESC)) AS x,
										atletas_resultados_id,
										atletas_resultados_resultado
									FROM tb_atletas_resultados ar
									WHERE ar.competencias_pruebas_id = v_competencias_pruebas_origen_id
									ORDER BY (CASE WHEN atletas_resultados_resultado = ''
										THEN '0'
														ELSE atletas_resultados_resultado END :: INTEGER) DESC) cc
					 ORDER BY x
				 ) AS res
		WHERE ar.atletas_resultados_id = res.atletas_resultados_id;

	END IF;

	RETURN 1;


END;
$$;


ALTER FUNCTION public.sp_atletas_resultados_save_record(p_atletas_resultados_id integer, p_atletas_codigo character varying, p_competencias_pruebas_id integer, p_postas_id integer, p_atletas_resultados_resultado character varying, p_atletas_resultados_puntos integer, p_atletas_resultados_puesto integer, p_atletas_resultados_viento numeric, p_atletas_resultados_protected boolean, p_activo boolean, p_usuario character varying, p_version_id integer, p_is_update bit) OWNER TO postgres;

--
-- TOC entry 256 (class 1255 OID 16436)
-- Name: sp_atletas_save_record(character varying, character varying, character varying, character varying, character, character varying, character varying, character varying, date, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, character varying, character varying, boolean, character varying, integer, bit); Type: FUNCTION; Schema: public; Owner: atluser
--

CREATE FUNCTION sp_atletas_save_record(p_atletas_codigo character varying, p_atletas_ap_paterno character varying, p_atletas_ap_materno character varying, p_atletas_nombres character varying, p_atletas_sexo character, p_atletas_nro_documento character varying, p_atletas_nro_pasaporte character varying, p_paises_codigo character varying, p_atletas_fecha_nacimiento date, p_atletas_telefono_casa character varying, p_atletas_telefono_celular character varying, p_atletas_email character varying, p_atletas_direccion character varying, p_atletas_observaciones character varying, p_atletas_talla_ropa_buzo character varying, p_atletas_talla_ropa_poloshort character varying, p_atletas_talla_zapatillas numeric, p_atletas_norma_zapatillas character varying, p_atletas_url_foto character varying, p_activo boolean, p_usuario character varying, p_version_id integer, p_is_update bit) RETURNS integer
LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 05-02-2014

Stored procedure que agrega o actualiza los registros del atleta.
Previo a la grabacion forma el nombre completo del atleta.

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

select * from ( select sp_atletas_save_record(?,?,etc) as updins) as ans where updins is not null;

de tal forma que retornara un registro si el update funciono o el insert , y 0 registros si no se realizo
el uodate. sto es conveniente cuando se usa por ejemplo el affected_rows de algunos drivers.
EN OTRAS BASES ESTO NO ES NECESARIO.

Historia : Creado 05-02-2014
*/
DECLARE v_nombre_completo  VARCHAR(300);
				v_atletas_sexo_old CHARACTER;
				v_paises_use_apm  BOOLEAN;
				v_paises_use_docid BOOLEAN;

BEGIN

	-- Validamos si esta referenciado en el caso el sexo sea cambiado.
	-- para eso requerimos saber el sexo actual
	IF p_is_update = '1'
	THEN
		SELECT atletas_sexo
		INTO v_atletas_sexo_old
		FROM tb_atletas
		WHERE atletas_codigo = p_atletas_codigo;

		IF v_atletas_sexo_old != p_atletas_sexo
		THEN
			IF EXISTS(SELECT 1
								FROM tb_atletas_resultados
								WHERE atletas_codigo = p_atletas_codigo
								LIMIT 1)
			THEN
				RAISE 'No puede cambiarse el sexo del atleta ya que esta referenciado en resultados'
				USING ERRCODE = 'restrict_violation';
			END IF;

			IF EXISTS(SELECT 1
								FROM tb_postas_detalle
								WHERE atletas_codigo = p_atletas_codigo
								LIMIT 1)
			THEN
				RAISE 'No puede cambiarse el sexo del atleta ya que esta referenciado en una posta'
				USING ERRCODE = 'restrict_violation';
			END IF;
		END IF;
	END IF;

	-- Chequeamos si debemos poner apellido materno y nro documento , eso depende del pais.
	SELECT paises_use_apm,paises_use_docid
	INTO v_paises_use_apm,v_paises_use_docid
	FROM tb_paises
	WHERE paises_codigo = p_paises_codigo;

	IF COALESCE(v_paises_use_apm,TRUE) = TRUE
	THEN
		IF coalesce(p_atletas_ap_materno, '') = '' OR length(p_atletas_ap_materno) = 0
		THEN
			RAISE 'Se requiere el apellido materno del atleta'
			USING ERRCODE = 'restrict_violation';
		END IF;
	END IF;

	IF COALESCE(v_paises_use_docid,TRUE) = TRUE
	THEN
		IF coalesce(p_atletas_nro_documento, '') = '' OR length(p_atletas_nro_documento) = 0
		THEN
			RAISE 'Se requiere el nro. de docuemento de identidad del atleta'
			USING ERRCODE = 'restrict_violation';
		END IF;
	END IF;

	-- Creamos el campo de nombre completo
	v_nombre_completo := '';
	IF coalesce(p_atletas_ap_paterno, '') != '' OR length(p_atletas_ap_paterno) > 0
	THEN
		v_nombre_completo := p_atletas_ap_paterno;
	END IF;
	IF coalesce(p_atletas_ap_materno, '') != '' OR length(p_atletas_ap_materno) > 0
	THEN
		v_nombre_completo := v_nombre_completo || ' ' || p_atletas_ap_materno;
	END IF;
	IF coalesce(p_atletas_nombres, '') != '' OR length(p_atletas_nombres) > 0
	THEN
		v_nombre_completo := v_nombre_completo || ', ' || p_atletas_nombres;
	END IF;


	IF p_is_update = '1'
	THEN
		UPDATE
			tb_atletas
		SET
			atletas_codigo               = p_atletas_codigo,
			atletas_ap_paterno           = p_atletas_ap_paterno,
			atletas_ap_materno           = p_atletas_ap_materno,
			atletas_nombres              = p_atletas_nombres,
			atletas_nombre_completo      = v_nombre_completo,
			atletas_sexo                 = p_atletas_sexo,
			atletas_nro_documento        = p_atletas_nro_documento,
			atletas_nro_pasaporte        = p_atletas_nro_pasaporte,
			paises_codigo                = p_paises_codigo,
			atletas_fecha_nacimiento     = p_atletas_fecha_nacimiento,
			atletas_telefono_casa        = p_atletas_telefono_casa,
			atletas_telefono_celular     = p_atletas_telefono_celular,
			atletas_email                = p_atletas_email,
			atletas_direccion            = p_atletas_direccion,
			atletas_observaciones        = p_atletas_observaciones,
			atletas_talla_ropa_buzo      = p_atletas_talla_ropa_buzo,
			atletas_talla_ropa_poloshort = p_atletas_talla_ropa_poloshort,
			atletas_talla_zapatillas     = p_atletas_talla_zapatillas,
			atletas_norma_zapatillas     = p_atletas_norma_zapatillas,
			atletas_url_foto             = p_atletas_url_foto,
			activo                       = p_activo,
			usuario_mod                  = p_usuario
		WHERE atletas_codigo = p_atletas_codigo AND xmin = p_version_id;
		RAISE NOTICE 'COUNT ID --> %', FOUND;

		IF FOUND
		THEN
			RETURN 1;
		ELSE
			RETURN NULL;
		END IF;
	ELSE
		INSERT INTO
			tb_atletas
			(atletas_codigo, atletas_ap_paterno, atletas_ap_materno, atletas_nombres, atletas_nombre_completo,
			 atletas_sexo, atletas_nro_documento, atletas_nro_pasaporte, paises_codigo,
			 atletas_fecha_nacimiento, atletas_telefono_casa, atletas_telefono_celular, atletas_email, atletas_direccion,
			 atletas_observaciones, atletas_talla_ropa_buzo, atletas_talla_ropa_poloshort, atletas_talla_zapatillas,
			 atletas_norma_zapatillas, atletas_url_foto, activo, usuario_mod)
		VALUES (p_atletas_codigo,
			p_atletas_ap_paterno,
			p_atletas_ap_materno,
			p_atletas_nombres,
			v_nombre_completo,
			p_atletas_sexo,
			p_atletas_nro_documento,
			p_atletas_nro_pasaporte,
			p_paises_codigo,
			p_atletas_fecha_nacimiento,
			p_atletas_telefono_casa,
			p_atletas_telefono_celular,
			p_atletas_email,
			p_atletas_direccion,
			p_atletas_observaciones,
			p_atletas_talla_ropa_buzo,
			p_atletas_talla_ropa_poloshort,
			p_atletas_talla_zapatillas,
			p_atletas_norma_zapatillas,
			p_atletas_url_foto,
			p_activo,
						p_usuario);
		RETURN 1;

	END IF;
END;
$$;


ALTER FUNCTION public.sp_atletas_save_record(p_atletas_codigo character varying, p_atletas_ap_paterno character varying, p_atletas_ap_materno character varying, p_atletas_nombres character varying, p_atletas_sexo character, p_atletas_nro_documento character varying, p_atletas_nro_pasaporte character varying, p_paises_codigo character varying, p_atletas_fecha_nacimiento date, p_atletas_telefono_casa character varying, p_atletas_telefono_celular character varying, p_atletas_email character varying, p_atletas_direccion character varying, p_atletas_observaciones character varying, p_atletas_talla_ropa_buzo character varying, p_atletas_talla_ropa_poloshort character varying, p_atletas_talla_zapatillas numeric, p_atletas_norma_zapatillas character varying, p_atletas_url_foto character varying, p_activo boolean, p_usuario character varying, p_version_id integer, p_is_update bit) OWNER TO atluser;

--
-- TOC entry 257 (class 1255 OID 16439)
-- Name: sp_clubesatletas_save_record(integer, character varying, character varying, date, date, boolean, character varying, integer, bit); Type: FUNCTION; Schema: public; Owner: atluser
--

CREATE FUNCTION sp_clubesatletas_save_record(p_clubesatletas_id integer, p_clubes_codigo character varying, p_atletas_codigo character varying, p_clubesatletas_desde date, p_clubesatletas_hasta date, p_activo boolean, p_usuario character varying, p_version_id integer, p_is_update bit) RETURNS integer
LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 03-02-2014

Stored procedure que agrega un registro de la relacion entre clubes y atletas
verificando previamente que el atleta no este asignado a otro club y dentro del rango
de fechas definidos.

Historia : Creado 03-02-2014
*/
DECLARE v_club_descripcion VARCHAR(300) = '';

BEGIN

	-- Si se agrega activo verificamos si existe en otra liga.
	IF p_activo = TRUE
	THEN
		-- Verificamos si el atleta esta definido en otro club y las fechas no se overlapan (un atleta no puede haber
		-- sido entrenado por 2 clubes a la vez
		IF EXISTS (SELECT 1
							 FROM tb_clubes_atletas ea
								 LEFT JOIN tb_clubes ent on ent.clubes_codigo = ea.clubes_codigo
							 where  atletas_codigo = p_atletas_codigo
											and coalesce(p_clubesatletas_id,-1) != coalesce(ea.clubesatletas_id,2)
											and (p_clubesatletas_desde  between clubesatletas_desde and clubesatletas_hasta or
													 p_clubesatletas_hasta  between clubesatletas_desde and clubesatletas_hasta or
													 clubesatletas_desde  between p_clubesatletas_desde and p_clubesatletas_hasta or
													 clubesatletas_hasta  between p_clubesatletas_desde and p_clubesatletas_hasta ) LIMIT 1)
		THEN
			-- Para recuperar el nombre del club (el primero) que ocurre en ese rango
			SELECT INTO  v_club_descripcion  clubes_descripcion
			FROM tb_clubes_atletas ea
				LEFT JOIN tb_clubes ent on ent.clubes_codigo = ea.clubes_codigo
			where  atletas_codigo = p_atletas_codigo
						 and (p_clubesatletas_desde  between clubesatletas_desde and clubesatletas_hasta or
									p_clubesatletas_hasta  between clubesatletas_desde and clubesatletas_hasta or
									clubesatletas_desde  between p_clubesatletas_desde and p_clubesatletas_hasta or
									clubesatletas_hasta  between p_clubesatletas_desde and p_clubesatletas_hasta ) LIMIT 1;

			-- Excepcion de pais con ese nombre existe
			RAISE 'El atleta pertenecia a otro club o al mismo club durante ese rango de fechas, verifique la fecha final definida en el club (%)',v_club_descripcion USING ERRCODE = 'restrict_violation';
		END IF;
	END IF;

	IF p_is_update = '1'
	THEN
		UPDATE
			tb_clubes_atletas
		SET
			clubes_codigo=p_clubes_codigo,
			atletas_codigo=p_atletas_codigo,
			clubesatletas_desde=p_clubesatletas_desde,
			clubesatletas_hasta=coalesce(p_clubesatletas_hasta,'2035-01-01'),
			activo=p_activo,
			usuario_mod=p_usuario
		WHERE clubesatletas_id = p_clubesatletas_id and xmin =p_version_id ;
		RAISE NOTICE  'COUNT ID --> %', FOUND;

		IF FOUND THEN
			RETURN 1;
		ELSE
			RETURN null;
		END IF;
	ELSE
		INSERT INTO
			tb_clubes_atletas
			(clubes_codigo,atletas_codigo,clubesatletas_desde,clubesatletas_hasta,activo,usuario)
		VALUES(p_clubes_codigo,
					 p_atletas_codigo,
					 p_clubesatletas_desde,
					 coalesce(p_clubesatletas_hasta,'2035-01-01'),
					 p_activo,
					 p_usuario);

		RETURN 1;
	END IF;
END;
$$;


ALTER FUNCTION public.sp_clubesatletas_save_record(p_clubesatletas_id integer, p_clubes_codigo character varying, p_atletas_codigo character varying, p_clubesatletas_desde date, p_clubesatletas_hasta date, p_activo boolean, p_usuario character varying, p_version_id integer, p_is_update bit) OWNER TO atluser;

--
-- TOC entry 258 (class 1255 OID 16440)
-- Name: sp_competencias_pruebas_delete_for_competencia(character varying, character varying); Type: FUNCTION; Schema: public; Owner: atluser
--

CREATE FUNCTION sp_competencias_pruebas_delete_for_competencia(p_competencias_codigo character varying, p_usuario character varying) RETURNS void
LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 08-10-2013

Stored procedure que elimina todas las pruebas asociadas a una competencia.
Dado que a estas pruebas estan asociados los resultados , tambien se elimina todos los resultados
asociados a las pruebas.
Historia : Creado 15-01-2014
*/
BEGIN

	-- Verificacion previa que el registro no esgta modificado
	--
	-- Existe una pequeñisima oportunidad que el registro sea alterado entre el exist y el delete
	-- pero dado que es intranscendente no es importante crear una sub transaccion para solo
	-- verificar eso , por ende es mas que suficiente solo esta previa verificacion por exist.
	IF EXISTS (SELECT 1 FROM tb_competencias WHERE competencias_codigo = p_competencias_codigo) THEN

		-- Eliminamos todos los resultados asociados a una competencia
		PERFORM sp_atletas_resultados_delete_for_competencia(p_competencias_codigo,p_usuario);

		-- Finalmente eliminamos las pruebas asociadas a la competencia.
		DELETE FROM
			tb_competencias_pruebas
		where competencias_codigo = p_competencias_codigo;

	ELSE
		RAISE 'No se pueden eliminar las pruebas asociadas a la comptencia % , ya que esta no existe',p_competencias_codigo USING ERRCODE = 'restrict_violation';
	END IF;
END;
$$;


ALTER FUNCTION public.sp_competencias_pruebas_delete_for_competencia(p_competencias_codigo character varying, p_usuario character varying) OWNER TO atluser;

--
-- TOC entry 259 (class 1255 OID 16441)
-- Name: sp_competencias_pruebas_delete_record(integer, character varying, integer); Type: FUNCTION; Schema: public; Owner: atluser
--

CREATE FUNCTION sp_competencias_pruebas_delete_record(p_competencias_pruebas_id integer, p_usuario character varying, p_version_id integer) RETURNS integer
LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 08-10-2013

Stored procedure que elimina todas los resultados de todos los atletas
para una especifica prueba de una competencia.pruebas y sus resultados asociados
para una competencia.

Previamente hace todas las validaciones necesarias para garantizar que los datos sean grabados
consistentemente,

En el caso de las combinadas eliminara los datos de la principal y las que las componen
osea todos los resultados asociados a la principal y todas sus pruebas adjuntas.

Una vez establecida la prueba para una competencia sera imposible cambiar el codigo de prueba.

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

	select * from ( select sp_atletas_resultados_save_record(?,?,etc) as updins) as ans where updins is not null;

	de tal forma que retornara un registro si el update funciono o el insert , y 0 registros si no se realizo
	el uodate. sto es conveniente cuando se usa por ejemplo el affected_rows de algunos drivers.
	EN OTRAS BASES ESTO NO ES NECESARIO.

Historia : Creado 15-01-2014
*/
DECLARE v_competencias_pruebas_origen_id integer=0;

BEGIN

	-- Verificacion previa que el registro no esgta modificado
	--
	-- Existe una pequeñisima oportunidad que el registro sea alterado entre el exist y el delete
	-- pero dado que es intranscendente no es importante crear una sub transaccion para solo
	-- verificar eso , por ende es mas que suficiente solo esta previa verificacion por exist.
	IF EXISTS (SELECT 1 FROM tb_competencias_pruebas WHERE competencias_pruebas_id = p_competencias_pruebas_id and xmin=p_version_id) THEN

		-- Vemos si esta resultado es parte de una prueba combinada
		-- o si es el resultado de una prueba combinada.
		SELECT competencias_pruebas_origen_id
		INTO v_competencias_pruebas_origen_id
		FROM tb_competencias_pruebas cp
		WHERE cp.competencias_pruebas_id =  p_competencias_pruebas_id;
		--
		IF v_competencias_pruebas_origen_id IS NOT NULL
		THEN
			-- La prueba no existe
			RAISE 'Una prueba que es parte de una prueba combinada no puede eliminarse independientemente , borre la prueba principal' USING ERRCODE = 'restrict_violation';
		END IF;

		-- Eliminamos primero todos sus resultados asociados.
		DELETE FROM
			tb_atletas_resultados
		WHERE (competencias_pruebas_id = p_competencias_pruebas_id
					 OR competencias_pruebas_id in (
			select competencias_pruebas_id
			from tb_competencias_pruebas
			where competencias_pruebas_origen_id=p_competencias_pruebas_id
		));


		-- Eliminamos la pricipal y las asociadas en caso de que a prueba sea multiple
		DELETE FROM
			tb_competencias_pruebas
		WHERE competencias_pruebas_id = p_competencias_pruebas_id
					OR competencias_pruebas_origen_id=p_competencias_pruebas_id;


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


ALTER FUNCTION public.sp_competencias_pruebas_delete_record(p_competencias_pruebas_id integer, p_usuario character varying, p_version_id integer) OWNER TO atluser;

--
-- TOC entry 292 (class 1255 OID 37511)
-- Name: sp_competencias_pruebas_save_record(integer, character varying, character varying, integer, date, numeric, boolean, character varying, integer, boolean, boolean, character varying, boolean, boolean, boolean, boolean, character varying, integer, bit); Type: FUNCTION; Schema: public; Owner: atluser
--

CREATE FUNCTION sp_competencias_pruebas_save_record(p_competencias_pruebas_id integer, p_competencias_codigo character varying, p_pruebas_codigo character varying, p_competencias_pruebas_origen_id integer, p_competencias_pruebas_fecha date, p_competencias_pruebas_viento numeric, p_competencias_pruebas_manual boolean, p_competencias_pruebas_tipo_serie character varying, p_competencias_pruebas_nro_serie integer, p_competencias_pruebas_anemometro boolean, p_competencias_pruebas_material_reglamentario boolean, p_competencias_pruebas_observaciones character varying, p_competencias_pruebas_protected boolean, p_update_viento_asociado boolean, p_strict_check_manual_time boolean, p_activo boolean, p_usuario character varying, p_version_id integer, p_is_update bit) RETURNS integer
LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 08-10-2013

Stored procedure que agrega o actualiza los registros de las pruebas de una
competencia.

Previamente hace todas las validaciones necesarias para garantizar que los datos sean grabados
consistentemente,

En el caso de las combinadas actualizara la principal y las que las componen o en el caso
de crear , creara la principal con sus pruebas componentes del mismo.


Una vez establecida la prueba para una competencia sera imposible cambiar el codigo de prueba.

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

	select * from ( select sp_atletas_resultados_save_record(?,?,etc) as updins) as ans where updins is not null;

	de tal forma que retornara un registro si el update funciono o el insert , y 0 registros si no se realizo
	el uodate. sto es conveniente cuando se usa por ejemplo el affected_rows de algunos drivers.
	EN OTRAS BASES ESTO NO ES NECESARIO.

Historia : Creado 15-01-2014
		 : 27-03-2016 el parametro p_update_viento_asociado indica si debe hacerse update al viento en la tabla tb_atletas_resultados
		 				si es que ha habido cambio en la existencia del anemometro en la competencia,
		 				Por lo general si este stored es llamado directamente drante el update de una competencia este valor debe ser tru,
		 				pero si es llamado desde algun sp que este actualizando las pruebas y la competencia a la vez este valor debe ser false
		 				y debe derivarse el cambio del viento al sp que llama.
*/
DECLARE v_categorias_codigo_competencia character varying(15);
				DECLARE v_competencias_fecha_inicio date;
				DECLARE v_competencias_fecha_final date;

				DECLARE v_unidad_medida_tipo_new character(1);
				DECLARE v_prueba_multiple_new boolean= FALSE;
				DECLARE v_categorias_codigo_orig character varying(15);
				DECLARE v_categorias_codigo_new character varying(15);
				DECLARE v_competencias_pruebas_id integer=0;
				DECLARE v_apppruebas_verifica_viento_new BOOLEAN = FALSE;
				DECLARE v_competencias_pruebas_origen_combinada BOOLEAN = FALSE;
				DECLARE v_apppruebas_viento_individual BOOLEAN;
				DECLARE v_competencias_pruebas_manual_old BOOLEAN;
				DECLARE v_competencias_pruebas_anemometro_old BOOLEAN;
				DECLARE v_count integer;
				DECLARE v_can_modify integer;

BEGIN

	--RAISE NOTICE 'ENTRO CON MANUAL = %',p_competencias_pruebas_manual;
	-----------------------------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------------
	-- VALIDACIONES PRIMARIAS DE INTEGRIDAD LOGICA
	-----------------------------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------------

	-- Buscamos si la prueba es parte de una combinada , de serlo informamos ya que
	-- no es posible agregar un resultado individual , debe agregarse a prueba principal
	IF (p_is_update = '0')
	THEN
		IF EXISTS(select 1 from  tb_pruebas_detalle pd
		WHERE pd.pruebas_detalle_prueba_codigo = p_pruebas_codigo)
		THEN
			-- No puede cambiarse la prueba
			RAISE 'La prueba es parte de una combinada , no puede ingresarse individualmente , por favor agregue primero la prueba principal.'  USING ERRCODE = 'restrict_violation';
		END IF;
	END IF;

	-- Busxcamos la categoria de la competencia, los datos de la prueba y del atleta
	-- basados en los datos actuales a grabar, esto no permitira saber si la relacion
	-- COmPETencia,PrueBA;ATLETA es correcta , digase si la competencia es de mayores
	-- la prueba debe ser de mayores y el atleta debe ser mayor, asi mismo si la prueba es para
	-- el sexo femenino , el atleta debe ser mujer
	SELECT categorias_codigo,competencias_fecha_inicio,competencias_fecha_final INTO
		v_categorias_codigo_competencia,v_competencias_fecha_inicio,v_competencias_fecha_final
	FROM tb_competencias where competencias_codigo=p_competencias_codigo;

	-- Verificamos primero si la fecha enviada esta entre las fechas de la competencia.
	IF p_competencias_pruebas_fecha < v_competencias_fecha_inicio OR p_competencias_pruebas_fecha > v_competencias_fecha_final
	THEN
		-- Excepcion La fecha esta fuera del rango de la competencia
		RAISE  'La fecha indicada para la prueba (%) no corresponde al rango de fechas de la competencia % - %',p_competencias_pruebas_fecha,v_competencias_fecha_inicio,v_competencias_fecha_final USING ERRCODE = 'restrict_violation';
	END If;

	-- Buscamos los datos de la gnerica de prueba que actualmente se quiere grabar para saber si tambien sera multiple.
	SELECT apppruebas_multiple,pr.categorias_codigo,apppruebas_verifica_viento,unidad_medida_tipo,apppruebas_viento_individual INTO
		v_prueba_multiple_new,v_categorias_codigo_new,v_apppruebas_verifica_viento_new,
		v_unidad_medida_tipo_new,v_apppruebas_viento_individual
	FROM tb_pruebas pr
		INNER JOIN tb_app_pruebas_values p ON p.apppruebas_codigo = pr.pruebas_generica_codigo
		INNER JOIN tb_pruebas_clasificacion c ON c.pruebas_clasificacion_codigo = p.pruebas_clasificacion_codigo
		INNER JOIN tb_unidad_medida um on um.unidad_medida_codigo = c.unidad_medida_codigo
	WHERE pr.pruebas_codigo = p_pruebas_codigo;

	-- OBTENIDOS LOS DATOS VERIFICAMOS LA RELACION
	-- Primero si la  categoria de la prueba y competencia son validas.
	-- SI NO EXISTE LA PRUEBA
	IF v_categorias_codigo_competencia != v_categorias_codigo_new
	THEN
		-- Excepcion no correspondencia de la categorias
		RAISE 'La categoria de la competencia (%) no corresponde a la de la prueba (%) , ambas deben ser iguales',v_categorias_codigo_competencia,v_categorias_codigo_new USING ERRCODE = 'restrict_violation';
	END IF;


	-----------------------------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------------
	-- OK paso todas las validaciones basicas , ahora veamos si la prueba tiene control de viento y ver si el viento esta indicado.
	-- SOLO CUANDO SE AGREGA.
	--	IF v_apppruebas_verifica_viento_new = TRUE AND v_apppruebas_viento_individual = FALSE
	--	THEN
	--		IF p_competencias_pruebas_viento is null and p_competencias_pruebas_anemometro = TRUE
	--		THEN
	--			-- La prueba requiere se indique el viento
	--			RAISE 'La prueba requiere se indique el limite de viento'  USING ERRCODE = 'restrict_violation';
	--		END IF;
	--	ELSE
	-- Si no requiere viento lo ponemos en null , por si acaso se envie dato por gusto.
	--		p_competencias_pruebas_viento := NULL;
	--	END IF;

	-- Se ha tomado la decision que el viento pueda ser null en cualquier caso ya que en la preactica muchas veces este
	-- no se conoce sobre todo en pruebas hitoricas.
	IF v_apppruebas_verifica_viento_new = TRUE AND v_apppruebas_viento_individual = FALSE
	THEN
		IF p_competencias_pruebas_anemometro = FALSE
		THEN
			-- No habra viento en el caso que el anemometro no este encendido.
			p_competencias_pruebas_viento := NULL;
		END IF;
	ELSE
		-- Si no requiere viento lo ponemos en null , por si acaso se envie dato por gusto.
		p_competencias_pruebas_viento := NULL;
	END IF;


	-- Si la unidad de medida de la prueba no es tiempo
	-- se blanquea (false) al campo que indica si la medida manual.
	IF v_unidad_medida_tipo_new != 'T'
	THEN
		p_competencias_pruebas_manual := false;
	END IF;


	-- Si la prueba no requiere verificacion de viento ponemos
	-- que si tuvo.
	IF v_apppruebas_verifica_viento_new = FALSE
	THEN
		p_competencias_pruebas_anemometro := TRUE;
	END IF;




	IF p_is_update = '1'
	THEN
		--RAISE NOTICE 'PASO UPDATE';
		-- Buscamos los datos actualmente grabado.
		IF NOT EXISTS(SELECT 1
									FROM tb_competencias_pruebas
									WHERE competencias_pruebas_id = p_competencias_pruebas_id and pruebas_codigo=p_pruebas_codigo)
		THEN
			-- No puede cambiarse la prueba
			RAISE 'Al actualizar no puede cambiarse de prueba !!'  USING ERRCODE = 'restrict_violation';
		END IF;

		-- Extraemos el dato previo de competencias_pruebas_manual para validacion
		SELECT competencias_pruebas_manual,competencias_pruebas_anemometro into v_competencias_pruebas_manual_old,v_competencias_pruebas_anemometro_old
		from tb_competencias_pruebas where competencias_pruebas_id = p_competencias_pruebas_id;


		-- Si el status de manual ha cambiado verificamos que no existan resultados ya registrados, de eexistir
		-- esto no seria posible. Debe existri mas de un resultado
		IF p_strict_check_manual_time = TRUE AND v_competencias_pruebas_manual_old != p_competencias_pruebas_manual
		THEN
			v_can_modify := (select fn_can_modify_manual_status(p_competencias_pruebas_id,null,'strict'))::INTEGER;
			IF v_can_modify = 0
			THEN
				IF v_competencias_pruebas_manual_old = TRUE
				THEN
					RAISE 'No puede cambiarse el estado manual de la prueba ya que existen resultados ya con el cronometraje manual'  USING ERRCODE = 'restrict_violation';
				ELSE
					RAISE 'No puede cambiarse el estado manual de la prueba ya que existen resultados ya con el cronometraje electronico'  USING ERRCODE = 'restrict_violation';
				END IF;
			END IF;
		END IF;


		-- El  update, si no es prueba multiple los valores completos
		IF coalesce(v_prueba_multiple_new,false) = FALSE
		THEN
			UPDATE
				tb_competencias_pruebas
			SET
				competencias_pruebas_id = p_competencias_pruebas_id,
				competencias_codigo =  p_competencias_codigo,
				pruebas_codigo =  p_pruebas_codigo,
				competencias_pruebas_fecha =  p_competencias_pruebas_fecha,
				competencias_pruebas_viento =  p_competencias_pruebas_viento,
				competencias_pruebas_manual =  p_competencias_pruebas_manual,
				competencias_pruebas_tipo_serie = p_competencias_pruebas_tipo_serie,
				competencias_pruebas_nro_serie=p_competencias_pruebas_nro_serie,
				competencias_pruebas_anemometro=p_competencias_pruebas_anemometro,
				competencias_pruebas_material_reglamentario=p_competencias_pruebas_material_reglamentario,
				competencias_pruebas_observaciones =  p_competencias_pruebas_observaciones,
				competencias_pruebas_protected =  p_competencias_pruebas_protected,
				activo = p_activo,
				usuario_mod = p_usuario
			WHERE competencias_pruebas_id = p_competencias_pruebas_id and
						(case when p_version_id is null then xmin = xmin else xmin=p_version_id	 end);


			--RAISE NOTICE  'COUNT ID --> %', FOUND;

			-- Todo ok , si se necesita agregar los detalles lo hacemos
			IF FOUND THEN
				-- Requerimos limpiar el viento en los resultados individuales de la prueba?
				IF v_competencias_pruebas_anemometro_old != p_competencias_pruebas_anemometro AND p_update_viento_asociado = TRUE
				THEN
					PERFORM sp_atletas_pruebas_resultado_clear_viento(p_competencias_pruebas_id, p_competencias_pruebas_anemometro,v_apppruebas_viento_individual, p_usuario);
				END IF;

				RETURN 1;
			ELSE
				RETURN null;
			END IF;
		ELSE
			-- Si es prueba multiple , entonces solo actualizamos los campos relevantes
			UPDATE
				tb_competencias_pruebas
			SET
				competencias_codigo =  p_competencias_codigo,
				pruebas_codigo =  p_pruebas_codigo,
				competencias_pruebas_fecha =  p_competencias_pruebas_fecha,
				competencias_pruebas_observaciones =  p_competencias_pruebas_observaciones,
				competencias_pruebas_protected =  p_competencias_pruebas_protected,
				activo = p_activo,
				usuario_mod = p_usuario
			WHERE competencias_pruebas_id = p_competencias_pruebas_id and
						(case when p_version_id is null then xmin = xmin else xmin=p_version_id end);

			--RAISE NOTICE  'COUNT ID --> %', FOUND;

			-- Todo ok , si se necesita agregar los detalles lo hacemos
			IF FOUND THEN
				-- Dado que es multiple , los campos relevantes los propagamos , por ejemplo
				-- el codigo de prueba.
				-- Cuidado la fecha ya bo es modificada ya que cada prueba debera indicarse su fecha.
				UPDATE
					tb_competencias_pruebas
				SET
					competencias_codigo =  p_competencias_codigo,
					competencias_pruebas_protected =  p_competencias_pruebas_protected,
					activo = p_activo,
					usuario_mod = p_usuario
				WHERE competencias_pruebas_origen_id = p_competencias_pruebas_id ;

				RETURN 1;
			ELSE
				RETURN null;
			END IF;
		END IF;
	ELSE
		--RAISE NOTICE 'PASO AGREGAR';
		-- Si el status de manual ha cambiado verificamos que no existan resultados ya registrados, de eexistir
		-- esto no seria posible. Debe existri mas de un resultado
		--		v_competencias_pruebas_manual_old := TRUE;

		--		IF p_competencias_pruebas_manual = TRUE
		--		THEN
		--			v_competencias_pruebas_manual_old := FALSE;
		--		END IF;
		--	    IF EXISTS(SELECT 1
		--	    		FROM tb_competencias_pruebas cp
		--	    		INNER JOIN  tb_atletas_resultados ar on cp.competencias_pruebas_id = ar.competencias_pruebas_id
		--	    		where cp.competencias_pruebas_id = p_competencias_pruebas_id and competencias_pruebas_manual=v_competencias_pruebas_manual_old)
		--	    THEN
		-- No puede cambiarse la prueba
		--			RAISE 'No puede cambiarse el estado manual de la prueba ya que existen pruebas registradas, dado que estas han sido registradas con los tiempos de acuerdo a lo actualmente indicado'  USING ERRCODE = 'restrict_violation';
		--	    END IF;

		-- Por si acaso actualizamos el flag de origen combinada si proviene
		-- de una , lo cual lo sabemos si existe un origen indicado.
		IF p_competencias_pruebas_origen_id IS NOT NULL
		THEN
			v_competencias_pruebas_origen_combinada:= true;
		END IF;

		IF coalesce(v_prueba_multiple_new,false) = TRUE
		THEN
			p_competencias_pruebas_viento := NULL;
			p_competencias_pruebas_manual := FALSE;
			p_competencias_pruebas_tipo_serie := 'FI';
			p_competencias_pruebas_nro_serie := 1;
			p_competencias_pruebas_anemometro := TRUE;
			p_competencias_pruebas_material_reglamentario := TRUE;
			v_competencias_pruebas_origen_combinada := FALSE;
			p_competencias_pruebas_origen_id := NULL;

		END IF;

		-- Debemos agregar la prueba a la competencia ya que no existe.
		INSERT INTO
			tb_competencias_pruebas
			(
				competencias_codigo,
				pruebas_codigo,
				competencias_pruebas_origen_combinada,
				competencias_pruebas_fecha,
				competencias_pruebas_viento,
				competencias_pruebas_manual,
				competencias_pruebas_tipo_serie,
				competencias_pruebas_nro_serie,
				competencias_pruebas_anemometro,
				competencias_pruebas_material_reglamentario,
				competencias_pruebas_observaciones,
				competencias_pruebas_protected,
				competencias_pruebas_origen_id,
				activo,
				usuario
			)
		VALUES(
			p_competencias_codigo,
			p_pruebas_codigo,
			v_competencias_pruebas_origen_combinada,
			p_competencias_pruebas_fecha,
			p_competencias_pruebas_viento,
			p_competencias_pruebas_manual,
			p_competencias_pruebas_tipo_serie,
			p_competencias_pruebas_nro_serie,
			p_competencias_pruebas_anemometro,
			p_competencias_pruebas_material_reglamentario,
			p_competencias_pruebas_observaciones,
			p_competencias_pruebas_protected,
			p_competencias_pruebas_origen_id,
			p_activo,
			p_usuario);


		-- Si la prueba es multiple se agregan las pruebas correpspondientes
		IF coalesce(v_prueba_multiple_new,false) = TRUE
		THEN

			SELECT currval(pg_get_serial_sequence('tb_competencias_pruebas', 'competencias_pruebas_id'))
			INTO v_competencias_pruebas_id;

			-- Iniciamos el insert de todas las pruebas que componen la mltiple o combinada
			INSERT INTO tb_competencias_pruebas (
				competencias_codigo,
				pruebas_codigo,
				competencias_pruebas_origen_combinada,
				competencias_pruebas_origen_id,
				competencias_pruebas_fecha,
				competencias_pruebas_viento,
				competencias_pruebas_manual,
				competencias_pruebas_tipo_serie,
				competencias_pruebas_nro_serie,
				competencias_pruebas_anemometro,
				competencias_pruebas_material_reglamentario,
				activo,
				usuario)
				SELECT
					p_competencias_codigo,
					pd.pruebas_detalle_prueba_codigo,
					true,
					v_competencias_pruebas_id,
					p_competencias_pruebas_fecha,
					null,
					false,
					'FI',
					1,
					true,
					true,
					true,
					p_usuario
				FROM tb_pruebas_detalle pd
				WHERE pd.pruebas_codigo = p_pruebas_codigo
				ORDER BY pd.pruebas_detalle_orden;
		END IF;

		RETURN 1;

	END IF;
END;
$$;


ALTER FUNCTION public.sp_competencias_pruebas_save_record(p_competencias_pruebas_id integer, p_competencias_codigo character varying, p_pruebas_codigo character varying, p_competencias_pruebas_origen_id integer, p_competencias_pruebas_fecha date, p_competencias_pruebas_viento numeric, p_competencias_pruebas_manual boolean, p_competencias_pruebas_tipo_serie character varying, p_competencias_pruebas_nro_serie integer, p_competencias_pruebas_anemometro boolean, p_competencias_pruebas_material_reglamentario boolean, p_competencias_pruebas_observaciones character varying, p_competencias_pruebas_protected boolean, p_update_viento_asociado boolean, p_strict_check_manual_time boolean, p_activo boolean, p_usuario character varying, p_version_id integer, p_is_update bit) OWNER TO atluser;

--
-- TOC entry 285 (class 1255 OID 37410)
-- Name: sp_competencias_save_record(character varying, character varying, character varying, character varying, character varying, character varying, date, date, character varying, boolean, character varying, integer, bit); Type: FUNCTION; Schema: public; Owner: atluser
--

CREATE FUNCTION sp_competencias_save_record(p_competencias_codigo character varying, p_competencias_descripcion character varying, p_competencia_tipo_codigo character varying, p_categorias_codigo character varying, p_paises_codigo character varying, p_ciudades_codigo character varying, p_competencias_fecha_inicio date, p_competencias_fecha_final date, p_competencias_clasificacion character varying, p_activo boolean, p_usuario character varying, p_version_id integer, p_is_update bit) RETURNS integer
LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 08-10-2013

Stored procedure que agrega o actualiza los registros de lAS COMPETENCIAS.
Previo verifica que durante un update si dicha competenia ya tiene resultados fuera
del las fechas de competencia indicadas no podra modificarse el registro.

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

	select * from ( select sp_competencias_save_record(?,?,etc) as updins) as ans where updins is not null;

	de tal forma que retornara un registro si el update funciono o el insert , y 0 registros si no se realizo
	el uodate. sto es conveniente cuando se usa por ejemplo el affected_rows de algunos drivers.
	EN OTRAS BASES ESTO NO ES NECESARIO.

Historia : Creado 25-02-2016
*/
BEGIN



	IF p_is_update = '1'
	THEN
		-- Verificamos si alguno con el mismo nombre existe e indicamos el error.
		IF EXISTS (select 1 from tb_competencias_pruebas cp
		where competencias_codigo = p_competencias_codigo and
					cp.competencias_pruebas_fecha not between p_competencias_fecha_inicio and p_competencias_fecha_final)
		THEN
			-- Excepcion de pais con ese nombre existe
			RAISE 'No puede modificar las fechas de la competencia ya que existen pruebas asociadas que quedarian fuera del nuevo rango de fechas' USING ERRCODE = 'restrict_violation';
		END IF;

		-- Si todo ok , efectuamos el update
		UPDATE
			tb_competencias
		SET
			competencias_codigo=p_competencias_codigo,
			competencias_descripcion=p_competencias_descripcion,
			competencia_tipo_codigo=p_competencia_tipo_codigo,
			categorias_codigo=p_categorias_codigo,
			paises_codigo=p_paises_codigo,
			ciudades_codigo=p_ciudades_codigo,
			competencias_fecha_inicio=p_competencias_fecha_inicio,
			competencias_fecha_final=p_competencias_fecha_final,
			competencias_clasificacion=p_competencias_clasificacion,
			activo=p_activo,
			usuario_mod=p_usuario
		WHERE competencias_codigo = p_competencias_codigo and xmin =p_version_id ;
		RAISE NOTICE  'COUNT ID --> %', FOUND;

		IF FOUND THEN
			RETURN 1;
		ELSE
			RAISE '' USING ERRCODE = 'record modified';
			RETURN null;
		END IF;
	ELSE
		INSERT INTO
			tb_competencias
			(competencias_codigo,competencias_descripcion,competencia_tipo_codigo,categorias_codigo,
			 paises_codigo,ciudades_codigo,competencias_fecha_inicio,competencias_fecha_final,competencias_clasificacion,activo,usuario)
		VALUES(p_competencias_codigo,
			p_competencias_descripcion,
			p_competencia_tipo_codigo,
			p_categorias_codigo,
			p_paises_codigo,
			p_ciudades_codigo,
			p_competencias_fecha_inicio,
			p_competencias_fecha_final,
			p_competencias_clasificacion,
			p_activo,
			p_usuario);

		RETURN 1;

	END IF;
END;
$$;


ALTER FUNCTION public.sp_competencias_save_record(p_competencias_codigo character varying, p_competencias_descripcion character varying, p_competencia_tipo_codigo character varying, p_categorias_codigo character varying, p_paises_codigo character varying, p_ciudades_codigo character varying, p_competencias_fecha_inicio date, p_competencias_fecha_final date, p_competencias_clasificacion character varying, p_activo boolean, p_usuario character varying, p_version_id integer, p_is_update bit) OWNER TO atluser;

--
-- TOC entry 260 (class 1255 OID 16447)
-- Name: sp_entrenadores_save_record(character varying, character varying, character varying, character varying, character varying, boolean, character varying, integer, bit); Type: FUNCTION; Schema: public; Owner: atluser
--

CREATE FUNCTION sp_entrenadores_save_record(p_entrenadores_codigo character varying, p_entrenadores_ap_paterno character varying, p_entrenadores_ap_materno character varying, p_entrenadores_nombres character varying, p_entrenadores_nivel_codigo character varying, p_activo boolean, p_usuario character varying, p_version_id integer, p_is_update bit) RETURNS integer
LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 05-02-2014

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

Historia : Creado 05-02-2014
*/
DECLARE v_nombre_completo	VARCHAR(300);
				DECLARE	v_rowcount 		INTEGER;

BEGIN

	-- Creamos el campo de nombre completo
	v_nombre_completo := '';
	IF coalesce(p_entrenadores_ap_paterno,'') != '' or length(p_entrenadores_ap_paterno) > 0
	THEN
		v_nombre_completo := p_entrenadores_ap_paterno;
	END IF;
	IF coalesce(p_entrenadores_ap_materno,'') != '' or length(p_entrenadores_ap_materno) > 0
	THEN
		v_nombre_completo := v_nombre_completo || ' ' || p_entrenadores_ap_materno;
	END IF;
	IF coalesce(p_entrenadores_nombres,'') != '' or length(p_entrenadores_nombres) > 0
	THEN
		v_nombre_completo := v_nombre_completo || ', ' || p_entrenadores_nombres;
	END IF;


	IF p_is_update = '1'
	THEN
		UPDATE
			tb_entrenadores
		SET
			entrenadores_codigo=p_entrenadores_codigo,
			entrenadores_ap_paterno=p_entrenadores_ap_paterno,
			entrenadores_ap_materno=p_entrenadores_ap_materno,
			entrenadores_nombres=p_entrenadores_nombres,
			entrenadores_nombre_completo=v_nombre_completo,
			entrenadores_nivel_codigo=p_entrenadores_nivel_codigo,
			activo=p_activo,
			usuario_mod=p_usuario
		WHERE entrenadores_codigo = p_entrenadores_codigo and xmin =p_version_id ;
		RAISE NOTICE  'COUNT ID --> %', FOUND;

		IF FOUND THEN
			RETURN 1;
		ELSE
			RETURN null;
		END IF;
	ELSE
		INSERT INTO
			tb_entrenadores
			(entrenadores_codigo,entrenadores_ap_paterno,entrenadores_ap_materno,entrenadores_nombres,entrenadores_nombre_completo,
			 entrenadores_nivel_codigo,activo,usuario_mod)
		VALUES (p_entrenadores_codigo,
						p_entrenadores_ap_paterno,
						p_entrenadores_ap_materno,
						p_entrenadores_nombres,
						v_nombre_completo,
						p_entrenadores_nivel_codigo,
						p_activo,
						p_usuario);
		RETURN 1;

	END IF;
END;
$$;


ALTER FUNCTION public.sp_entrenadores_save_record(p_entrenadores_codigo character varying, p_entrenadores_ap_paterno character varying, p_entrenadores_ap_materno character varying, p_entrenadores_nombres character varying, p_entrenadores_nivel_codigo character varying, p_activo boolean, p_usuario character varying, p_version_id integer, p_is_update bit) OWNER TO atluser;

--
-- TOC entry 261 (class 1255 OID 16450)
-- Name: sp_entrenadoresatletas_save_record(integer, character varying, character varying, date, date, boolean, character varying, integer, bit); Type: FUNCTION; Schema: public; Owner: atluser
--

CREATE FUNCTION sp_entrenadoresatletas_save_record(p_entrenadoresatletas_id integer, p_entrenadores_codigo character varying, p_atletas_codigo character varying, p_entrenadoresatletas_desde date, p_entrenadoresatletas_hasta date, p_activo boolean, p_usuario character varying, p_version_id integer, p_is_update bit) RETURNS integer
LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 03-02-2014

Stored procedure que agrega un registro de la relacion entre entrenadores y atletas
verificando previamente que el atleta no este asignado a otro entrenador ydentro del rango
de fechas definidos.

Historia : Creado 03-02-2014
*/
DECLARE v_entrenador_nombre VARCHAR(300) = '';

BEGIN

	-- Si se agrega activo verificamos si existe en otra liga.
	IF p_activo = TRUE
	THEN
		-- Verificamos si el atleta esta definido en otro entrenador y las fechas no se overlapan (un atleta no puede haber
		-- sido entrenado por 2 entrenadores a la vez
		IF EXISTS (SELECT 1
							 FROM tb_entrenadores_atletas ea
								 LEFT JOIN tb_entrenadores ent on ent.entrenadores_codigo = ea.entrenadores_codigo
							 where  atletas_codigo = p_atletas_codigo
											and coalesce(p_entrenadoresatletas_id,-1) != coalesce(ea.entrenadoresatletas_id,2)
											and (p_entrenadoresatletas_desde  between entrenadoresatletas_desde and entrenadoresatletas_hasta or
													 coalesce(p_entrenadoresatletas_hasta,'2035-01-01')   between entrenadoresatletas_desde and entrenadoresatletas_hasta or
													 entrenadoresatletas_desde  between p_entrenadoresatletas_desde and coalesce(p_entrenadoresatletas_hasta,'2035-01-01')  or
													 entrenadoresatletas_hasta  between p_entrenadoresatletas_desde and coalesce(p_entrenadoresatletas_hasta,'2035-01-01')  ) LIMIT 1)
		THEN
			-- Para recuperar el nombre del entrenador (el primero) que ocurre en ese rango
			SELECT entrenadores_nombre_completo   INTO  v_entrenador_nombre
			FROM tb_entrenadores_atletas ea
				LEFT JOIN tb_entrenadores ent on ent.entrenadores_codigo = ea.entrenadores_codigo
			where  atletas_codigo = p_atletas_codigo
						 and (p_entrenadoresatletas_desde  between entrenadoresatletas_desde and entrenadoresatletas_hasta or
									coalesce(p_entrenadoresatletas_hasta,'2035-01-01')  between entrenadoresatletas_desde and entrenadoresatletas_hasta or
									entrenadoresatletas_desde  between p_entrenadoresatletas_desde and coalesce(p_entrenadoresatletas_hasta,'2035-01-01') or
									entrenadoresatletas_hasta  between p_entrenadoresatletas_desde and coalesce(p_entrenadoresatletas_hasta,'2035-01-01') ) LIMIT 1;

			-- Excepcion de pais con ese nombre existe
			RAISE 'El atleta pertenecia a otro entrenador o al mismo entrenador durante ese rango de fechas, verifique la fecha final definida en el entrenador (%)',v_entrenador_nombre USING ERRCODE = 'restrict_violation';
		END IF;
	END IF;

	IF p_is_update = '1'
	THEN
		UPDATE
			tb_entrenadores_atletas
		SET
			entrenadores_codigo=p_entrenadores_codigo,
			atletas_codigo=p_atletas_codigo,
			entrenadoresatletas_desde=p_entrenadoresatletas_desde,
			entrenadoresatletas_hasta=coalesce(p_entrenadoresatletas_hasta,'2035-01-01'),
			activo=p_activo,
			usuario_mod=p_usuario
		WHERE entrenadoresatletas_id = p_entrenadoresatletas_id and xmin =p_version_id ;
		RAISE NOTICE  'COUNT ID --> %', FOUND;

		IF FOUND THEN
			RETURN 1;
		ELSE
			RETURN null;
		END IF;
	ELSE
		INSERT INTO
			tb_entrenadores_atletas
			(entrenadores_codigo,atletas_codigo,entrenadoresatletas_desde,entrenadoresatletas_hasta,activo,usuario)
		VALUES(p_entrenadores_codigo,
					 p_atletas_codigo,
					 p_entrenadoresatletas_desde,
					 coalesce(p_entrenadoresatletas_hasta,'2035-01-01'),
					 p_activo,
					 p_usuario);

		RETURN 1;
	END IF;
END;
$$;


ALTER FUNCTION public.sp_entrenadoresatletas_save_record(p_entrenadoresatletas_id integer, p_entrenadores_codigo character varying, p_atletas_codigo character varying, p_entrenadoresatletas_desde date, p_entrenadoresatletas_hasta date, p_activo boolean, p_usuario character varying, p_version_id integer, p_is_update bit) OWNER TO atluser;

--
-- TOC entry 262 (class 1255 OID 16451)
-- Name: sp_liga_delete_record(character varying, character varying, integer); Type: FUNCTION; Schema: public; Owner: atluser
--

CREATE FUNCTION sp_liga_delete_record(p_ligas_codigo character varying, p_usuario_mod character varying, p_version_id integer) RETURNS integer
LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 03-02-2014

Stored procedure que elimina una liga eliminando todos las asociaciones a sus clubes,
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

	select * from ( select sp_liga_delete_record(?,?,etc) as updins) as ans where updins is not null;

	de tal forma que retornara un registro si el delete funciono , y 0 registros si no se realizo
	el delete. Esto es conveniente cuando se usa por ejemplo el affected_rows de algunos drivers.
	EN OTRAS BASES ESTO NO ES NECESARIO.
Historia : Creado 03-02-2014
*/
BEGIN

	-- Verificacion previa que el registro no esgta modificado
	--
	-- Existe una pequeñisima oportunidad que el registro sea alterado entre el exist y el delete
	-- pero dado que es intranscendente no es importante crear una sub transaccion para solo
	-- verificar eso , por ende es mas que suficiente solo esta previa verificacion por exist.
	IF EXISTS (SELECT 1 FROM tb_ligas WHERE ligas_codigo = p_ligas_codigo and xmin=p_version_id) THEN
		-- Eliminamos
		DELETE FROM
			tb_ligas_clubes
		WHERE ligas_codigo = p_ligas_codigo;

		DELETE FROM
			tb_ligas
		WHERE ligas_codigo = p_ligas_codigo and xmin =p_version_id;

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


ALTER FUNCTION public.sp_liga_delete_record(p_ligas_codigo character varying, p_usuario_mod character varying, p_version_id integer) OWNER TO atluser;

--
-- TOC entry 265 (class 1255 OID 16452)
-- Name: sp_ligasclubes_save_record(integer, character varying, character varying, date, date, boolean, character varying, integer, bit); Type: FUNCTION; Schema: public; Owner: atluser
--

CREATE FUNCTION sp_ligasclubes_save_record(p_ligasclubes_id integer, p_ligas_codigo character varying, p_clubes_codigo character varying, p_ligasclubes_desde date, p_ligasclubes_hasta date, p_activo boolean, p_usuario character varying, p_versionid integer, p_is_update bit) RETURNS integer
LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 03-02-2014

Stored procedure que agrega un registro de la relacion entre ligas y clubes
verificando previamente que el club no este asignado a otra liga y dentro del rango
de fechas definidos.

Historia : Creado 03-02-2014
*/
DECLARE v_liga_descripcion VARCHAR(300) = '';

BEGIN

	-- Si se agrega activo verificamos si existe en otra liga.
	--	IF p_activo = TRUE
	--	THEN
	-- Verificamos si el atleta esta definido en otro club y las fechas no se overlapan (un atleta no puede haber
	-- sido entrenado por 2 clubes a la vez
	IF EXISTS (SELECT 1
						 FROM tb_ligas_clubes ea
						 where  clubes_codigo = p_clubes_codigo
										and coalesce(p_ligasclubes_id,-1) != coalesce(ea.ligasclubes_id,2)
										and (p_ligasclubes_desde  between ligasclubes_desde and ligasclubes_hasta or
												 p_ligasclubes_hasta  between ligasclubes_desde and ligasclubes_hasta or
												 ligasclubes_desde  between p_ligasclubes_desde and p_ligasclubes_hasta or
												 ligasclubes_hasta  between p_ligasclubes_desde and p_ligasclubes_hasta ) LIMIT 1)
	THEN
		-- Para recuperar el nombre del club (el primero) que ocurre en ese rango
		SELECT INTO  v_liga_descripcion  ligas_descripcion
		FROM tb_ligas_clubes ea
			LEFT JOIN tb_ligas ent on ent.ligas_codigo = ea.ligas_codigo
		where  clubes_codigo = p_clubes_codigo
					 and (p_ligasclubes_desde  between ligasclubes_desde and ligasclubes_hasta or
								p_ligasclubes_hasta  between ligasclubes_desde and ligasclubes_hasta or
								ligasclubes_desde  between p_ligasclubes_desde and p_ligasclubes_hasta or
								ligasclubes_hasta  between p_ligasclubes_desde and p_ligasclubes_hasta ) LIMIT 1;

		-- Excepcion de pais con ese nombre existe
		RAISE 'El club pertenecia a otra liga o a la misma liga durante ese rango de fechas, verifique la fecha final definida en la liga (%)',v_liga_descripcion USING ERRCODE = 'restrict_violation';
	END IF;
	--	END IF;

	IF p_is_update = '1'
	THEN
		-- Update a la relacion liga/club
		UPDATE tb_ligas_clubes
		SET ligas_codigo=p_ligas_codigo,
			clubes_codigo=p_clubes_codigo,
			ligasclubes_desde=p_ligasclubes_desde,
			ligasclubes_hasta=coalesce(p_ligasclubes_hasta,'2035-12-31'),
			usuario_mod=p_usuario,
			activo=p_activo
		WHERE p_ligasclubes_id = p_ligasclubes_id and xmin=p_versionid;


		RAISE NOTICE  'COUNT ID --> %', FOUND;

		IF FOUND THEN
			RETURN 1;
		ELSE
			RETURN null;
		END IF;
	ELSE
		INSERT INTO
			tb_ligas_clubes
			(ligas_codigo,clubes_codigo,ligasclubes_desde,ligasclubes_hasta,activo,usuario)
		VALUES(p_ligas_codigo,
					 p_clubes_codigo,
					 p_ligasclubes_desde,
					 coalesce(p_ligasclubes_hasta,'2035-12-31'),
					 p_activo,
					 p_usuario);

		RETURN 1;
	END IF;
END;
$$;


ALTER FUNCTION public.sp_ligasclubes_save_record(p_ligasclubes_id integer, p_ligas_codigo character varying, p_clubes_codigo character varying, p_ligasclubes_desde date, p_ligasclubes_hasta date, p_activo boolean, p_usuario character varying, p_versionid integer, p_is_update bit) OWNER TO atluser;

--
-- TOC entry 267 (class 1255 OID 37786)
-- Name: sp_paises_save_record(character varying, character varying, boolean, character varying, boolean, boolean, boolean, character varying, integer, bit); Type: FUNCTION; Schema: public; Owner: atluser
--

CREATE FUNCTION sp_paises_save_record(p_paises_codigo character varying, p_paises_descripcion character varying, p_paises_entidad boolean, p_regiones_codigo character varying, p_paises_use_apm boolean, p_paises_use_docid boolean, p_activo boolean, p_usuario character varying, p_version_id integer, p_is_update bit) RETURNS integer
LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 08-10-2013

Stored procedure que agrega o actualiza los registros de los paises.
Previo verifica que no exista un pais con el mismo nombre y desactiva el campo
paises_entidad si se esta tratando de grabar un registro con ese valor en TRUE
pero ya existe otro que lo tiene.

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

	select * from ( select sp_paises_save_record(?,?,etc) as updins) as ans where updins is not null;

	de tal forma que retornara un registro si el update funciono o el insert , y 0 registros si no se realizo
	el uodate. sto es conveniente cuando se usa por ejemplo el affected_rows de algunos drivers.
	EN OTRAS BASES ESTO NO ES NECESARIO.

Historia : Creado 15-01-2014
*/
BEGIN
	-- Verificamos si alguno con el mismo nombre existe e indicamos el error.
	IF EXISTS (SELECT 1 FROM tb_paises
	where paises_codigo != p_paises_codigo and UPPER(LTRIM(RTRIM(paises_descripcion))) = UPPER(LTRIM(RTRIM(p_paises_descripcion))))
	THEN
		-- Excepcion de pais con ese nombre existe
		RAISE 'Ya existe un pais con ese nombre pero diferente codigo' USING ERRCODE = 'restrict_violation';
	END IF;

	-- Si un pais ya tiene indicado su entidad y se trata de indicar al registro
	-- que se agrega o modifca que tendra el indicador de entidad , primero quitamos
	-- el que existe previo a grabar.
	IF p_paises_entidad = TRUE
	THEN
		UPDATE
			tb_paises
		SET paises_entidad=FALSE
		WHERE paises_entidad=TRUE and paises_codigo != p_paises_codigo;
	END IF;

	IF p_is_update = '1'
	THEN
		UPDATE
			tb_paises
		SET
			paises_descripcion=p_paises_descripcion,
			paises_entidad=p_paises_entidad,
			regiones_codigo=p_regiones_codigo,
			paises_use_apm=p_paises_use_apm,
			paises_use_docid=p_paises_use_docid,
			activo=p_activo,
			usuario_mod=p_usuario
		WHERE paises_codigo = p_paises_codigo and xmin =p_version_id ;
		RAISE NOTICE  'COUNT ID --> %', FOUND;

		IF FOUND THEN
			RETURN 1;
		ELSE
			RAISE '' USING ERRCODE = 'record modified';
			RETURN null;
		END IF;
	ELSE
		INSERT INTO
			tb_paises
			(paises_codigo,
			 paises_descripcion,
			 paises_entidad,
			 paises_use_apm,
			 paises_use_docid,
			 regiones_codigo,
			 activo,
			 usuario)
		VALUES(p_paises_codigo,
					 p_paises_descripcion,
					 p_paises_entidad,
					 p_paises_use_apm,
					 p_paises_use_docid,
					 p_regiones_codigo,
					 p_activo,
					 p_usuario);

		RETURN 1;

	END IF;
END;
$$;


ALTER FUNCTION public.sp_paises_save_record(p_paises_codigo character varying, p_paises_descripcion character varying, p_paises_entidad boolean, p_regiones_codigo character varying, p_paises_use_apm boolean, p_paises_use_docid boolean, p_activo boolean, p_usuario character varying, p_version_id integer, p_is_update bit) OWNER TO atluser;

--
-- TOC entry 264 (class 1255 OID 16456)
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
-- TOC entry 263 (class 1255 OID 16457)
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
-- TOC entry 296 (class 1255 OID 37696)
-- Name: sp_postas_delete_record(integer, character varying, integer); Type: FUNCTION; Schema: public; Owner: atluser
--

CREATE FUNCTION sp_postas_delete_record(p_postas_id integer, p_usuario_mod character varying, p_version_id integer) RETURNS integer
LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 03-02-2014

Stored procedure que elimina una posta eliminando todos los atletas asociados
a dicha posta.
,
NO ELIMINA LOS PRUEBAS ASOCIADAS SOLO LAS REFERENCIAS A LAS MISMAS.

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

select * from ( select sp_postas_delete_record(?,?,etc) as updins) as ans where updins is not null;

de tal forma que retornara un registro si el delete funciono , y 0 registros si no se realizo
el delete. Esto es conveniente cuando se usa por ejemplo el affected_rows de algunos drivers.
EN OTRAS BASES ESTO NO ES NECESARIO.
Historia : Creado 03-02-2014
*/
BEGIN
	IF EXISTS(SELECT 1
						FROM tb_postas po
							INNER JOIN tb_atletas_resultados ar
								ON ar.competencias_pruebas_id = po.competencias_pruebas_id AND po.postas_id = ar.postas_id
						WHERE po.postas_id = p_postas_id LIMIT 1)
	THEN
		RAISE 'La posta ya esta asociada a un resultado y no puede eliminarse'
		USING ERRCODE = 'restrict_violation';
	END IF;
	-- Verificacion previa que el registro no esgta modificado
	--
	-- Existe una pequeñisima oportunidad que el registro sea alterado entre el exist y el delete
	-- pero dado que es intranscendente no es importante crear una sub transaccion para solo
	-- verificar eso , por ende es mas que suficiente solo esta previa verificacion por exist.
	IF EXISTS(SELECT 1
						FROM tb_postas
						WHERE postas_id = p_postas_id AND xmin = p_version_id)
	THEN
		-- Eliminamos detalle si existe
		DELETE FROM
			tb_postas_detalle
		WHERE postas_id = p_postas_id;

		-- Eliminamos la prueba
		DELETE FROM
			tb_postas
		WHERE postas_id = p_postas_id AND xmin = p_version_id;

		-- SI SE PUDO ELIMINAR SE INDICA 1 DE LO CONTRARIO NULL
		-- VER DOCUMENTACION DE LA FUNCION
		IF FOUND
		THEN
			RETURN 1;
		ELSE
			RETURN NULL;
		END IF;
	ELSE
		RETURN NULL;
	END IF;

END;
$$;


ALTER FUNCTION public.sp_postas_delete_record(p_postas_id integer, p_usuario_mod character varying, p_version_id integer) OWNER TO atluser;

--
-- TOC entry 244 (class 1255 OID 37710)
-- Name: sp_postas_save_record(integer, character varying, integer, boolean, character varying, integer, bit); Type: FUNCTION; Schema: public; Owner: atluser
--

CREATE FUNCTION sp_postas_save_record(p_postas_id integer, p_postas_descripcion character varying, p_competencias_pruebas_id integer, p_activo boolean, p_usuario character varying, p_version_id integer, p_is_update bit) RETURNS integer
LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 02-04-2016

Stored procedure que agrega o actualiza los registros de las postas.

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

select * from ( select sp_postas_save_record(?,?,etc) as updins) as ans where updins is not null;

de tal forma que retornara un registro si el update funciono o el insert , y 0 registros si no se realizo
el uodate. sto es conveniente cuando se usa por ejemplo el affected_rows de algunos drivers.
EN OTRAS BASES ESTO NO ES NECESARIO.

Historia : Creado 15-01-2014
*/

DECLARE v_apppruebas_nro_atletas INTEGER;
				v_pruebas_codigo_old     CHARACTER VARYING(15);
				v_pruebas_codigo_new     CHARACTER VARYING(15);
				v_categorias_codigo_old  CHARACTER VARYING(15);
				v_categorias_codigo_new  CHARACTER VARYING(15);
				v_pruebas_sexo_old       CHARACTER;
				v_pruebas_sexo_new       CHARACTER;


BEGIN

	-- Hay cambio de prueba?
	-- En el mode add o update esta prueba debe ser una prueba que admita mas de un atleta.
	-- Leemos data para validacion
	SELECT
		pv.apppruebas_nro_atletas,
		cp.pruebas_codigo,
		co.categorias_codigo,
		p.pruebas_sexo
	INTO
		v_apppruebas_nro_atletas,
		v_pruebas_codigo_new,
		v_categorias_codigo_new,
		v_pruebas_sexo_new
	FROM tb_competencias_pruebas cp
		INNER JOIN tb_pruebas p ON p.pruebas_codigo = cp.pruebas_codigo
		INNER JOIN tb_app_pruebas_values pv ON pv.apppruebas_codigo = p.pruebas_generica_codigo
		INNER JOIN tb_competencias co ON co.competencias_codigo = cp.competencias_codigo
	WHERE cp.competencias_pruebas_id = p_competencias_pruebas_id;

	IF v_apppruebas_nro_atletas <= 1
	THEN
		RAISE EXCEPTION 'La prueba no acepta postas'
		USING ERRCODE = 'restrict_violation';
	END IF;

	--
	IF p_is_update = '1'
	THEN
		-- Validamos que si hay cambio de prueba , el sexo y categoria de la prueba no hayan cambiado de lo contrario sera
		-- imposible hacer el update  ya que todos los componentes de la posta quedarian invalidados.
		-- Ya existen atletas asociados a esta posta?
		IF EXISTS(SELECT 1
							FROM tb_postas_detalle
							WHERE postas_id = p_postas_id)
		THEN
			-- Dado que es un update , leemos los datos previos para comparar.
			SELECT
				cp.pruebas_codigo,
				co.categorias_codigo,
				p.pruebas_sexo
			INTO
				v_pruebas_codigo_old,
				v_categorias_codigo_old,
				v_pruebas_sexo_old
			FROM tb_competencias_pruebas cp
				INNER JOIN tb_pruebas p ON p.pruebas_codigo = cp.pruebas_codigo
				INNER JOIN tb_app_pruebas_values pv ON pv.apppruebas_codigo = p.pruebas_generica_codigo
				INNER JOIN tb_competencias co ON co.competencias_codigo = cp.competencias_codigo
			WHERE cp.competencias_pruebas_id = (SELECT competencias_pruebas_id
																					FROM tb_postas
																					WHERE postas_id = p_postas_id);

			IF (v_pruebas_codigo_new != v_pruebas_codigo_old AND
					(v_categorias_codigo_new != v_categorias_codigo_old OR v_pruebas_sexo_new != v_pruebas_sexo_old))
			THEN
				RAISE EXCEPTION 'La prueba elegida pertenece a una categoria o sexo diferente a la original, dado que ya existen atletas asignados a esta posta no se permite dicho cambio'
				USING ERRCODE = 'restrict_violation';
			END IF;

		END IF;

		UPDATE
			tb_postas
		SET
			postas_descripcion      = p_postas_descripcion,
			competencias_pruebas_id = p_competencias_pruebas_id,
			activo                  = p_activo,
			usuario_mod             = p_usuario
		WHERE postas_id = p_postas_id AND xmin = p_version_id;
		--   RAISE NOTICE 'COUNT ID --> %', FOUND;

		IF FOUND
		THEN
			RETURN 1;
		ELSE
			RAISE ''
			USING ERRCODE = 'record modified';
			RETURN NULL;
		END IF;
	ELSE
		INSERT INTO
			tb_postas
			(postas_descripcion,
			 competencias_pruebas_id,
			 activo,
			 usuario)
		VALUES (p_postas_descripcion,
						p_competencias_pruebas_id,
						p_activo,
						p_usuario);

		RETURN 1;

	END IF;
END;
$$;


ALTER FUNCTION public.sp_postas_save_record(p_postas_id integer, p_postas_descripcion character varying, p_competencias_pruebas_id integer, p_activo boolean, p_usuario character varying, p_version_id integer, p_is_update bit) OWNER TO atluser;

--
-- TOC entry 294 (class 1255 OID 37701)
-- Name: sp_postasdetalle_save_record(integer, integer, character varying, boolean, character varying, integer, bit); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_postasdetalle_save_record(p_postas_detalle_id integer, p_postas_id integer, p_atletas_codigo character varying, p_activo boolean, p_usuario character varying, p_version_id integer, p_is_update bit) RETURNS integer
LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 03-02-2014

Stored procedure que agrega un atleta a una posta.
Se verifica primero que:

Que el atleta no se encuentre en otra posta para la misma prueba/competencia
Que el sexo del atleta corresponda a la posta
Que el atleta peetenezca a la categoria de la prueba de la posta.

IMPORTANTE : Esta procedure function devuelve un entero siempre que el update o el insert
se hayan realizado y devuelve null si no se realizo el update. Esta extraña forma
se debe a que en pgsql las funciones se ejecutan con select funct_name() , esto quiere
decir que al margen si el update se realizo o no siempre devolvera un registro afectado.
En realidad lo que esta diciendo es que el select de la funcion se ha ejecutado , pero no
es eso lo que deseamos si no saber si el update se realizo o no , para poder simular el
comportamiento standard de otras bases de datos he realizado un truco , determinando si existio
o no el update usando la variable postgres FOUND y retornando 1 si lo hzo y null si no lo hizo.

Esta forma permite realizar el siguiente select cuando se trata de un UPDATE :

select * from ( select sp_postasdetalle_save_record(?,?,etc) as updins) as ans where updins is not null;

de tal forma que retornara un registro si el update funciono o el insert , y 0 registros si no se realizo
el uodate. sto es conveniente cuando se usa por ejemplo el affected_rows de algunos drivers.
EN OTRAS BASES ESTO NO ES NECESARIO.


Historia : Creado 03-03-2014
*/
DECLARE v_prueba_sexo                CHARACTER;
				v_atletas_sexo               CHARACTER;
				v_competencias_pruebas_id    INTEGER;
				v_atletas_fecha_nacimiento   DATE;
				v_categorias_codigo          VARCHAR(15);
				v_pruebas_codigo             VARCHAR(15);
				v_numero_atletas             INTEGER;
				v_competencias_pruebas_fecha DATE;
				v_agnos                      INTEGER;
				v_actual_nro_atletas         INTEGER;

BEGIN
	-- Leemos data para validacion
	SELECT
		--   competencias_codigo,
		pruebas_codigo,
		p.competencias_pruebas_id,
		competencias_pruebas_fecha
	INTO v_pruebas_codigo, v_competencias_pruebas_id, v_competencias_pruebas_fecha
	FROM tb_postas p
		INNER JOIN tb_competencias_pruebas cp ON cp.competencias_pruebas_id = p.competencias_pruebas_id
		INNER JOIN tb_competencias c ON c.competencias_codigo = cp.competencias_codigo
	WHERE
		p.postas_id = p_postas_id;

	-- Leemos data para validar atelta y nmero de atletas
	SELECT
		pruebas_sexo,
		categorias_codigo,
		pv.apppruebas_nro_atletas
	INTO
		v_prueba_sexo, v_categorias_codigo, v_numero_atletas
	FROM tb_pruebas pr
		INNER JOIN tb_app_pruebas_values pv ON pr.pruebas_generica_codigo = pv.apppruebas_codigo
	WHERE pr.pruebas_codigo = v_pruebas_codigo;

	-- 0 -------------------------------------------------------------------------------
	-- Si es add verificamos el maximo numero de atletas.
	IF p_is_update = '0'
	THEN
		SELECT count(*)
		INTO
			v_actual_nro_atletas
		FROM tb_postas_detalle
		WHERE postas_id = p_postas_id;

		IF v_actual_nro_atletas + 1 > v_numero_atletas
		THEN
			RAISE 'El maximo numero de atletas permitido para este tipo de posta es % ', v_numero_atletas
			USING ERRCODE = 'restrict_violation';
		END IF;
	END IF;


	-- 1 -------------------------------------------------------------------------------
	-- El atleta ya esta en una posta para la misma competencia/Prueba?
	-- IF p_is_update = '0'
	-- THEN
	IF EXISTS(SELECT 1
						FROM tb_postas_detalle pd
							INNER JOIN tb_postas p ON p.postas_id = pd.postas_id
						WHERE pd.atletas_codigo = p_atletas_codigo AND p.competencias_pruebas_id = v_competencias_pruebas_id)
	THEN
		RAISE 'El atleta seleccionado ya se encuentra en una posta para esta misma competencia y prueba'
		USING ERRCODE = 'restrict_violation';
	END IF;
	-- END IF;

	-- 2 -------------------------------------------------------------------------------
	-- El atleta tiene el sexo adecuado para la prueba y tiene la edad permitida?

	-- Buscamos sexo y fecha del atletas.
	SELECT
		atletas_sexo,
		atletas_fecha_nacimiento
	INTO v_atletas_sexo, v_atletas_fecha_nacimiento
	FROM tb_atletas
	WHERE atletas_codigo = p_atletas_codigo;

	-- Si la prueba a agregar no es del mismo sexo que la principal lo indifamos.
	IF coalesce(v_atletas_sexo, 'X') != coalesce(v_prueba_sexo, 'Y')
	THEN
		RAISE 'El sexo del atleta no corresponde a la de la prueba indicada, ambos deben ser iguales '
		USING ERRCODE = 'restrict_violation';
	END IF;

	-- 3 -------------------------------------------------------------------------------
	-- El atleta tiene la edad permitida?

	-- La mas dificil , si en la fecha de la prueba el atleta pertenecia a la categoria de
	-- la competencia. Para esto
	-- a) Que edad tenia el atleta en la fecha de la competencia.
	-- b) hasta que edad permite la categoria.
	SELECT date_part('year' :: TEXT, v_competencias_pruebas_fecha :: DATE) -
				 date_part('year' :: TEXT, v_atletas_fecha_nacimiento :: DATE)
	INTO
		v_agnos;

	-- Veamos en la categoria si esta dentro del rango
	-- Importante , basta que la atleta sea menor para la categoria que compitio , ya que una juvenil o menor
	-- podrian competir en una prueba de mayores , por ende si se toma como rango no
	-- funcionaria.
	IF NOT EXISTS(SELECT 1
								FROM tb_categorias
								WHERE categorias_codigo = v_categorias_codigo AND
											v_agnos <= categorias_edad_final)
	THEN
		-- Excepcion el atleta no esta dentro de la categoria
		RAISE 'Para la fecha % en que se realizo la prueba el atleta nacido el % , tendria % años no podria haber competido dentro de la categoria %', v_competencias_pruebas_fecha, v_atletas_fecha_nacimiento, v_agnos, v_categorias_codigo
		USING ERRCODE = 'restrict_violation';
	END IF;


	IF p_is_update = '1'
	THEN
		UPDATE
			tb_postas_detalle
		SET
			postas_id      = p_postas_id,
			atletas_codigo = p_atletas_codigo,
			activo         = p_activo,
			usuario_mod    = p_usuario
		WHERE postas_detalle_id = p_postas_detalle_id AND xmin = p_version_id;
		--RAISE NOTICE 'COUNT ID --> %', FOUND;

		IF FOUND
		THEN
			RETURN 1;
		ELSE
			RETURN NULL;
		END IF;
	ELSE
		INSERT INTO
			tb_postas_detalle
			(postas_id, atletas_codigo, activo, usuario)
		VALUES (p_postas_id,
						p_atletas_codigo,
						p_activo,
						p_usuario);

		RETURN 1;
	END IF;
END;
$$;


ALTER FUNCTION public.sp_postasdetalle_save_record(p_postas_detalle_id integer, p_postas_id integer, p_atletas_codigo character varying, p_activo boolean, p_usuario character varying, p_version_id integer, p_is_update bit) OWNER TO postgres;

--
-- TOC entry 266 (class 1255 OID 16463)
-- Name: sp_pruebas_delete_record(character varying, character varying, integer); Type: FUNCTION; Schema: public; Owner: atluser
--

CREATE FUNCTION sp_pruebas_delete_record(p_pruebas_codigo character varying, p_usuario_mod character varying, p_version_id integer) RETURNS integer
LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 03-02-2014

Stored procedure que elimina una prueba eliminando todos las pruebas asociadas
para el caso de prueas multiples o combinadas,
NO ELIMINA LOS PRUEBAS ASOCIADAS SOLO LAS REFERENCIAS A LAS MISMAS.

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

	select * from ( select sp_prueba_delete_record(?,?,etc) as updins) as ans where updins is not null;

	de tal forma que retornara un registro si el delete funciono , y 0 registros si no se realizo
	el delete. Esto es conveniente cuando se usa por ejemplo el affected_rows de algunos drivers.
	EN OTRAS BASES ESTO NO ES NECESARIO.
Historia : Creado 03-02-2014
*/
BEGIN
	-- Valida que si es parte de una combinada no pueda eliminarse.
	IF EXISTS (SELECT 1 from tb_pruebas_detalle where pruebas_detalle_prueba_codigo  = p_pruebas_codigo)
	THEN
		RAISE 'No puede eliminarse individualmente una prueba parte de una combinada, eliminela prueba principal' USING ERRCODE = 'restrict_violation';
	END IF;

	-- Verificacion previa que el registro no esgta modificado
	--
	-- Existe una pequeñisima oportunidad que el registro sea alterado entre el exist y el delete
	-- pero dado que es intranscendente no es importante crear una sub transaccion para solo
	-- verificar eso , por ende es mas que suficiente solo esta previa verificacion por exist.
	IF EXISTS (SELECT 1 FROM tb_pruebas WHERE pruebas_codigo = p_pruebas_codigo and xmin=p_version_id) THEN
		-- Eliminamos detalle si existe
		DELETE FROM
			tb_pruebas_detalle
		WHERE pruebas_codigo = p_pruebas_codigo;

		-- Eliminamos la prueba
		DELETE FROM
			tb_pruebas
		WHERE pruebas_codigo = p_pruebas_codigo and xmin =p_version_id;

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


ALTER FUNCTION public.sp_pruebas_delete_record(p_pruebas_codigo character varying, p_usuario_mod character varying, p_version_id integer) OWNER TO atluser;

--
-- TOC entry 270 (class 1255 OID 16466)
-- Name: sp_pruebas_save_record(character varying, character varying, character varying, character varying, character, character varying, character varying, boolean, character varying, integer, bit); Type: FUNCTION; Schema: public; Owner: atluser
--

CREATE FUNCTION sp_pruebas_save_record(p_pruebas_codigo character varying, p_pruebas_descripcion character varying, p_pruebas_generica_codigo character varying, p_categorias_codigo character varying, p_pruebas_sexo character, p_pruebas_record_hasta character varying, p_pruebas_anotaciones character varying, p_activo boolean, p_usuario character varying, p_version_id integer, p_is_update bit) RETURNS integer
LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 08-10-2013

Stored procedure que agrega o actualiza los registros de las pruebas.
Previo verifica que la categoria de la prueba sea de menor o igual nivel
que la categoria hasta la que es valida la prueba.
Por ejemplo si la cateegoria es MAYORES la prueba es valida hasta MAYORES
no podria indicarse MENORES.

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

	select * from ( select sp_pruebas_save_record(?,?,etc) as updins) as ans where updins is not null;

	de tal forma que retornara un registro si el update funciono o el insert , y 0 registros si no se realizo
	el uodate. sto es conveniente cuando se usa por ejemplo el affected_rows de algunos drivers.
	EN OTRAS BASES ESTO NO ES NECESARIO.

Historia : Creado 15-01-2014
*/
DECLARE v_peso_cat01 INT;
				DECLARE v_peso_cat02 INT;
				DECLARE v_prueba_multiple BOOLEAN= FALSE;
				DECLARE v_prueba_multiple_old BOOLEAN = FALSE;
				DECLARE v_pruebas_generica_descripcion_old CHARACTER VARYING(200);
				DECLARE v_pruebas_generica_codigo_old CHARACTER VARYING(15);
				DECLARE v_categorias_codigo_old CHARACTER VARYING(15);
				DECLARE v_sexo_old CHARACTER(1);

BEGIN
	-- VALIDACION DE LA CATEGORIA HASTA LA QUE ES VALIDA LA PRUEBA , YA QUE ESTA DEBE SER SIEMPRE MENOR
	-- O IGUAL A LA CATEGORIA DEFINIDA PARA LA PRUEBA.
	select appcat_peso into v_peso_cat01 from tb_app_categorias_values
	where appcat_codigo = (select categorias_validacion from tb_categorias where categorias_codigo = p_categorias_codigo);
	select appcat_peso into v_peso_cat02 from tb_app_categorias_values
	where appcat_codigo = (select categorias_validacion from tb_categorias where categorias_codigo = p_pruebas_record_hasta);

	v_peso_cat01 := coalesce(v_peso_cat01,0);
	v_peso_cat02 := coalesce(v_peso_cat02,-1);

	if v_peso_cat01 > v_peso_cat02
	THEN
		-- Excepcion de pais con ese nombre existe
		RAISE 'La categoria hasta la que es valida la marca de la prueba debe ser mayor o igual a la categoria de la prueba %d %d',v_peso_cat01,v_peso_cat02 USING ERRCODE = 'restrict_violation';
	END IF;



	IF p_is_update = '1'
	THEN
		-- VEMOS SI LA PRUEBA ERA MULTIPLE O NO PARA TOMAR DECISIONES
		-- OBSERVESE QUE SE COMPARA CONTRA EL ESTADO ACTUAL EN LA BASE.
		SELECT apppruebas_multiple INTO
			v_prueba_multiple
		FROM tb_app_pruebas_values p
		WHERE p.apppruebas_codigo = p_pruebas_generica_codigo;


		-- LEEMOS LA DATA ORIGINAL PARA EVALUAR
		SELECT apppruebas_multiple,apppruebas_descripcion,pruebas_generica_codigo,categorias_codigo,pruebas_sexo INTO
			v_prueba_multiple_old,v_pruebas_generica_descripcion_old,v_pruebas_generica_codigo_old,
			v_categorias_codigo_old,v_sexo_old
		FROM tb_pruebas p
			INNER JOIN tb_app_pruebas_values ap  on  ap.apppruebas_codigo = p.pruebas_generica_codigo
		WHERE pruebas_codigo  = p_pruebas_codigo;

		-- Si la prueba ya tiene algun resultado registrado se verifica y de tener se impide el update.
		-- Esto no es verificable por integridad directa de base , ya que lo que se asocia al resultado
		-- es el codigo de la prueba , no el codigo generico. Por ende cambiar el codigo generico de una prueba que ya
		-- tiene resultados asociados devengaria en un desastre.
		-- Lo mismo sucederia si se cambia el sxo o la categoria de la prueba existiendo ya un resultado.
		IF  v_pruebas_generica_codigo_old != p_pruebas_generica_codigo OR v_categorias_codigo_old != p_categorias_codigo OR
				v_sexo_old != p_pruebas_sexo
		THEN
			IF EXISTS (SELECT 1 FROM tb_atletas_resultados al
				INNER JOIN tb_competencias_pruebas cp on cp.competencias_pruebas_id = al.competencias_pruebas_id
			WHERE cp.pruebas_codigo = p_pruebas_codigo  LIMIT 1)
			THEN
				RAISE 'Ya no es posible cambiar la prueba generica % ya que esta prueba ya registra resultados vigentes, asi mismo ni el sexo o categoria de la misma',v_pruebas_generica_descripcion_old USING ERRCODE = 'restrict_violation';
			END IF;
		END IF;


		-- La prueba deja de ser multiple?
		-- eliminamos cualquier prueba asociada , para el caso que pase de multiple a simple.
		IF coalesce(v_prueba_multiple,FALSE) = FALSE
		THEN
			DELETE FROM tb_pruebas_detalle where pruebas_codigo=p_pruebas_codigo;
			-- Si la prueba antigua y actual son multiples pero han cambiado de codigo
			-- digamos del heptatlon al decatlon , debemos tambien borrar el detalle.
		ELSE IF coalesce(v_prueba_multiple,FALSE) = TRUE AND coalesce(v_prueba_multiple_old,FALSE) = TRUE
						AND v_pruebas_generica_codigo_old != p_pruebas_generica_codigo
		THEN
			DELETE FROM tb_pruebas_detalle where pruebas_codigo=p_pruebas_codigo;
		END IF;
		END IF;


		UPDATE
			tb_pruebas
		SET
			pruebas_descripcion=p_pruebas_descripcion,
			pruebas_generica_codigo=p_pruebas_generica_codigo,
			categorias_codigo=p_categorias_codigo,
			pruebas_sexo=p_pruebas_sexo,
			pruebas_record_hasta=p_pruebas_record_hasta,
			pruebas_anotaciones=p_pruebas_anotaciones,
			activo=p_activo,
			usuario_mod=p_usuario
		WHERE pruebas_codigo = p_pruebas_codigo and xmin =p_version_id ;
		RAISE NOTICE  'COUNT ID --> %', FOUND;

		IF FOUND THEN
			RETURN 1;
		ELSE
			RAISE '' USING ERRCODE = 'record modified';
			RETURN null;
		END IF;
	ELSE
		INSERT INTO
			tb_pruebas
			(pruebas_codigo,pruebas_descripcion,pruebas_generica_codigo,categorias_codigo,
			 pruebas_sexo,pruebas_record_hasta,pruebas_anotaciones,
			 activo,usuario)
		VALUES(p_pruebas_codigo,
					 p_pruebas_descripcion,
					 p_pruebas_generica_codigo,
					 p_categorias_codigo,
					 p_pruebas_sexo,
					 p_pruebas_record_hasta,
					 p_pruebas_anotaciones,
					 p_activo,
					 p_usuario);

		RETURN 1;

	END IF;
END;
$$;


ALTER FUNCTION public.sp_pruebas_save_record(p_pruebas_codigo character varying, p_pruebas_descripcion character varying, p_pruebas_generica_codigo character varying, p_categorias_codigo character varying, p_pruebas_sexo character, p_pruebas_record_hasta character varying, p_pruebas_anotaciones character varying, p_activo boolean, p_usuario character varying, p_version_id integer, p_is_update bit) OWNER TO atluser;

--
-- TOC entry 271 (class 1255 OID 16469)
-- Name: sp_pruebasdetalle_save_record(integer, character varying, character varying, integer, boolean, character varying, integer, bit); Type: FUNCTION; Schema: public; Owner: atluser
--

CREATE FUNCTION sp_pruebasdetalle_save_record(p_pruebas_detalle_id integer, p_pruebas_codigo character varying, p_pruebas_detalle_prueba_codigo character varying, p_pruebas_detalle_orden integer, p_activo boolean, p_usuario character varying, p_version_id integer, p_is_update bit) RETURNS integer
LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 03-02-2014

Stored procedure que graba un registro de la relacion entre prueba y multiple y sus pruebas
que la componen  verificando previamente

que la prueba no sea la misma que la principal.
que si una prueba multiple trata de agregarse como parte de otra se indique el error.
Que el numero de orden a asignar a la prueba en detalle no este usado
Que la prueba matriz sea multiple o combinada para agregarsele pruebas
Que el sexo de la prueba detalle sea del mismo tipo que la principal..
Que la prueba matriz y la que se desea agregar sean de la misma categoria.

IMPORTANTE : Esta procedure function devuelve un entero siempre que el update o el insert
	se hayan realizado y devuelve null si no se realizo el update. Esta extraña forma
	se debe a que en pgsql las funciones se ejecutan con select funct_name() , esto quiere
	decir que al margen si el update se realizo o no siempre devolvera un registro afectado.
	En realidad lo que esta diciendo es que el select de la funcion se ha ejecutado , pero no
	es eso lo que deseamos si no saber si el update se realizo o no , para poder simular el
	comportamiento standard de otras bases de datos he realizado un truco , determinando si existio
	o no el update usando la variable postgres FOUND y retornando 1 si lo hzo y null si no lo hizo.

	Esta forma permite realizar el siguiente select cuando se trata de un UPDATE :

	select * from ( select sp_paises_save_record(?,?,etc) as updins) as ans where updins is not null;

	de tal forma que retornara un registro si el update funciono o el insert , y 0 registros si no se realizo
	el uodate. sto es conveniente cuando se usa por ejemplo el affected_rows de algunos drivers.
	EN OTRAS BASES ESTO NO ES NECESARIO.


Historia : Creado 03-03-2014
*/
DECLARE v_prueba_nombre VARCHAR(300) = '';
				DECLARE v_prueba_multiple BOOLEAN = FALSE;
				DECLARE v_categorias_codigo VARCHAR(15);
				DECLARE v_prueba_sexo character ;

				DECLARE v_prueba_sexo_origen character;
				DECLARE v_categorias_codigo_origen VARCHAR(15);

BEGIN
	-- 1 -------------------------------------------------------------------------------
	-- La prueba en detalle es la misma que la principal.
	IF p_pruebas_codigo = p_pruebas_detalle_prueba_codigo
	THEN
		-- Excepcion si se quiere insertar la prueba principal como detalle
		RAISE 'La prueba principal  no puede ser puesta como detalle de ella misma.' USING ERRCODE = 'restrict_violation';

	END IF;

	-- 2 -------------------------------------------------------------------------------
	-- Determino la descripcion y si la prueba a agregar o actualizar es multiple (combinadas)
	SELECT pruebas_descripcion , apppruebas_multiple,pruebas_sexo,categorias_codigo INTO
		v_prueba_nombre,
		v_prueba_multiple,
		v_prueba_sexo_origen,
		v_categorias_codigo_origen
	FROM tb_pruebas p
		INNER JOIN tb_app_pruebas_values apppr on apppr.apppruebas_codigo = p.pruebas_generica_codigo
	WHERE p.pruebas_codigo = p_pruebas_detalle_prueba_codigo;

	-- Verificamos que no tratamos de ingresar como detalle una pruba multiple (eso no es posible)
	IF v_prueba_multiple = TRUE
	THEN
		RAISE 'La prueba "%" es multiple y no puede ser parte de otra.',v_prueba_nombre USING ERRCODE = 'restrict_violation';
	END IF;


	-- 3 -------------------------------------------------------------------------------
	-- Verificamos que no exista una con el mismo numero de orden para la misma prueba multiple.
	IF p_is_update = '1'
	THEN
		-- Si es update logicamente no debe verificarse el mismo registro a actualizar
		IF EXISTS (SELECT 1 FROM tb_pruebas_detalle
		where pruebas_codigo = p_pruebas_codigo and pruebas_detalle_orden = p_pruebas_detalle_orden
					and pruebas_detalle_id != p_pruebas_detalle_id)
		THEN
			-- Ya existe una prueba con ese orden
			RAISE 'Existe una prueba con el mismo orden , verifique por favor' USING ERRCODE = 'restrict_violation';
		END IF;
	ELSE
		IF EXISTS (SELECT 1 FROM tb_pruebas_detalle
		where pruebas_codigo = p_pruebas_codigo and pruebas_detalle_orden = p_pruebas_detalle_orden)
		THEN
			-- Ya existe una prueba con ese orden
			RAISE 'Existe una prueba con el mismo orden , verifique por favor' USING ERRCODE = 'restrict_violation';
		END IF;

	END IF;
	-- 4 -------------------------------------------------------------------------------
	-- Ahora verificamos que la prueba madre sea realmente multiple
	v_prueba_multiple := FALSE;

	SELECT pruebas_descripcion , apppruebas_multiple ,pruebas_sexo,categorias_codigo INTO
		v_prueba_nombre,
		v_prueba_multiple,
		v_prueba_sexo,
		v_categorias_codigo
	FROM tb_pruebas p
		INNER JOIN tb_app_pruebas_values apppr on apppr.apppruebas_codigo = p.pruebas_generica_codigo
	WHERE p.pruebas_codigo = p_pruebas_codigo;

	-- Es multiple?
	IF v_prueba_multiple = FALSE
	THEN
		RAISE 'La prueba "%" debe ser combinada para permitir agregarsele pruebas.',v_prueba_nombre USING ERRCODE = 'restrict_violation';
	END IF;

	-- Si la prueba a agregar no es del mismo sexo que la principal lo indifamos.
	IF v_prueba_sexo_origen != v_prueba_sexo
	THEN
		RAISE 'La prueba "%" es para el sexo (%) y se intenta agregar una prueba para otro sexo.',v_prueba_nombre,v_prueba_sexo_origen USING ERRCODE = 'restrict_violation';
	END IF;

	IF v_categorias_codigo != v_categorias_codigo_origen
	THEN
		RAISE 'La prueba "%" no es de la misma categoria que la que se intenta agregar.',v_prueba_nombre USING ERRCODE = 'restrict_violation';
	END IF;

	-- Verificamos que la prueba no tenga resultados individuales
	IF EXISTS (SELECT 1 FROM tb_atletas_resultados  ar
		INNER JOIN tb_competencias_pruebas cp on cp.competencias_pruebas_id=ar.competencias_pruebas_id
	WHERE cp.pruebas_codigo = p_pruebas_detalle_prueba_codigo and cp.competencias_pruebas_origen_combinada = FALSE)
	THEN
		-- Ya existe resultados individuales para la prueba
		RAISE 'Dicha prueba ya tiene resultados como prueba individual , por ende no puede pertenecer a una combinada ' USING ERRCODE = 'restrict_violation';
	END IF;

	IF p_is_update = '1'
	THEN
		UPDATE
			tb_pruebas_detalle
		SET
			pruebas_codigo=p_pruebas_codigo,
			pruebas_detalle_prueba_codigo=p_pruebas_detalle_prueba_codigo,
			pruebas_detalle_orden=p_pruebas_detalle_orden,
			activo=p_activo,
			usuario_mod=p_usuario
		WHERE pruebas_detalle_id = p_pruebas_detalle_id and xmin =p_version_id ;
		RAISE NOTICE  'COUNT ID --> %', FOUND;

		IF FOUND THEN
			RETURN 1;
		ELSE
			RETURN null;
		END IF;
	ELSE
		INSERT INTO
			tb_pruebas_detalle
			(pruebas_codigo,pruebas_detalle_prueba_codigo,pruebas_detalle_orden,activo,usuario)
		VALUES(p_pruebas_codigo,
					 p_pruebas_detalle_prueba_codigo,
					 p_pruebas_detalle_orden,
					 p_activo,
					 p_usuario);

		RETURN 1;
	END IF;
END;
$$;


ALTER FUNCTION public.sp_pruebasdetalle_save_record(p_pruebas_detalle_id integer, p_pruebas_codigo character varying, p_pruebas_detalle_prueba_codigo character varying, p_pruebas_detalle_orden integer, p_activo boolean, p_usuario character varying, p_version_id integer, p_is_update bit) OWNER TO atluser;

--
-- TOC entry 269 (class 1255 OID 16472)
-- Name: sp_records_delete(integer, character varying, integer); Type: FUNCTION; Schema: public; Owner: atluser
--

CREATE FUNCTION sp_records_delete(p_records_id integer, p_usuario_mod character varying, p_version_id integer) RETURNS integer
LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 13-07-2014

Stored procedure que elimina un record y todos los records que se derivaron de este
lo cual se determina a traves del campo records_id_origen.

Historia : Creado 03-02-2014
*/

BEGIN
	-- Verificacion previa que el registro no esgta modificado
	--
	-- Existe una pequeñisima oportunidad que el registro sea alterado entre el exist y el delete
	-- pero dado que es intranscendente no es importante crear una sub transaccion para solo
	-- verificar eso , por ende es mas que suficiente solo esta previa verificacion por exist.
	IF EXISTS (SELECT 1 FROM tb_records WHERE records_id = p_records_id and xmin=p_version_id) THEN
		-- ELiminamos primeros los asociados dado el constraint.
		DELETE FROM
			tb_records
		WHERE records_id_origen = p_records_id ;

		-- Eliminamosla pricipal y las asociadas en caso de que a prueba sea multiple
		DELETE FROM
			tb_records
		WHERE records_id = p_records_id ;


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


ALTER FUNCTION public.sp_records_delete(p_records_id integer, p_usuario_mod character varying, p_version_id integer) OWNER TO atluser;

--
-- TOC entry 268 (class 1255 OID 16473)
-- Name: sp_records_save_record(integer, character varying, integer, character varying, integer, boolean, boolean, character varying, integer, bit); Type: FUNCTION; Schema: public; Owner: atluser
--

CREATE FUNCTION sp_records_save_record(p_records_id integer, p_records_tipo_codigo character varying, p_atletas_resultados_id integer, p_categorias_codigo character varying, p_records_id_origen integer, p_records_protected boolean, p_activo boolean, p_usuario character varying, p_version_id integer, p_is_update bit) RETURNS integer
LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 10-07-2014

Stored procedure que agrega los registros de los record de pruebas

Previamente hace todas las validaciones necesarias para garantizar que los datos sean grabados
consistentemente,

Dado que no hay mayores datos actualizables , no se permite el update para lo cual se envia
el mensaje adecuado.

Si se agrega un record mundial se promocionara el record regional y nacional para la categoria indicada
, de igual manera si se agre un record regional se agregara el nacional, siempre que si y solo si no exista
uno grabado previamente.

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

	select * from ( select sp_atletas_resultados_save_record(?,?,etc) as updins) as ans where updins is not null;

	de tal forma que retornara un registro si el update funciono o el insert , y 0 registros si no se realizo
	el uodate. sto es conveniente cuando se usa por ejemplo el affected_rows de algunos drivers.
	EN OTRAS BASES ESTO NO ES NECESARIO.

Historia : Creado 15-01-2014
*/
DECLARE v_competencias_pruebas_fecha date;
				DECLARE v_records_id integer;
				DECLARE v_records_tipo_tipo character(1);
				DECLARE v_postas_id integer;
				DECLARE v_is_valid_categoria integer;


BEGIN
	-----------------------------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------------
	-- VEMOS PRIMERO SI EL TIPO DE RECORD EXISTE
	-----------------------------------------------------------------------------------------------------------
	SELECT records_tipo_tipo INTO v_records_tipo_tipo
	FROM tb_records_tipo
	WHERE records_tipo_codigo = p_records_tipo_codigo;

	IF v_records_tipo_tipo IS NULL
	THEN
		RAISE 'No se ha encontrado el tipo de record %',p_records_tipo_codigo USING ERRCODE = 'restrict_violation';
	END IF;

	-----------------------------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------------
	-- VALIDACIONES PRIMARIAS DE INTEGRIDAD LOGICA
	-----------------------------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------------
	-- Determinamos si el resultado es de una posta
	SELECT  postas_id INTO v_postas_id
	FROM tb_atletas_resultados
	WHERE atletas_resultados_id = p_atletas_resultados_id;

	IF v_postas_id IS NULL
	THEN
		SELECT
			competencias_pruebas_fecha,
			coalesce(categoria, 0) as is_valid_categoria
		INTO
			v_competencias_pruebas_fecha,
			v_is_valid_categoria
		FROM
			(
				SELECT
					competencias_pruebas_fecha,
					(SELECT 1
					 FROM tb_categorias
					 WHERE categorias_codigo = p_categorias_codigo AND
								 (SELECT date_part('year' :: TEXT, competencias_pruebas_fecha :: DATE) -
												 date_part('year' :: TEXT, atletas_fecha_nacimiento :: DATE)) <= categorias_edad_final
					 LIMIT 1) AS categoria
				FROM tb_atletas_resultados ar
					INNER JOIN tb_competencias_pruebas cp ON cp.competencias_pruebas_id = ar.competencias_pruebas_id
					INNER JOIN tb_competencias co ON co.competencias_codigo = cp.competencias_codigo
					INNER JOIN tb_atletas at ON at.atletas_codigo = ar.atletas_codigo
				WHERE ar.atletas_resultados_id = p_atletas_resultados_id
			) res;
	ELSE
		SELECT
			max(competencias_pruebas_fecha),
			min(coalesce(categoria, 0)) as is_valid_categoria
		INTO
			v_competencias_pruebas_fecha,
			v_is_valid_categoria
		FROM
			(
				SELECT
					competencias_pruebas_fecha,
					(SELECT 1
					 FROM tb_categorias
					 WHERE categorias_codigo = p_categorias_codigo AND
								 (SELECT date_part('year' :: TEXT, competencias_pruebas_fecha :: DATE) -
												 date_part('year' :: TEXT, atletas_fecha_nacimiento :: DATE)) <= categorias_edad_final
					 LIMIT 1) AS categoria
				FROM tb_atletas_resultados ar
					INNER JOIN tb_postas po ON po.postas_id = ar.postas_id
					INNER JOIN tb_postas_detalle pd ON pd.postas_id = po.postas_id
					INNER JOIN tb_competencias_pruebas cp ON cp.competencias_pruebas_id = ar.competencias_pruebas_id
					INNER JOIN tb_competencias co ON co.competencias_codigo = cp.competencias_codigo
					INNER JOIN tb_atletas at ON at.atletas_codigo = pd.atletas_codigo
				WHERE ar.atletas_resultados_id = p_atletas_resultados_id
			) res;
	END IF;

	--	SELECT  ar.atletas_codigo,competencias_pruebas_fecha,atletas_fecha_nacimiento,
	--		atletas_sexo,pruebas_codigo
	--	INTO
	--		v_atletas_codigo,v_competencias_pruebas_fecha,v_atletas_fecha_nacimiento,
	--		v_atletas_sexo,v_pruebas_codigo
	--	FROM tb_atletas_resultados ar
	--		inner join tb_competencias_pruebas cp on cp.competencias_pruebas_id = ar.competencias_pruebas_id
	--		inner join tb_competencias co on co.competencias_codigo=cp.competencias_codigo
	--		inner join tb_atletas at on at.atletas_codigo=ar.atletas_codigo
	--	WHERE ar.atletas_resultados_id = p_atletas_resultados_id;--


	-- Verificamos si la categoria del record es compatible con la categoria del atleta
	-- La mas dificil , si en la fecha de la prueba el atleta pertenecia a la categoria de
	-- la competencia. Para esto
	-- a) Que edad tenia el atleta en la fecha de la competencia.
	-- b) hasta que edad permite la categoria.
	--	select date_part( 'year'::text,v_competencias_pruebas_fecha::date)-date_part( 'year'::text,v_atletas_fecha_nacimiento::date) INTO
	--		v_agnos;


	-- Veamos en la categoria si esta dentro del rango
	-- Importante , basta que la atleta sea menor para la categoria que compitio , ya que una juvenil o menor
	-- podrian competir en una prueba de mayores , por ende si se toma como rango no
	-- funcionaria.
	IF v_is_valid_categoria = 0
	THEN
		-- Excepcion el atleta no esta dentro de la categoria
		RAISE 'Para la fecha % en que se realizo la prueba el atleta  no podria haber competido dentro de la categoria %',v_competencias_pruebas_fecha,p_categorias_codigo USING ERRCODE = 'restrict_violation';
	END IF;


	IF p_is_update = '1'
	THEN
		RAISE 'No se permite actualizar un record , elimine primero y luego ingreselo..' USING ERRCODE = 'restrict_violation';
	ELSE
		INSERT INTO
			tb_records
			(
				records_tipo_codigo,
				atletas_resultados_id,
				categorias_codigo,
				records_protected,
				activo,
				usuario
			)
		VALUES (
			p_records_tipo_codigo,
			p_atletas_resultados_id,
			p_categorias_codigo,
			p_records_protected,
			p_activo,
			p_usuario
		);

		-- Si el tipo de record es absoluto , grabamos de no existir los records absolutos de menor peso.
		IF v_records_tipo_tipo = 'A'
		THEN
			-- Leemos el id grabado
			SELECT currval(pg_get_serial_sequence('tb_records', 'records_id'))
			INTO v_records_id;

			-- Debemos agregar la prueba a la competencia ya que no existe.
			INSERT INTO
				tb_records
				(
					records_tipo_codigo,
					atletas_resultados_id,
					categorias_codigo,
					records_protected,
					records_id_origen,
					activo,
					usuario
				)
				select
					rt.records_tipo_codigo,
					p_atletas_resultados_id,
					p_categorias_codigo,
					p_records_protected,
					v_records_id,
					p_activo,
					p_usuario
				from tb_records_tipo  rt
				where records_tipo_tipo='A' and
							records_tipo_peso <= (
								-- los de menor peso
								coalesce((select records_tipo_peso from tb_records_tipo
								where records_tipo_tipo='A'
											and records_tipo_codigo=p_records_tipo_codigo),0)
							)
							and records_tipo_codigo not in (
					-- que no se encuentren registrados.
					select records_tipo_codigo
					from tb_records
					where
						atletas_resultados_id = p_atletas_resultados_id and
						categorias_codigo = p_categorias_codigo and
						records_id != v_records_id
					union all
					select p_records_tipo_codigo
				);
		END IF;
		RETURN 1;

	END IF;
END;
$$;


ALTER FUNCTION public.sp_records_save_record(p_records_id integer, p_records_tipo_codigo character varying, p_atletas_resultados_id integer, p_categorias_codigo character varying, p_records_id_origen integer, p_records_protected boolean, p_activo boolean, p_usuario character varying, p_version_id integer, p_is_update bit) OWNER TO atluser;

--
-- TOC entry 273 (class 1255 OID 16476)
-- Name: sp_records_tipo_save_record(character varying, character varying, character varying, character, character, integer, boolean, boolean, character varying, integer, bit); Type: FUNCTION; Schema: public; Owner: atluser
--

CREATE FUNCTION sp_records_tipo_save_record(p_records_tipo_codigo character varying, p_records_tipo_descripcion character varying, p_records_tipo_abreviatura character varying, p_records_tipo_tipo character, p_records_tipo_clasificacion character, p_records_tipo_peso integer, p_records_tipo_protected boolean, p_activo boolean, p_usuario character varying, p_versionid integer, p_is_update bit) RETURNS integer
LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 03-02-2014

Stored procedure que agrega un registro de la relacion entre ligas y clubes
verificando previamente que el club no este asignado a otra liga y dentro del rango
de fechas definidos.

Historia : Creado 03-02-2014
*/
DECLARE v_records_tipo_descripcion character varying(100);

BEGIN

	-- Si sla clasificacion de record es mundial u olimpico no debe haber otro
	-- codigo con dicha clasificacion.
	IF p_records_tipo_clasificacion IN ('M','O','R','N')
	THEN
		-- vemos si ya existe una definicion para mundial,regional,nacional u olimpico
		SELECT INTO v_records_tipo_descripcion records_tipo_descripcion
		FROM tb_records_tipo ea
		where  records_tipo_codigo != p_records_tipo_codigo AND
					 records_tipo_clasificacion = p_records_tipo_clasificacion
		LIMIT 1;

		IF v_records_tipo_descripcion IS NOT NULL
		THEN
			-- Excepcion de pais con ese nombre existe
			RAISE 'El tipo de record % ya esta indicado con la clasificacion % , solo uno tipo de record puede ser especificado como tal',v_records_tipo_descripcion,p_records_tipo_clasificacion USING ERRCODE = 'restrict_violation';
		END IF;
	END IF;

	-- Si el tipo de record es mundial , olimpico o regional se fuerza que el tipo
	-- sea absoluto
	IF p_records_tipo_clasificacion IN ('M','R','N')
	THEN
		p_records_tipo_tipo := 'A';
	ELSE
		p_records_tipo_tipo := 'C';
	END IF;

	IF p_is_update = '1'
	THEN
		-- Update a la relacion liga/club
		UPDATE tb_records_tipo
		SET records_tipo_codigo=p_records_tipo_codigo,
			records_tipo_descripcion=p_records_tipo_descripcion,
			records_tipo_abreviatura=p_records_tipo_abreviatura,
			records_tipo_tipo=p_records_tipo_tipo,
			records_tipo_clasificacion=p_records_tipo_clasificacion,
			records_tipo_peso=p_records_tipo_peso,
			records_tipo_protected=p_records_tipo_protected,
			usuario_mod=p_usuario,
			activo=p_activo
		WHERE records_tipo_codigo = p_records_tipo_codigo and xmin=p_versionid;


		RAISE NOTICE  'COUNT ID --> %', FOUND;

		IF FOUND THEN
			RETURN 1;
		ELSE
			RETURN null;
		END IF;
	ELSE
		INSERT INTO
			tb_records_tipo
			(records_tipo_codigo,records_tipo_descripcion,records_tipo_abreviatura,records_tipo_tipo,records_tipo_clasificacion,records_tipo_peso,records_tipo_protected,activo,usuario)
		VALUES(p_records_tipo_codigo,
					 p_records_tipo_descripcion,
					 p_records_tipo_abreviatura,
					 p_records_tipo_tipo,
					 p_records_tipo_clasificacion,
					 p_records_tipo_peso,
					 p_records_tipo_protected,
					 p_activo,
					 p_usuario);

		RETURN 1;
	END IF;
END;
$$;


ALTER FUNCTION public.sp_records_tipo_save_record(p_records_tipo_codigo character varying, p_records_tipo_descripcion character varying, p_records_tipo_abreviatura character varying, p_records_tipo_tipo character, p_records_tipo_clasificacion character, p_records_tipo_peso integer, p_records_tipo_protected boolean, p_activo boolean, p_usuario character varying, p_versionid integer, p_is_update bit) OWNER TO atluser;

--
-- TOC entry 274 (class 1255 OID 16477)
-- Name: sp_regiones_save_record(character varying, character varying, boolean, character varying, integer, bit); Type: FUNCTION; Schema: public; Owner: atluser
--

CREATE FUNCTION sp_regiones_save_record(p_regiones_codigo character varying, p_regiones_descripcion character varying, p_activo boolean, p_usuario character varying, p_version_id integer, p_is_update bit) RETURNS integer
LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 08-10-2013

Stored procedure que agrega o actualiza los registros de las regiones atleticas.
Previo verifica que no exista una region con el mismo nombre.

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

	select * from ( select sp_regiones_save_record(?,?,etc) as updins) as ans where updins is not null;

	de tal forma que retornara un registro si el update funciono o el insert , y 0 registros si no se realizo
	el uodate. sto es conveniente cuando se usa por ejemplo el affected_rows de algunos drivers.
	EN OTRAS BASES ESTO NO ES NECESARIO.

Historia : Creado 15-06-2014
*/
BEGIN
	-- Verificamos si alguno con el mismo nombre existe e indicamos el error.
	IF EXISTS (SELECT 1 FROM tb_regiones
	where regiones_codigo != p_regiones_codigo and UPPER(LTRIM(RTRIM(regiones_descripcion))) = UPPER(LTRIM(RTRIM(p_regiones_descripcion))))
	THEN
		-- Excepcion de region con ese nombre existe
		RAISE 'Ya existe una region con ese nombre pero diferente codigo' USING ERRCODE = 'restrict_violation';
	END IF;


	IF p_is_update = '1'
	THEN
		UPDATE
			tb_regiones
		SET
			regiones_descripcion=p_regiones_descripcion,
			activo=p_activo,
			usuario_mod=p_usuario
		WHERE regiones_codigo = p_regiones_codigo and xmin =p_version_id ;
		RAISE NOTICE  'COUNT ID --> %', FOUND;

		IF FOUND THEN
			RETURN 1;
		ELSE
			RAISE '' USING ERRCODE = 'record modified';
			RETURN null;
		END IF;
	ELSE
		INSERT INTO
			tb_regiones
			(regiones_codigo,regiones_descripcion,activo,usuario)
		VALUES(p_regiones_codigo,
					 p_regiones_descripcion,
					 p_activo,
					 p_usuario);

		RETURN 1;

	END IF;
END;
$$;


ALTER FUNCTION public.sp_regiones_save_record(p_regiones_codigo character varying, p_regiones_descripcion character varying, p_activo boolean, p_usuario character varying, p_version_id integer, p_is_update bit) OWNER TO atluser;

--
-- TOC entry 275 (class 1255 OID 16480)
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
-- TOC entry 276 (class 1255 OID 16483)
-- Name: sp_view_prueba_resultados_detalle(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_view_prueba_resultados_detalle(p_atletas_resultados_id integer) RETURNS TABLE(atletas_resultados_id integer, pruebas_codigo character varying, pruebas_descripcion character varying, atletas_resultados_resultado character varying, competencias_pruebas_viento numeric, competencias_pruebas_fecha date, atletas_resultados_puntos integer, obs character varying, pruebas_detalle_orden integer)
LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 08-10-2013

Stored procedure que devuelve una lista de las pruebas que componen una prueba combinada con sus respectivos datos
solo para efectos de presentacion.

El parametros atletas_resultados_id debe ser el que corresponde a la prueba principal de la prueba combinada.

Historia : Creado 12-05-2014
*/
BEGIN

	return QUERY
	select
		eatl.atletas_resultados_id,
		cp.pruebas_codigo,
		pr.pruebas_descripcion ,
		eatl.atletas_resultados_resultado,
		(case when pv.apppruebas_viento_individual = TRUE THEN atletas_resultados_viento else cp.competencias_pruebas_viento end) as competencias_pruebas_viento,
		cp.competencias_pruebas_fecha,
		eatl.atletas_resultados_puntos,
		((case when cp.competencias_pruebas_manual = TRUE THEN 'M' ELSE ' ' END) ||
		 (case when cp.competencias_pruebas_material_reglamentario=FALSE THEN 'I' ELSE '_' END) ||
		 (case when cp.competencias_pruebas_anemometro = FALSE then 'a' else '_' end) ||
		 (case when cp.competencias_pruebas_origen_combinada = TRUE THEN
			 case when coalesce(atletas_resultados_viento,cp.competencias_pruebas_viento) > coalesce(apppruebas_viento_limite_multiple,100) then 'V'
			 when coalesce(atletas_resultados_viento,cp.competencias_pruebas_viento) > coalesce(apppruebas_viento_limite_normal,100) then 'v'
			 else '_'
			 end
			ELSE
				case when coalesce(atletas_resultados_viento,cp.competencias_pruebas_viento) > coalesce(apppruebas_viento_limite_normal,100) then 'V'
				else '_'
				end
			END))::character varying as obs,
		prd.pruebas_detalle_orden
	from  tb_atletas_resultados eatl
		inner join tb_competencias_pruebas cp on cp.competencias_pruebas_id = eatl.competencias_pruebas_id
		inner join tb_pruebas pr on pr.pruebas_codigo = cp.pruebas_codigo
		inner join tb_pruebas_detalle prd on prd.pruebas_detalle_prueba_codigo = pr.pruebas_codigo
		inner join tb_app_pruebas_values pv on pv.apppruebas_codigo = pr.pruebas_generica_codigo
	where
		competencias_pruebas_origen_id = (select competencias_pruebas_id from tb_competencias_pruebas cp2 where cp2.competencias_pruebas_id =
																																																						(select competencias_pruebas_id from tb_atletas_resultados eatl2 where eatl2.atletas_resultados_id=p_atletas_resultados_id))
		and eatl.atletas_codigo=(select atletas_codigo from tb_atletas_resultados eatl2 where eatl2.atletas_resultados_id=p_atletas_resultados_id)
	order by pruebas_detalle_orden;
END;
$$;


ALTER FUNCTION public.sp_view_prueba_resultados_detalle(p_atletas_resultados_id integer) OWNER TO postgres;

--
-- TOC entry 277 (class 1255 OID 16484)
-- Name: sp_view_records_categorias(character varying, character, character varying, date, date, character varying, boolean, boolean, integer); Type: FUNCTION; Schema: public; Owner: atluser
--

CREATE FUNCTION sp_view_records_categorias(p_apppruebas_codigo character varying, p_atletas_sexo character, p_records_tipo_codigo character varying, p_fecha_desde date, p_fecha_hasta date, p_categorias_codigo character varying, p_include_manuales boolean, p_include_altura boolean, p_max_results integer) RETURNS TABLE(tipo_record character varying, atleta character varying, prueba character varying, lugar character varying, viento character varying, categoria character varying, fecha date, resultado character varying)
LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 13-06-2014

Stored procedure que retorna en forma resumida los diversos resultados para una prueba,
ya sea por categorias,fechas , resultados manuales o no de uno o mas atletas para su respectiva
comparacion , indicando resultados si son manuales u observados, puediendose filtrar los
mismos.

Basicamente para uso de reportes.

Historia : 13-06-2014
*/
BEGIN
	p_fecha_desde := coalesce(p_fecha_desde,'1910-01-01');
	p_fecha_hasta := coalesce(p_fecha_hasta,'2099-01-01');
	p_include_manuales := coalesce(p_include_manuales,FALSE);
	p_include_altura := coalesce(p_include_altura,FALSE);

	return QUERY
	select
		res.records_tipo_descripcion as tipo_record,
		res.atletas_nombre_completo  as atleta,
		res.apppruebas_descripcion as prueba,
		res.lugar,
		(case when res.viento = 0.00 then '( 0.00)'
		 when res.viento > 0.00 then '(+' || res.viento || ')'
		 when res.viento = -100.00 then '(*****)'
		 when res.viento = -200.00 then ''
		 else '(' || res.viento || ')'
		 end)::character varying as viento,
		--res.competencias_pruebas_manual,
		res.categorias_descripcion as categoria,
		res.competencias_pruebas_fecha as fecha,
		--res.atletas_resultados_resultado,
		(case when res.competencias_pruebas_manual = true  then res.atletas_resultados_resultado || '(M)' else res.atletas_resultados_resultado || '    ' end)::character varying as resultado
	--res.ciudades_altura
	from (
				 select
					 rt.records_tipo_descripcion ,
					 atl.atletas_nombre_completo,
					 pv.apppruebas_descripcion ,
					 (co.competencias_descripcion || ' / ' || paises_descripcion || ' / ' || ciudades_descripcion)::character varying as lugar,
					 (case when pv.apppruebas_verifica_viento = TRUE and cp.competencias_pruebas_anemometro = TRUE
						 then (case when apppruebas_viento_individual = TRUE then coalesce(atletas_resultados_viento,0) else coalesce(competencias_pruebas_viento,0) end)
						when pv.apppruebas_verifica_viento = TRUE and cp.competencias_pruebas_anemometro = FALSE
							then -100.00
						else -200.00
						end)::numeric as viento,
					 cp.competencias_pruebas_manual,
					 cat.categorias_descripcion,
					 cp.competencias_pruebas_fecha,
					 (case when ciu.ciudades_altura = true then ar.atletas_resultados_resultado || ' (A)' else ar.atletas_resultados_resultado || '    ' end) as atletas_resultados_resultado,
					 ciu.ciudades_altura
				 from tb_records rec
					 inner join tb_records_tipo rt on rt.records_tipo_codigo=rec.records_tipo_codigo
					 inner join tb_atletas_resultados ar on ar.atletas_resultados_id=rec.atletas_resultados_id
					 inner join tb_atletas atl on atl.atletas_codigo = ar.atletas_codigo
					 inner join tb_competencias_pruebas cp on cp.competencias_pruebas_id = ar.competencias_pruebas_id
					 inner join tb_pruebas pru on pru.pruebas_codigo = cp.pruebas_codigo
					 inner join tb_app_pruebas_values pv on pv.apppruebas_codigo = pru.pruebas_generica_codigo
					 inner join tb_competencias co on co.competencias_codigo = cp.competencias_codigo
					 inner join tb_paises pai on pai.paises_codigo = co.paises_codigo
					 inner join tb_ciudades ciu on ciu.ciudades_codigo = co.ciudades_codigo
					 inner join tb_pruebas_clasificacion cl on cl.pruebas_clasificacion_codigo = pv.pruebas_clasificacion_codigo
					 inner join tb_categorias cat on cat.categorias_codigo = rec.categorias_codigo
				 --inner join tb_unidad_medida um on um.unidad_medida_codigo = cl.unidad_medida_codigo
				 where
					 rec.categorias_codigo =p_categorias_codigo and
					 rec.records_tipo_codigo=p_records_tipo_codigo and
					 atletas_sexo=p_atletas_sexo and
					 (case when p_apppruebas_codigo is null then true else pv.apppruebas_codigo=p_apppruebas_codigo end) and
					 cp.competencias_pruebas_fecha between p_fecha_desde and p_fecha_hasta and
					 (case when p_include_manuales = FALSE then cp.competencias_pruebas_manual = FALSE else true end) and
					 (case when p_include_altura = FALSE then ciu.ciudades_altura = FALSE else true end)
				 LIMIT COALESCE(p_max_results, NULL )
			 ) res
	order by prueba,fecha desc;

END;
$$;


ALTER FUNCTION public.sp_view_records_categorias(p_apppruebas_codigo character varying, p_atletas_sexo character, p_records_tipo_codigo character varying, p_fecha_desde date, p_fecha_hasta date, p_categorias_codigo character varying, p_include_manuales boolean, p_include_altura boolean, p_max_results integer) OWNER TO atluser;

--
-- TOC entry 278 (class 1255 OID 16487)
-- Name: sp_view_records_fulldata(character varying, character, character varying, date, date, character varying, boolean, boolean, character varying, integer, integer); Type: FUNCTION; Schema: public; Owner: atluser
--

CREATE FUNCTION sp_view_records_fulldata(p_apppruebas_codigo character varying, p_atletas_sexo character, p_records_tipo_codigo character varying, p_fecha_desde date, p_fecha_hasta date, p_categorias_codigo character varying, p_include_manuales boolean, p_include_altura boolean, p_pruebas_tipo_codigo character varying, p_topn integer, p_max_results integer) RETURNS TABLE(tipo_record character varying, atleta character varying, prueba character varying, lugar character varying, viento character varying, categoria character varying, fecha date, resultado character varying, atletas_sexo character, pruebas_tipo_descripcion character varying, combinada_results character varying)
LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 13-06-2014

Stored procedure que retorna en forma resumida los diversos resultados para una prueba,
ya sea por categorias,fechas , resultados manuales o no de uno o mas atletas para su respectiva
comparacion , indicando resultados si son manuales u observados, puediendose filtrar los
mismos.

Basicamente para uso de reportes.

Historia : 13-06-2014
*/
BEGIN
	p_fecha_desde := coalesce(p_fecha_desde,'1910-01-01');
	p_fecha_hasta := coalesce(p_fecha_hasta,'2099-01-01');
	p_include_manuales := coalesce(p_include_manuales,FALSE);
	p_include_altura := coalesce(p_include_altura,FALSE);
	p_topn := coalesce(p_topn,1000);

	return QUERY
	select
		data.tipo_record,
		data.atleta,
		data.prueba,
		data.lugar,
		data.viento,
		data.categoria,
		data.fecha,
		data.resultado,
		data.atletas_sexo,
		data.pruebas_tipo_descripcion,
		data.combinada_results
	from (
				 select
					 res.records_tipo_descripcion as tipo_record,
					 res.atletas_nombre_completo  as atleta,
					 res.apppruebas_descripcion as prueba,
					 res.lugar,
					 (case when res.viento = 0.00 then '( 0.00)'
						when res.viento > 0.00 then '(+' || res.viento || ')'
						when res.viento = -100.00 then '(*****)'
						when res.viento = -200.00 then '     '
						else '(' || res.viento || ')'
						end)::character varying as viento,
					 res.categorias_descripcion as categoria,
					 res.competencias_pruebas_fecha as fecha,
					 (case when res.competencias_pruebas_manual = true  then res.atletas_resultados_resultado || '(M)' else res.atletas_resultados_resultado || '   ' end)::character varying as resultado,
					 res.atletas_sexo,
					 res.pruebas_tipo_descripcion,
					 res.unidad_medida_tipo,
					 res.combinada_results,
					 (case when res.unidad_medida_tipo = 'T' then
						 ROW_NUMBER() OVER (PARTITION BY apppruebas_descripcion ORDER BY res.numb_resultado ASC)
						else
							ROW_NUMBER() OVER (PARTITION BY apppruebas_descripcion ORDER BY res.numb_resultado DESC)
						end)::INTEGER as rank_pos
				 from (
								select
									rt.records_tipo_descripcion ,
									(CASE WHEN ar.postas_id IS NOT NULL
										THEN
											(SELECT array_to_string(ARRAY(SELECT unnest(array_agg(atl.atletas_ap_paterno))
																										ORDER BY 1), ',')
											 FROM tb_postas_detalle pd
												 INNER JOIN tb_postas po ON po.postas_id = pd.postas_id
												 INNER JOIN tb_atletas atl ON atl.atletas_codigo = pd.atletas_codigo
											 WHERE pd.postas_id = ar.postas_id
											 GROUP BY pd.postas_id)
									 ELSE
										 atl.atletas_nombre_completo
									 END) AS atletas_nombre_completo,
									pv.apppruebas_descripcion ,
									(co.competencias_descripcion || ' / ' || paises_descripcion || ' / ' || ciudades_descripcion)::character varying as lugar,
									(case when pv.apppruebas_verifica_viento = TRUE and cp.competencias_pruebas_anemometro = TRUE
										then (case when apppruebas_viento_individual = TRUE then coalesce(atletas_resultados_viento,0) else coalesce(competencias_pruebas_viento,0) end)
									 when pv.apppruebas_verifica_viento = TRUE and cp.competencias_pruebas_anemometro = FALSE
										 then -100.00
									 else -200.00
									 end)::numeric as viento,
									cp.competencias_pruebas_manual,
									cat.categorias_descripcion,
									cp.competencias_pruebas_fecha,
									(case when ciu.ciudades_altura = true then ar.atletas_resultados_resultado || ' (A)' else ar.atletas_resultados_resultado || '    ' end) as atletas_resultados_resultado,
									ciu.ciudades_altura,
									atl.atletas_sexo,
									pt.pruebas_tipo_descripcion,
									um.unidad_medida_tipo,
									case when apppruebas_multiple = true then
										fn_get_combinada_resultados_as_text(cp.competencias_pruebas_id,atl.atletas_codigo,rec.categorias_codigo)
									else null
									end as combinada_results,
									fn_get_marca_normalizada_tonumber(fn_get_marca_normalizada_totext(ar.atletas_resultados_resultado, um.unidad_medida_codigo, cp.competencias_pruebas_manual, pv.apppruebas_factor_manual), um.unidad_medida_codigo) as numb_resultado
								from tb_records rec
									inner join tb_records_tipo rt on rt.records_tipo_codigo=rec.records_tipo_codigo
									inner join tb_atletas_resultados ar on ar.atletas_resultados_id=rec.atletas_resultados_id
									inner join tb_atletas atl on atl.atletas_codigo = ar.atletas_codigo
									inner join tb_competencias_pruebas cp on cp.competencias_pruebas_id = ar.competencias_pruebas_id
									inner join tb_pruebas pru on pru.pruebas_codigo = cp.pruebas_codigo
									inner join tb_app_pruebas_values pv on pv.apppruebas_codigo = pru.pruebas_generica_codigo
									inner join tb_competencias co on co.competencias_codigo = cp.competencias_codigo
									inner join tb_paises pai on pai.paises_codigo = co.paises_codigo
									inner join tb_ciudades ciu on ciu.ciudades_codigo = co.ciudades_codigo
									inner join tb_pruebas_clasificacion cl on cl.pruebas_clasificacion_codigo = pv.pruebas_clasificacion_codigo
									inner join tb_pruebas_tipo pt on pt.pruebas_tipo_codigo = cl.pruebas_tipo_codigo
									inner join tb_categorias cat on cat.categorias_codigo = rec.categorias_codigo
									inner join tb_unidad_medida um on um.unidad_medida_codigo = cl.unidad_medida_codigo
								where
									rec.categorias_codigo =p_categorias_codigo and
									rec.records_tipo_codigo=p_records_tipo_codigo and
									(case when p_atletas_sexo is null then true else atl.atletas_sexo=p_atletas_sexo end) and
									(case when p_pruebas_tipo_codigo is null then true else cl.pruebas_tipo_codigo=p_pruebas_tipo_codigo end) and
									(case when p_apppruebas_codigo is null then true else pv.apppruebas_codigo=p_apppruebas_codigo end) and
									cp.competencias_pruebas_fecha between p_fecha_desde and p_fecha_hasta and
									(case when p_include_manuales = FALSE then cp.competencias_pruebas_manual = FALSE else true end) and
									(case when p_include_altura = FALSE then ciu.ciudades_altura = FALSE else true end)
								LIMIT COALESCE(p_max_results, NULL )
							) res
			 ) data
	where data.rank_pos <= p_topn
	order by prueba,fecha desc,data.rank_pos;
END;
$$;


ALTER FUNCTION public.sp_view_records_fulldata(p_apppruebas_codigo character varying, p_atletas_sexo character, p_records_tipo_codigo character varying, p_fecha_desde date, p_fecha_hasta date, p_categorias_codigo character varying, p_include_manuales boolean, p_include_altura boolean, p_pruebas_tipo_codigo character varying, p_topn integer, p_max_results integer) OWNER TO atluser;

--
-- TOC entry 279 (class 1255 OID 16490)
-- Name: sp_view_records_fulldata_old(character varying, character, character varying, date, date, character varying, boolean, boolean, character varying, integer, integer); Type: FUNCTION; Schema: public; Owner: atluser
--

CREATE FUNCTION sp_view_records_fulldata_old(p_apppruebas_codigo character varying, p_atletas_sexo character, p_records_tipo_codigo character varying, p_fecha_desde date, p_fecha_hasta date, p_categorias_codigo character varying, p_include_manuales boolean, p_include_altura boolean, p_pruebas_tipo_codigo character varying, p_topn integer, p_max_results integer) RETURNS TABLE(tipo_record character varying, atleta character varying, prueba character varying, lugar character varying, viento character varying, categoria character varying, fecha date, resultado character varying, atletas_sexo character, pruebas_tipo_descripcion character varying)
LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 13-06-2014

Stored procedure que retorna en forma resumida los diversos resultados para una prueba,
ya sea por categorias,fechas , resultados manuales o no de uno o mas atletas para su respectiva
comparacion , indicando resultados si son manuales u observados, puediendose filtrar los
mismos.

Basicamente para uso de reportes.

Historia : 13-06-2014
*/
BEGIN
	p_fecha_desde := coalesce(p_fecha_desde,'1910-01-01');
	p_fecha_hasta := coalesce(p_fecha_hasta,'2099-01-01');
	p_include_manuales := coalesce(p_include_manuales,FALSE);
	p_include_altura := coalesce(p_include_altura,FALSE);
	p_topn := coalesce(p_topn,1000);

	return QUERY
	select
		data.tipo_record,
		data.atleta,
		data.prueba,
		data.lugar,
		data.viento,
		data.categoria,
		data.fecha,
		data.resultado,
		data.atletas_sexo,
		data.pruebas_tipo_descripcion
	from (
				 select
					 res.records_tipo_descripcion as tipo_record,
					 res.atletas_nombre_completo  as atleta,
					 res.apppruebas_descripcion as prueba,
					 res.lugar,
					 (case when res.viento = 0.00 then '( 0.00)'
						when res.viento > 0.00 then '(+' || res.viento || ')'
						when res.viento = -100.00 then '(*****)'
						when res.viento = -200.00 then '     '
						else '(' || res.viento || ')'
						end)::character varying as viento,
					 res.categorias_descripcion as categoria,
					 res.competencias_pruebas_fecha as fecha,
					 (case when res.competencias_pruebas_manual = true  then res.atletas_resultados_resultado || '(M)' else res.atletas_resultados_resultado || '   ' end)::character varying as resultado,
					 res.atletas_sexo,
					 res.pruebas_tipo_descripcion,
					 res.unidad_medida_tipo,
					 (case when res.unidad_medida_tipo = 'T' then
						 ROW_NUMBER() OVER (PARTITION BY apppruebas_descripcion ORDER BY res.competencias_pruebas_fecha ASC)
						else
							ROW_NUMBER() OVER (PARTITION BY apppruebas_descripcion ORDER BY res.competencias_pruebas_fecha DESC)
						end)::INTEGER as rank_pos
				 from (
								select
									rt.records_tipo_descripcion ,
									atl.atletas_nombre_completo,
									pv.apppruebas_descripcion ,
									(co.competencias_descripcion || ' / ' || paises_descripcion || ' / ' || ciudades_descripcion)::character varying as lugar,
									(case when pv.apppruebas_verifica_viento = TRUE and cp.competencias_pruebas_anemometro = TRUE
										then (case when apppruebas_viento_individual = TRUE then coalesce(atletas_resultados_viento,0) else coalesce(competencias_pruebas_viento,0) end)
									 when pv.apppruebas_verifica_viento = TRUE and cp.competencias_pruebas_anemometro = FALSE
										 then -100.00
									 else -200.00
									 end)::numeric as viento,
									cp.competencias_pruebas_manual,
									cat.categorias_descripcion,
									cp.competencias_pruebas_fecha,
									(case when ciu.ciudades_altura = true then ar.atletas_resultados_resultado || ' (A)' else ar.atletas_resultados_resultado || '    ' end) as atletas_resultados_resultado,
									ciu.ciudades_altura,
									atl.atletas_sexo,
									pt.pruebas_tipo_descripcion,
									um.unidad_medida_tipo
								from tb_records rec
									inner join tb_records_tipo rt on rt.records_tipo_codigo=rec.records_tipo_codigo
									inner join tb_atletas_resultados ar on ar.atletas_resultados_id=rec.atletas_resultados_id
									inner join tb_atletas atl on atl.atletas_codigo = ar.atletas_codigo
									inner join tb_competencias_pruebas cp on cp.competencias_pruebas_id = ar.competencias_pruebas_id
									inner join tb_pruebas pru on pru.pruebas_codigo = cp.pruebas_codigo
									inner join tb_app_pruebas_values pv on pv.apppruebas_codigo = pru.pruebas_generica_codigo
									inner join tb_competencias co on co.competencias_codigo = cp.competencias_codigo
									inner join tb_paises pai on pai.paises_codigo = co.paises_codigo
									inner join tb_ciudades ciu on ciu.ciudades_codigo = co.ciudades_codigo
									inner join tb_pruebas_clasificacion cl on cl.pruebas_clasificacion_codigo = pv.pruebas_clasificacion_codigo
									inner join tb_pruebas_tipo pt on pt.pruebas_tipo_codigo = cl.pruebas_tipo_codigo
									inner join tb_categorias cat on cat.categorias_codigo = rec.categorias_codigo
									inner join tb_unidad_medida um on um.unidad_medida_codigo = cl.unidad_medida_codigo
								where
									rec.categorias_codigo =p_categorias_codigo and
									rec.records_tipo_codigo=p_records_tipo_codigo and
									(case when p_atletas_sexo is null then true else atl.atletas_sexo=p_atletas_sexo end) and
									(case when p_pruebas_tipo_codigo is null then true else cl.pruebas_tipo_codigo=p_pruebas_tipo_codigo end) and
									(case when p_apppruebas_codigo is null then true else pv.apppruebas_codigo=p_apppruebas_codigo end) and
									cp.competencias_pruebas_fecha between p_fecha_desde and p_fecha_hasta and
									(case when p_include_manuales = FALSE then cp.competencias_pruebas_manual = FALSE else true end) and
									(case when p_include_altura = FALSE then ciu.ciudades_altura = FALSE else true end)
								LIMIT COALESCE(p_max_results, NULL )
							) res
			 ) data
	where data.rank_pos <= p_topn
	order by prueba,fecha desc;
END;
$$;


ALTER FUNCTION public.sp_view_records_fulldata_old(p_apppruebas_codigo character varying, p_atletas_sexo character, p_records_tipo_codigo character varying, p_fecha_desde date, p_fecha_hasta date, p_categorias_codigo character varying, p_include_manuales boolean, p_include_altura boolean, p_pruebas_tipo_codigo character varying, p_topn integer, p_max_results integer) OWNER TO atluser;

--
-- TOC entry 282 (class 1255 OID 16493)
-- Name: sp_view_resultados_atleta(character varying, character varying, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_view_resultados_atleta(v_atletas_codigo character varying, v_pruebas_codigo_generico character varying, v_offset integer, v_limit integer) RETURNS TABLE(atletas_resultados_id integer, atletas_codigo character varying, pruebas_codigo character varying, pruebas_descripcion character varying, competencias_pruebas_tipo_serie character varying, competencias_pruebas_nro_serie integer, serie character varying, categorias_codigo character varying, pruebas_record_hasta character varying, atletas_resultados_puesto integer, atletas_resultados_resultado character varying, norm_resultado integer, competencias_pruebas_viento numeric, obs character varying, lugar character varying, competencias_pruebas_fecha date, origen character varying, apppruebas_multiple boolean)
LANGUAGE plpgsql
AS $$
BEGIN

	return QUERY
	select
		res.atletas_resultados_id,
		res.atletas_codigo,
		res.pruebas_codigo,
		res.pruebas_descripcion,
		res.competencias_pruebas_tipo_serie,
		res.competencias_pruebas_nro_serie,
		(case when res.competencias_pruebas_tipo_serie IN ('SU','FI')
			then res.competencias_pruebas_tipo_serie
		 else (res.competencias_pruebas_tipo_serie || '-' || res.competencias_pruebas_nro_serie)
		 end)::character varying as serie,
		co.categorias_codigo,
		res.pruebas_record_hasta,
		res.atletas_resultados_puesto,
		res.atletas_resultados_resultado,
		(select fn_get_marca_normalizada(res.atletas_resultados_resultado,res.unidad_medida_codigo,competencias_pruebas_manual,res.apppruebas_factor_manual)) as norm_resultado,
		-- El viento para las pruebas de saltos horizontales por ejemplo se da en el mismo resultado y no en la prueba
		-- en otros casos se da en la prueba , esto dependera si apppruebas_viento_individual= TRUE
		-- En el caso que la prueba no requiera viento retornamos null.
		(case when res.apppruebas_verifica_viento = TRUE
			THEN
				(case when res.apppruebas_viento_individual = TRUE THEN res.atletas_resultados_viento ELSE res.competencias_pruebas_viento END)
		 ELSE
			 NULL
		 END) as competencias_pruebas_viento,
		((case when competencias_pruebas_manual = TRUE THEN 'M' ELSE '-' END) ||
		 (case when competencias_pruebas_material_reglamentario=FALSE THEN 'I' ELSE '-' END) ||
		 (case when competencias_pruebas_anemometro = FALSE then 'a' else '-' end) ||
		 (case when ciudades_altura = TRUE THEN 'A' ELSE '-' END) ||
		 (case when res.origen = 'M' THEN
			 case when res.competencias_pruebas_viento > coalesce(res.apppruebas_viento_limite_multiple,100) then 'V'
			 when res.competencias_pruebas_viento > coalesce(res.apppruebas_viento_limite_normal,100) then 'v'
			 else '-'
			 end
			ELSE
				case when res.competencias_pruebas_viento > coalesce(res.apppruebas_viento_limite_normal,100) then 'V'
				else '-'
				end
			END))::character varying as obs,
		(competencias_descripcion || ' / '  || paises_descripcion || ' / ' || ciudades_descripcion)::character varying as lugar,
		res.competencias_pruebas_fecha,
		res.origen::character varying,
		res.apppruebas_multiple
	from (
				 select
					 eatl.atletas_resultados_id,cp.pruebas_codigo,eatl.atletas_codigo,pr.pruebas_descripcion,
					 cp.competencias_pruebas_tipo_serie,cp. 	competencias_pruebas_nro_serie,
					 eatl.atletas_resultados_puesto,competencias_pruebas_manual,cp.competencias_pruebas_viento,eatl.atletas_resultados_viento,
					 cp.competencias_pruebas_material_reglamentario,cp.competencias_pruebas_anemometro,
					 pr.pruebas_record_hasta,cp.competencias_pruebas_fecha,cp.competencias_codigo,
					 eatl.atletas_resultados_resultado,(case when competencias_pruebas_origen_combinada = TRUE then 'C' else 'D' end) as origen,apppruebas_viento_limite_normal,
					 apppruebas_viento_limite_multiple,pv.apppruebas_verifica_viento,
					 um.unidad_medida_tipo,um.unidad_medida_codigo,pv.apppruebas_multiple,pv.apppruebas_factor_manual,pv.apppruebas_viento_individual
				 from  tb_atletas_resultados eatl
					 inner join tb_atletas atl on eatl.atletas_codigo = atl.atletas_codigo
					 inner join tb_competencias_pruebas cp on cp.competencias_pruebas_id = eatl.competencias_pruebas_id
					 inner join tb_pruebas pr on pr.pruebas_codigo =cp.pruebas_codigo
					 inner join tb_app_pruebas_values pv on pv.apppruebas_codigo = pr.pruebas_generica_codigo
					 inner join tb_pruebas_clasificacion cl on cl.pruebas_clasificacion_codigo = pv.pruebas_clasificacion_codigo
					 inner join tb_unidad_medida um on um.unidad_medida_codigo = cl.unidad_medida_codigo
				 where eatl.atletas_codigo = v_atletas_codigo and coalesce(v_pruebas_codigo_generico,pv.apppruebas_codigo) = pv.apppruebas_codigo
				 union all
				 SELECT
					 eatl.atletas_resultados_id,cp.pruebas_codigo,eatl.atletas_codigo,pr.pruebas_descripcion,
					 cp.competencias_pruebas_tipo_serie,cp.competencias_pruebas_nro_serie,
					 eatl.atletas_resultados_puesto,competencias_pruebas_manual,cp.competencias_pruebas_viento,eatl.atletas_resultados_viento,
					 cp.competencias_pruebas_material_reglamentario,cp.competencias_pruebas_anemometro,pr.pruebas_record_hasta,
					 cp.competencias_pruebas_fecha,cp.competencias_codigo,eatl.atletas_resultados_resultado,'D' AS origen,
					 apppruebas_viento_limite_normal,apppruebas_viento_limite_multiple,pv.apppruebas_verifica_viento,
					 um.unidad_medida_tipo,um.unidad_medida_codigo,pv.apppruebas_multiple,pv.apppruebas_factor_manual,pv.apppruebas_viento_individual
				 from tb_atletas_resultados eatl
					 INNER JOIN tb_postas po ON po.postas_id = eatl.postas_id
					 INNER JOIN tb_competencias_pruebas cp ON cp.competencias_pruebas_id = po.competencias_pruebas_id
					 INNER JOIN tb_postas_detalle pd ON pd.postas_id = po.postas_id
					 INNER JOIN tb_pruebas pr ON pr.pruebas_codigo = cp.pruebas_codigo
					 INNER JOIN tb_app_pruebas_values pv ON pv.apppruebas_codigo = pr.pruebas_generica_codigo
					 INNER JOIN tb_pruebas_clasificacion cl ON cl.pruebas_clasificacion_codigo = pv.pruebas_clasificacion_codigo
					 INNER JOIN tb_unidad_medida um ON um.unidad_medida_codigo = cl.unidad_medida_codigo
				 where pd.atletas_codigo = v_atletas_codigo and coalesce(v_pruebas_codigo_generico,pv.apppruebas_codigo) = pv.apppruebas_codigo
			 ) res
		inner join tb_competencias co on co.competencias_codigo = res.competencias_codigo
		inner join tb_ciudades ciu on ciu.ciudades_codigo = co.ciudades_codigo
		inner join tb_paises pa on pa.paises_codigo = ciu.paises_codigo
		inner join tb_categorias ca on ca.categorias_codigo = co.categorias_codigo
		inner join tb_app_categorias_values cv on cv.appcat_codigo = ca.categorias_validacion
	--order by pruebas_descripcion,CO.categorias_codigo,appcat_peso
	OFFSET COALESCE( v_offset, 0 )
	LIMIT COALESCE(v_limit, NULL );

END;
$$;


ALTER FUNCTION public.sp_view_resultados_atleta(v_atletas_codigo character varying, v_pruebas_codigo_generico character varying, v_offset integer, v_limit integer) OWNER TO postgres;

--
-- TOC entry 280 (class 1255 OID 16495)
-- Name: sp_view_resultados_atleta_fulldata(character varying, character varying, character varying, integer, integer, boolean); Type: FUNCTION; Schema: public; Owner: atluser
--

CREATE FUNCTION sp_view_resultados_atleta_fulldata(v_atletas_codigo character varying, v_pruebas_codigo_generico character varying, v_categorias_codigo character varying, v_ano_inicial integer, v_ano_final integer, v_order_by_date boolean) RETURNS TABLE(atletas_resultados_id integer, atletas_codigo character varying, atletas_nombre_completo character varying, pruebas_codigo character varying, pruebas_descripcion character varying, pruebas_tipo_descripcion character varying, categorias_codigo character varying, categorias_descripcion character varying, pruebas_record_hasta character varying, atletas_resultados_resultado character varying, norm_resultado integer, competencias_pruebas_viento numeric, obs character varying, lugar character varying, competencias_pruebas_fecha date, combinada_results character varying, records_descriptor character varying)
LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 11-01-2015

Funcion que retorna toda la informacion asociada a los resultados de un atleta en un rango de fechas , categoria y/o codigo de prueba
especifica.

PARAMETROS :
v_atletas_codigo - Codigo del atleta
v_pruebas_codigo_generico - codigo generico de la prueba o null si se desea todas
v_categorias_codigo - codigo de la categoria en que efectuo la prueba o null para todas.
v_order_by_date resultados ordenados por fecha (true) o por ranking de resultado si es false.

Historia : Creado 11-01-2015
*/
BEGIN
	return QUERY
	select
		final.atletas_resultados_id,
		final.atletas_codigo,
		final.atletas_nombre_completo,
		final.pruebas_codigo,
		final.pruebas_descripcion,
		final.pruebas_tipo_descripcion,
		final.categorias_codigo,
		final.categorias_descripcion,
		final.pruebas_record_hasta,
		final.atletas_resultados_resultado,
		final.norm_resultado,
		final.competencias_pruebas_viento,
		final.obs,
		final.lugar,
		final.competencias_pruebas_fecha,
		final.combinada_results,
		final.records_descriptor
	from(
				select distinct
					res.atletas_resultados_id,
					res.atletas_codigo,
					res.atletas_nombre_completo,
					res.pruebas_codigo,
					res.pruebas_descripcion,
					res.pruebas_tipo_descripcion,
					co.categorias_codigo,
					res.pruebas_record_hasta,
					res.atletas_resultados_resultado,
					case when unidad_medida_tipo = 'T' then
						(select fn_get_marca_normalizada(res.atletas_resultados_resultado,res.unidad_medida_codigo,competencias_pruebas_manual,res.apppruebas_factor_manual))
					else
						(select fn_get_marca_normalizada(res.atletas_resultados_resultado,res.unidad_medida_codigo,competencias_pruebas_manual,res.apppruebas_factor_manual)) * -1
					end as norm_resultado,
					-- El viento para las pruebas de saltos horizontales por ejemplo se da en el mismo resultado y no en la prueba
					-- en otros casos se da en la prueba , esto dependera si apppruebas_viento_individual= TRUE
					-- En el caso que la prueba no requiera viento retornamos null.
					(case when res.apppruebas_verifica_viento = TRUE
						THEN
							(case when res.apppruebas_viento_individual = TRUE THEN res.atletas_resultados_viento ELSE res.competencias_pruebas_viento END)
					 ELSE
						 NULL
					 END) as competencias_pruebas_viento,
					((case when competencias_pruebas_manual = TRUE THEN 'M' ELSE '-' END) ||
					 (case when competencias_pruebas_material_reglamentario=FALSE THEN 'I' ELSE '-' END) ||
					 (case when competencias_pruebas_anemometro = FALSE then 'a' else '-' end) ||
					 (case when ciudades_altura = TRUE THEN 'A' ELSE '-' END) ||
					 (case when res.origen = 'M' THEN
						 case when res.competencias_pruebas_viento > coalesce(res.apppruebas_viento_limite_multiple,100) then 'V'
						 when res.competencias_pruebas_viento > coalesce(res.apppruebas_viento_limite_normal,100) then 'v'
						 else '-'
						 end
						ELSE
							case when res.competencias_pruebas_viento > coalesce(res.apppruebas_viento_limite_normal,100) then 'V'
							else '-'
							end
						END))::character varying as obs,
					(competencias_descripcion || ' / '  || paises_descripcion || ' / ' || ciudades_descripcion)::character varying as lugar,
					res.competencias_pruebas_fecha,
					case when res.apppruebas_multiple = true then
						fn_get_combinada_resultados_as_text(res.competencias_pruebas_id,res.atletas_codigo,co.categorias_codigo)
					else null
					end as combinada_results,
					fn_get_records_for_result_as_text(res.atletas_resultados_id, null) as records_descriptor,
					res.categorias_descripcion,
					fecha_int,
					cv.appcat_peso

				from (
							 select
								 eatl.atletas_resultados_id,cp.competencias_pruebas_id,cp.pruebas_codigo,eatl.atletas_codigo,
								 atl.atletas_nombre_completo,pr.pruebas_descripcion,
								 competencias_pruebas_manual,cp.competencias_pruebas_viento,eatl.atletas_resultados_viento,
								 cp.competencias_pruebas_material_reglamentario,cp.competencias_pruebas_anemometro,
								 pr.pruebas_record_hasta,cp.competencias_pruebas_fecha,cp.competencias_codigo,
								 eatl.atletas_resultados_resultado,
								 (case when competencias_pruebas_origen_combinada = TRUE then 'C' else 'D' end) as origen,
								 apppruebas_viento_limite_normal,
								 apppruebas_viento_limite_multiple,pv.apppruebas_verifica_viento,
								 um.unidad_medida_tipo,um.unidad_medida_codigo,pv.apppruebas_multiple,pv.apppruebas_factor_manual,pv.apppruebas_viento_individual,
								 pt.pruebas_tipo_descripcion,
								 pr.categorias_codigo,
								 cat.categorias_descripcion,
								 rt.records_tipo_abreviatura	,
								 cast(extract(epoch from cp.competencias_pruebas_fecha::TIMESTAMP) as INTEGER) as fecha_int
							 from  tb_atletas_resultados eatl
								 inner join tb_atletas atl on eatl.atletas_codigo = atl.atletas_codigo
								 inner join tb_competencias_pruebas cp on cp.competencias_pruebas_id = eatl.competencias_pruebas_id
								 inner join tb_pruebas pr on pr.pruebas_codigo =cp.pruebas_codigo
								 inner join tb_categorias cat on cat.categorias_codigo =pr.categorias_codigo
								 inner join tb_app_pruebas_values pv on pv.apppruebas_codigo = pr.pruebas_generica_codigo
								 inner join tb_pruebas_clasificacion cl on cl.pruebas_clasificacion_codigo = pv.pruebas_clasificacion_codigo
								 inner join tb_pruebas_tipo pt on pt.pruebas_tipo_codigo = cl.pruebas_tipo_codigo
								 inner join tb_unidad_medida um on um.unidad_medida_codigo = cl.unidad_medida_codigo
								 left  join tb_records rec on rec.atletas_resultados_id=eatl.atletas_resultados_id
								 left join tb_records_tipo rt on rt.records_tipo_codigo=rec.records_tipo_codigo
							 where
								 eatl.atletas_codigo = v_atletas_codigo and
								 coalesce(v_pruebas_codigo_generico,pv.apppruebas_codigo) = pv.apppruebas_codigo and
								 coalesce(v_categorias_codigo,pr.categorias_codigo) = pr.categorias_codigo and
								 extract(year from cp.competencias_pruebas_fecha) >= coalesce(v_ano_inicial,1900) and
								 extract(year from cp.competencias_pruebas_fecha) <= coalesce(v_ano_final,2100)
							 union all
							 select
								 eatl.atletas_resultados_id,cp.competencias_pruebas_id,cp.pruebas_codigo,pd.atletas_codigo,
								 atl.atletas_nombre_completo,pr.pruebas_descripcion,
								 competencias_pruebas_manual,cp.competencias_pruebas_viento,eatl.atletas_resultados_viento,
								 cp.competencias_pruebas_material_reglamentario,cp.competencias_pruebas_anemometro,
								 pr.pruebas_record_hasta,cp.competencias_pruebas_fecha,cp.competencias_codigo,
								 eatl.atletas_resultados_resultado,
								 (case when competencias_pruebas_origen_combinada = TRUE then 'C' else 'D' end) as origen,
								 apppruebas_viento_limite_normal,
								 apppruebas_viento_limite_multiple,pv.apppruebas_verifica_viento,
								 um.unidad_medida_tipo,um.unidad_medida_codigo,pv.apppruebas_multiple,pv.apppruebas_factor_manual,pv.apppruebas_viento_individual,
								 pt.pruebas_tipo_descripcion,
								 pr.categorias_codigo,
								 cat.categorias_descripcion,
								 rt.records_tipo_abreviatura	,
								 cast(extract(epoch from cp.competencias_pruebas_fecha::TIMESTAMP) as INTEGER) as fecha_int
							 from  tb_atletas_resultados eatl
								 INNER JOIN tb_postas po ON po.postas_id = eatl.postas_id
								 INNER JOIN tb_postas_detalle pd on pd.postas_id = po.postas_id
								 inner join tb_atletas atl on atl.atletas_codigo = pd.atletas_codigo
								 inner join tb_competencias_pruebas cp on cp.competencias_pruebas_id = eatl.competencias_pruebas_id
								 inner join tb_pruebas pr on pr.pruebas_codigo =cp.pruebas_codigo
								 inner join tb_categorias cat on cat.categorias_codigo =pr.categorias_codigo
								 inner join tb_app_pruebas_values pv on pv.apppruebas_codigo = pr.pruebas_generica_codigo
								 inner join tb_pruebas_clasificacion cl on cl.pruebas_clasificacion_codigo = pv.pruebas_clasificacion_codigo
								 inner join tb_pruebas_tipo pt on pt.pruebas_tipo_codigo = cl.pruebas_tipo_codigo
								 inner join tb_unidad_medida um on um.unidad_medida_codigo = cl.unidad_medida_codigo
								 left  join tb_records rec on rec.atletas_resultados_id=eatl.atletas_resultados_id
								 left join tb_records_tipo rt on rt.records_tipo_codigo=rec.records_tipo_codigo
							 where
								 pd.atletas_codigo = v_atletas_codigo and
								 coalesce(v_pruebas_codigo_generico,pv.apppruebas_codigo) = pv.apppruebas_codigo and
								 coalesce(v_categorias_codigo,pr.categorias_codigo) = pr.categorias_codigo and
								 extract(year from cp.competencias_pruebas_fecha) >= coalesce(v_ano_inicial,1900) and
								 extract(year from cp.competencias_pruebas_fecha) <= coalesce(v_ano_final,2100)

						 ) res
					inner join tb_competencias co on co.competencias_codigo = res.competencias_codigo
					inner join tb_ciudades ciu on ciu.ciudades_codigo = co.ciudades_codigo
					inner join tb_paises pa on pa.paises_codigo = ciu.paises_codigo
					inner join tb_categorias ca on ca.categorias_codigo = co.categorias_codigo
					inner join tb_app_categorias_values cv on cv.appcat_codigo = ca.categorias_validacion
				--ORDER BY cv.appcat_peso
			) final
	ORDER BY appcat_peso,pruebas_descripcion,case v_order_by_date = TRUE when TRUE then final.fecha_int else final.norm_resultado end;END;
$$;


ALTER FUNCTION public.sp_view_resultados_atleta_fulldata(v_atletas_codigo character varying, v_pruebas_codigo_generico character varying, v_categorias_codigo character varying, v_ano_inicial integer, v_ano_final integer, v_order_by_date boolean) OWNER TO atluser;

--
-- TOC entry 297 (class 1255 OID 37761)
-- Name: sp_view_resultados_competencia_especifica(character varying, character varying, character, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_view_resultados_competencia_especifica(v_competencias_codigo character varying, v_pruebas_codigo character varying, v_pruebas_sexo character, v_offset integer, v_limit integer) RETURNS TABLE(atletas_resultados_id integer, atletas_codigo character varying, atletas_nombre_completo character varying, pruebas_codigo character varying, pruebas_descripcion character varying, competencias_pruebas_tipo_serie character varying, competencias_pruebas_nro_serie integer, serie character varying, pruebas_sexo character, categorias_codigo character varying, pruebas_record_hasta character varying, atletas_resultados_puesto integer, atletas_resultados_resultado character varying, norm_resultado integer, competencias_pruebas_viento numeric, obs character varying, competencias_pruebas_fecha date, origen character varying, apppruebas_multiple boolean, postas_atletas character varying)
LANGUAGE plpgsql
AS $$
BEGIN

	RETURN QUERY
	SELECT
		res.atletas_resultados_id,
		res.atletas_codigo,
		res.atletas_nombre_completo,
		res.pruebas_codigo,
		res.pruebas_descripcion,
		res.competencias_pruebas_tipo_serie,
		res.competencias_pruebas_nro_serie,
		(CASE WHEN res.competencias_pruebas_tipo_serie IN ('SU', 'FI')
			THEN res.competencias_pruebas_tipo_serie
		 ELSE (res.competencias_pruebas_tipo_serie || '-' || res.competencias_pruebas_nro_serie)
		 END) :: CHARACTER VARYING         AS serie,
		res.pruebas_sexo,
		res.categorias_codigo,
		res.pruebas_record_hasta,
		res.atletas_resultados_puesto,
		res.atletas_resultados_resultado,
		(SELECT
			 fn_get_marca_normalizada(res.atletas_resultados_resultado, res.unidad_medida_codigo, competencias_pruebas_manual,
																0.26)) AS norm_resultado,
		(CASE WHEN apppruebas_verifica_viento = TRUE
			THEN
				(CASE WHEN res.apppruebas_viento_individual = TRUE
					THEN res.atletas_resultados_viento
				 ELSE res.competencias_pruebas_viento END)
		 ELSE
			 NULL
		 END)                              AS competencias_pruebas_viento,
		((CASE WHEN res.competencias_pruebas_manual = TRUE
			THEN 'M'
			ELSE '-' END) ||
		 (CASE WHEN res.competencias_pruebas_material_reglamentario = FALSE
			 THEN 'I'
			ELSE '-' END) ||
		 (CASE WHEN res.competencias_pruebas_anemometro = FALSE
			 THEN 'a'
			ELSE '-' END) ||
		 (CASE WHEN ciudades_altura = TRUE
			 THEN 'A'
			ELSE '-' END) ||
		 (CASE WHEN res.origen = 'C'
			 THEN
				 CASE WHEN coalesce(atletas_resultados_viento, res.competencias_pruebas_viento) >
									 coalesce(res.apppruebas_viento_limite_multiple, 100)
					 THEN 'V'
				 WHEN coalesce(atletas_resultados_viento, res.competencias_pruebas_viento) >
							coalesce(res.apppruebas_viento_limite_normal, 100)
					 THEN 'v'
				 ELSE '-'
				 END
			ELSE
				CASE WHEN res.competencias_pruebas_viento > coalesce(res.apppruebas_viento_limite_normal, 100)
					THEN 'V'
				ELSE '-'
				END
			END)) :: CHARACTER VARYING       AS obs,
		res.competencias_pruebas_fecha,
		res.origen :: CHARACTER VARYING,
		res.apppruebas_multiple,
		res.postas_atletas:: CHARACTER VARYING
	FROM (
				 SELECT
					 eatl.atletas_resultados_id,
					 cp.pruebas_codigo,
					 eatl.atletas_codigo,
					 atl.atletas_nombre_completo,
					 pr.pruebas_descripcion,
					 pr.pruebas_sexo,
					 cp.competencias_pruebas_tipo_serie,
					 cp.competencias_pruebas_nro_serie,
					 eatl.atletas_resultados_puesto,
					 competencias_pruebas_manual,
					 cp.competencias_pruebas_viento,
					 competencias_pruebas_material_reglamentario,
					 competencias_pruebas_anemometro,
					 pr.pruebas_record_hasta,
					 cp.competencias_pruebas_fecha,
					 cp.competencias_codigo,
					 eatl.atletas_resultados_resultado,
					 (CASE WHEN competencias_pruebas_origen_combinada = TRUE
						 THEN 'C'
						ELSE 'D' END) AS origen,
					 apppruebas_viento_limite_normal,
					 apppruebas_viento_limite_multiple,
					 um.unidad_medida_tipo,
					 um.unidad_medida_codigo,
					 pv.apppruebas_multiple,
					 co.categorias_codigo,
					 co.ciudades_codigo,
					 pv.apppruebas_viento_individual,
					 atletas_resultados_viento,
					 apppruebas_verifica_viento,
					 (CASE WHEN eatl.postas_id IS NOT NULL
						 THEN
							 (SELECT max(postas_descripcion) || ' - ' ||
											 array_to_string(ARRAY(SELECT unnest(array_agg(atl.atletas_ap_paterno))
																						 ORDER BY 1), ',')
								FROM tb_postas_detalle pd
									INNER JOIN tb_postas po ON po.postas_id = pd.postas_id
									INNER JOIN tb_atletas atl ON atl.atletas_codigo = pd.atletas_codigo
								WHERE pd.postas_id = eatl.postas_id
								GROUP BY pd.postas_id)
						ELSE
							NULL
						END)          AS postas_atletas
				 FROM tb_atletas_resultados eatl
					 INNER JOIN tb_competencias_pruebas cp ON cp.competencias_pruebas_id = eatl.competencias_pruebas_id
					 INNER JOIN tb_competencias co ON co.competencias_codigo = cp.competencias_codigo
					 INNER JOIN tb_atletas atl ON eatl.atletas_codigo = atl.atletas_codigo
					 INNER JOIN tb_pruebas pr ON pr.pruebas_codigo = cp.pruebas_codigo
					 INNER JOIN tb_app_pruebas_values pv ON pv.apppruebas_codigo = pr.pruebas_generica_codigo
					 INNER JOIN tb_pruebas_clasificacion cl ON cl.pruebas_clasificacion_codigo = pv.pruebas_clasificacion_codigo
					 INNER JOIN tb_unidad_medida um ON um.unidad_medida_codigo = cl.unidad_medida_codigo
				 WHERE cp.competencias_codigo = v_competencias_codigo
							 AND coalesce(v_pruebas_codigo, cp.pruebas_codigo) = cp.pruebas_codigo
							 AND coalesce(v_pruebas_sexo, pr.pruebas_sexo) = pr.pruebas_sexo
			 ) res
		INNER JOIN tb_ciudades ciu ON ciu.ciudades_codigo = res.ciudades_codigo
		INNER JOIN tb_app_categorias_values cv ON cv.appcat_codigo = res.categorias_codigo
	ORDER BY pruebas_sexo, pruebas_descripcion, res.categorias_codigo, appcat_peso
	OFFSET COALESCE(v_offset, 0)
	LIMIT COALESCE(v_limit, NULL);


END;
$$;


ALTER FUNCTION public.sp_view_resultados_competencia_especifica(v_competencias_codigo character varying, v_pruebas_codigo character varying, v_pruebas_sexo character, v_offset integer, v_limit integer) OWNER TO postgres;

--
-- TOC entry 283 (class 1255 OID 16499)
-- Name: sp_view_resultados_competencia_por_generica(character varying, character varying, character, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_view_resultados_competencia_por_generica(v_competencias_codigo character varying, v_pruebas_codigo_generico character varying, v_pruebas_sexo character, v_offset integer, v_limit integer) RETURNS TABLE(atletas_resultados_id integer, atletas_codigo character varying, atletas_nombre_completo character varying, pruebas_codigo character varying, pruebas_descripcion character varying, competencias_pruebas_tipo_serie character varying, competencias_pruebas_nro_serie integer, serie character varying, pruebas_sexo character, categorias_codigo character varying, pruebas_record_hasta character varying, atletas_resultados_puesto integer, atletas_resultados_resultado character varying, norm_resultado integer, competencias_pruebas_viento numeric, obs character varying, competencias_pruebas_fecha date, origen character varying, apppruebas_multiple boolean)
LANGUAGE plpgsql
AS $$
BEGIN

	return QUERY
	select
		res.atletas_resultados_id,
		res.atletas_codigo,
		res.atletas_nombre_completo,
		res.pruebas_codigo,
		res.pruebas_descripcion,
		res.competencias_pruebas_tipo_serie,
		res.competencias_pruebas_nro_serie,
		(case when res.competencias_pruebas_tipo_serie IN ('SU','FI')
			then res.competencias_pruebas_tipo_serie
		 else (res.competencias_pruebas_tipo_serie || '-' || res.competencias_pruebas_nro_serie)
		 end)::character varying as serie,
		res.pruebas_sexo,
		res.categorias_codigo,
		res.pruebas_record_hasta,
		res.atletas_resultados_puesto,
		res.atletas_resultados_resultado,
		(select fn_get_marca_normalizada(res.atletas_resultados_resultado,res.unidad_medida_codigo,competencias_pruebas_manual,0.26)) as norm_resultado,
		res.competencias_pruebas_viento,
		((case when res.competencias_pruebas_manual = TRUE THEN 'M' ELSE '-' END) ||
		 (case when res.competencias_pruebas_material_reglamentario=FALSE THEN 'I' ELSE '-' END) ||
		 (case when res.competencias_pruebas_anemometro = FALSE then 'a' else '-' end) ||
		 (case when ciudades_altura = TRUE THEN 'A' ELSE '-' END) ||
		 (case when res.origen = 'C' THEN
			 case when res.competencias_pruebas_viento > coalesce(res.apppruebas_viento_limite_multiple,100) then 'V'
			 when res.competencias_pruebas_viento > coalesce(res.apppruebas_viento_limite_normal,100) then 'v'
			 else '-'
			 end
			ELSE
				case when res.competencias_pruebas_viento > coalesce(res.apppruebas_viento_limite_normal,100) then 'V'
				else '-'
				end
			END))::character varying as obs,
		res.competencias_pruebas_fecha,
		res.origen::character varying,
		res.apppruebas_multiple
	from (
				 select
					 eatl.atletas_resultados_id,cp.pruebas_codigo,eatl.atletas_codigo,atl.atletas_nombre_completo,
					 pr.pruebas_descripcion,pr.pruebas_sexo,cp.competencias_pruebas_tipo_serie,cp.competencias_pruebas_nro_serie,
					 eatl.atletas_resultados_puesto,competencias_pruebas_manual,cp.competencias_pruebas_viento,competencias_pruebas_material_reglamentario,
					 competencias_pruebas_anemometro,pr.pruebas_record_hasta,cp.competencias_pruebas_fecha,cp.competencias_codigo,
					 eatl.atletas_resultados_resultado,(case when competencias_pruebas_origen_combinada = TRUE then 'C' else 'D' end) as origen,apppruebas_viento_limite_normal,apppruebas_viento_limite_multiple,
					 um.unidad_medida_tipo,um.unidad_medida_codigo,pv.apppruebas_multiple,co.categorias_codigo,co.ciudades_codigo
				 from  tb_atletas_resultados eatl
					 inner join tb_competencias_pruebas cp on cp.competencias_pruebas_id = eatl.competencias_pruebas_id
					 inner join tb_competencias co on co.competencias_codigo = cp.competencias_codigo
					 inner join tb_atletas atl on eatl.atletas_codigo = atl.atletas_codigo
					 inner join tb_pruebas pr on pr.pruebas_codigo = cp.pruebas_codigo
					 inner join tb_app_pruebas_values pv on pv.apppruebas_codigo = pr.pruebas_generica_codigo
					 inner join tb_pruebas_clasificacion cl on cl.pruebas_clasificacion_codigo = pv.pruebas_clasificacion_codigo
					 inner join tb_unidad_medida um on um.unidad_medida_codigo = cl.unidad_medida_codigo
				 where cp.competencias_codigo = v_competencias_codigo
							 and coalesce(v_pruebas_codigo_generico,pv.apppruebas_codigo) = pv.apppruebas_codigo
							 and coalesce(v_pruebas_sexo,pr.pruebas_sexo) = pr.pruebas_sexo
			 ) res
		inner join tb_ciudades ciu on ciu.ciudades_codigo = res.ciudades_codigo
		inner join tb_app_categorias_values cv on cv.appcat_codigo = res.categorias_codigo
	order by pruebas_sexo,pruebas_descripcion,res.categorias_codigo,appcat_peso
	OFFSET COALESCE( v_offset, 0 )
	LIMIT COALESCE(v_limit, NULL );


END;
$$;


ALTER FUNCTION public.sp_view_resultados_competencia_por_generica(v_competencias_codigo character varying, v_pruebas_codigo_generico character varying, v_pruebas_sexo character, v_offset integer, v_limit integer) OWNER TO postgres;

--
-- TOC entry 284 (class 1255 OID 16500)
-- Name: sp_view_resumen_records_por_prueba_categorias(character varying, character, character varying, date, date, character varying, boolean, boolean, integer); Type: FUNCTION; Schema: public; Owner: atluser
--

CREATE FUNCTION sp_view_resumen_records_por_prueba_categorias(p_apppruebas_codigo character varying, p_atletas_sexo character, p_records_tipo_codigo character varying, p_fecha_desde date, p_fecha_hasta date, p_categorias_codigo character varying, p_include_manuales boolean, p_include_altura boolean, p_max_results integer) RETURNS TABLE(records_tipo_descripcion character varying, atletas_nombre_completo character varying, apppruebas_descripcion character varying, lugar character varying, comentario character varying, competencias_pruebas_manual boolean, categorias_codigo character varying, competencias_pruebas_fecha date, atletas_resultados_resultado character varying, norm_resultado character varying, numb_resultado numeric, ciudades_altura boolean, unidad_medida_codigo character varying)
LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 13-06-2014

Stored procedure que retorna en forma resumida los diversos resultados para una prueba,
ya sea por categorias,fechas , resultados manuales o no de uno o mas atletas para su respectiva
comparacion , indicando resultados si son manuales u observados, puediendose filtrar los
mismos.

Basicamente para uso de reportes.

Historia : 13-06-2014
*/
BEGIN
	p_fecha_desde := coalesce(p_fecha_desde,'1910-01-01');
	p_fecha_hasta := coalesce(p_fecha_hasta,'2099-01-01');
	p_include_manuales := coalesce(p_include_manuales,FALSE);
	p_include_altura := coalesce(p_include_altura,FALSE);

	return QUERY
	select
		rt.records_tipo_descripcion,
		atl.atletas_nombre_completo,
		pv.apppruebas_descripcion,
		(co.competencias_descripcion || ' / ' || paises_descripcion || ' / ' || ciudades_descripcion)::character varying as lugar,
		--	coalesce((case when apppruebas_viento_individual = TRUE THEN ar.atletas_resultados_viento ELSE competencias_pruebas_viento END),0.00) as competencias_pruebas_viento,
		(
			(case when cp.competencias_pruebas_origen_id is not null then  (select pruebas_descripcion from tb_pruebas where pruebas_codigo = (select pruebas_codigo from tb_competencias_pruebas  where competencias_pruebas_id  = cp.competencias_pruebas_origen_id)) else '' end )  ||
			(case when cp.competencias_pruebas_origen_id is not null then  '/' || rec.categorias_codigo  else rec.categorias_codigo  end ) || '( ' ||
			(case when pv.apppruebas_verifica_viento = TRUE and cp.competencias_pruebas_anemometro = TRUE
				then 'V:' || (case when apppruebas_viento_individual = TRUE then coalesce(atletas_resultados_viento,0) else coalesce(competencias_pruebas_viento,0) end)
			 when pv.apppruebas_verifica_viento = TRUE and cp.competencias_pruebas_anemometro = FALSE
				 then 'V:A-'
			 else 'V:xx'
			 end)
			|| (case when competencias_pruebas_material_reglamentario = FALSE then ' / M-' else '' end)
			|| (case when cp.competencias_pruebas_manual = TRUE then ' / Manual' else '' end)
			|| ' )'
		)::character varying as comentario,
		cp.competencias_pruebas_manual,
		rec.categorias_codigo,
		cp.competencias_pruebas_fecha,
		ar.atletas_resultados_resultado,
		fn_get_marca_normalizada_totext(ar.atletas_resultados_resultado, um.unidad_medida_codigo, cp.competencias_pruebas_manual, pv.apppruebas_factor_manual) as norm_resultado,
		fn_get_marca_normalizada_tonumber(fn_get_marca_normalizada_totext(ar.atletas_resultados_resultado, um.unidad_medida_codigo, cp.competencias_pruebas_manual, pv.apppruebas_factor_manual), um.unidad_medida_codigo) as numb_resultado,
		ciu.ciudades_altura,
		um.unidad_medida_codigo
	from tb_records rec
		inner join tb_records_tipo rt on rt.records_tipo_codigo=rec.records_tipo_codigo
		inner join tb_atletas_resultados ar on ar.atletas_resultados_id=rec.atletas_resultados_id
		inner join tb_atletas atl on atl.atletas_codigo = ar.atletas_codigo
		inner join tb_competencias_pruebas cp on cp.competencias_pruebas_id = ar.competencias_pruebas_id
		inner join tb_pruebas pru on pru.pruebas_codigo = cp.pruebas_codigo
		inner join tb_app_pruebas_values pv on pv.apppruebas_codigo = pru.pruebas_generica_codigo
		inner join tb_competencias co on co.competencias_codigo = cp.competencias_codigo
		inner join tb_paises pai on pai.paises_codigo = co.paises_codigo
		inner join tb_ciudades ciu on ciu.ciudades_codigo = co.ciudades_codigo
		inner join tb_pruebas_clasificacion cl on cl.pruebas_clasificacion_codigo = pv.pruebas_clasificacion_codigo
		inner join tb_unidad_medida um on um.unidad_medida_codigo = cl.unidad_medida_codigo
	where
		rec.categorias_codigo =p_categorias_codigo and
		rec.records_tipo_codigo=p_records_tipo_codigo and
		atletas_sexo=p_atletas_sexo and
		pv.apppruebas_codigo=p_apppruebas_codigo and
		cp.competencias_pruebas_fecha between p_fecha_desde and p_fecha_hasta and
		(case when p_include_manuales = FALSE then cp.competencias_pruebas_manual = FALSE else true end) and
		(case when p_include_altura = FALSE then ciu.ciudades_altura = FALSE else true end)
	order by cp.competencias_pruebas_fecha asc , atletas_resultados_resultado desc
	LIMIT COALESCE(p_max_results, NULL );

END;
$$;


ALTER FUNCTION public.sp_view_resumen_records_por_prueba_categorias(p_apppruebas_codigo character varying, p_atletas_sexo character, p_records_tipo_codigo character varying, p_fecha_desde date, p_fecha_hasta date, p_categorias_codigo character varying, p_include_manuales boolean, p_include_altura boolean, p_max_results integer) OWNER TO atluser;

--
-- TOC entry 286 (class 1255 OID 16503)
-- Name: sp_view_resumen_resultados_por_prueba_atletas(character varying, character varying[], character, date, date, character varying, character varying, boolean, boolean, integer); Type: FUNCTION; Schema: public; Owner: atluser
--

CREATE FUNCTION sp_view_resumen_resultados_por_prueba_atletas(p_apppruebas_codigo character varying, p_atletas_codigo character varying[], p_atletas_sexo character, p_fecha_desde date, p_fecha_hasta date, p_desde_categoria character varying, p_hasta_categoria character varying, p_include_manuales boolean, p_include_observados boolean, p_max_results integer) RETURNS TABLE(atletas_nombre_completo character varying, apppruebas_descripcion character varying, lugar character varying, comentario character varying, competencias_pruebas_manual boolean, categorias_codigo character varying, pruebas_record_hasta character varying, competencias_pruebas_fecha date, atletas_resultados_resultado character varying, norm_resultado character varying, numb_resultado numeric, vflag character, tipo character varying, unidad_medida_codigo character varying)
LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 13-06-2014

Stored procedure que retorna en forma resumida los diversos resultados para una prueba,
ya sea por categorias,fechas , resultados manuales o no de uno o mas atletas para su respectiva
comparacion , indicando resultados si son manuales u observados, puediendose filtrar los
mismos.

Basicamente para uso de reportes.
Historia : 13-06-2014
*/
DECLARE v_peso_desde INTEGER;
				DECLARE v_peso_hasta INTEGER;
BEGIN
	p_fecha_desde := coalesce(p_fecha_desde,'1910-01-01');
	p_fecha_hasta := coalesce(p_fecha_hasta,'2099-01-01');
	p_include_manuales := coalesce(p_include_manuales,FALSE);

	select appcat_peso into v_peso_desde from tb_app_categorias_values  where appcat_codigo  = coalesce((select categorias_validacion from tb_categorias c where c.categorias_codigo=p_desde_categoria),'INF');
	select appcat_peso into v_peso_hasta from tb_app_categorias_values  where appcat_codigo  = coalesce((select categorias_validacion from tb_categorias c where c.categorias_codigo=p_hasta_categoria),'MAY');

	return QUERY
	select * from (
									select
										atl.atletas_nombre_completo,
										pv.apppruebas_descripcion,
										(competencias_descripcion || ' / ' || ciudades_descripcion || ' / ' || paises_descripcion)::character varying as lugar,
										(
											(case when cp.competencias_pruebas_origen_id is not null then  (select pruebas_descripcion from tb_pruebas where pruebas_codigo = (select pruebas_codigo from tb_competencias_pruebas  where competencias_pruebas_id  = cp.competencias_pruebas_origen_id)) else '' end )  ||
											(case when cp.competencias_pruebas_origen_id is not null then  '/' || pr.categorias_codigo || '-' || pr.pruebas_record_hasta  else pr.categorias_codigo || '-' || pr.pruebas_record_hasta end ) || '( ' ||
											(case when pv.apppruebas_verifica_viento = TRUE and cp.competencias_pruebas_anemometro = TRUE
												then 'V:' || (case when apppruebas_viento_individual = TRUE then coalesce(atletas_resultados_viento,0) else coalesce(competencias_pruebas_viento,0) end)
											 when pv.apppruebas_verifica_viento = TRUE and cp.competencias_pruebas_anemometro = FALSE
												 then 'V:A-'
											 else 'V:xx'
											 end)
											|| (case when competencias_pruebas_material_reglamentario = FALSE then ' / M-' else '' end)
											|| (case when cp.competencias_pruebas_manual = TRUE then ' / Manual' else '' end)
											|| (case when ciudades_altura = TRUE THEN ' (A)' ELSE '' END)
											|| ' )'
										)::character varying as comentario,
										cp.competencias_pruebas_manual::boolean,
										pr.categorias_codigo,
										pr.pruebas_record_hasta,
										cp.competencias_pruebas_fecha,
										eatl.atletas_resultados_resultado,
										fn_get_marca_normalizada_totext(eatl.atletas_resultados_resultado, um.unidad_medida_codigo, cp.competencias_pruebas_manual, pv.apppruebas_factor_manual) as norm_resultado,
										fn_get_marca_normalizada_tonumber(fn_get_marca_normalizada_totext(eatl.atletas_resultados_resultado, um.unidad_medida_codigo, cp.competencias_pruebas_manual, pv.apppruebas_factor_manual), um.unidad_medida_codigo) as numb_resultado,
										(case when (case when apppruebas_viento_individual = TRUE then coalesce(atletas_resultados_viento,0) else coalesce(competencias_pruebas_viento,0) end) > apppruebas_viento_limite_normal
															 OR (pv.apppruebas_verifica_viento = TRUE and cp.competencias_pruebas_anemometro = FALSE)
															 OR (competencias_pruebas_material_reglamentario = FALSE)
															 OR (ciudades_altura = TRUE)
											then '*'
										 else ''
										 end)::character as vflag,
										'RS'::character varying as tipo, -- resultado normal
										cl.unidad_medida_codigo
									from  tb_atletas_resultados eatl
										inner join tb_atletas atl on eatl.atletas_codigo = atl.atletas_codigo
										inner join tb_competencias_pruebas cp on cp.competencias_pruebas_id = eatl.competencias_pruebas_id
										inner join tb_competencias co on co.competencias_codigo = cp.competencias_codigo
										inner join tb_ciudades ciu on ciu.ciudades_codigo = co.ciudades_codigo
										inner join tb_paises pa on pa.paises_codigo = ciu.paises_codigo
										inner join tb_pruebas pr on pr.pruebas_codigo =cp.pruebas_codigo
										inner join tb_categorias ca on ca.categorias_codigo = co.categorias_codigo
										inner join tb_app_categorias_values cv on cv.appcat_codigo = ca.categorias_validacion
										inner join tb_app_pruebas_values pv on pv.apppruebas_codigo = pr.pruebas_generica_codigo
										inner join tb_pruebas_clasificacion cl on cl.pruebas_clasificacion_codigo = pv.pruebas_clasificacion_codigo
										inner join tb_unidad_medida um on um.unidad_medida_codigo = cl.unidad_medida_codigo
									where
										(case when p_atletas_codigo is not null then eatl.atletas_codigo = ANY(p_atletas_codigo) else true end) and
										pr.pruebas_generica_codigo = p_apppruebas_codigo and
										(eatl.atletas_resultados_resultado != '0' AND eatl.atletas_resultados_resultado != '0.00' AND eatl.atletas_resultados_resultado != '') and
										atl.atletas_sexo = p_atletas_sexo and
										cp.competencias_pruebas_fecha between p_fecha_desde and p_fecha_hasta and
										(case when p_include_manuales = FALSE then cp.competencias_pruebas_manual = FALSE else true end) and
										cv.appcat_peso >= v_peso_desde and cv.appcat_peso <= v_peso_hasta
								) res
	where (case when p_include_observados = FALSE then res.vflag != '*' else true end) -- los observados
	order by atletas_nombre_completo,competencias_pruebas_fecha
	LIMIT COALESCE(p_max_results, NULL );
END;
$$;


ALTER FUNCTION public.sp_view_resumen_resultados_por_prueba_atletas(p_apppruebas_codigo character varying, p_atletas_codigo character varying[], p_atletas_sexo character, p_fecha_desde date, p_fecha_hasta date, p_desde_categoria character varying, p_hasta_categoria character varying, p_include_manuales boolean, p_include_observados boolean, p_max_results integer) OWNER TO atluser;

--
-- TOC entry 287 (class 1255 OID 16506)
-- Name: sp_view_resumen_topn_resultados_por_prueba_atletas(character varying, character varying[], character, date, date, character varying, character varying, boolean, boolean, integer); Type: FUNCTION; Schema: public; Owner: atluser
--

CREATE FUNCTION sp_view_resumen_topn_resultados_por_prueba_atletas(p_apppruebas_codigo character varying, p_atletas_codigo character varying[], p_atletas_sexo character, p_fecha_desde date, p_fecha_hasta date, p_desde_categoria character varying, p_hasta_categoria character varying, p_include_manuales boolean, p_include_observados boolean, p_topn integer) RETURNS TABLE(atletas_nombre_completo character varying, apppruebas_descripcion character varying, lugar character varying, comentario character varying, competencias_pruebas_manual boolean, categorias_codigo character varying, pruebas_record_hasta character varying, competencias_pruebas_fecha date, atletas_resultados_resultado character varying, norm_resultado character varying, numb_resultado numeric, vflag character, tipo character varying, unidad_medida_codigo character varying, rank_pos integer)
LANGUAGE plpgsql
AS $$
/**
Autor : Carlos arana Reategui
Fecha : 13-06-2014

Stored procedure que retorna en forma resumida los diversos resultados para una prueba,
ya sea por categorias,fechas , resultados manuales o no de uno o mas atletas para su respectiva
comparacion , indicando resultados si son manuales u observados, puediendose filtrar los
mismos.
En este caso solo se retornaran los TOP N resultados de cada uno y su posicion de ranking de los mismos.

Basicamente para uso de reportes.

Historia : 13-06-2014
*/
DECLARE v_peso_desde INTEGER;
				DECLARE v_peso_hasta INTEGER;
BEGIN
	p_fecha_desde := coalesce(p_fecha_desde,'1910-01-01');
	p_fecha_hasta := coalesce(p_fecha_hasta,'2099-01-01');
	p_include_manuales := coalesce(p_include_manuales,FALSE);

	select appcat_peso into v_peso_desde from tb_app_categorias_values  where appcat_codigo  = coalesce((select categorias_validacion from tb_categorias c where c.categorias_codigo=p_desde_categoria),'INF');
	select appcat_peso into v_peso_hasta from tb_app_categorias_values  where appcat_codigo  = coalesce((select categorias_validacion from tb_categorias c where c.categorias_codigo=p_hasta_categoria),'MAY');

	return QUERY
	select * from (
									select
										rankeados.atletas_nombre_completo,
										rankeados.apppruebas_descripcion,
										rankeados.lugar,
										rankeados.comentario,
										rankeados.competencias_pruebas_manual,
										rankeados.categorias_codigo,
										rankeados.pruebas_record_hasta,
										rankeados.competencias_pruebas_fecha,
										rankeados.atletas_resultados_resultado,
										rankeados.norm_resultado,
										rankeados.numb_resultado,
										rankeados.vflag,
										rankeados.tipo,
										rankeados.unidad_medida_codigo,
										(case when rankeados.unidad_medida_tipo = 'T' then
											ROW_NUMBER() OVER (PARTITION BY apppruebas_codigo,atletas_codigo ORDER BY rankeados.numb_resultado ASC)
										 else
											 ROW_NUMBER() OVER (PARTITION BY apppruebas_codigo,atletas_codigo ORDER BY rankeados.numb_resultado DESC)
										 end)::INTEGER as rank_pos
									from (
												 select * from (
																				 select
																					 pv.apppruebas_codigo,
																					 atl.atletas_codigo,
																					 atl.atletas_nombre_completo,
																					 pv.apppruebas_descripcion,
																					 (competencias_descripcion || ' / ' || ciudades_descripcion || ' / ' || paises_descripcion)::character varying as lugar,
																					 (
																						 (case when cp.competencias_pruebas_origen_id is not null then  (select pruebas_descripcion from tb_pruebas where pruebas_codigo = (select pruebas_codigo from tb_competencias_pruebas  where competencias_pruebas_id  = cp.competencias_pruebas_origen_id)) else '' end )  ||
																						 (case when cp.competencias_pruebas_origen_id is not null then  '/' || pr.categorias_codigo || '-' || pr.pruebas_record_hasta  else pr.categorias_codigo || '-' || pr.pruebas_record_hasta end ) || '( ' ||
																						 (case when pv.apppruebas_verifica_viento = TRUE and cp.competencias_pruebas_anemometro = TRUE
																							 then 'V:' || (case when apppruebas_viento_individual = TRUE then coalesce(atletas_resultados_viento,0) else coalesce(competencias_pruebas_viento,0) end)
																							when pv.apppruebas_verifica_viento = TRUE and cp.competencias_pruebas_anemometro = FALSE
																								then 'V:A-'
																							else 'V:xx'
																							end)
																						 || (case when competencias_pruebas_material_reglamentario = FALSE then ' / M-' else '' end)
																						 || (case when cp.competencias_pruebas_manual = TRUE then ' / Manual' else '' end)
																						 || ' )'
																					 )::character varying as comentario,
																					 cp.competencias_pruebas_manual::boolean,
																					 pr.categorias_codigo,
																					 pr.pruebas_record_hasta,
																					 cp.competencias_pruebas_fecha,
																					 eatl.atletas_resultados_resultado,
																					 fn_get_marca_normalizada_totext(eatl.atletas_resultados_resultado, um.unidad_medida_codigo, cp.competencias_pruebas_manual, pv.apppruebas_factor_manual) as norm_resultado,
																					 fn_get_marca_normalizada_tonumber(fn_get_marca_normalizada_totext(eatl.atletas_resultados_resultado, um.unidad_medida_codigo, cp.competencias_pruebas_manual, pv.apppruebas_factor_manual), um.unidad_medida_codigo) as numb_resultado,
																					 (case when (case when apppruebas_viento_individual = TRUE then coalesce(atletas_resultados_viento,0) else coalesce(competencias_pruebas_viento,0) end) > apppruebas_viento_limite_normal
																											OR (pv.apppruebas_verifica_viento = TRUE and cp.competencias_pruebas_anemometro = FALSE)
																											OR (competencias_pruebas_material_reglamentario = FALSE)
																						 then '*'
																						else ''
																						end)::character as vflag,
																					 'NR'::character varying as tipo, -- resultado normal
																					 cl.unidad_medida_codigo,
																					 unidad_medida_tipo
																				 from  tb_atletas_resultados eatl
																					 inner join tb_atletas atl on eatl.atletas_codigo = atl.atletas_codigo
																					 inner join tb_competencias_pruebas cp on cp.competencias_pruebas_id = eatl.competencias_pruebas_id
																					 inner join tb_competencias co on co.competencias_codigo = cp.competencias_codigo
																					 inner join tb_ciudades ciu on ciu.ciudades_codigo = co.ciudades_codigo
																					 inner join tb_paises pa on pa.paises_codigo = ciu.paises_codigo
																					 inner join tb_pruebas pr on pr.pruebas_codigo =cp.pruebas_codigo
																					 inner join tb_categorias ca on ca.categorias_codigo = co.categorias_codigo
																					 inner join tb_app_categorias_values cv on cv.appcat_codigo = ca.categorias_validacion
																					 inner join tb_app_pruebas_values pv on pv.apppruebas_codigo = pr.pruebas_generica_codigo
																					 inner join tb_pruebas_clasificacion cl on cl.pruebas_clasificacion_codigo = pv.pruebas_clasificacion_codigo
																					 inner join tb_unidad_medida um on um.unidad_medida_codigo = cl.unidad_medida_codigo
																				 where
																					 (case when p_atletas_codigo is not null then eatl.atletas_codigo = ANY(p_atletas_codigo) else true end) and
																					 pr.pruebas_generica_codigo = p_apppruebas_codigo and
																					 (eatl.atletas_resultados_resultado != '0' AND eatl.atletas_resultados_resultado != '0.00' AND eatl.atletas_resultados_resultado != '') and
																					 atl.atletas_sexo = p_atletas_sexo and
																					 cp.competencias_pruebas_fecha between p_fecha_desde and p_fecha_hasta and
																					 (case when p_include_manuales = FALSE then cp.competencias_pruebas_manual = FALSE else true end) and
																					 cv.appcat_peso >= v_peso_desde and cv.appcat_peso <= v_peso_hasta
																			 ) res
												 where (case when p_include_observados = FALSE then res.vflag != '*' else true end) -- los observados
											 ) rankeados
								) results
	where results.rank_pos <= p_topn
	order by atletas_nombre_completo,rank_pos ASC;
END;
$$;


ALTER FUNCTION public.sp_view_resumen_topn_resultados_por_prueba_atletas(p_apppruebas_codigo character varying, p_atletas_codigo character varying[], p_atletas_sexo character, p_fecha_desde date, p_fecha_hasta date, p_desde_categoria character varying, p_hasta_categoria character varying, p_include_manuales boolean, p_include_observados boolean, p_topn integer) OWNER TO atluser;

--
-- TOC entry 281 (class 1255 OID 16509)
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
-- TOC entry 288 (class 1255 OID 16510)
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
-- TOC entry 289 (class 1255 OID 16511)
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
-- TOC entry 171 (class 1259 OID 16512)
-- Name: tb_app_categorias_values; Type: TABLE; Schema: public; Owner: atluser; Tablespace:
--

CREATE TABLE tb_app_categorias_values (
	appcat_codigo character varying(3) NOT NULL,
	appcat_peso integer,
	activo boolean DEFAULT true NOT NULL,
	usuario character varying(15) NOT NULL,
	fecha_creacion timestamp without time zone NOT NULL,
	usuario_mod character varying(15),
	fecha_modificacion timestamp without time zone
);


ALTER TABLE public.tb_app_categorias_values OWNER TO atluser;

--
-- TOC entry 2674 (class 0 OID 0)
-- Dependencies: 171
-- Name: TABLE tb_app_categorias_values; Type: COMMENT; Schema: public; Owner: atluser
--

COMMENT ON TABLE tb_app_categorias_values IS 'Contiene los valores validos para la validacion de categorias , toda categoria definid debe indicar un valor en esta tabla para saber como validarlo o como tratar la categoria.';


--
-- TOC entry 2675 (class 0 OID 0)
-- Dependencies: 171
-- Name: COLUMN tb_app_categorias_values.appcat_peso; Type: COMMENT; Schema: public; Owner: atluser
--

COMMENT ON COLUMN tb_app_categorias_values.appcat_peso IS 'Indicara que categoria pesa mas que otra , por ejemplo mayores debe tener mas peso que sub23.';


--
-- TOC entry 172 (class 1259 OID 16516)
-- Name: tb_app_pruebas_values; Type: TABLE; Schema: public; Owner: atluser; Tablespace:
--

CREATE TABLE tb_app_pruebas_values (
	apppruebas_codigo character varying(15) NOT NULL,
	apppruebas_descripcion character varying(200),
	pruebas_clasificacion_codigo character varying(15) NOT NULL,
	apppruebas_marca_menor character varying(12) NOT NULL,
	apppruebas_marca_mayor character varying(12) NOT NULL,
	apppruebas_multiple boolean DEFAULT false NOT NULL,
	apppruebas_verifica_viento boolean DEFAULT false NOT NULL,
	apppruebas_viento_limite_normal numeric(5,2),
	apppruebas_viento_limite_multiple numeric(5,2),
	apppruebas_protected boolean DEFAULT false NOT NULL,
	activo boolean DEFAULT true NOT NULL,
	usuario character varying(15) NOT NULL,
	fecha_creacion timestamp without time zone NOT NULL,
	usuario_mod character varying(15),
	fecha_modificacion timestamp without time zone,
	apppruebas_nro_atletas integer DEFAULT 1 NOT NULL,
	apppruebas_factor_manual numeric(5,2) DEFAULT 0.00 NOT NULL,
	apppruebas_viento_individual boolean DEFAULT false NOT NULL
);


ALTER TABLE public.tb_app_pruebas_values OWNER TO atluser;

--
-- TOC entry 2676 (class 0 OID 0)
-- Dependencies: 172
-- Name: TABLE tb_app_pruebas_values; Type: COMMENT; Schema: public; Owner: atluser
--

COMMENT ON TABLE tb_app_pruebas_values IS 'Contiene los valores que identifican genericamente las diversas pruebas atleticas';


--
-- TOC entry 173 (class 1259 OID 16526)
-- Name: tb_atletas; Type: TABLE; Schema: public; Owner: atluser; Tablespace:
--

CREATE TABLE tb_atletas (
	atletas_codigo character varying(15) NOT NULL,
	atletas_ap_paterno character varying(60) NOT NULL,
	atletas_ap_materno character varying(60),
	atletas_nombres character varying(120) NOT NULL,
	atletas_nombre_completo character varying(220) NOT NULL,
	atletas_sexo character(1) NOT NULL,
	atletas_nro_documento character varying(15),
	atletas_nro_pasaporte character varying(15) NOT NULL,
	paises_codigo character varying(15) NOT NULL,
	atletas_fecha_nacimiento date NOT NULL,
	atletas_telefono_casa character varying(14),
	atletas_telefono_celular character varying(14),
	atletas_email character varying(150),
	atletas_direccion character varying(250) NOT NULL,
	atletas_observaciones character varying(250),
	atletas_talla_ropa_buzo character varying(3) NOT NULL,
	atletas_talla_ropa_poloshort character varying(3) NOT NULL,
	atletas_talla_zapatillas numeric,
	atletas_norma_zapatillas character varying(3) NOT NULL,
	atletas_url_foto character varying(300),
	activo boolean DEFAULT true NOT NULL,
	usuario character varying(15) NOT NULL,
	fecha_creacion timestamp without time zone NOT NULL,
	usuario_mod character varying(15),
	fecha_modificacion timestamp without time zone,
	atletas_protected boolean DEFAULT false NOT NULL,
	CONSTRAINT chk_atletas_norma_zapatillas CHECK (((atletas_norma_zapatillas)::text = ANY (ARRAY[('UK'::character varying)::text, ('US'::character varying)::text, ('NM'::character varying)::text, ('??'::character varying)::text]))),
	CONSTRAINT chk_atletas_sexo CHECK ((atletas_sexo = ANY (ARRAY['F'::bpchar, 'M'::bpchar]))),
	CONSTRAINT chk_atletas_talla_pantalon CHECK (((atletas_talla_ropa_poloshort)::text = ANY (ARRAY[('??'::character varying)::text, ('XS'::character varying)::text, ('S'::character varying)::text, ('M'::character varying)::text, ('L'::character varying)::text, ('XL'::character varying)::text, ('XXL'::character varying)::text, ('XXXL'::character varying)::text]))),
	CONSTRAINT chk_atletas_talla_torso CHECK (((atletas_talla_ropa_buzo)::text = ANY (ARRAY[('??'::character varying)::text, ('XS'::character varying)::text, ('S'::character varying)::text, ('M'::character varying)::text, ('L'::character varying)::text, ('XL'::character varying)::text, ('XXL'::character varying)::text, ('XXXL'::character varying)::text])))
);


ALTER TABLE public.tb_atletas OWNER TO atluser;

--
-- TOC entry 174 (class 1259 OID 16537)
-- Name: tb_atletas_carnets; Type: TABLE; Schema: public; Owner: atluser; Tablespace:
--

CREATE TABLE tb_atletas_carnets (
	atletas_carnets_id integer NOT NULL,
	atletas_carnets_numero character varying(10) NOT NULL,
	atletas_carnets_agno integer DEFAULT date_part('year'::text, ('now'::text)::date) NOT NULL,
	atletas_codigo character varying(15) NOT NULL,
	atletas_carnets_fecha date NOT NULL,
	activo boolean DEFAULT true NOT NULL,
	usuario character varying(15) NOT NULL,
	fecha_creacion timestamp without time zone NOT NULL,
	usuario_mod character varying(15),
	fecha_modificacion timestamp without time zone
);


ALTER TABLE public.tb_atletas_carnets OWNER TO atluser;

--
-- TOC entry 175 (class 1259 OID 16542)
-- Name: tb_atletas_carnets_atletas_carnets_id_seq; Type: SEQUENCE; Schema: public; Owner: atluser
--

CREATE SEQUENCE tb_atletas_carnets_atletas_carnets_id_seq
START WITH 1
INCREMENT BY 1
NO MINVALUE
NO MAXVALUE
CACHE 1;


ALTER TABLE public.tb_atletas_carnets_atletas_carnets_id_seq OWNER TO atluser;

--
-- TOC entry 2677 (class 0 OID 0)
-- Dependencies: 175
-- Name: tb_atletas_carnets_atletas_carnets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: atluser
--

ALTER SEQUENCE tb_atletas_carnets_atletas_carnets_id_seq OWNED BY tb_atletas_carnets.atletas_carnets_id;


--
-- TOC entry 176 (class 1259 OID 16544)
-- Name: tb_atletas_resultados; Type: TABLE; Schema: public; Owner: atluser; Tablespace:
--

CREATE TABLE tb_atletas_resultados (
	atletas_resultados_id integer NOT NULL,
	atletas_codigo character varying(15) NOT NULL,
	competencias_pruebas_id integer DEFAULT 0 NOT NULL,
	atletas_resultados_resultado character varying(12) NOT NULL,
	atletas_resultados_puesto integer DEFAULT 0 NOT NULL,
	atletas_resultados_protected boolean DEFAULT false NOT NULL,
	activo boolean DEFAULT true NOT NULL,
	usuario character varying(15) NOT NULL,
	fecha_creacion timestamp without time zone NOT NULL,
	usuario_mod character varying(15),
	fecha_modificacion timestamp without time zone,
	atletas_resultados_puntos integer DEFAULT 0 NOT NULL,
	atletas_resultados_viento numeric(6,2) DEFAULT 0,
	postas_id integer
);


ALTER TABLE public.tb_atletas_resultados OWNER TO atluser;

--
-- TOC entry 177 (class 1259 OID 16553)
-- Name: tb_atletas_resultados_atletas_resultados_id_seq; Type: SEQUENCE; Schema: public; Owner: atluser
--

CREATE SEQUENCE tb_atletas_resultados_atletas_resultados_id_seq
START WITH 1
INCREMENT BY 1
NO MINVALUE
NO MAXVALUE
CACHE 1;


ALTER TABLE public.tb_atletas_resultados_atletas_resultados_id_seq OWNER TO atluser;

--
-- TOC entry 2678 (class 0 OID 0)
-- Dependencies: 177
-- Name: tb_atletas_resultados_atletas_resultados_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: atluser
--

ALTER SEQUENCE tb_atletas_resultados_atletas_resultados_id_seq OWNED BY tb_atletas_resultados.atletas_resultados_id;


--
-- TOC entry 178 (class 1259 OID 16555)
-- Name: tb_atletas_resultados_detalle; Type: TABLE; Schema: public; Owner: atluser; Tablespace:
--

CREATE TABLE tb_atletas_resultados_detalle (
	atletas_resultados_detalle_id integer NOT NULL,
	atletas_resultados_id integer NOT NULL,
	pruebas_codigo character varying(15) NOT NULL,
	atletas_resultados_detalle_resultado character varying(12) NOT NULL,
	atletas_resultados_detalle_viento numeric(6,2),
	atletas_resultados_detalle_manual boolean DEFAULT false NOT NULL,
	atletas_resultados_detalle_puntos integer NOT NULL,
	activo boolean DEFAULT true NOT NULL,
	usuario character varying(15) NOT NULL,
	fecha_creacion timestamp without time zone NOT NULL,
	usuario_mod character varying(15),
	fecha_modificacion timestamp without time zone
);


ALTER TABLE public.tb_atletas_resultados_detalle OWNER TO atluser;

--
-- TOC entry 179 (class 1259 OID 16560)
-- Name: tb_atletas_resultados_detalle_atletas_resultados_detalle_id_seq; Type: SEQUENCE; Schema: public; Owner: atluser
--

CREATE SEQUENCE tb_atletas_resultados_detalle_atletas_resultados_detalle_id_seq
START WITH 1
INCREMENT BY 1
NO MINVALUE
NO MAXVALUE
CACHE 1;


ALTER TABLE public.tb_atletas_resultados_detalle_atletas_resultados_detalle_id_seq OWNER TO atluser;

--
-- TOC entry 2679 (class 0 OID 0)
-- Dependencies: 179
-- Name: tb_atletas_resultados_detalle_atletas_resultados_detalle_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: atluser
--

ALTER SEQUENCE tb_atletas_resultados_detalle_atletas_resultados_detalle_id_seq OWNED BY tb_atletas_resultados_detalle.atletas_resultados_detalle_id;


--
-- TOC entry 180 (class 1259 OID 16562)
-- Name: tb_atletas_resultados_old; Type: TABLE; Schema: public; Owner: atluser; Tablespace:
--

CREATE TABLE tb_atletas_resultados_old (
	atletas_resultados_id integer DEFAULT nextval('tb_atletas_resultados_atletas_resultados_id_seq'::regclass) NOT NULL,
	atletas_codigo character varying(15) NOT NULL,
	competencias_codigo character varying(15) NOT NULL,
	pruebas_codigo character varying(15) NOT NULL,
	atletas_resultados_fecha date NOT NULL,
	atletas_resultados_resultado character varying(12) NOT NULL,
	atletas_resultados_viento numeric(6,2),
	atletas_resultados_puesto integer DEFAULT 0,
	atletas_resultados_manual boolean DEFAULT false NOT NULL,
	atletas_resultados_altura boolean DEFAULT false NOT NULL,
	atletas_resultados_invalida boolean DEFAULT false NOT NULL,
	atletas_resultados_observaciones character varying(250),
	atletas_resultados_protected boolean DEFAULT false NOT NULL,
	atletas_resultados_origen character(1) DEFAULT 'D'::bpchar NOT NULL,
	activo boolean DEFAULT true NOT NULL,
	usuario character varying(15) NOT NULL,
	fecha_creacion timestamp without time zone NOT NULL,
	usuario_mod character varying(15),
	fecha_modificacion timestamp without time zone,
	competencias_pruebas_id integer DEFAULT 0 NOT NULL,
	CONSTRAINT chk_atletas_resultados_origen CHECK (((atletas_resultados_origen)::text = ANY (ARRAY[('D'::character varying)::text, ('C'::character varying)::text])))
);


ALTER TABLE public.tb_atletas_resultados_old OWNER TO atluser;

--
-- TOC entry 181 (class 1259 OID 16575)
-- Name: tb_categorias; Type: TABLE; Schema: public; Owner: atluser; Tablespace:
--

CREATE TABLE tb_categorias (
	categorias_codigo character varying(15) NOT NULL,
	categorias_descripcion character varying(120) NOT NULL,
	categorias_edad_inicial integer NOT NULL,
	categorias_edad_final integer NOT NULL,
	categorias_valido_desde date,
	categorias_validacion character varying(3) NOT NULL,
	categorias_protected boolean DEFAULT false NOT NULL,
	activo boolean DEFAULT true NOT NULL,
	usuario character varying(15) NOT NULL,
	fecha_creacion timestamp without time zone NOT NULL,
	usuario_mod character varying(15),
	fecha_modificacion timestamp without time zone,
	CONSTRAINT chk_categorias_edades CHECK ((categorias_edad_final >= categorias_edad_inicial))
);


ALTER TABLE public.tb_categorias OWNER TO atluser;

--
-- TOC entry 182 (class 1259 OID 16581)
-- Name: tb_ciudades; Type: TABLE; Schema: public; Owner: atluser; Tablespace:
--

CREATE TABLE tb_ciudades (
	ciudades_codigo character varying(15) NOT NULL,
	ciudades_descripcion character varying(120) NOT NULL,
	paises_codigo character varying(15) NOT NULL,
	activo boolean DEFAULT true NOT NULL,
	usuario character varying(15) NOT NULL,
	fecha_creacion timestamp without time zone NOT NULL,
	usuario_mod character varying(15),
	fecha_modificacion timestamp without time zone,
	ciudades_altura boolean DEFAULT false
);


ALTER TABLE public.tb_ciudades OWNER TO atluser;

--
-- TOC entry 183 (class 1259 OID 16586)
-- Name: tb_clubes; Type: TABLE; Schema: public; Owner: atluser; Tablespace:
--

CREATE TABLE tb_clubes (
	clubes_codigo character varying(15) NOT NULL,
	clubes_descripcion character varying(120) NOT NULL,
	clubes_persona_contacto character varying(150),
	clubes_telefono_oficina character varying(14),
	clubes_telefono_celular character varying(14),
	clubes_email character varying(150),
	clubes_direccion character varying(250),
	clubes_web_url character varying(250),
	activo boolean DEFAULT true NOT NULL,
	usuario character varying(15) NOT NULL,
	fecha_creacion timestamp without time zone NOT NULL,
	usuario_mod character varying(15),
	fecha_modificacion timestamp without time zone
);


ALTER TABLE public.tb_clubes OWNER TO atluser;

--
-- TOC entry 184 (class 1259 OID 16593)
-- Name: tb_clubes_atletas; Type: TABLE; Schema: public; Owner: atluser; Tablespace:
--

CREATE TABLE tb_clubes_atletas (
	clubesatletas_id integer NOT NULL,
	clubes_codigo character varying(15) NOT NULL,
	atletas_codigo character varying(15) NOT NULL,
	clubesatletas_desde date NOT NULL,
	clubesatletas_hasta date,
	activo boolean DEFAULT true NOT NULL,
	usuario character varying(15) NOT NULL,
	fecha_creacion timestamp without time zone NOT NULL,
	usuario_mod character varying(15),
	fecha_modificacion timestamp without time zone
);


ALTER TABLE public.tb_clubes_atletas OWNER TO atluser;

--
-- TOC entry 185 (class 1259 OID 16597)
-- Name: tb_clubes_atletas_clubesatletas_id_seq; Type: SEQUENCE; Schema: public; Owner: atluser
--

CREATE SEQUENCE tb_clubes_atletas_clubesatletas_id_seq
START WITH 1
INCREMENT BY 1
NO MINVALUE
NO MAXVALUE
CACHE 1;


ALTER TABLE public.tb_clubes_atletas_clubesatletas_id_seq OWNER TO atluser;

--
-- TOC entry 2680 (class 0 OID 0)
-- Dependencies: 185
-- Name: tb_clubes_atletas_clubesatletas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: atluser
--

ALTER SEQUENCE tb_clubes_atletas_clubesatletas_id_seq OWNED BY tb_clubes_atletas.clubesatletas_id;


--
-- TOC entry 186 (class 1259 OID 16599)
-- Name: tb_competencia_tipo; Type: TABLE; Schema: public; Owner: atluser; Tablespace:
--

CREATE TABLE tb_competencia_tipo (
	competencia_tipo_codigo character varying(15) NOT NULL,
	competencia_tipo_descripcion character varying(120) NOT NULL,
	activo boolean DEFAULT true NOT NULL,
	usuario character varying(15) NOT NULL,
	fecha_creacion timestamp without time zone NOT NULL,
	usuario_mod character varying(15),
	fecha_modificacion timestamp without time zone
);


ALTER TABLE public.tb_competencia_tipo OWNER TO atluser;

--
-- TOC entry 187 (class 1259 OID 16603)
-- Name: tb_competencias; Type: TABLE; Schema: public; Owner: atluser; Tablespace:
--

CREATE TABLE tb_competencias (
	competencias_codigo character varying(15) NOT NULL,
	competencias_descripcion character varying(200) NOT NULL,
	competencia_tipo_codigo character varying(15) NOT NULL,
	categorias_codigo character varying(15) NOT NULL,
	paises_codigo character varying(15) NOT NULL,
	ciudades_codigo character varying(15) NOT NULL,
	competencias_fecha_inicio date NOT NULL,
	competencias_fecha_final date NOT NULL,
	competencias_es_oficial boolean DEFAULT false NOT NULL,
	activo boolean DEFAULT true NOT NULL,
	usuario character varying(15) NOT NULL,
	fecha_creacion timestamp without time zone NOT NULL,
	usuario_mod character varying(15),
	fecha_modificacion timestamp without time zone,
	competencias_clasificacion character(1) DEFAULT 'O'::bpchar NOT NULL,
	CONSTRAINT chk_competencias_clasificacion CHECK ((competencias_clasificacion = ANY (ARRAY['I'::bpchar, 'O'::bpchar])))
);


ALTER TABLE public.tb_competencias OWNER TO atluser;

--
-- TOC entry 2681 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN tb_competencias.competencias_clasificacion; Type: COMMENT; Schema: public; Owner: atluser
--

COMMENT ON COLUMN tb_competencias.competencias_clasificacion IS 'Indica si es indoor o outdoor';


--
-- TOC entry 2682 (class 0 OID 0)
-- Dependencies: 187
-- Name: CONSTRAINT chk_competencias_clasificacion ON tb_competencias; Type: COMMENT; Schema: public; Owner: atluser
--

COMMENT ON CONSTRAINT chk_competencias_clasificacion ON tb_competencias IS 'Chequea que los valores solo puedan ser I-Indoor o O-Outdoor';


--
-- TOC entry 188 (class 1259 OID 16610)
-- Name: tb_competencias_pruebas; Type: TABLE; Schema: public; Owner: atluser; Tablespace:
--

CREATE TABLE tb_competencias_pruebas (
	competencias_pruebas_id integer NOT NULL,
	competencias_codigo character varying(15) NOT NULL,
	pruebas_codigo character varying(15) NOT NULL,
	competencias_pruebas_origen_combinada boolean NOT NULL,
	competencias_pruebas_fecha date NOT NULL,
	competencias_pruebas_viento numeric(6,2),
	competencias_pruebas_manual boolean DEFAULT false NOT NULL,
	competencias_pruebas_tipo_serie character varying(2) NOT NULL,
	competencias_pruebas_nro_serie integer,
	competencias_pruebas_anemometro boolean DEFAULT true NOT NULL,
	competencias_pruebas_material_reglamentario boolean DEFAULT true NOT NULL,
	competencias_pruebas_observaciones character varying(250),
	competencias_pruebas_protected boolean DEFAULT false NOT NULL,
	activo boolean DEFAULT true NOT NULL,
	usuario character varying(15) NOT NULL,
	fecha_creacion timestamp without time zone NOT NULL,
	usuario_mod character varying(15),
	fecha_modificacion timestamp without time zone,
	competencias_pruebas_origen_id integer,
	CONSTRAINT chk_competencias_pruebas_tipo_serie CHECK (((competencias_pruebas_tipo_serie)::text = ANY (ARRAY[('HT'::character varying)::text, ('SR'::character varying)::text, ('SM'::character varying)::text, ('FI'::character varying)::text, ('SU'::character varying)::text])))
);


ALTER TABLE public.tb_competencias_pruebas OWNER TO atluser;

--
-- TOC entry 189 (class 1259 OID 16619)
-- Name: tb_competencias_pruebas_competencias_pruebas_id_seq; Type: SEQUENCE; Schema: public; Owner: atluser
--

CREATE SEQUENCE tb_competencias_pruebas_competencias_pruebas_id_seq
START WITH 1
INCREMENT BY 1
NO MINVALUE
NO MAXVALUE
CACHE 1;


ALTER TABLE public.tb_competencias_pruebas_competencias_pruebas_id_seq OWNER TO atluser;

--
-- TOC entry 2683 (class 0 OID 0)
-- Dependencies: 189
-- Name: tb_competencias_pruebas_competencias_pruebas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: atluser
--

ALTER SEQUENCE tb_competencias_pruebas_competencias_pruebas_id_seq OWNED BY tb_competencias_pruebas.competencias_pruebas_id;


--
-- TOC entry 190 (class 1259 OID 16621)
-- Name: tb_entidad; Type: TABLE; Schema: public; Owner: atluser; Tablespace:
--

CREATE TABLE tb_entidad (
	entidad_id integer NOT NULL,
	entidad_razon_social character varying(200) NOT NULL,
	entidad_ruc character varying(15) NOT NULL,
	entidad_titulo_alterno character varying(200),
	entidad_direccion character varying(200) NOT NULL,
	entidad_web_url character varying(200),
	entidad_telefonos character varying(60),
	entidad_fax character varying(10),
	entidad_eslogan character varying(250),
	entidad_siglas character varying(15),
	entidad_correo character varying(100),
	activo boolean DEFAULT true NOT NULL,
	usuario character varying(15) NOT NULL,
	fecha_creacion timestamp without time zone NOT NULL,
	usuario_mod character varying(15),
	fecha_modificacion timestamp without time zone
);


ALTER TABLE public.tb_entidad OWNER TO atluser;

--
-- TOC entry 2684 (class 0 OID 0)
-- Dependencies: 190
-- Name: TABLE tb_entidad; Type: COMMENT; Schema: public; Owner: atluser
--

COMMENT ON TABLE tb_entidad IS 'Datos generales de la entidad que usa el sistema';


--
-- TOC entry 191 (class 1259 OID 16628)
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
-- TOC entry 2685 (class 0 OID 0)
-- Dependencies: 191
-- Name: tb_entidad_entidad_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: atluser
--

ALTER SEQUENCE tb_entidad_entidad_id_seq OWNED BY tb_entidad.entidad_id;


--
-- TOC entry 192 (class 1259 OID 16630)
-- Name: tb_entrenadores; Type: TABLE; Schema: public; Owner: atluser; Tablespace:
--

CREATE TABLE tb_entrenadores (
	entrenadores_codigo character varying(15) NOT NULL,
	entrenadores_ap_paterno character varying(60) NOT NULL,
	entrenadores_ap_materno character varying(60) NOT NULL,
	entrenadores_nombres character varying(120) NOT NULL,
	entrenadores_nombre_completo character varying(220) NOT NULL,
	entrenadores_nivel_codigo character varying(15) NOT NULL,
	activo boolean DEFAULT true NOT NULL,
	usuario character varying(15) NOT NULL,
	fecha_creacion timestamp without time zone NOT NULL,
	usuario_mod character varying(15),
	fecha_modificacion timestamp without time zone
);


ALTER TABLE public.tb_entrenadores OWNER TO atluser;

--
-- TOC entry 193 (class 1259 OID 16637)
-- Name: tb_entrenadores_atletas; Type: TABLE; Schema: public; Owner: atluser; Tablespace:
--

CREATE TABLE tb_entrenadores_atletas (
	entrenadoresatletas_id integer NOT NULL,
	entrenadores_codigo character varying(15) NOT NULL,
	atletas_codigo character varying(15) NOT NULL,
	entrenadoresatletas_desde date NOT NULL,
	entrenadoresatletas_hasta date,
	activo boolean DEFAULT true NOT NULL,
	usuario character varying(15) NOT NULL,
	fecha_creacion timestamp without time zone NOT NULL,
	usuario_mod character varying(15),
	fecha_modificacion timestamp without time zone
);


ALTER TABLE public.tb_entrenadores_atletas OWNER TO atluser;

--
-- TOC entry 194 (class 1259 OID 16641)
-- Name: tb_entrenadores_atletas_entrenadoresatletas_id_seq; Type: SEQUENCE; Schema: public; Owner: atluser
--

CREATE SEQUENCE tb_entrenadores_atletas_entrenadoresatletas_id_seq
START WITH 1
INCREMENT BY 1
NO MINVALUE
NO MAXVALUE
CACHE 1;


ALTER TABLE public.tb_entrenadores_atletas_entrenadoresatletas_id_seq OWNER TO atluser;

--
-- TOC entry 2686 (class 0 OID 0)
-- Dependencies: 194
-- Name: tb_entrenadores_atletas_entrenadoresatletas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: atluser
--

ALTER SEQUENCE tb_entrenadores_atletas_entrenadoresatletas_id_seq OWNED BY tb_entrenadores_atletas.entrenadoresatletas_id;


--
-- TOC entry 195 (class 1259 OID 16643)
-- Name: tb_entrenadores_nivel; Type: TABLE; Schema: public; Owner: atluser; Tablespace:
--

CREATE TABLE tb_entrenadores_nivel (
	entrenadores_nivel_codigo character varying(15) NOT NULL,
	entrenadores_nivel_descripcion character varying(60) NOT NULL,
	entrenadores_nivel_protected boolean DEFAULT false NOT NULL,
	activo boolean DEFAULT true NOT NULL,
	usuario character varying(15) NOT NULL,
	fecha_creacion timestamp without time zone NOT NULL,
	usuario_mod character varying(15),
	fecha_modificacion timestamp without time zone
);


ALTER TABLE public.tb_entrenadores_nivel OWNER TO atluser;

--
-- TOC entry 196 (class 1259 OID 16648)
-- Name: tb_ligas; Type: TABLE; Schema: public; Owner: atluser; Tablespace:
--

CREATE TABLE tb_ligas (
	ligas_codigo character varying(15) NOT NULL,
	ligas_descripcion character varying(120) NOT NULL,
	ligas_persona_contacto character varying(150),
	ligas_telefono_oficina character varying(14),
	ligas_telefono_celular character varying(14),
	ligas_email character varying(150),
	ligas_direccion character varying(250),
	ligas_web_url character varying(250),
	activo boolean DEFAULT true NOT NULL,
	usuario character varying(15) NOT NULL,
	fecha_creacion timestamp without time zone NOT NULL,
	usuario_mod character varying(15),
	fecha_modificacion timestamp without time zone
);


ALTER TABLE public.tb_ligas OWNER TO atluser;

--
-- TOC entry 197 (class 1259 OID 16655)
-- Name: tb_ligas_clubes; Type: TABLE; Schema: public; Owner: atluser; Tablespace:
--

CREATE TABLE tb_ligas_clubes (
	ligasclubes_id integer NOT NULL,
	ligas_codigo character varying(15) NOT NULL,
	clubes_codigo character varying(15) NOT NULL,
	ligasclubes_desde date NOT NULL,
	ligasclubes_hasta date NOT NULL,
	activo boolean DEFAULT true NOT NULL,
	usuario character varying(15) NOT NULL,
	fecha_creacion timestamp without time zone NOT NULL,
	usuario_mod character varying(15),
	fecha_modificacion timestamp without time zone
);


ALTER TABLE public.tb_ligas_clubes OWNER TO atluser;

--
-- TOC entry 198 (class 1259 OID 16659)
-- Name: tb_ligas_clubes_ligasclubes_id_seq; Type: SEQUENCE; Schema: public; Owner: atluser
--

CREATE SEQUENCE tb_ligas_clubes_ligasclubes_id_seq
START WITH 1
INCREMENT BY 1
NO MINVALUE
NO MAXVALUE
CACHE 1;


ALTER TABLE public.tb_ligas_clubes_ligasclubes_id_seq OWNER TO atluser;

--
-- TOC entry 2687 (class 0 OID 0)
-- Dependencies: 198
-- Name: tb_ligas_clubes_ligasclubes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: atluser
--

ALTER SEQUENCE tb_ligas_clubes_ligasclubes_id_seq OWNED BY tb_ligas_clubes.ligasclubes_id;


--
-- TOC entry 199 (class 1259 OID 16661)
-- Name: tb_paises; Type: TABLE; Schema: public; Owner: atluser; Tablespace:
--

CREATE TABLE tb_paises (
	paises_codigo character varying(15) NOT NULL,
	paises_descripcion character varying(120) NOT NULL,
	paises_entidad boolean DEFAULT false NOT NULL,
	activo boolean DEFAULT true NOT NULL,
	usuario character varying(15) NOT NULL,
	fecha_creacion timestamp without time zone NOT NULL,
	usuario_mod character varying(15),
	fecha_modificacion timestamp without time zone,
	regiones_codigo character varying(15) DEFAULT 'SAMERICA'::character varying NOT NULL,
	paises_use_apm boolean DEFAULT true NOT NULL,
	paises_use_docid boolean DEFAULT true NOT NULL
);


ALTER TABLE public.tb_paises OWNER TO atluser;

--
-- TOC entry 226 (class 1259 OID 37650)
-- Name: tb_postas; Type: TABLE; Schema: public; Owner: atluser; Tablespace:
--

CREATE TABLE tb_postas (
	postas_id integer NOT NULL,
	postas_descripcion character varying(50) NOT NULL,
	competencias_pruebas_id integer NOT NULL,
	activo boolean DEFAULT true NOT NULL,
	usuario character varying(15) NOT NULL,
	fecha_creacion timestamp without time zone NOT NULL,
	usuario_mod character varying(15),
	fecha_modificacion timestamp without time zone
);


ALTER TABLE public.tb_postas OWNER TO atluser;

--
-- TOC entry 228 (class 1259 OID 37666)
-- Name: tb_postas_detalle; Type: TABLE; Schema: public; Owner: atluser; Tablespace:
--

CREATE TABLE tb_postas_detalle (
	postas_detalle_id integer NOT NULL,
	postas_id integer NOT NULL,
	atletas_codigo character varying(15) NOT NULL,
	activo boolean DEFAULT true NOT NULL,
	usuario character varying(15) NOT NULL,
	fecha_creacion timestamp without time zone NOT NULL,
	usuario_mod character varying(15),
	fecha_modificacion timestamp without time zone
);


ALTER TABLE public.tb_postas_detalle OWNER TO atluser;

--
-- TOC entry 227 (class 1259 OID 37664)
-- Name: tb_postas_detalle_postas_detalle_id_seq; Type: SEQUENCE; Schema: public; Owner: atluser
--

CREATE SEQUENCE tb_postas_detalle_postas_detalle_id_seq
START WITH 1
INCREMENT BY 1
NO MINVALUE
NO MAXVALUE
CACHE 1;


ALTER TABLE public.tb_postas_detalle_postas_detalle_id_seq OWNER TO atluser;

--
-- TOC entry 2688 (class 0 OID 0)
-- Dependencies: 227
-- Name: tb_postas_detalle_postas_detalle_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: atluser
--

ALTER SEQUENCE tb_postas_detalle_postas_detalle_id_seq OWNED BY tb_postas_detalle.postas_detalle_id;


--
-- TOC entry 225 (class 1259 OID 37648)
-- Name: tb_postas_postas_id_seq; Type: SEQUENCE; Schema: public; Owner: atluser
--

CREATE SEQUENCE tb_postas_postas_id_seq
START WITH 1
INCREMENT BY 1
NO MINVALUE
NO MAXVALUE
CACHE 1;


ALTER TABLE public.tb_postas_postas_id_seq OWNER TO atluser;

--
-- TOC entry 2689 (class 0 OID 0)
-- Dependencies: 225
-- Name: tb_postas_postas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: atluser
--

ALTER SEQUENCE tb_postas_postas_id_seq OWNED BY tb_postas.postas_id;


--
-- TOC entry 200 (class 1259 OID 16667)
-- Name: tb_pruebas; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

CREATE TABLE tb_pruebas (
	pruebas_codigo character varying(15) NOT NULL,
	pruebas_descripcion character varying(150) NOT NULL,
	pruebas_generica_codigo character varying(15) NOT NULL,
	pruebas_sexo character(1) NOT NULL,
	categorias_codigo character varying(15) NOT NULL,
	pruebas_record_hasta character varying(15),
	pruebas_anotaciones character varying(180),
	pruebas_protected boolean DEFAULT false NOT NULL,
	activo boolean DEFAULT true NOT NULL,
	usuario character varying(15) NOT NULL,
	fecha_creacion timestamp without time zone NOT NULL,
	usuario_mod character varying(15),
	fecha_modificacion timestamp without time zone,
	CONSTRAINT chk_pruebas_sexo CHECK ((pruebas_sexo = ANY (ARRAY['F'::bpchar, 'M'::bpchar])))
);


ALTER TABLE public.tb_pruebas OWNER TO postgres;

--
-- TOC entry 201 (class 1259 OID 16673)
-- Name: tb_pruebas_clasificacion; Type: TABLE; Schema: public; Owner: atluser; Tablespace:
--

CREATE TABLE tb_pruebas_clasificacion (
	pruebas_clasificacion_codigo character varying(15) NOT NULL,
	pruebas_clasificacion_descripcion character varying(120) NOT NULL,
	pruebas_tipo_codigo character varying(15) NOT NULL,
	unidad_medida_codigo character varying(5) NOT NULL,
	activo boolean DEFAULT true NOT NULL,
	usuario character varying(15) NOT NULL,
	fecha_creacion timestamp without time zone NOT NULL,
	usuario_mod character varying(15),
	fecha_modificacion timestamp without time zone
);


ALTER TABLE public.tb_pruebas_clasificacion OWNER TO atluser;

--
-- TOC entry 202 (class 1259 OID 16677)
-- Name: tb_pruebas_detalle; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

CREATE TABLE tb_pruebas_detalle (
	pruebas_detalle_id integer NOT NULL,
	pruebas_codigo character varying(15) NOT NULL,
	pruebas_detalle_prueba_codigo character varying(15) NOT NULL,
	pruebas_detalle_orden integer NOT NULL,
	pruebas_detalle_protected boolean DEFAULT false NOT NULL,
	activo boolean DEFAULT true NOT NULL,
	usuario character varying(15) NOT NULL,
	fecha_creacion timestamp without time zone NOT NULL,
	usuario_mod character varying(15),
	fecha_modificacion timestamp without time zone
);


ALTER TABLE public.tb_pruebas_detalle OWNER TO postgres;

--
-- TOC entry 203 (class 1259 OID 16682)
-- Name: tb_pruebas_detalle_pruebas_detalle_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE tb_pruebas_detalle_pruebas_detalle_id_seq
START WITH 1
INCREMENT BY 1
NO MINVALUE
NO MAXVALUE
CACHE 1;


ALTER TABLE public.tb_pruebas_detalle_pruebas_detalle_id_seq OWNER TO postgres;

--
-- TOC entry 2690 (class 0 OID 0)
-- Dependencies: 203
-- Name: tb_pruebas_detalle_pruebas_detalle_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE tb_pruebas_detalle_pruebas_detalle_id_seq OWNED BY tb_pruebas_detalle.pruebas_detalle_id;


--
-- TOC entry 204 (class 1259 OID 16684)
-- Name: tb_pruebas_tipo; Type: TABLE; Schema: public; Owner: atluser; Tablespace:
--

CREATE TABLE tb_pruebas_tipo (
	pruebas_tipo_codigo character varying(15) NOT NULL,
	pruebas_tipo_descripcion character varying(120) NOT NULL,
	activo boolean DEFAULT true NOT NULL,
	usuario character varying(15) NOT NULL,
	fecha_creacion timestamp without time zone NOT NULL,
	usuario_mod character varying(15),
	fecha_modificacion timestamp without time zone
);


ALTER TABLE public.tb_pruebas_tipo OWNER TO atluser;

--
-- TOC entry 205 (class 1259 OID 16688)
-- Name: tb_records; Type: TABLE; Schema: public; Owner: atluser; Tablespace:
--

CREATE TABLE tb_records (
	records_id integer NOT NULL,
	records_tipo_codigo character varying(15) NOT NULL,
	atletas_resultados_id integer NOT NULL,
	categorias_codigo character varying(15) NOT NULL,
	records_id_origen integer,
	records_protected boolean DEFAULT false NOT NULL,
	activo boolean DEFAULT true NOT NULL,
	usuario character varying(15) NOT NULL,
	fecha_creacion timestamp without time zone NOT NULL,
	usuario_mod character varying(15),
	fecha_modificacion timestamp without time zone
);


ALTER TABLE public.tb_records OWNER TO atluser;

--
-- TOC entry 206 (class 1259 OID 16693)
-- Name: tb_records_pase; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

CREATE TABLE tb_records_pase (
	records_id integer,
	records_tipo_codigo character varying(15),
	atletas_resultados_id integer,
	categorias_codigo character varying(15),
	records_id_origen integer,
	records_protected boolean,
	activo boolean,
	usuario character varying(15),
	fecha_creacion timestamp without time zone,
	usuario_mod character varying(15),
	fecha_modificacion timestamp without time zone
);


ALTER TABLE public.tb_records_pase OWNER TO postgres;

--
-- TOC entry 207 (class 1259 OID 16696)
-- Name: tb_records_records_id_seq; Type: SEQUENCE; Schema: public; Owner: atluser
--

CREATE SEQUENCE tb_records_records_id_seq
START WITH 1
INCREMENT BY 1
NO MINVALUE
NO MAXVALUE
CACHE 1;


ALTER TABLE public.tb_records_records_id_seq OWNER TO atluser;

--
-- TOC entry 2691 (class 0 OID 0)
-- Dependencies: 207
-- Name: tb_records_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: atluser
--

ALTER SEQUENCE tb_records_records_id_seq OWNED BY tb_records.records_id;


--
-- TOC entry 208 (class 1259 OID 16698)
-- Name: tb_records_tipo; Type: TABLE; Schema: public; Owner: atluser; Tablespace:
--

CREATE TABLE tb_records_tipo (
	records_tipo_codigo character varying(15) NOT NULL,
	records_tipo_descripcion character varying(100) NOT NULL,
	records_tipo_abreviatura character varying(2) NOT NULL,
	records_tipo_tipo character(1) DEFAULT 'C'::bpchar NOT NULL,
	records_tipo_clasificacion character(1) DEFAULT 'X'::bpchar NOT NULL,
	records_tipo_peso integer DEFAULT 0 NOT NULL,
	records_tipo_protected boolean DEFAULT false NOT NULL,
	activo boolean DEFAULT true NOT NULL,
	usuario character varying(15) NOT NULL,
	fecha_creacion timestamp without time zone NOT NULL,
	usuario_mod character varying(15),
	fecha_modificacion timestamp without time zone,
	CONSTRAINT chk_records_clasificacion CHECK ((records_tipo_clasificacion = ANY (ARRAY['O'::bpchar, 'M'::bpchar, 'R'::bpchar, 'N'::bpchar, 'X'::bpchar, 'T'::bpchar]))),
	CONSTRAINT chk_records_tipo CHECK ((records_tipo_tipo = ANY (ARRAY['C'::bpchar, 'A'::bpchar])))
);


ALTER TABLE public.tb_records_tipo OWNER TO atluser;

--
-- TOC entry 2692 (class 0 OID 0)
-- Dependencies: 208
-- Name: COLUMN tb_records_tipo.records_tipo_peso; Type: COMMENT; Schema: public; Owner: atluser
--

COMMENT ON COLUMN tb_records_tipo.records_tipo_peso IS 'Indica el peso , por ejemplo el record mundial pesa 100  , 90 el regional , 50 el nacional , 0 para los records de competencia tales como el record olimpico.';


--
-- TOC entry 209 (class 1259 OID 16708)
-- Name: tb_records_tipo_pase; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

CREATE TABLE tb_records_tipo_pase (
	records_tipo_codigo character varying(15),
	records_tipo_descripcion character varying(100),
	records_tipo_abreviatura character varying(2),
	records_tipo_tipo character(1),
	records_tipo_clasificacion character(1),
	records_tipo_peso integer,
	records_tipo_protected boolean,
	activo boolean,
	usuario character varying(15),
	fecha_creacion timestamp without time zone,
	usuario_mod character varying(15),
	fecha_modificacion timestamp without time zone
);


ALTER TABLE public.tb_records_tipo_pase OWNER TO postgres;

--
-- TOC entry 210 (class 1259 OID 16711)
-- Name: tb_regiones; Type: TABLE; Schema: public; Owner: atluser; Tablespace:
--

CREATE TABLE tb_regiones (
	regiones_codigo character varying(15) NOT NULL,
	regiones_descripcion character varying(120) NOT NULL,
	activo boolean DEFAULT true NOT NULL,
	usuario character varying(15) NOT NULL,
	fecha_creacion timestamp without time zone NOT NULL,
	usuario_mod character varying(15),
	fecha_modificacion timestamp without time zone
);


ALTER TABLE public.tb_regiones OWNER TO atluser;

--
-- TOC entry 211 (class 1259 OID 16715)
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
-- TOC entry 212 (class 1259 OID 16720)
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
-- TOC entry 2693 (class 0 OID 0)
-- Dependencies: 212
-- Name: tb_sys_menu_menu_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: atluser
--

ALTER SEQUENCE tb_sys_menu_menu_id_seq OWNED BY tb_sys_menu.menu_id;


--
-- TOC entry 213 (class 1259 OID 16722)
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
-- TOC entry 214 (class 1259 OID 16726)
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
-- TOC entry 215 (class 1259 OID 16735)
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
-- TOC entry 2694 (class 0 OID 0)
-- Dependencies: 215
-- Name: tb_sys_perfil_detalle_perfdet_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: atluser
--

ALTER SEQUENCE tb_sys_perfil_detalle_perfdet_id_seq OWNED BY tb_sys_perfil_detalle.perfdet_id;


--
-- TOC entry 216 (class 1259 OID 16737)
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
-- TOC entry 2695 (class 0 OID 0)
-- Dependencies: 216
-- Name: tb_sys_perfil_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: atluser
--

ALTER SEQUENCE tb_sys_perfil_id_seq OWNED BY tb_sys_perfil.perfil_id;


--
-- TOC entry 217 (class 1259 OID 16739)
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
-- TOC entry 218 (class 1259 OID 16743)
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
-- TOC entry 219 (class 1259 OID 16747)
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
-- TOC entry 2696 (class 0 OID 0)
-- Dependencies: 219
-- Name: tb_sys_usuario_perfiles_usuario_perfil_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: atluser
--

ALTER SEQUENCE tb_sys_usuario_perfiles_usuario_perfil_id_seq OWNED BY tb_sys_usuario_perfiles.usuario_perfil_id;


--
-- TOC entry 220 (class 1259 OID 16749)
-- Name: tb_unidad_medida; Type: TABLE; Schema: public; Owner: atluser; Tablespace:
--

CREATE TABLE tb_unidad_medida (
	unidad_medida_codigo character varying(8) NOT NULL,
	unidad_medida_descripcion character varying(80) NOT NULL,
	unidad_medida_regex_e character varying(60) NOT NULL,
	unidad_medida_regex_m character varying(60) NOT NULL,
	unidad_medida_protected boolean DEFAULT false NOT NULL,
	activo boolean DEFAULT true NOT NULL,
	usuario character varying(15) NOT NULL,
	fecha_creacion timestamp without time zone NOT NULL,
	usuario_mod character varying(15),
	fecha_modificacion timestamp without time zone,
	unidad_medida_tipo character(1) NOT NULL,
	CONSTRAINT chk_unidad_medida_tipo CHECK ((unidad_medida_tipo = ANY (ARRAY['T'::bpchar, 'M'::bpchar, 'P'::bpchar])))
);


ALTER TABLE public.tb_unidad_medida OWNER TO atluser;

--
-- TOC entry 221 (class 1259 OID 16755)
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
-- TOC entry 222 (class 1259 OID 16760)
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
-- TOC entry 2697 (class 0 OID 0)
-- Dependencies: 222
-- Name: tb_usuarios_usuarios_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: atluser
--

ALTER SEQUENCE tb_usuarios_usuarios_id_seq OWNED BY tb_usuarios.usuarios_id;


--
-- TOC entry 224 (class 1259 OID 37545)
-- Name: v_count; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

CREATE TABLE v_count (
	count bigint
);


ALTER TABLE public.v_count OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16762)
-- Name: v_peso_desde; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

CREATE TABLE v_peso_desde (
	appcat_peso integer
);


ALTER TABLE public.v_peso_desde OWNER TO postgres;

--
-- TOC entry 2177 (class 2604 OID 16789)
-- Name: atletas_carnets_id; Type: DEFAULT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_atletas_carnets ALTER COLUMN atletas_carnets_id SET DEFAULT nextval('tb_atletas_carnets_atletas_carnets_id_seq'::regclass);


--
-- TOC entry 2184 (class 2604 OID 16790)
-- Name: atletas_resultados_id; Type: DEFAULT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_atletas_resultados ALTER COLUMN atletas_resultados_id SET DEFAULT nextval('tb_atletas_resultados_atletas_resultados_id_seq'::regclass);


--
-- TOC entry 2187 (class 2604 OID 16791)
-- Name: atletas_resultados_detalle_id; Type: DEFAULT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_atletas_resultados_detalle ALTER COLUMN atletas_resultados_detalle_id SET DEFAULT nextval('tb_atletas_resultados_detalle_atletas_resultados_detalle_id_seq'::regclass);


--
-- TOC entry 2205 (class 2604 OID 16792)
-- Name: clubesatletas_id; Type: DEFAULT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_clubes_atletas ALTER COLUMN clubesatletas_id SET DEFAULT nextval('tb_clubes_atletas_clubesatletas_id_seq'::regclass);


--
-- TOC entry 2216 (class 2604 OID 16793)
-- Name: competencias_pruebas_id; Type: DEFAULT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_competencias_pruebas ALTER COLUMN competencias_pruebas_id SET DEFAULT nextval('tb_competencias_pruebas_competencias_pruebas_id_seq'::regclass);


--
-- TOC entry 2219 (class 2604 OID 16794)
-- Name: entidad_id; Type: DEFAULT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_entidad ALTER COLUMN entidad_id SET DEFAULT nextval('tb_entidad_entidad_id_seq'::regclass);


--
-- TOC entry 2222 (class 2604 OID 16795)
-- Name: entrenadoresatletas_id; Type: DEFAULT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_entrenadores_atletas ALTER COLUMN entrenadoresatletas_id SET DEFAULT nextval('tb_entrenadores_atletas_entrenadoresatletas_id_seq'::regclass);


--
-- TOC entry 2227 (class 2604 OID 16796)
-- Name: ligasclubes_id; Type: DEFAULT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_ligas_clubes ALTER COLUMN ligasclubes_id SET DEFAULT nextval('tb_ligas_clubes_ligasclubes_id_seq'::regclass);


--
-- TOC entry 2273 (class 2604 OID 37653)
-- Name: postas_id; Type: DEFAULT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_postas ALTER COLUMN postas_id SET DEFAULT nextval('tb_postas_postas_id_seq'::regclass);


--
-- TOC entry 2275 (class 2604 OID 37669)
-- Name: postas_detalle_id; Type: DEFAULT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_postas_detalle ALTER COLUMN postas_detalle_id SET DEFAULT nextval('tb_postas_detalle_postas_detalle_id_seq'::regclass);


--
-- TOC entry 2239 (class 2604 OID 16797)
-- Name: pruebas_detalle_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY tb_pruebas_detalle ALTER COLUMN pruebas_detalle_id SET DEFAULT nextval('tb_pruebas_detalle_pruebas_detalle_id_seq'::regclass);


--
-- TOC entry 2243 (class 2604 OID 16798)
-- Name: records_id; Type: DEFAULT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_records ALTER COLUMN records_id SET DEFAULT nextval('tb_records_records_id_seq'::regclass);


--
-- TOC entry 2254 (class 2604 OID 16799)
-- Name: menu_id; Type: DEFAULT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_sys_menu ALTER COLUMN menu_id SET DEFAULT nextval('tb_sys_menu_menu_id_seq'::regclass);


--
-- TOC entry 2256 (class 2604 OID 16800)
-- Name: perfil_id; Type: DEFAULT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_sys_perfil ALTER COLUMN perfil_id SET DEFAULT nextval('tb_sys_perfil_id_seq'::regclass);


--
-- TOC entry 2263 (class 2604 OID 16801)
-- Name: perfdet_id; Type: DEFAULT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_sys_perfil_detalle ALTER COLUMN perfdet_id SET DEFAULT nextval('tb_sys_perfil_detalle_perfdet_id_seq'::regclass);


--
-- TOC entry 2266 (class 2604 OID 16802)
-- Name: usuario_perfil_id; Type: DEFAULT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_sys_usuario_perfiles ALTER COLUMN usuario_perfil_id SET DEFAULT nextval('tb_sys_usuario_perfiles_usuario_perfil_id_seq'::regclass);


--
-- TOC entry 2272 (class 2604 OID 16803)
-- Name: usuarios_id; Type: DEFAULT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_usuarios ALTER COLUMN usuarios_id SET DEFAULT nextval('tb_usuarios_usuarios_id_seq'::regclass);


--
-- TOC entry 2608 (class 0 OID 16512)
-- Dependencies: 171
-- Data for Name: tb_app_categorias_values; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY tb_app_categorias_values (appcat_codigo, appcat_peso, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
TOD	0	t	ADMIN	2014-03-03 15:14:04.174442	\N	\N
MEN	10	t	ADMIN	2014-03-03 15:14:21.338253	\N	\N
JUV	20	t	ADMIN	2014-03-03 15:14:34.572141	\N	\N
S23	30	t	ADMIN	2014-03-03 15:14:55.950176	\N	\N
MAY	40	t	ADMIN	2014-03-03 15:15:07.533988	\N	\N
CAD	9	t	ADMIN	2014-03-11 12:51:03.98295	\N	\N
INF	6	t	ADMIN	2014-03-11 12:50:34.557352	postgres	2014-03-11 12:56:08.382828
\.


--
-- TOC entry 2609 (class 0 OID 16516)
-- Dependencies: 172
-- Data for Name: tb_app_pruebas_values; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY tb_app_pruebas_values (apppruebas_codigo, apppruebas_descripcion, pruebas_clasificacion_codigo, apppruebas_marca_menor, apppruebas_marca_mayor, apppruebas_multiple, apppruebas_verifica_viento, apppruebas_viento_limite_normal, apppruebas_viento_limite_multiple, apppruebas_protected, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion, apppruebas_nro_atletas, apppruebas_factor_manual, apppruebas_viento_individual) FROM stdin;
LBALA	Impulsion de Bala	LANZ	5.00	30.00	f	f	\N	\N	f	t	postgres	2014-03-21 04:39:40.145286	TESTUSER	2014-06-04 03:02:57.772999	1	0.00	f
SALTO	Salto Alto	SALTO	1.10	2.45	f	f	\N	\N	f	t	postgres	2014-03-21 04:39:40.145286	TESTUSER	2014-06-04 03:02:57.772999	1	0.00	f
1500MP	1500 Metros Planos	SFONDO	3:00.00	10:00.00	f	f	\N	\N	f	t	postgres	2014-03-21 04:39:40.145286	TESTUSER	2014-06-04 03:02:57.772999	1	0.00	f
100MV	100 Metros con Vallas	VEL	11.00	21.00	f	t	2.00	4.00	f	t	postgres	2014-03-21 04:39:40.145286	TESTUSER	2014-06-04 03:02:57.772999	1	0.24	f
LJABALINA	Lanzamiento de Jabalina	LANZ	10.20	70.00	f	f	\N	\N	f	t	postgres	2014-03-21 04:39:40.145286	TESTUSER	2014-06-04 03:02:57.772999	1	0.00	f
100MP	100 Metros Planos	VEL	9.80	24.00	f	t	2.00	\N	f	t	postgres	2014-03-21 04:39:40.145286	TESTUSER	2014-06-04 03:02:57.772999	1	0.24	f
110MV	110 Metros Con Vallas	VEL	11.00	24.00	f	t	2.00	4.00	f	t	postgres	2014-03-21 04:39:40.145286	TESTUSER	2014-06-04 03:02:57.772999	1	0.24	f
400MV	400 Metros con Vallas	VEL	55.00	4:00.00	f	f	\N	\N	f	t	postgres	2014-03-21 04:39:40.145286	TESTUSER	2014-06-04 03:02:57.772999	1	0.14	f
LMARTILLO	Lanzamiento de Martillo	LANZ	11.00	90.00	f	f	\N	\N	f	t	postgres	2014-03-21 04:39:40.145286	TESTUSER	2014-06-04 03:02:57.772999	1	0.00	f
800MP	800 Metros Planos	SFONDO	0:41.00	4:30.10	f	f	\N	\N	f	t	postgres	2014-03-21 04:39:40.145286	TESTUSER	2014-06-04 03:02:57.772999	1	0.00	f
200MP	200 Metros Planos	VEL	20.00	40.00	f	t	2.00	4.00	f	t	postgres	2014-03-21 04:39:40.145286	TESTUSER	2014-06-04 03:02:57.772999	1	0.24	f
SLARGO	Salto Largo	SALTO	2.10	6.45	f	t	2.00	4.00	f	t	postgres	2014-03-21 04:39:40.145286	TESTUSER	2014-06-04 03:07:52.969061	1	0.00	t
STRIPLE	Salto Triple	SALTO	5.00	15.00	f	t	2.00	4.00	f	t	postgres	2014-03-21 04:39:40.145286	TESTUSER	2014-06-04 03:07:58.732714	1	0.00	t
10000MP	10000 Metros Planos	FONDO	0:30:00.00	1:30:00.00	f	f	\N	\N	f	t	postgres	2014-03-21 04:39:40.145286	TESTUSER	2014-07-26 12:31:11.165132	1	0.00	f
3000MOBS	3000 Metros Con Obstaculos	SFONDO	6:00.00	20:00.00	f	f	\N	\N	f	t	TESTUSER	2014-07-26 15:03:02.82383	\N	\N	1	0.00	f
10000MMARCHA	10000 Metros-Marcha	FONDO	0:20:00.00	1:30:00.00	f	f	\N	\N	f	t	TESTUSER	2014-07-28 16:27:05.221417	TESTUSER	2014-07-28 16:28:44.444895	1	0.00	f
400MP	400 Metros Planos	VEL	45:00	1:59.59	f	f	\N	\N	f	t	postgres	2014-03-21 04:39:40.145286	TESTUSER	2015-04-26 14:52:46.349739	1	0.14	f
SGARROCHA	Salto con Garrocha	SALTO	2.00	5.00	f	f	\N	\N	f	t	TESTUSER	2015-04-19 20:17:40.800641	TESTUSER	2015-04-26 16:58:54.75577	1	0.00	f
DECATLON	Decatlon	COMBI	2000	8000	t	f	\N	\N	f	t	postgres	2014-03-21 04:39:40.145286	TESTUSER	2016-02-10 03:09:12.603376	1	0.00	f
HEPTATLON	Heptatlon	COMBI	00	7500	t	f	\N	\N	t	t	postgres	2014-03-21 04:39:40.145286	TESTUSER	2016-04-19 15:15:23.490504	1	0.00	f
4X400MP	4x400 Metros Planos	VEL	50.00	6:00.00	f	f	\N	\N	f	t	TESTUSER	2014-04-20 04:52:20.849685	TESTUSER	2016-04-24 23:43:36.033306	4	0.00	f
\.


--
-- TOC entry 2610 (class 0 OID 16526)
-- Dependencies: 173
-- Data for Name: tb_atletas; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY tb_atletas (atletas_codigo, atletas_ap_paterno, atletas_ap_materno, atletas_nombres, atletas_nombre_completo, atletas_sexo, atletas_nro_documento, atletas_nro_pasaporte, paises_codigo, atletas_fecha_nacimiento, atletas_telefono_casa, atletas_telefono_celular, atletas_email, atletas_direccion, atletas_observaciones, atletas_talla_ropa_buzo, atletas_talla_ropa_poloshort, atletas_talla_zapatillas, atletas_norma_zapatillas, atletas_url_foto, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion, atletas_protected) FROM stdin;
46134708	Chavez	Korfiatis	Arturo	Chavez Korfiatis, Arturo	M	46134708		PER	1990-01-12				?????????????		L	M	12.5	US		t	atluser	2014-03-11 02:46:12.17129	TESTUSER	2014-03-11 03:02:12.003074	f
73501965	Kimberly	Cardoza	Ramirez	Kimberly Cardoza, Ramirez	F	73501966		PER	1995-10-12				N/C		M	M	\N	??	../../photos/63e7bbfb84d242e5cb214d4f3ed1958a.jpg	t	atluser	2014-07-16 15:38:43.522741	TESTUSER	2014-07-25 22:44:46.700743	f
71336507	Yurivilca	Calderon	Paolo	Yurivilca Calderon, Paolo	M	71336507		PER	1996-04-23				Huncayo		??	??	\N	??	../../photos/user_male.png	t	atluser	2014-07-26 12:23:31.855384	TESTUSER	\N	f
08786474	Noeding	Koltermann	Edith	Noeding Koltermann, Edith	F	08786474		PER	1954-11-03				Lima		??	??	\N	??		t	atluser	2014-07-27 17:41:52.355187	TESTUSER	\N	f
10305307	Massa	Vidarte	Gilda Maria	Massa Vidarte, Gilda Maria	F	10305307		PER	1976-02-19				??		??	??	\N	??		t	atluser	2014-07-27 17:56:59.815211	TESTUSER	\N	f
DEBSOUZA	Souza	Peixoto Luna	Deborah	Souza Peixoto Luna, Deborah	F	99999991		PER	1969-01-01				???		??	??	\N	??		t	atluser	2014-07-27 18:20:54.522625	TESTUSER	\N	f
70424527	Mautino	Ruiz	Paola	Mautino Ruiz, Paola	F	70424527		PER	1990-01-01				??????		??	??	\N	??		t	atluser	2014-07-28 22:31:47.624488	TESTUSER	\N	f
70830992	Martinez	Chiroque	Andy	Martinez Chiroque, Andy	M	70830992		PER	1993-09-28				??		??	??	\N	??		t	atluser	2014-08-02 17:41:39.623876	TESTUSER	\N	f
07197388	Bolivar	Rios	Carmela	Bolivar Rios, Carmela	F	07197388		PER	1957-04-23				????		??	??	\N	??		t	atluser	2014-09-07 15:04:07.335452	TESTUSER	\N	f
40503227	Reategui	Valdez	Sandra	Reategui Valdez, Sandra	F	40503227		PER	1980-03-10				????		??	??	\N	??		t	atluser	2014-09-07 15:15:43.263211	TESTUSER	\N	f
10307755	Pacheco	Milichichi	Beatriz	Pacheco Milichichi, Beatriz	F	10307755		PER	1956-03-28				????		??	??	\N	??		t	atluser	2014-09-07 15:27:08.251574	TESTUSER	\N	f
70690315	Toche	Zevallos	Candy Naomi	Toche Zevallos, Candy Naomi	F	70690315		PER	1998-09-13				no indicada		??	??	\N	??		t	atluser	2015-03-14 15:33:12.314335	TESTUSER	\N	f
79515419	Torres	Cordova	Maitte De La Flor	Torres Cordova, Maitte De La Flor	F	79515419		PER	1993-09-04				No Indicada		??	??	\N	??		t	atluser	2015-03-14 16:25:11.930399	TESTUSER	2015-04-26 14:58:58.005031	f
72661990	Gutierrez	Pozo	Jose Mauricio	Gutierrez Pozo, Jose Mauricio	M	72661990		PER	1998-09-13				No indicada		??	??	\N	??		t	atluser	2015-04-26 16:57:36.049823	TESTUSER	\N	f
09753033	Yañez	Lazo	Katherine	Yañez Lazo, Katherine	F	09753033		PER	1972-09-07				??		??	??	\N	??		t	atluser	2014-07-27 19:31:46.526579	TESTUSER	2014-07-27 20:40:17.759941	f
POSTAM	POSTA	POSTA	POSTAM	POSTA POSTA, POSTAM	M	00000000		PER	1990-01-01				???		??	??	\N	??		t	atluser	2016-04-19 12:38:32.04532	TESTUSER	2016-04-19 14:09:41.979565	t
71835626	Arenas	Cahuasi	Zulema Katia	Arenas Cahuasi, Zulema Katia	F	71835626		PER	1995-11-15				Arequipa		??	??	\N	??		t	atluser	2014-07-26 12:56:20.048343	TESTUSER	2016-04-19 16:50:12.508099	f
POSTAF	POSTA	POSTA	POSTAF	POSTA POSTA, POSTAF	F	00000001		PER	1990-01-01				???	Restringido por el sistema	??	??	\N	??		t	atluser	2016-04-19 12:40:00.925446	TESTUSER	2016-05-01 12:58:53.278898	t
46658908	Arana	Chiesa	Melissa	Arana Chiesa, Melissa	F	46658908		PER	1990-12-22	2756910	961716739	mac22_12@hotmail.com	Monte De Los Olivos 108 / Urb. Prolongacion Benavides / Santiago de Surco		S	S	8	US	../../photos/093772aff38e23f01e675f669820c164.jpg	t	atluser	2014-03-12 12:21:50.421765	TESTUSER	2016-05-04 16:54:30.300021	f
JACVSCH	Scholz		Jackson Volney	Scholz, Jackson Volney	M			USA	1897-03-15				Michigan		??	??	\N	??	../../photos/0e387f6a0e71f0cbe8d6b32bb6751287.jpg	t	atluser	2016-05-22 22:17:20.137579	TESTUSER	2016-05-22 22:18:06.77204	f
DONLYP	Lippincott		Donald	Lippincott, Donald	M			USA	1893-11-16				Philadelphia,USA		??	??	\N	??	../../photos/a9819b399e7a854fd8928008de60920b.jpg	t	atluser	2016-05-22 13:41:44.951733	TESTUSER	2016-05-22 22:21:45.840551	f
\.


--
-- TOC entry 2611 (class 0 OID 16537)
-- Dependencies: 174
-- Data for Name: tb_atletas_carnets; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY tb_atletas_carnets (atletas_carnets_id, atletas_carnets_numero, atletas_carnets_agno, atletas_codigo, atletas_carnets_fecha, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
14	0100	2014	46658908	2012-01-01	t	TESTUSER	2014-03-12 13:57:01.615722	TESTUSER	2014-03-12 13:57:49.710961
1	100	2014	46134708	2014-01-01	t	TESTUSER	2014-03-12 04:18:25.023382	TESTUSER	2014-03-12 13:58:03.830108
\.


--
-- TOC entry 2698 (class 0 OID 0)
-- Dependencies: 175
-- Name: tb_atletas_carnets_atletas_carnets_id_seq; Type: SEQUENCE SET; Schema: public; Owner: atluser
--

SELECT pg_catalog.setval('tb_atletas_carnets_atletas_carnets_id_seq', 16, true);


--
-- TOC entry 2613 (class 0 OID 16544)
-- Dependencies: 176
-- Data for Name: tb_atletas_resultados; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY tb_atletas_resultados (atletas_resultados_id, atletas_codigo, competencias_pruebas_id, atletas_resultados_resultado, atletas_resultados_puesto, atletas_resultados_protected, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion, atletas_resultados_puntos, atletas_resultados_viento, postas_id) FROM stdin;
677	46134708	96	2.15	10	f	t	TESTUSER	2014-06-05 21:43:31.197857	TESTUSER	2014-07-16 20:57:57.375519	0	\N	\N
776	73501965	610	2:22.59	0	f	t	TESTUSER	2014-07-18 17:11:05.352493	TESTUSER	2014-07-18 17:13:22.259515	789	\N	\N
778	71835626	624	9:54.12	3	f	t	TESTUSER	2014-07-26 15:05:47.826234	\N	\N	0	\N	\N
779	71835626	625	9:59.38	6	f	t	TESTUSER	2014-07-27 01:36:39.026511	\N	\N	0	\N	\N
781	71835626	627	10:05.48	1	f	t	TESTUSER	2014-07-27 14:47:02.888642	\N	\N	0	\N	\N
742	46658908	574	15.15	0	f	t	TESTUSER	2014-07-17 09:50:03.039304	TESTUSER	2014-07-17 09:50:21.629318	822	\N	\N
785	71336507	631	0:40:02.07	3	f	t	TESTUSER	2014-07-28 16:29:51.814612	\N	\N	0	\N	\N
746	46658908	578	5.26	20	f	t	TESTUSER	2014-07-17 09:50:03.039304	atluser	2014-07-18 12:57:37.553202	631	1.30	\N
743	46658908	575	1.57	10	f	t	TESTUSER	2014-07-17 09:50:03.039304	atluser	2014-07-17 14:08:54.817505	701	\N	\N
744	46658908	576	11.09	17	f	t	TESTUSER	2014-07-17 09:50:03.039304	atluser	2014-07-17 14:17:23.939685	601	\N	\N
747	46658908	579	29.33	20	f	t	TESTUSER	2014-07-17 09:50:03.039304	atluser	2014-07-18 16:05:32.268143	464	\N	\N
745	46658908	577	26.52	23	f	t	TESTUSER	2014-07-17 09:50:03.039304	atluser	2014-07-17 15:02:26.850281	752	\N	\N
736	46658908	568	10.66	0	f	t	TESTUSER	2014-07-16 16:47:33.093815	TESTUSER	2014-07-28 22:40:51.99181	573	\N	\N
748	46658908	580	2:21.38	10	f	t	TESTUSER	2014-07-17 09:50:03.039304	atluser	2014-07-18 16:06:25.394236	805	\N	\N
771	73501965	605	1.57	0	f	t	TESTUSER	2014-07-18 17:11:05.352493	TESTUSER	2014-07-18 17:11:36.932776	701	\N	\N
788	73501965	634	1.64	0	f	t	TESTUSER	2014-07-28 16:58:35.082982	TESTUSER	2014-07-28 16:59:26.55692	783	\N	\N
789	73501965	635	9.93	0	f	t	TESTUSER	2014-07-28 16:58:35.082982	TESTUSER	2014-07-28 16:59:42.038764	525	\N	\N
737	46658908	569	26.62	0	f	t	TESTUSER	2014-07-16 16:48:50.079056	TESTUSER	2014-07-28 22:40:59.386831	744	\N	\N
790	73501965	636	26.81	0	f	t	TESTUSER	2014-07-28 16:58:35.082982	TESTUSER	2014-07-28 17:00:15.975446	728	\N	\N
791	73501965	637	5.07	0	f	t	TESTUSER	2014-07-28 16:58:35.082982	TESTUSER	2014-07-28 17:00:41.783238	578	1.00	\N
792	73501965	638	25.55	0	f	t	TESTUSER	2014-07-28 16:58:35.082982	TESTUSER	2014-07-28 17:01:12.930891	393	\N	\N
793	73501965	639	2:25.26	0	f	t	TESTUSER	2014-07-28 16:58:35.082982	TESTUSER	2014-07-28 17:01:31.360077	753	\N	\N
734	46658908	566	15.47	0	f	t	TESTUSER	2014-07-16 16:45:13.196204	TESTUSER	2014-07-28 22:40:25.366098	781	\N	\N
735	46658908	567	1.61	0	f	t	TESTUSER	2014-07-16 16:46:43.555646	TESTUSER	2014-07-28 22:40:43.877491	747	\N	\N
739	46658908	571	38.29	0	f	t	TESTUSER	2014-07-16 16:52:57.758443	TESTUSER	2014-07-16 16:55:02.119882	635	\N	\N
740	46658908	572	2:23.20	0	f	t	TESTUSER	2014-07-16 16:53:44.74489	TESTUSER	2014-07-16 16:55:09.015548	781	\N	\N
796	70424527	642	6.32	1	f	t	TESTUSER	2014-07-28 22:45:20.96353	\N	\N	0	1.60	\N
721	46658908	549	16.03	3	f	t	TESTUSER	2014-07-16 15:20:10.086423	\N	\N	711	\N	\N
772	73501965	606	10.35	0	f	t	TESTUSER	2014-07-18 17:11:05.352493	TESTUSER	2014-07-18 17:11:50.920194	552	\N	\N
797	71835626	643	9:53.42	2	f	t	TESTUSER	2014-08-01 18:00:37.596604	\N	\N	0	\N	\N
722	46658908	550	1.55	2	f	t	TESTUSER	2014-07-16 15:21:02.102497	\N	\N	678	\N	\N
787	73501965	633	16.40	8	f	t	TESTUSER	2014-07-28 16:58:35.082982	TESTUSER	2016-03-08 01:11:58.132757	666	\N	\N
723	46658908	551	10.90	2	f	t	TESTUSER	2014-07-16 15:21:33.887285	\N	\N	589	\N	\N
724	46658908	552	26.56	3	f	t	TESTUSER	2014-07-16 15:22:12.797712	\N	\N	749	\N	\N
725	46658908	553	5.22	0	f	t	TESTUSER	2014-07-16 15:26:01.528916	TESTUSER	2014-07-16 16:55:30.993895	620	0.00	\N
726	46658908	554	39.48	0	f	t	TESTUSER	2014-07-16 15:28:34.322773	TESTUSER	2014-07-16 16:55:36.252744	657	\N	\N
727	46658908	555	2:28.22	0	f	t	TESTUSER	2014-07-16 15:29:27.34853	TESTUSER	2014-07-16 16:55:42.307548	715	\N	\N
775	73501965	609	30.90	0	f	t	TESTUSER	2014-07-18 17:11:05.352493	TESTUSER	2014-07-18 17:13:03.397934	494	\N	\N
770	73501965	604	15.60	0	f	t	TESTUSER	2014-07-18 17:11:05.352493	TESTUSER	2014-12-27 14:12:48.118234	764	\N	\N
780	71835626	626	9:55.23	1	f	t	TESTUSER	2014-07-27 14:16:34.798897	TESTUSER	2016-03-17 01:43:46.646752	0	\N	\N
774	73501965	608	5.03	0	f	t	TESTUSER	2014-07-18 17:11:05.352493	TESTUSER	2014-12-27 14:10:45.694125	567	2.50	\N
804	79515419	648	54.74	1	f	t	TESTUSER	2015-03-14 16:31:52.311957	\N	\N	0	\N	\N
806	79515419	650	1:01:21	4	f	t	TESTUSER	2015-03-14 17:01:01.717668	\N	\N	0	\N	\N
807	70424527	651	6.26	1	f	t	TESTUSER	2015-03-15 17:54:47.066594	TESTUSER	2015-03-15 17:55:40.783741	0	1.80	\N
809	46658908	653	15.30	0	f	t	TESTUSER	2015-04-19 19:30:09.433864	TESTUSER	2015-04-19 19:32:23.938427	802	\N	\N
816	70424527	660	6.41	3	f	t	TESTUSER	2015-04-19 20:13:58.972789	\N	\N	0	1.00	\N
810	46658908	654	1.63	0	f	t	TESTUSER	2015-04-19 19:30:09.433864	TESTUSER	2015-04-19 19:32:52.337993	771	\N	\N
814	46658908	658	36.44	0	f	t	TESTUSER	2015-04-19 19:30:09.433864	TESTUSER	2015-04-19 19:34:37.414615	599	\N	\N
811	46658908	655	11.02	0	f	t	TESTUSER	2015-04-19 19:30:09.433864	TESTUSER	2015-04-19 19:33:07.661453	596	\N	\N
812	46658908	656	26.42	0	f	t	TESTUSER	2015-04-19 19:30:09.433864	TESTUSER	2015-04-19 19:33:35.035804	761	\N	\N
815	46658908	659	2:19.85	0	f	t	TESTUSER	2015-04-19 19:30:09.433864	TESTUSER	2015-04-19 19:34:56.151349	826	\N	\N
817	70830992	661	20.95	2	f	t	TESTUSER	2015-04-26 12:23:36.297155	\N	\N	0	\N	\N
819	79515419	674	54.63	2	f	t	TESTUSER	2015-04-26 14:53:43.436547	\N	\N	0	\N	\N
820	72661990	675	4.70	1	f	t	TESTUSER	2015-04-26 17:06:44.705213	\N	\N	0	\N	\N
795	10305307	641	6.23	0	f	t	TESTUSER	2014-07-28 22:10:49.166631	TESTUSER	2016-03-20 14:19:03.68455	0	\N	\N
799	70830992	645	10.30	1	f	t	TESTUSER	2014-08-02 17:51:35.218898	atluser	2016-03-02 14:31:01.565309	0	\N	\N
1138	46658908	855	2:10.10	2	f	t	TESTUSER	2016-03-18 03:28:18.628588	TESTUSER	2016-03-18 13:43:30.132692	0	\N	\N
794	08786474	640	6.01	0	f	t	TESTUSER	2014-07-28 21:28:21.240928	TESTUSER	2016-03-20 14:19:18.577342	0	\N	\N
784	10305307	630	6.22	3	f	t	TESTUSER	2014-07-28 03:11:37.207778	TESTUSER	2016-03-20 14:29:04.727622	0	\N	\N
783	10305307	629	6.15	0	f	t	TESTUSER	2014-07-27 22:45:10.238465	TESTUSER	2016-03-20 14:29:10.460798	0	\N	\N
720	46658908	548	4719	4	f	t	TESTUSER	2014-07-16 15:20:10.086423	TESTUSER	2016-03-09 18:20:43.196465	0	\N	\N
741	46658908	573	4776	3	f	t	TESTUSER	2014-07-17 09:50:03.039304	TESTUSER	2016-03-09 18:13:23.391979	0	\N	\N
803	70690315	647	1.74	1	f	t	TESTUSER	2015-03-14 15:39:01.10463	TESTUSER	2015-03-14 15:42:17.511566	0	\N	\N
773	73501965	607	26.42	0	f	t	TESTUSER	2014-07-18 17:11:05.352493	TESTUSER	2014-07-18 17:12:16.581166	761	\N	\N
782	08786474	628	6.10	0	f	t	TESTUSER	2014-07-27 21:12:12.354983	TESTUSER	2016-03-20 14:29:14.9746	0	\N	\N
813	46658908	657	5.38	0	f	t	TESTUSER	2015-04-19 19:30:09.433864	TESTUSER	2015-04-19 19:34:06.309458	665	0.20	\N
808	46658908	652	5020	3	f	t	TESTUSER	2015-04-19 19:30:09.433864	atluser	2015-04-19 19:34:56.151349	0	\N	\N
818	70424527	662	6.43	1	f	t	TESTUSER	2015-04-26 12:40:05.470178	TESTUSER	2015-04-26 19:32:26.950783	0	0.90	\N
738	46658908	570	5.45	0	f	t	TESTUSER	2014-07-16 16:52:13.089386	TESTUSER	2016-02-17 18:57:31.373183	686	1.50	\N
733	46658908	565	4947	4	f	t	TESTUSER	2014-07-16 16:45:13.196204	TESTUSER	2014-07-16 16:54:20.797871	0	\N	\N
1177	70424527	880	4:04.1	1	f	t	TESTUSER	2016-03-20 16:37:21.786637	TESTUSER	2016-03-22 00:32:27.601111	0	\N	\N
786	73501965	632	4426	11	f	t	TESTUSER	2014-07-28 16:58:35.082982	atluser	2016-03-11 17:39:07.438814	0	\N	\N
1164	71835626	866	10.90	2	f	t	TESTUSER	2016-03-19 00:10:54.27843	TESTUSER	2016-03-19 00:13:50.666141	500	\N	\N
1135	46658908	852	1:01.10	2	f	t	TESTUSER	2016-03-18 02:59:54.858396	TESTUSER	2016-03-18 03:00:58.508648	0	\N	\N
1200	46658908	892	24.03	0	f	t	TESTUSER	2016-03-22 00:57:50.714696	\N	\N	0	\N	\N
798	70830992	644	10.2	1	f	t	TESTUSER	2014-08-02 17:45:35.458328	TESTUSER	2016-03-22 00:58:18.560422	0	\N	\N
1168	71835626	870	1:59.00	2	f	t	TESTUSER	2016-03-19 00:10:54.27843	atluser	2016-03-28 13:18:37.59873	600	\N	\N
1204	79515419	862	12.1	5	f	t	TESTUSER	2016-03-22 04:22:52.990673	TESTUSER	2016-03-25 23:45:01.480805	0	\N	\N
769	73501965	603	4628	10	f	t	TESTUSER	2014-07-18 17:11:05.352493	TESTUSER	2016-03-09 18:22:28.889135	0	\N	\N
1198	73501965	862	11.2	1	f	t	TESTUSER	2016-03-22 00:02:19.877899	TESTUSER	2016-03-22 03:19:21.085775	0	\N	\N
1132	46658908	849	12.1	1	f	t	TESTUSER	2016-03-18 02:30:41.714796	TESTUSER	2016-03-21 18:15:26.940043	0	\N	\N
1201	70690315	862	13.3	4	f	t	TESTUSER	2016-03-22 01:28:32.164295	TESTUSER	2016-03-22 04:18:10.45446	0	\N	\N
1179	70830992	923	22.89	0	f	t	TESTUSER	2016-03-20 16:53:54.104873	TESTUSER	2016-03-29 03:55:33.647654	0	\N	\N
1205	71835626	855	2:19.00	3	f	t	TESTUSER	2016-03-22 13:17:18.741259	\N	\N	0	\N	\N
1154	71835626	861	9:03.03	1	f	t	TESTUSER	2016-03-18 23:07:38.536846	\N	\N	0	\N	\N
1147	46658908	864	15.01	2	f	t	TESTUSER	2016-03-18 13:50:33.342962	TESTUSER	2016-03-22 03:32:45.143874	800	\N	\N
1181	71835626	862	12.4	8	f	t	TESTUSER	2016-03-21 18:27:15.538775	TESTUSER	2016-03-28 04:34:17.444219	0	\N	\N
1144	46658908	861	9:10.00	1	f	t	TESTUSER	2016-03-18 13:38:14.094751	\N	\N	0	\N	\N
1137	46658908	854	1:01.10	3	f	t	TESTUSER	2016-03-18 03:25:01.6442	TESTUSER	2016-03-18 13:43:18.543509	0	\N	\N
1206	70690315	855	2:20.12	5	f	t	TESTUSER	2016-03-22 13:17:46.615608	atluser	2016-03-22 13:27:27.205476	0	\N	\N
1207	79515419	855	2:23.10	6	f	t	TESTUSER	2016-03-22 13:28:02.076926	\N	\N	0	\N	\N
1216	46658908	914	15.0	1	f	t	TESTUSER	2016-03-28 01:52:06.05888	TESTUSER	2016-03-29 04:11:26.274553	560	\N	\N
1145	46658908	862	11.4	6	f	t	TESTUSER	2016-03-18 13:45:18.682267	TESTUSER	2016-03-22 18:26:41.791969	0	\N	\N
1176	70830992	879	2.44	1	f	t	TESTUSER	2016-03-20 16:32:45.756243	TESTUSER	2016-03-20 16:41:41.844105	0	\N	\N
1148	46658908	865	1.56	2	f	t	TESTUSER	2016-03-18 13:50:33.342962	TESTUSER	2016-03-18 14:50:48.036124	450	\N	\N
1134	46658908	851	26.10	2	f	t	TESTUSER	2016-03-18 02:42:06.302694	TESTUSER	2016-03-19 18:20:01.454874	0	\N	\N
1162	71835626	864	14.10	0	f	t	TESTUSER	2016-03-19 00:10:54.27843	TESTUSER	2016-03-22 03:30:29.101318	1200	\N	\N
1167	71835626	869	40.12	2	f	t	TESTUSER	2016-03-19 00:10:54.27843	TESTUSER	2016-03-19 04:29:49.047388	700	\N	\N
1150	46658908	867	26.20	2	f	t	TESTUSER	2016-03-18 13:50:33.342962	TESTUSER	2016-03-19 18:38:09.685907	900	\N	\N
1161	71835626	863	5600	1	f	t	TESTUSER	2016-03-19 00:10:54.27843	TESTUSER	2016-03-28 13:18:37.59873	0	\N	\N
1178	70690315	881	14.02	1	f	t	TESTUSER	2016-03-20 16:43:31.382639	atluser	2016-03-21 16:57:09.979565	0	\N	\N
1146	46658908	863	5210	2	f	t	TESTUSER	2016-03-18 13:50:33.342962	atluser	2016-03-28 13:18:37.59873	0	\N	\N
1165	71835626	867	25.10	1	f	t	TESTUSER	2016-03-19 00:10:54.27843	TESTUSER	2016-03-19 04:36:32.388135	1100	\N	\N
1214	46658908	912	11.01	4	f	t	TESTUSER	2016-03-28 01:05:43.190642	\N	\N	0	\N	\N
1151	46658908	868	5.60	1	f	t	TESTUSER	2016-03-18 13:50:33.342962	TESTUSER	2016-03-30 14:24:48.619246	230	\N	\N
1159	71835626	872	9:10.10	1	f	t	TESTUSER	2016-03-18 23:53:35.132664	\N	\N	0	\N	\N
1210	70830992	898	6.00	3	f	t	TESTUSER	2016-03-25 23:43:12.492317	TESTUSER	2016-03-26 03:51:10.373974	0	22.00	\N
1218	46658908	916	0	0	f	t	TESTUSER	2016-03-28 01:52:06.05888	\N	\N	0	\N	\N
1219	46658908	917	0	0	f	t	TESTUSER	2016-03-28 01:52:06.05888	\N	\N	0	\N	\N
1158	71835626	871	12.44	2	f	t	TESTUSER	2016-03-18 23:41:23.363084	TESTUSER	2016-03-19 15:04:31.967832	0	\N	\N
1221	46658908	919	0	0	f	t	TESTUSER	2016-03-28 01:52:06.05888	\N	\N	0	\N	\N
1222	46658908	920	0	0	f	t	TESTUSER	2016-03-28 01:52:06.05888	\N	\N	0	\N	\N
1166	71835626	868	5.25	2	f	t	TESTUSER	2016-03-19 00:10:54.27843	TESTUSER	2016-03-30 14:24:48.619246	500	\N	\N
1163	71835626	865	1.85	5	f	t	TESTUSER	2016-03-19 00:10:54.27843	TESTUSER	2016-03-19 00:12:35.317581	1000	\N	\N
1153	46658908	870	2:10.01	1	f	t	TESTUSER	2016-03-18 13:50:33.342962	TESTUSER	2016-03-19 03:20:59.181577	950	\N	\N
1149	46658908	866	11.80	5	f	t	TESTUSER	2016-03-18 13:50:33.342962	TESTUSER	2016-03-19 18:53:04.666523	900	\N	\N
1152	46658908	869	45.00	5	f	t	TESTUSER	2016-03-18 13:50:33.342962	TESTUSER	2016-03-19 03:34:31.977007	980	\N	\N
1217	46658908	915	1.55	2	f	t	TESTUSER	2016-03-28 01:52:06.05888	TESTUSER	2016-03-28 01:59:28.441854	700	\N	\N
1211	70830992	890	6.45	2	f	t	TESTUSER	2016-03-25 23:52:36.397226	TESTUSER	2016-03-28 00:54:48.685894	0	\N	\N
1173	46134708	877	2.45	2	f	t	TESTUSER	2016-03-19 15:47:11.752565	\N	\N	0	\N	\N
1174	46134708	878	4.45	1	f	t	TESTUSER	2016-03-19 15:51:30.254129	\N	\N	0	\N	\N
1175	72661990	877	2.45	3	f	t	TESTUSER	2016-03-19 16:00:05.748045	\N	\N	0	\N	\N
1212	72661990	890	6.10	4	f	t	TESTUSER	2016-03-28 01:02:22.140905	TESTUSER	2016-03-28 03:44:20.914336	0	\N	\N
1160	73501965	873	4:00.10	2	f	t	TESTUSER	2016-03-19 00:00:30.33452	TESTUSER	2016-03-20 15:43:36.831787	0	\N	\N
1208	46134708	890	6.25	3	f	t	TESTUSER	2016-03-25 14:17:17.266492	TESTUSER	2016-03-28 00:54:48.685894	0	\N	\N
1232	72661990	921	11.2	2	f	t	TESTUSER	2016-03-29 00:56:06.689784	\N	\N	0	\N	\N
1236	72661990	923	22.33	1	f	t	TESTUSER	2016-03-29 03:42:09.717104	\N	\N	0	\N	\N
1237	71336507	884	22.11	4	f	t	TESTUSER	2016-03-29 03:44:02.685462	TESTUSER	2016-03-29 03:44:30.424102	0	\N	\N
1235	46134708	884	22.77	1	f	t	TESTUSER	2016-03-29 03:36:29.046391	TESTUSER	2016-03-29 03:52:10.301506	0	\N	\N
1238	46134708	924	22.99	1	f	t	TESTUSER	2016-03-29 03:56:11.188948	TESTUSER	2016-03-29 03:56:23.700195	0	\N	\N
1215	46658908	913	1960	2	f	t	TESTUSER	2016-03-28 01:52:06.05888	atluser	2016-03-28 03:20:09.49734	0	\N	\N
1220	46658908	918	6.10	1	f	t	TESTUSER	2016-03-28 01:52:06.05888	TESTUSER	2016-03-30 14:24:29.825278	700	\N	\N
1239	70830992	934	10.28	1	f	t	TESTUSER	2016-04-22 12:29:00.626295	\N	\N	0	\N	\N
1249	POSTAM	925	4:04.33	2	f	t	TESTUSER	2016-04-25 01:54:34.91994	\N	\N	0	\N	55
1256	46658908	936	15.41	1	f	t	TESTUSER	2016-04-26 23:09:32.979382	TESTUSER	2016-04-28 16:13:08.848569	0	\N	\N
1257	POSTAM	925	4:04.22	3	f	t	TESTUSER	2016-05-12 01:54:43.345688	\N	\N	0	\N	56
1258	DONLYP	938	10.6	1	f	t	TESTUSER	2016-05-22 14:02:41.63908	atluser	2016-05-22 17:58:27.162842	0	\N	\N
\.


--
-- TOC entry 2699 (class 0 OID 0)
-- Dependencies: 177
-- Name: tb_atletas_resultados_atletas_resultados_id_seq; Type: SEQUENCE SET; Schema: public; Owner: atluser
--

SELECT pg_catalog.setval('tb_atletas_resultados_atletas_resultados_id_seq', 1258, true);


--
-- TOC entry 2615 (class 0 OID 16555)
-- Dependencies: 178
-- Data for Name: tb_atletas_resultados_detalle; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY tb_atletas_resultados_detalle (atletas_resultados_detalle_id, atletas_resultados_id, pruebas_codigo, atletas_resultados_detalle_resultado, atletas_resultados_detalle_viento, atletas_resultados_detalle_manual, atletas_resultados_detalle_puntos, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
\.


--
-- TOC entry 2700 (class 0 OID 0)
-- Dependencies: 179
-- Name: tb_atletas_resultados_detalle_atletas_resultados_detalle_id_seq; Type: SEQUENCE SET; Schema: public; Owner: atluser
--

SELECT pg_catalog.setval('tb_atletas_resultados_detalle_atletas_resultados_detalle_id_seq', 63, true);


--
-- TOC entry 2617 (class 0 OID 16562)
-- Dependencies: 180
-- Data for Name: tb_atletas_resultados_old; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY tb_atletas_resultados_old (atletas_resultados_id, atletas_codigo, competencias_codigo, pruebas_codigo, atletas_resultados_fecha, atletas_resultados_resultado, atletas_resultados_viento, atletas_resultados_puesto, atletas_resultados_manual, atletas_resultados_altura, atletas_resultados_invalida, atletas_resultados_observaciones, atletas_resultados_protected, atletas_resultados_origen, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion, competencias_pruebas_id) FROM stdin;
29	46134708	BOL2013	SLLARGOMMY	2013-12-12	5.45	4.00	1	f	f	f		f	D	t	TESTUSER	2014-04-06 12:16:54.971535	\N	\N	0
37	46658908	SOP2014	HEPTAFMY	2014-03-07	7220	\N	1	f	f	f	test	f	D	t	TESTUSER	2014-04-21 05:03:56.461002	atluser	2014-04-21 20:02:38.200465	0
27	46134708	ODESUR2014	100MPMMY	2014-03-01	24.0	3.00	1	t	f	f		f	D	t	TESTUSER	2014-04-06 12:15:39.079933	atluser	2014-04-21 04:45:25.417951	0
34	46658908	ODESUR2014	HEPTAFMY	2014-03-01	7000	\N	1	f	f	f		f	D	t	TESTUSER	2014-04-07 18:03:56.052075	atluser	2014-04-21 20:03:09.761642	0
36	46658908	GPBIRIARTE	HEPTAFMY	2013-05-10	800	\N	1	f	f	f		f	D	t	TESTUSER	2014-04-21 03:45:17.210493	atluser	2014-04-21 14:50:09.292711	0
9	46658908	GPBIRIARTE	100MVFMY	2013-05-10	17.3	1.00	1	t	f	f	kkkk	f	D	t	TESTUSER	2014-03-31 00:48:19.949326	atluser	2014-04-25 22:00:05.841288	0
26	46658908	GPBIRIARTE	100MPFMY	2013-05-10	10.2	2.50	\N	t	t	f		f	D	t	TESTUSER	2014-04-05 18:19:55.304615	atluser	2014-04-25 22:08:20.931567	0
19	46658908	GPBIRIARTE	SLLARGOFMY	2013-05-10	4.58	1.00	1	f	t	f		f	D	t	TESTUSER	2014-03-31 16:43:01.437273	atluser	2014-04-26 02:57:20.432223	0
32	46134708	GPBIRIARTE	100MPMMY	2013-05-10	12.28	1.00	1	f	f	f		f	D	t	TESTUSER	2014-04-07 03:18:29.274498	atluser	2014-04-26 03:10:18.998461	0
20	46134708	BOL2013	SLALTOMMY	2013-12-12	2.36	\N	1	f	f	f		f	D	t	TESTUSER	2014-03-31 16:47:26.402758	atluser	2014-04-26 14:55:10.453303	0
33	46658908	SOP2014	800MPFMY	2014-03-07	2.19.00	\N	1	f	f	f		f	D	t	TESTUSER	2014-04-07 17:48:21.564218	\N	\N	0
\.


--
-- TOC entry 2618 (class 0 OID 16575)
-- Dependencies: 181
-- Data for Name: tb_categorias; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY tb_categorias (categorias_codigo, categorias_descripcion, categorias_edad_inicial, categorias_edad_final, categorias_valido_desde, categorias_validacion, categorias_protected, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
JUV	Juveniles	18	19	1940-01-01	JUV	t	t	TESTUSER	2014-03-03 14:28:52.910569	postgres	2014-03-06 02:23:24.384389
TOD	Todas	11	45	1940-01-01	TOD	t	t	TESTUSER	2014-03-03 14:30:06.501183	postgres	2014-03-06 02:23:24.384389
MEN	Menores	15	17	1940-01-01	MEN	t	t	TESTUSER	2014-03-03 14:28:23.006005	TESTUSER	2014-03-06 02:23:24.384389
MAY	Mayores	20	35	1940-01-01	MAY	t	t	TESTUSER	2014-03-03 14:29:25.594981	TESTUSER	2014-03-06 02:23:24.384389
SUB23	Sub 23	20	22	1940-01-01	S23	t	t	TESTUSER	2014-03-03 14:29:48.95104	TESTUSER	2014-03-06 02:23:24.384389
CADE	Cadetes	13	14	1940-01-01	CAD	t	t	TESTUSER	2014-03-05 21:13:15.806671	TESTUSER	2014-03-11 12:59:45.692438
INF	Infantil	11	12	1940-01-01	INF	t	t	TESTUSER	2014-03-05 21:14:00.037012	TESTUSER	2014-03-11 12:59:47.462269
\.


--
-- TOC entry 2619 (class 0 OID 16581)
-- Dependencies: 182
-- Data for Name: tb_ciudades; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY tb_ciudades (ciudades_codigo, ciudades_descripcion, paises_codigo, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion, ciudades_altura) FROM stdin;
LIM	Lima	PER	t	TESTUSER	2014-01-15 17:31:24.272057	TESTUSER	2014-01-15 17:53:38.778161	f
TRU	Trujillo	PER	t	TESTUSER	2014-01-15 17:37:59.111946	TESTUSER	2014-01-15 17:53:46.405956	f
SCHI	Santiago de Chile	CHI	t	TESTUSER	2014-01-15 17:57:26.057761	\N	\N	f
DON	Doneskt	UKR	t	TESTUSER	2014-03-05 21:53:57.846678	\N	\N	f
SOP	Sopot	POL	t	TESTUSER	2014-03-07 04:03:17.038401	\N	\N	f
LPAZ	La Paz	BOL	t	TESTUSER	2014-04-25 19:31:58.761949	\N	\N	t
BARIN	Barinas	VEN	t	TESTUSER	2014-03-18 23:09:33.935852	TESTUSER	2014-05-29 04:45:25.17325	f
OTT	Ottawa	CAN	t	TESTUSER	2014-07-16 15:33:33.933375	\N	\N	f
ORG	Oregon	USA	t	TESTUSER	2014-07-26 12:07:38.106143	\N	\N	f
CMDF	Ciudad De Mexico	MEX	t	TESTUSER	2014-07-27 20:59:53.334892	\N	\N	t
ARI	Arica	CHI	t	TESTUSER	2014-07-27 22:41:29.785374	\N	\N	f
BOG	Bogota	COL	t	TESTUSER	2014-07-27 23:01:25.592757	\N	\N	t
MUN	Munich	GER	t	TESTUSER	2014-07-28 21:26:08.699639	\N	\N	f
PMA	Palma de Mallorca	ESP	t	TESTUSER	2014-07-28 21:39:19.38885	\N	\N	f
SAO	Sao Paulo	BRA	t	TESTUSER	2014-08-01 13:43:55.071158	\N	\N	f
CUEN	Cuenca	ECU	t	TESTUSER	2015-03-14 12:30:45.866155	\N	\N	t
MONT	Montevideo	URU	t	TESTUSER	2015-03-14 16:50:26.951072	\N	\N	f
COR	Cordova	ARG	t	TESTUSER	2014-01-15 17:58:01.517872	TESTUSER	2016-02-08 02:01:37.447632	f
ASU	Asuncion	PAR	t	TESTUSER	2015-04-19 19:24:47.551946	TESTUSER	2016-02-08 16:52:09.286009	f
STK	Estocolmo	SWE	t	TESTUSER	2016-05-02 17:00:15.510201	\N	\N	f
\.


--
-- TOC entry 2620 (class 0 OID 16586)
-- Dependencies: 183
-- Data for Name: tb_clubes; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY tb_clubes (clubes_codigo, clubes_descripcion, clubes_persona_contacto, clubes_telefono_oficina, clubes_telefono_celular, clubes_email, clubes_direccion, clubes_web_url, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
JOWENS	Club De Atletismo JESSE OWENS	Carlos Arana Reategui	2349247	993786532	aranape@gmail.com.pe	xxxx 300300gsg	http://www.jesseowens.com.pe	t	TESTUSER	2014-02-17 17:55:19.762563	TESTUSER	2014-03-05 21:18:36.53791
AVIA	Club De Atletismo Avia	Marita Letts				SURCO		t	TESTUSER	2014-03-05 21:23:43.131571	\N	\N
SYRSA	Club de Atletismo SYRSA	Marita Letts				surco		t	TESTUSER	2014-03-05 21:31:45.516033	TESTUSER	2014-03-05 21:31:54.402111
NOCON	No Conocidos	????				????		t	TESTUSER	2014-03-05 22:07:40.405955	\N	\N
ALBORADA	Club Alborada	Oscar y Marcial Zuñiga Parra				N/C		t	TESTUSER	2014-07-16 15:35:51.084452	\N	\N
CCANG	Club Canguros Valiente	Oscar Valiente / Fernando Valiente				Por Definir		t	TESTUSER	2014-03-05 21:21:51.326401	TESTUSER	2016-02-11 00:09:46.217774
\.


--
-- TOC entry 2621 (class 0 OID 16593)
-- Dependencies: 184
-- Data for Name: tb_clubes_atletas; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY tb_clubes_atletas (clubesatletas_id, clubes_codigo, atletas_codigo, clubesatletas_desde, clubesatletas_hasta, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
7	ALBORADA	10307755	2012-01-01	2035-01-01	t	TESTUSER	2014-07-16 15:39:07.275625	TESTUSER	2016-02-11 02:56:12.25852
8	CCANG	70424527	2010-01-01	2011-01-01	t	TESTUSER	2016-02-10 21:48:24.234373	TESTUSER	2016-02-11 11:43:39.39831
\.


--
-- TOC entry 2701 (class 0 OID 0)
-- Dependencies: 185
-- Name: tb_clubes_atletas_clubesatletas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: atluser
--

SELECT pg_catalog.setval('tb_clubes_atletas_clubesatletas_id_seq', 13, true);


--
-- TOC entry 2623 (class 0 OID 16599)
-- Dependencies: 186
-- Data for Name: tb_competencia_tipo; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY tb_competencia_tipo (competencia_tipo_codigo, competencia_tipo_descripcion, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
MUN	Mundial	t	TESTUSER	2014-02-19 04:05:07.388753	\N	\N
GPRIX	Gran Prix	t	TESTUSER	2014-02-19 04:06:50.210692	\N	\N
NAC	Nacional	t	TESTUSER	2014-02-19 04:07:28.815042	\N	\N
OLIM	Olimpiadas	t	TESTUSER	2014-02-19 04:05:58.088152	TESTUSER	2014-03-05 23:22:44.410609
PANAM	Panamericanos	t	TESTUSER	2014-03-05 23:23:03.660655	\N	\N
BOL	Bolivarianos	t	TESTUSER	2014-03-05 23:23:28.096861	\N	\N
ODES	Odesur	t	TESTUSER	2014-03-05 23:23:46.025479	\N	\N
IBERO	Iberoamericano	t	TESTUSER	2014-08-01 13:42:24.331214	\N	\N
CTROL	Control Evaluativo	t	TESTUSER	2015-04-26 17:03:00.847058	\N	\N
SUDA	Sud Americano	t	TESTUSER	2014-02-19 04:06:26.558116	TESTUSER	2016-02-22 01:30:58.68104
\.


--
-- TOC entry 2624 (class 0 OID 16603)
-- Dependencies: 187
-- Data for Name: tb_competencias; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY tb_competencias (competencias_codigo, competencias_descripcion, competencia_tipo_codigo, categorias_codigo, paises_codigo, ciudades_codigo, competencias_fecha_inicio, competencias_fecha_final, competencias_es_oficial, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion, competencias_clasificacion) FROM stdin;
MUN2013ME	Mundial De Menores 2013	MUN	MEN	UKR	DON	2013-07-01	2013-07-02	f	t	TESTUSER	2014-03-05 21:56:32.476406	TESTUSER	2014-06-30 18:49:26.614419	O
ODESUR2014	ODESUR 2014	ODES	MAY	CHI	SCHI	2014-03-01	2014-03-16	f	t	TESTUSER	2014-03-16 05:05:25.543289	TESTUSER	2014-06-30 18:49:05.873404	O
SOP2014	SOPOT Indoor 2014	MUN	MAY	POL	SOP	2014-03-07	2014-03-09	f	t	TESTUSER	2014-03-07 04:05:00.392897	TESTUSER	2014-07-01 16:49:09.297073	I
PANPC2014M	Panamericano de Pruebas Combinadas	PANAM	MAY	CAN	OTT	2014-07-17	2014-07-18	f	t	TESTUSER	2014-07-16 19:16:32.305292	\N	\N	I
PANPC2014J	Panamericano de Pruebas Combinadas	PANAM	JUV	CAN	OTT	2014-07-16	2014-07-17	f	t	TESTUSER	2014-07-18 17:08:15.170525	\N	\N	I
MUNJV2014	IAAF World Junior Championships 2014	MUN	JUV	USA	ORG	2014-07-22	2014-07-27	f	t	TESTUSER	2014-07-26 12:10:04.037309	\N	\N	O
GPCC2014	Gran Prix Carlos Calmet	GPRIX	MAY	PER	LIM	2014-06-25	2014-06-25	f	t	TESTUSER	2014-07-26 18:46:54.752648	\N	\N	O
GPPGV2014	Gran Prix Pedro Galvez Velarde	GPRIX	MAY	PER	LIM	2014-06-22	2014-06-22	f	t	TESTUSER	2014-07-27 14:44:36.260828	\N	\N	O
GPBIRIARTE	Gran Prix Brigido Iriarte	GPRIX	MAY	VEN	BARIN	2013-05-10	2013-05-11	f	t	TESTUSER	2014-03-18 23:08:36.115572	TESTUSER	2014-07-27 14:45:35.849702	O
PANMEX1975	Panamericanos De Mexico 1975	PANAM	MAY	MEX	CMDF	1975-10-12	1975-10-26	f	t	TESTUSER	2014-07-27 21:02:15.887998	\N	\N	O
SUDAM1999	Sudamericano Colombia 1999	SUDA	MAY	COL	BOG	1999-06-25	1999-06-27	f	t	TESTUSER	2014-07-27 23:03:22.3321	\N	\N	O
NACJUV2014	Nacional Juvenil 2014	NAC	JUV	PER	LIM	2014-05-16	2014-05-18	f	t	TESTUSER	2014-07-28 16:54:39.411333	\N	\N	O
GPMUN1977	Gran Prix Munich 1977	GPRIX	MAY	GER	MUN	1977-06-14	1977-06-14	f	t	TESTUSER	2014-07-28 21:27:22.589176	\N	\N	O
UNIVPM1999	Universiada 1999	MUN	MAY	ESP	PMA	1999-07-03	1999-07-13	f	t	TESTUSER	2014-07-28 21:46:19.421784	\N	\N	O
IBERO2014	Iberoamericano de Sao Paulo 2014	IBERO	MAY	BRA	SAO	2014-08-01	2014-08-03	f	t	TESTUSER	2014-08-01 13:45:28.714072	\N	\N	O
GPCUEN2015	Gran Prix Cuenca 2015	GPRIX	MAY	ECU	CUEN	2015-03-14	2015-03-15	f	t	TESTUSER	2015-03-14 12:52:18.179989	\N	\N	O
S232015	Sudamericano Sub 23 Montevideo	SUDA	SUB23	URU	MONT	2014-05-03	2014-05-05	f	t	TESTUSER	2015-03-14 16:53:15.073492	\N	\N	O
GPORLG2015	Gran Prix Orlando Guayta 2015	GPRIX	MAY	CHI	SCHI	2015-04-10	2015-04-11	f	t	TESTUSER	2015-04-19 20:11:43.169528	\N	\N	O
GPCLIM2015	Grand Prix Ciudad de Lima	GPRIX	MAY	PER	LIM	2015-04-25	2015-04-25	f	t	TESTUSER	2015-04-26 12:18:26.999509	\N	\N	O
GPPGV2015	Gran Prix Pedro Galvez Velarde 2015	GPRIX	MAY	PER	LIM	2015-04-24	2015-04-24	f	t	TESTUSER	2015-04-26 14:45:44.358426	\N	\N	O
CTRL032015	Control Evaluativo 03/2015	CTROL	MEN	PER	LIM	2015-03-11	2015-03-11	f	t	TESTUSER	2015-04-26 17:06:12.206382	\N	\N	O
GPPCOMBASU	Gran Prix Pruebas Combinadas Asuncion 2015	GPRIX	MAY	PAR	ASU	2015-04-11	2015-04-12	f	t	TESTUSER	2015-04-19 19:27:24.243217	TESTUSER	2016-02-25 13:59:53.746583	O
SDQ	qweqew	NAC	MAY	PER	LIM	2016-01-01	2016-02-01	f	t	TESTUSER	2016-02-25 02:57:32.585897	TESTUSER	2016-02-26 01:36:00.768478	O
GPARIC1996	Gran Prix Arica 1996	GPRIX	MAY	CHI	ARI	1996-05-26	1996-05-26	f	t	TESTUSER	2014-07-27 22:43:43.864479		2016-02-26 03:41:51.654001	O
BOL2013	Bolivarianos 2013	BOL	MAY	PER	TRU	2013-11-15	2013-11-30	f	t	TESTUSER	2014-03-05 23:26:19.196013		2016-02-26 03:44:02.378378	O
XXXXX	xxxxx	GPRIX	MAY	PER	LIM	2016-01-01	2016-01-02	f	t	TESTUSER	2016-03-01 14:02:56.062132	\N	\N	O
GPBMPAZ16	Gran Prix Mario Paz Biruet	GPRIX	MAY	BOL	LPAZ	2016-04-22	2016-04-22	f	t	TESTUSER	2016-04-22 12:25:54.027562		2016-04-22 12:29:28.713748	O
OLSWE1912	Olimpiadas Estocolomo 1912	OLIM	MAY	SWE	STK	1912-05-05	1912-07-27	f	t	TESTUSER	2016-05-02 17:02:01.745683	\N	\N	O
\.


--
-- TOC entry 2625 (class 0 OID 16610)
-- Dependencies: 188
-- Data for Name: tb_competencias_pruebas; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY tb_competencias_pruebas (competencias_pruebas_id, competencias_codigo, pruebas_codigo, competencias_pruebas_origen_combinada, competencias_pruebas_fecha, competencias_pruebas_viento, competencias_pruebas_manual, competencias_pruebas_tipo_serie, competencias_pruebas_nro_serie, competencias_pruebas_anemometro, competencias_pruebas_material_reglamentario, competencias_pruebas_observaciones, competencias_pruebas_protected, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion, competencias_pruebas_origen_id) FROM stdin;
96	SOP2014	SLALTOMMY	f	2014-03-07	\N	f	FI	1	t	t		f	t	TESTUSER	2014-05-07 03:35:19.235573	TESTUSER	2014-05-07 04:52:20.465363	\N
912	XXXXX	IBALAFMY	f	2016-01-01	\N	f	FI	1	t	t		f	t	TESTUSER	2016-03-28 01:05:43.190642	\N	\N	\N
914	SDQ	100MVFMYHEP	t	2016-01-01	\N	t	FI	1	f	t		f	t	TESTUSER	2016-03-28 01:52:06.05888	TESTUSER	2016-03-29 04:11:07.219776	913
879	SDQ	SLALTOMMY	f	2016-01-01	\N	f	FI	1	t	t		f	t	TESTUSER	2016-03-20 16:32:45.756243	TESTUSER	2016-03-20 16:41:41.844105	\N
247	GPBIRIARTE	200MPFMY	f	2013-05-10	2.00	t	FI	1	t	t		f	t	TESTUSER	2014-05-30 20:54:52.875641	\N	\N	\N
625	MUNJV2014	300MOBSFJV	f	2014-07-26	\N	f	FI	1	t	t		f	t	TESTUSER	2014-07-27 01:36:39.026511	\N	\N	\N
627	GPPGV2014	3000MOBSFMY	f	2014-06-22	\N	f	FI	1	t	t		f	t	TESTUSER	2014-07-27 14:47:02.888642	\N	\N	\N
631	MUNJV2014	10000MARMMJV	f	2014-07-22	\N	f	FI	1	t	t		f	t	TESTUSER	2014-07-28 16:29:51.814612	\N	\N	\N
642	BOL2013	SLLARGOFMY	f	2013-11-28	\N	f	FI	1	t	t		f	t	TESTUSER	2014-07-28 22:45:20.96353	\N	\N	\N
643	IBERO2014	3000MOBSFMY	f	2014-08-01	\N	f	FI	1	t	t		f	t	TESTUSER	2014-08-01 18:00:37.596604	\N	\N	\N
645	IBERO2014	100MPMMY	f	2014-08-01	0.60	f	FI	1	t	t		f	t	TESTUSER	2014-08-02 17:51:35.218898	\N	\N	\N
854	XXXXX	400MPFMY	f	2016-01-01	\N	f	FI	1	t	t	test	f	t	TESTUSER	2016-03-18 03:25:01.6442	TESTUSER	2016-03-18 13:43:18.543509	\N
877	XXXXX	SLALTOMMY	f	2016-01-01	\N	f	FI	1	t	t		f	t	TESTUSER	2016-03-19 15:47:11.752565	\N	\N	\N
641	UNIVPM1999	SLLARGOFMY	f	1999-07-12	\N	f	SM	1	t	t	Se desconoce el viento se sabe fue correcto	f	t	TESTUSER	2014-07-28 22:10:49.166631	TESTUSER	2016-03-18 17:21:30.455559	\N
629	GPARIC1996	SLLARGOFMY	f	1996-05-26	\N	f	FI	1	t	t	No se conoce el viento pero se sabe que fue valido	f	t	TESTUSER	2014-07-27 22:45:10.238465	TESTUSER	2016-03-20 14:29:10.460798	\N
628	PANMEX1975	SLLARGOFMY	f	1975-10-12	\N	f	FI	1	t	t	No se conoce el viento real , se sabe que fue legal	f	t	TESTUSER	2014-07-27 21:12:12.354983	TESTUSER	2014-07-27 21:34:21.424088	\N
640	GPMUN1977	SLLARGOFMY	f	1977-06-14	\N	f	FI	1	t	t	No se tiene el viento pero se sabe que fue legal.	f	t	TESTUSER	2014-07-28 21:28:21.240928	TESTUSER	2016-03-20 14:19:18.577342	\N
630	SUDAM1999	SLLARGOFMY	f	1999-06-25	\N	f	SM	1	t	t	No se conoce el viento pero se sabe que fue reglamentario	f	t	TESTUSER	2014-07-28 03:11:37.207778	TESTUSER	2016-03-20 14:29:04.727622	\N
533	ODESUR2014	200MPFMY	f	2014-03-01	2.00	t	FI	1	t	t		f	t	TESTUSER	2014-06-07 02:54:22.394027	TESTUSER	2014-06-07 02:54:51.500813	\N
633	NACJUV2014	100MVFJVHEP	t	2014-05-16	-1.30	f	FI	1	t	t		f	t	TESTUSER	2014-07-28 16:58:35.082982	TESTUSER	2016-03-15 12:15:14.427666	632
624	MUNJV2014	300MOBSFJV	f	2014-07-22	\N	f	SM	1	t	t		f	t	TESTUSER	2014-07-26 15:05:47.826234	\N	\N	\N
195	GPBIRIARTE	100MPMMY	f	2013-05-10	3.00	t	SM	7	t	t		f	t	TESTUSER	2014-05-23 16:53:25.383245	TESTUSER	2014-05-24 04:28:53.059496	\N
197	GPBIRIARTE	100MPMMY	f	2013-05-10	2.50	f	SM	5	t	t		f	t	TESTUSER	2014-05-23 17:08:37.891251	TESTUSER	2014-05-24 04:34:02.304046	\N
204	GPBIRIARTE	100MPMMY	f	2013-05-10	3.00	t	HT	1	t	t		f	t	TESTUSER	2014-05-24 04:34:27.79928	\N	\N	\N
632	NACJUV2014	HEPTAFJV	f	2014-05-16	\N	f	FI	1	t	t		f	t	TESTUSER	2014-07-28 16:58:35.082982	atluser	2016-03-15 12:15:14.427666	\N
634	NACJUV2014	SALTOFJVHEP	t	2014-05-16	\N	f	FI	1	t	t		f	t	TESTUSER	2014-07-28 16:58:35.082982	TESTUSER	2014-07-28 16:59:26.55692	632
567	BOL2013	SALTOFMYHEP	t	2013-11-28	\N	f	FI	1	t	t		f	t	TESTUSER	2014-07-16 16:38:25.029369	TESTUSER	2014-07-28 22:40:43.877491	565
635	NACJUV2014	IBALAFJVHEP	t	2014-05-16	\N	f	FI	1	t	t		f	t	TESTUSER	2014-07-28 16:58:35.082982	TESTUSER	2014-07-28 16:59:42.038764	632
491	GPBIRIARTE	JABALFMY	f	2013-05-10	\N	f	FI	1	t	t		f	t	TESTUSER	2014-06-03 22:09:28.371387	\N	\N	\N
568	BOL2013	IBALAFMYHEP	t	2013-11-28	\N	f	FI	1	t	t		f	t	TESTUSER	2014-07-16 16:38:25.029369	TESTUSER	2014-07-28 22:40:51.99181	565
636	NACJUV2014	200MPFJVHEP	t	2014-05-16	0.00	f	FI	1	t	t		f	t	TESTUSER	2014-07-28 16:58:35.082982	TESTUSER	2014-07-28 17:00:15.975446	632
637	NACJUV2014	SLARGOFJVHEP	t	2014-05-17	\N	f	FI	1	t	t		f	t	TESTUSER	2014-07-28 16:58:35.082982	TESTUSER	2014-07-28 17:00:41.783238	632
638	NACJUV2014	JABALFJVHEP	t	2014-05-17	\N	f	FI	1	t	t		f	t	TESTUSER	2014-07-28 16:58:35.082982	TESTUSER	2014-07-28 17:01:12.930891	632
571	BOL2013	JABALFMYHEP	t	2013-11-29	\N	f	FI	1	t	t		f	t	TESTUSER	2014-07-16 16:38:25.029369	TESTUSER	2014-07-28 22:41:15.799022	565
639	NACJUV2014	800MPFJVHEP	t	2014-05-17	\N	f	FI	1	t	t		f	t	TESTUSER	2014-07-28 16:58:35.082982	TESTUSER	2014-07-28 17:01:31.360077	632
873	XXXXX	1500MPFMY	f	2016-01-01	\N	f	FI	1	t	t		f	t	TESTUSER	2016-03-19 00:00:30.33452	TESTUSER	2016-03-20 15:43:36.831787	\N
569	BOL2013	200MPFMYHEP	t	2013-11-28	-1.10	f	FI	1	t	t		f	t	TESTUSER	2014-07-16 16:38:25.029369	TESTUSER	2016-02-17 23:47:38.406094	565
607	PANPC2014J	200MPFJVHEP	t	2014-07-16	1.80	f	FI	1	t	t		f	t	TESTUSER	2014-07-18 17:11:05.352493	TESTUSER	2016-03-15 12:34:22.07976	603
852	XXXXX	400MVFMY	f	2016-01-01	\N	t	FI	1	t	t		f	t	TESTUSER	2016-03-18 02:59:54.858396	TESTUSER	2016-03-20 16:04:05.266723	\N
626	GPCC2014	3000MOBSFMY	f	2014-06-25	\N	f	FI	1	f	t	yrtyyt	f	t	TESTUSER	2014-07-27 14:16:34.798897	TESTUSER	2016-03-17 01:43:46.646752	\N
883	SDQ	200MPFMY	f	2016-01-01	\N	f	FI	1	f	t		f	t	TESTUSER	2016-03-20 16:49:51.654928	TESTUSER	2016-03-21 16:45:16.146645	\N
573	PANPC2014M	HEPTAFMY	f	2014-07-17	\N	f	FI	1	t	t		f	t	TESTUSER	2014-07-16 19:16:49.62012	TESTUSER	2016-03-09 18:10:27.17566	\N
574	PANPC2014M	100MVFMYHEP	t	2014-07-17	2.20	f	FI	1	t	t	false	f	t	TESTUSER	2014-07-16 19:16:49.62012	TESTUSER	2014-07-17 09:50:46.067309	573
575	PANPC2014M	SALTOFMYHEP	t	2014-07-17	0.00	f	FI	1	t	t	\N	f	t	TESTUSER	2014-07-16 19:16:49.62012	TESTUSER	2016-03-09 18:10:27.17566	573
576	PANPC2014M	IBALAFMYHEP	t	2014-07-17	0.00	f	FI	1	t	t	\N	f	t	TESTUSER	2014-07-16 19:16:49.62012	TESTUSER	2016-03-09 18:10:27.17566	573
577	PANPC2014M	200MPFMYHEP	t	2014-07-17	0.00	f	FI	1	t	t	\N	f	t	TESTUSER	2014-07-16 19:16:49.62012	TESTUSER	2016-03-09 18:10:27.17566	573
578	PANPC2014M	SLARGOFMYHEP	t	2014-07-17	0.00	f	FI	1	t	t	\N	f	t	TESTUSER	2014-07-16 19:16:49.62012	TESTUSER	2016-03-09 18:10:27.17566	573
579	PANPC2014M	JABALFMYHEP	t	2014-07-17	0.00	f	FI	1	t	t	\N	f	t	TESTUSER	2014-07-16 19:16:49.62012	TESTUSER	2016-03-09 18:10:27.17566	573
889	SDQ	SGARROCHAMMY	f	2016-01-01	\N	f	FI	1	t	t		f	t	TESTUSER	2016-03-21 04:58:34.637645	\N	\N	\N
885	SDQ	400MPFMY	f	2016-01-01	\N	f	SR	1	t	t	xxxxxxxx	f	t	TESTUSER	2016-03-20 16:56:24.589979	TESTUSER	2016-03-21 04:18:42.239387	\N
887	SDQ	800MPFMY	f	2016-01-01	\N	f	FI	1	t	t		f	t	TESTUSER	2016-03-21 04:53:32.455231	\N	\N	\N
881	SDQ	100MVFMY	f	2016-01-01	2.00	f	FI	1	t	t	rertertreter sfewrwr sfdsfsdf	f	t	TESTUSER	2016-03-20 16:43:31.382639	TESTUSER	2016-03-21 17:52:20.954796	\N
605	PANPC2014J	SALTOFJVHEP	t	2014-07-16	\N	f	FI	1	t	t		f	t	TESTUSER	2014-07-18 17:11:05.352493	TESTUSER	2014-07-18 17:11:36.932776	603
606	PANPC2014J	IBALAFJVHEP	t	2014-07-16	\N	f	FI	1	t	t		f	t	TESTUSER	2014-07-18 17:11:05.352493	TESTUSER	2014-07-18 17:11:50.920194	603
609	PANPC2014J	JABALFJVHEP	t	2014-07-17	\N	f	FI	1	t	t		f	t	TESTUSER	2014-07-18 17:11:05.352493	TESTUSER	2014-07-18 17:13:03.397934	603
610	PANPC2014J	800MPFJVHEP	t	2014-07-17	\N	f	FI	1	t	t		f	t	TESTUSER	2014-07-18 17:11:05.352493	TESTUSER	2014-07-18 17:13:22.259515	603
891	XXXXX	100MPFMY	f	2016-01-01	\N	f	SR	1	f	t		f	t	TESTUSER	2016-03-21 17:54:52.644148	\N	\N	\N
871	XXXXX	100MVFMY	f	2016-01-01	3.00	f	SR	3	t	f	utyu6utyu	f	t	TESTUSER	2016-03-18 23:50:01.084908	TESTUSER	2016-03-22 18:23:16.259894	\N
895	XXXXX	SLLARGOMMY	f	2016-01-01	\N	f	SM	1	t	t		f	t	TESTUSER	2016-03-23 00:18:16.227865	\N	\N	\N
901	XXXXX	SLLARGOMMY	f	2016-01-01	\N	f	SR	1	t	t		f	t	TESTUSER	2016-03-23 00:36:28.369266	\N	\N	\N
905	XXXXX	SLLARGOMMY	f	2016-01-01	\N	f	SR	9	t	t		f	t	TESTUSER	2016-03-23 14:13:57.057312	\N	\N	\N
907	XXXXX	3000MOBSFMY	f	2016-01-01	\N	f	SR	1	t	t		f	t	TESTUSER	2016-03-23 14:21:04.057099	\N	\N	\N
572	BOL2013	800MPFMYHEP	t	2013-11-29	\N	f	FI	1	t	t		f	t	TESTUSER	2014-07-16 16:38:25.029369	TESTUSER	2014-07-28 22:41:21.795285	565
648	GPCUEN2015	400MPFMY	f	2015-03-14	0.00	f	FI	1	t	t	Record Nacional Sub 23 y Mayores	f	t	TESTUSER	2015-03-14 16:31:52.311957	\N	\N	\N
650	S232015	400MVFS23	f	2014-05-05	\N	f	FI	1	t	t		f	t	TESTUSER	2015-03-14 17:01:01.717668	\N	\N	\N
651	GPCUEN2015	SLLARGOFMY	f	2015-03-15	\N	f	FI	1	t	t		f	t	TESTUSER	2015-03-15 17:54:47.066594	TESTUSER	2015-03-15 17:55:40.783741	\N
654	GPPCOMBASU	SALTOFMYHEP	t	2015-04-11	\N	f	FI	1	t	t		f	t	TESTUSER	2015-04-19 19:28:09.780435	TESTUSER	2015-04-19 19:32:52.337993	652
655	GPPCOMBASU	IBALAFMYHEP	t	2015-04-11	\N	f	FI	1	t	t		f	t	TESTUSER	2015-04-19 19:28:09.780435	TESTUSER	2015-04-19 19:33:07.661453	652
656	GPPCOMBASU	200MPFMYHEP	t	2015-04-11	-1.10	f	FI	1	t	t		f	t	TESTUSER	2015-04-19 19:28:09.780435	TESTUSER	2015-04-19 19:33:35.035804	652
658	GPPCOMBASU	JABALFMYHEP	t	2015-04-11	\N	f	FI	1	t	t		f	t	TESTUSER	2015-04-19 19:28:09.780435	TESTUSER	2015-04-19 19:34:37.414615	652
659	GPPCOMBASU	800MPFMYHEP	t	2015-04-11	\N	f	FI	1	t	t		f	t	TESTUSER	2015-04-19 19:28:09.780435	TESTUSER	2015-04-19 19:34:56.151349	652
660	GPORLG2015	SLLARGOFMY	f	2015-04-11	\N	f	FI	1	t	t		f	t	TESTUSER	2015-04-19 20:12:25.326492	\N	\N	\N
661	GPCLIM2015	200MPMMY	f	2015-04-25	0.30	f	FI	1	t	t	Record Nacional Sub 23	f	t	TESTUSER	2015-04-26 12:23:36.297155	\N	\N	\N
674	GPPGV2015	400MPFMY	f	2015-04-24	\N	f	FI	1	t	t		f	t	TESTUSER	2015-04-26 14:53:13.20512	\N	\N	\N
675	CTRL032015	SGARROCHAMME	f	2015-03-11	\N	f	FI	1	t	t		f	t	TESTUSER	2015-04-26 17:06:30.200271	\N	\N	\N
662	GPCLIM2015	SLLARGOFMY	f	2015-04-25	\N	f	FI	1	t	t	Record Nacional Absoluto	f	t	TESTUSER	2015-04-26 12:40:05.470178	TESTUSER	2015-04-26 12:43:40.098072	\N
647	GPCUEN2015	SLALTOFMY	f	2015-03-14	\N	f	FI	1	t	t	Record  de menores y juveniles	f	t	TESTUSER	2015-03-14 15:39:01.10463	TESTUSER	2015-03-14 15:42:17.511566	\N
898	XXXXX	SLLARGOMMY	f	2016-01-01	\N	f	FI	1	t	t		f	t	TESTUSER	2016-03-23 00:29:16.535966	TESTUSER	2016-03-25 23:43:12.492317	\N
791	GPBIRIARTE	SGARROCHAMMY	f	2013-05-10	\N	f	FI	1	t	t	tryrty	f	t	TESTUSER	2016-03-10 13:28:27.208087	\N	\N	\N
548	GPBIRIARTE	HEPTAFMY	f	2013-05-10	\N	f	FI	1	t	t		f	t	TESTUSER	2014-07-16 15:16:33.816929	TESTUSER	2016-03-09 23:57:39.788692	\N
553	GPBIRIARTE	SLARGOFMYHEP	t	2013-05-11	\N	f	FI	1	t	t		f	t	TESTUSER	2014-07-16 15:16:33.816929	TESTUSER	2014-07-16 16:55:30.993895	548
554	GPBIRIARTE	JABALFMYHEP	t	2013-05-11	\N	f	FI	1	t	t		f	t	TESTUSER	2014-07-16 15:16:33.816929	TESTUSER	2014-07-16 16:55:36.252744	548
555	GPBIRIARTE	800MPFMYHEP	t	2013-05-11	\N	f	FI	1	t	t		f	t	TESTUSER	2014-07-16 15:16:33.816929	TESTUSER	2014-07-16 16:55:42.307548	548
550	GPBIRIARTE	SALTOFMYHEP	t	2013-05-10	0.00	f	FI	1	t	t	\N	f	t	TESTUSER	2014-07-16 15:16:33.816929	TESTUSER	2016-03-09 18:20:43.196465	548
551	GPBIRIARTE	IBALAFMYHEP	t	2013-05-10	0.00	f	FI	1	t	t	\N	f	t	TESTUSER	2014-07-16 15:16:33.816929	TESTUSER	2016-03-09 18:20:43.196465	548
552	GPBIRIARTE	200MPFMYHEP	t	2013-05-10	0.00	f	FI	1	t	t	\N	f	t	TESTUSER	2014-07-16 15:16:33.816929	TESTUSER	2016-03-09 18:20:43.196465	548
549	GPBIRIARTE	100MVFMYHEP	t	2013-05-10	0.00	f	FI	1	t	t		f	t	TESTUSER	2014-07-16 15:16:33.816929	TESTUSER	2016-03-09 12:25:11.892059	548
793	GPBIRIARTE	100MPMMY	f	2013-05-10	2.50	f	SM	1	t	t		f	t	TESTUSER	2016-03-10 13:34:50.375272	\N	\N	\N
906	XXXXX	100MVFMY	f	2016-01-01	3.00	f	FI	1	t	t		f	t	TESTUSER	2016-03-23 14:15:04.97606	TESTUSER	2016-03-28 04:32:50.233769	\N
566	BOL2013	100MVFMYHEP	t	2013-11-28	0.30	f	FI	1	t	t		f	t	TESTUSER	2014-07-16 16:38:25.029369	TESTUSER	2014-07-28 22:40:25.366098	565
884	SDQ	200MPMMY	f	2016-01-01	2.00	f	HT	1	t	t		f	t	TESTUSER	2016-03-20 16:53:54.104873	TESTUSER	2016-03-29 03:44:30.424102	\N
790	GPBIRIARTE	SLLARGOMMY	f	2013-05-10	\N	f	FI	1	t	t	tyyu	f	t	TESTUSER	2016-03-10 13:22:17.83176	\N	\N	\N
794	GPBIRIARTE	200MPMMY	f	2013-05-10	-3.00	f	FI	1	t	t		f	t	TESTUSER	2016-03-10 13:55:52.528913	TESTUSER	2016-03-10 14:09:38.66608	\N
863	XXXXX	HEPTAFMY	f	2016-01-01	\N	f	FI	1	f	t	test 2	f	t	TESTUSER	2016-03-18 13:50:33.342962	TESTUSER	2016-03-30 14:24:48.619246	\N
861	XXXXX	3000MOBSFMY	f	2016-01-01	\N	f	FI	1	t	t		f	t	TESTUSER	2016-03-18 13:38:14.094751	\N	\N	\N
855	XXXXX	800MPFMY	f	2016-01-01	\N	f	FI	1	t	t		f	t	TESTUSER	2016-03-18 03:28:18.628588	TESTUSER	2016-03-18 13:43:30.132692	\N
801	XXXXX	200MPMMY	f	2016-01-01	-100.00	f	FI	1	t	t		f	t	TESTUSER	2016-03-10 14:43:23.970463	\N	\N	\N
570	BOL2013	SLARGOFMYHEP	t	2013-11-29	\N	f	FI	1	t	t		f	t	TESTUSER	2014-07-16 16:38:25.029369	TESTUSER	2014-12-27 14:01:19.411617	565
565	BOL2013	HEPTAFMY	f	2013-11-28	\N	f	FI	1	t	t		f	t	TESTUSER	2014-07-16 16:38:25.029369	TESTUSER	2014-12-27 14:01:19.411617	\N
653	GPPCOMBASU	100MVFMYHEP	t	2015-04-11	0.90	f	FI	1	t	t		f	t	TESTUSER	2015-04-19 19:28:09.780435	TESTUSER	2015-04-19 19:32:23.938427	652
657	GPPCOMBASU	SLARGOFMYHEP	t	2015-04-11	\N	f	FI	1	t	t		f	t	TESTUSER	2015-04-19 19:28:09.780435	TESTUSER	2016-03-15 12:41:15.878566	652
580	PANPC2014M	800MPFMYHEP	t	2014-07-17	0.00	f	FI	1	t	t	\N	f	t	TESTUSER	2014-07-16 19:16:49.62012	TESTUSER	2016-03-09 18:10:27.17566	573
867	XXXXX	200MPFMYHEP	t	2016-01-01	-1.50	f	FI	1	t	t		f	t	TESTUSER	2016-03-18 13:50:33.342962	TESTUSER	2016-03-19 04:36:32.388135	863
604	PANPC2014J	100MVFJVHEP	t	2014-07-16	2.60	f	FI	1	t	t		f	t	TESTUSER	2014-07-18 17:11:05.352493	TESTUSER	2014-12-27 14:15:41.686707	603
608	PANPC2014J	SLARGOFJVHEP	t	2014-07-17	\N	f	FI	1	t	t		f	t	TESTUSER	2014-07-18 17:11:05.352493	TESTUSER	2014-07-18 17:12:39.365828	603
870	XXXXX	800MPFMYHEP	t	2016-01-01	\N	f	FI	1	t	t		f	t	TESTUSER	2016-03-18 13:50:33.342962	TESTUSER	2016-03-19 03:20:59.181577	863
872	XXXXX	3000MOBSFMY	f	2016-01-01	\N	f	HT	1	t	t		f	t	TESTUSER	2016-03-18 23:53:35.132664	\N	\N	\N
869	XXXXX	JABALFMYHEP	t	2016-01-01	\N	f	FI	1	t	t		f	t	TESTUSER	2016-03-18 13:50:33.342962	TESTUSER	2016-03-19 03:31:58.250326	863
878	XXXXX	SGARROCHAMMY	f	2016-01-01	\N	f	FI	1	t	t		f	t	TESTUSER	2016-03-19 15:51:30.254129	\N	\N	\N
866	XXXXX	IBALAFMYHEP	t	2016-01-01	\N	f	FI	1	t	t		f	t	TESTUSER	2016-03-18 13:50:33.342962	TESTUSER	2016-03-19 00:13:50.666141	863
851	XXXXX	200MPFMY	f	2016-01-02	2.60	f	FI	1	t	t		f	t	TESTUSER	2016-03-18 02:42:06.302694	TESTUSER	2016-03-19 18:22:22.979831	\N
874	XXXXX	100MPFMY	f	2016-01-01	\N	f	HT	1	f	t		f	t	TESTUSER	2016-03-19 04:59:43.861246	TESTUSER	2016-03-19 18:55:31.227189	\N
865	XXXXX	SALTOFMYHEP	t	2016-01-01	\N	f	FI	1	t	t		f	t	TESTUSER	2016-03-18 13:50:33.342962	TESTUSER	2016-03-19 00:12:35.317581	863
603	PANPC2014J	HEPTAFJV	f	2014-07-16	\N	f	FI	1	t	t		f	t	TESTUSER	2014-07-18 17:11:05.352493	TESTUSER	2016-03-15 12:34:22.07976	\N
652	GPPCOMBASU	HEPTAFMY	f	2015-04-11	\N	f	FI	1	t	t		f	t	TESTUSER	2015-04-19 19:28:09.780435	atluser	2016-03-15 12:41:15.878566	\N
888	SDQ	IBALAFMY	f	2016-01-01	\N	f	FI	1	t	t	dfsdfsd	f	t	TESTUSER	2016-03-21 04:54:38.531458	\N	\N	\N
892	SDQ	200MPFMY	f	2016-01-01	2.00	f	SR	1	t	t		f	t	TESTUSER	2016-03-22 00:57:50.714696	\N	\N	\N
880	SDQ	1500MPFMY	f	2016-02-01	\N	t	FI	1	t	t	sdsdfsdf	f	t	TESTUSER	2016-03-20 16:37:21.786637	TESTUSER	2016-03-22 00:32:27.601111	\N
886	SDQ	3000MOBSFMY	f	2016-01-02	\N	f	FI	1	t	t	dddddd	f	t	TESTUSER	2016-03-21 04:34:20.455613	TESTUSER	2016-03-21 13:28:23.635998	\N
644	IBERO2014	100MPMMY	f	2014-08-01	-0.20	t	SM	1	t	t		f	t	TESTUSER	2014-08-02 17:45:35.458328	TESTUSER	2016-03-22 00:58:18.560422	\N
864	XXXXX	100MVFMYHEP	t	2016-01-01	2.00	f	FI	1	t	t		f	t	TESTUSER	2016-03-18 13:50:33.342962	TESTUSER	2016-03-25 19:54:17.828832	863
902	XXXXX	SLLARGOMMY	f	2016-01-01	\N	f	SR	3	t	t		f	t	TESTUSER	2016-03-23 03:33:27.84097	\N	\N	\N
904	XXXXX	SLLARGOMMY	f	2016-01-01	\N	f	SR	4	t	t		f	t	TESTUSER	2016-03-23 04:00:58.475691	\N	\N	\N
849	XXXXX	100MPFMY	f	2016-01-01	3.00	t	FI	1	t	t		f	t	TESTUSER	2016-03-18 02:30:41.714796	TESTUSER	2016-03-25 23:45:32.669067	\N
909	SDQ	SLLARGOMMY	f	2016-01-01	\N	f	SM	1	t	t		f	t	TESTUSER	2016-03-25 03:16:32.876223	\N	\N	\N
911	SDQ	SLLARGOMMY	f	2016-01-01	\N	f	SM	2	f	t		f	t	TESTUSER	2016-03-25 04:55:00.154468	TESTUSER	2016-03-25 04:57:29.725619	\N
921	SDQ	100MPMMY	f	2016-01-01	\N	t	FI	1	t	t		f	t	TESTUSER	2016-03-29 00:55:32.176658	TESTUSER	2016-03-29 00:55:39.252815	\N
922	SDQ	200MPMMY	f	2016-01-01	2.00	t	FI	1	t	t		f	t	TESTUSER	2016-03-29 03:14:20.527584	TESTUSER	2016-03-29 03:15:05.048916	\N
923	SDQ	200MPMMY	f	2016-01-01	2.00	f	SR	1	t	t		f	t	TESTUSER	2016-03-29 03:42:09.717104	TESTUSER	2016-03-29 03:44:02.685462	\N
917	SDQ	200MPFMYHEP	t	2016-01-01	\N	f	FI	1	t	t	\N	f	t	TESTUSER	2016-03-28 01:52:06.05888	TESTUSER	2016-03-28 01:57:13.673707	913
924	SDQ	200MPMMY	f	2016-01-01	2.00	f	SM	1	t	t		f	t	TESTUSER	2016-03-29 03:56:11.188948	TESTUSER	2016-03-29 03:56:23.700195	\N
919	SDQ	JABALFMYHEP	t	2016-01-01	\N	f	FI	1	t	t	\N	f	t	TESTUSER	2016-03-28 01:52:06.05888	TESTUSER	2016-03-28 01:57:13.673707	913
920	SDQ	800MPFMYHEP	t	2016-01-01	\N	f	FI	1	t	t	\N	f	t	TESTUSER	2016-03-28 01:52:06.05888	TESTUSER	2016-03-28 01:57:13.673707	913
915	SDQ	SALTOFMYHEP	t	2016-01-01	\N	f	FI	1	t	t		f	t	TESTUSER	2016-03-28 01:52:06.05888	TESTUSER	2016-03-28 01:56:08.340392	913
918	SDQ	SLARGOFMYHEP	t	2016-01-01	\N	f	FI	1	f	t		f	t	TESTUSER	2016-03-28 01:52:06.05888	TESTUSER	2016-03-30 14:24:29.825278	913
913	SDQ	HEPTAFMY	f	2016-01-01	\N	t	FI	1	f	t		f	t	TESTUSER	2016-03-28 01:52:06.05888	TESTUSER	2016-03-29 04:11:07.219776	\N
868	XXXXX	SLARGOFMYHEP	t	2016-01-01	\N	f	FI	1	f	t		f	t	TESTUSER	2016-03-18 13:50:33.342962	TESTUSER	2016-03-30 14:24:48.619246	863
925	XXXXX	4X400MPMMY	f	2016-01-01	\N	f	FI	1	t	t		f	t	TESTUSER	2016-04-03 23:51:20.16632	\N	\N	\N
926	XXXXX	4X400MPFMY	f	2016-01-01	\N	f	FI	1	t	t		f	t	TESTUSER	2016-04-04 01:14:28.506523	\N	\N	\N
927	SOP2014	4X400MPFMY	f	2014-03-07	\N	f	FI	1	t	t		f	t	TESTUSER	2016-04-20 01:48:40.191637	\N	\N	\N
928	XXXXX	4X400MPFMY	f	2016-01-01	\N	f	SR	1	t	t	sdsgsd	f	t	TESTUSER	2016-04-20 23:52:49.357128	\N	\N	\N
932	XXXXX	4X400MPMMY	f	2016-01-01	\N	f	SR	1	t	t		f	t	TESTUSER	2016-04-21 00:36:24.595845	\N	\N	\N
933	XXXXX	4X400MPMMY	f	2016-01-01	\N	f	HT	1	t	t		f	t	TESTUSER	2016-04-21 02:03:21.829977	\N	\N	\N
934	GPBMPAZ16	100MPMMY	f	2016-04-22	0.40	f	FI	1	t	t		f	t	TESTUSER	2016-04-22 12:28:39.840274	\N	\N	\N
916	SDQ	IBALAFMYHEP	t	2016-01-01	\N	f	FI	1	t	t		f	t	TESTUSER	2016-03-28 01:52:06.05888	TESTUSER	2016-03-28 03:42:44.56661	913
936	XXXXX	100MVFMY	f	2016-01-01	\N	f	HT	1	t	t	fgfg	f	t	TESTUSER	2016-04-26 23:09:06.452276	TESTUSER	2016-04-28 16:13:08.848569	\N
890	SDQ	SLLARGOMMY	f	2016-01-01	\N	f	FI	1	f	f	le dolia el pie	f	t	TESTUSER	2016-03-21 05:16:06.462058	TESTUSER	2016-03-28 03:44:20.914336	\N
862	XXXXX	100MVFMY	f	2016-01-01	3.00	t	SR	1	t	t		f	t	TESTUSER	2016-03-18 13:45:18.682267	TESTUSER	2016-03-28 04:33:57.847181	\N
938	OLSWE1912	100MPMMY	f	1912-07-06	\N	t	HT	16	t	t		f	t	TESTUSER	2016-05-22 14:02:00.927285	TESTUSER	2016-05-22 18:45:18.158962	\N
\.


--
-- TOC entry 2702 (class 0 OID 0)
-- Dependencies: 189
-- Name: tb_competencias_pruebas_competencias_pruebas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: atluser
--

SELECT pg_catalog.setval('tb_competencias_pruebas_competencias_pruebas_id_seq', 938, true);


--
-- TOC entry 2627 (class 0 OID 16621)
-- Dependencies: 190
-- Data for Name: tb_entidad; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY tb_entidad (entidad_id, entidad_razon_social, entidad_ruc, entidad_titulo_alterno, entidad_direccion, entidad_web_url, entidad_telefonos, entidad_fax, entidad_eslogan, entidad_siglas, entidad_correo, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
1	FEDERACION DEPORTIVA PERUANA DE ATLETISMO	09900100010	FEDEATLE	AV CANADA CDRA 6 / LA VIDENA / SAN LUIS					FDPA		t	TESTUSER	2014-01-14 18:29:40.943718	TESTUSER	2016-02-07 18:29:20.594996
\.


--
-- TOC entry 2703 (class 0 OID 0)
-- Dependencies: 191
-- Name: tb_entidad_entidad_id_seq; Type: SEQUENCE SET; Schema: public; Owner: atluser
--

SELECT pg_catalog.setval('tb_entidad_entidad_id_seq', 1, true);


--
-- TOC entry 2629 (class 0 OID 16630)
-- Dependencies: 192
-- Data for Name: tb_entrenadores; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY tb_entrenadores (entrenadores_codigo, entrenadores_ap_paterno, entrenadores_ap_materno, entrenadores_nombres, entrenadores_nombre_completo, entrenadores_nivel_codigo, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
00001	Urbina	Galvez	Alberto	Urbina Galvez, Alberto	NIVEL5	t	atluser	2014-03-06 03:11:02.555597	TESTUSER	\N
00002	Valiente	Nose	Fernando	Valiente Nose, Fernando	NIVEL1	t	atluser	2014-05-06 22:04:55.137619	TESTUSER	\N
NOIND	No indicado	NA	NA	No indicado NA, NA	PROMO	t	atluser	2014-03-16 05:17:17.471232	TESTUSER	2016-02-11 15:07:07.723436
\.


--
-- TOC entry 2630 (class 0 OID 16637)
-- Dependencies: 193
-- Data for Name: tb_entrenadores_atletas; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY tb_entrenadores_atletas (entrenadoresatletas_id, entrenadores_codigo, atletas_codigo, entrenadoresatletas_desde, entrenadoresatletas_hasta, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
1	00001	46658908	2007-01-01	2030-01-01	t	TESTUSER	2014-04-14 12:33:52.214018	TESTUSER	2016-03-12 16:24:16.048586
\.


--
-- TOC entry 2704 (class 0 OID 0)
-- Dependencies: 194
-- Name: tb_entrenadores_atletas_entrenadoresatletas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: atluser
--

SELECT pg_catalog.setval('tb_entrenadores_atletas_entrenadoresatletas_id_seq', 5, true);


--
-- TOC entry 2632 (class 0 OID 16643)
-- Dependencies: 195
-- Data for Name: tb_entrenadores_nivel; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY tb_entrenadores_nivel (entrenadores_nivel_codigo, entrenadores_nivel_descripcion, entrenadores_nivel_protected, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
EDFISICA	Educacion Fisica	t	t	TESTUSER	2014-03-06 03:01:00.736498	postgres	2014-03-06 03:03:48.662056
NIVEL1	Nivel 1 IAAF	t	t	TESTUSER	2014-03-06 03:01:19.01571	postgres	2014-03-06 03:03:48.662056
NIVEL2	Nivel 2 IAAF	t	t	TESTUSER	2014-03-06 03:01:28.828614	postgres	2014-03-06 03:03:48.662056
NIVEL3	Nivel 3 IAAF	t	t	TESTUSER	2014-03-06 03:01:42.723429	postgres	2014-03-06 03:03:48.662056
NIVEL4	Nivel 4 IAAF	t	t	TESTUSER	2014-03-06 03:02:11.506018	postgres	2014-03-06 03:03:48.662056
NIVEL5	Nivel 5 IAAF	t	t	TESTUSER	2014-03-06 03:02:23.353387	postgres	2014-03-06 03:03:48.662056
NOIND	No Indicado	f	t	TESTUSER	2014-03-16 05:17:33.124416	\N	\N
PROMO	Promotor	f	t	TESTUSER	2014-03-06 03:02:33.722386	TESTUSER	2016-02-11 14:52:01.277123
\.


--
-- TOC entry 2633 (class 0 OID 16648)
-- Dependencies: 196
-- Data for Name: tb_ligas; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY tb_ligas (ligas_codigo, ligas_descripcion, ligas_persona_contacto, ligas_telefono_oficina, ligas_telefono_celular, ligas_email, ligas_direccion, ligas_web_url, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
LBARRAN	Liga Deportiva Atletica De Barranco	Carlos Arana Reategui		993786532	aranape@gmail.com	Monte De Los Olivos 198		t	TESTUSER	2014-03-05 21:25:57.100939	\N	\N
NOCON	No Conocida	???				???		t	TESTUSER	2014-03-05 22:06:56.01083	\N	\N
LSAMBORJA	Liga de San Borja	Oscar y Marcial Zuñiga Parra				N/C		t	TESTUSER	2014-07-16 15:36:29.289427	\N	\N
LSANLUIS	Liga De San Luis	Oscar Valiente				????		t	TESTUSER	2015-03-14 16:46:20.347704	\N	\N
\.


--
-- TOC entry 2634 (class 0 OID 16655)
-- Dependencies: 197
-- Data for Name: tb_ligas_clubes; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY tb_ligas_clubes (ligasclubes_id, ligas_codigo, clubes_codigo, ligasclubes_desde, ligasclubes_hasta, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
14	LBARRAN	JOWENS	2014-01-01	2035-12-31	t	TESTUSER	2015-03-14 16:47:28.622291	TESTUSER	2016-03-09 03:32:37.879316
\.


--
-- TOC entry 2705 (class 0 OID 0)
-- Dependencies: 198
-- Name: tb_ligas_clubes_ligasclubes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: atluser
--

SELECT pg_catalog.setval('tb_ligas_clubes_ligasclubes_id_seq', 16, true);


--
-- TOC entry 2636 (class 0 OID 16661)
-- Dependencies: 199
-- Data for Name: tb_paises; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY tb_paises (paises_codigo, paises_descripcion, paises_entidad, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion, regiones_codigo, paises_use_apm, paises_use_docid) FROM stdin;
PER	Peru	t	t	TESTUSER	2014-01-15 02:56:36.298578	TESTUSER	2016-04-29 16:01:15.190543	SAMERICA	t	t
COL	Colombia	f	t	TESTUSER	2014-03-03 01:07:47.093623	TESTUSER	2016-05-05 00:37:51.186041	SAMERICA	t	f
CAN	Canada	f	t	TESTUSER	2014-07-16 15:33:10.2895	TESTUSER	2016-05-05 00:38:02.231625	CAMECARIB	f	f
CHI	Chile	f	t	TESTUSER	2014-01-15 04:32:53.663519	TESTUSER	2016-05-05 00:38:18.91928	SAMERICA	t	f
VEN	Venezuela	f	t	TESTUSER	2014-03-18 23:08:55.320403	TESTUSER	2016-05-05 00:38:28.075614	SAMERICA	t	f
PAR	Paraguay	f	t	TESTUSER	2014-01-15 04:32:41.280826	TESTUSER	2016-05-05 00:38:36.852454	SAMERICA	t	f
USA	Estados Unidos	f	t	TESTUSER	2014-07-26 12:07:04.595319	TESTUSER	2016-05-05 00:40:11.027221	CAMECARIB	f	f
BOL	Bolivia	f	t	TESTUSER	2014-04-25 19:31:41.082426	TESTUSER	2016-05-05 00:40:19.620363	SAMERICA	t	f
ARG	Argentina	f	t	TESTUSER	2014-01-15 14:30:29.047479	TESTUSER	2016-05-05 00:40:23.39893	SAMERICA	t	f
UKR	Ucrania	f	t	TESTUSER	2014-03-05 21:53:28.073274	TESTUSER	2016-05-05 00:40:34.533169	EUROPA	t	f
SWE	Suecia	f	t	TESTUSER	2016-05-02 16:51:09.005734	TESTUSER	2016-05-05 00:40:39.845515	EUROPA	t	f
POL	Polonia	f	t	TESTUSER	2014-03-07 04:03:01.557686	TESTUSER	2016-05-05 00:40:44.604717	EUROPA	t	f
IRL	Irlanda	f	t	TESTUSER	2014-10-05 12:49:46.222586	TESTUSER	2016-05-05 00:40:51.649902	EUROPA	t	f
ECU	Ecuador	f	t	TESTUSER	2014-01-15 04:33:04.408989	TESTUSER	2016-05-05 00:40:55.311117	SAMERICA	t	f
ESP	EspaÃ±a	f	t	TESTUSER	2014-07-28 21:37:55.772452	TESTUSER	2016-05-05 00:40:58.291257	EUROPA	t	f
MEX	Mexico	f	t	TESTUSER	2014-07-27 20:59:05.312412	TESTUSER	2016-05-05 00:41:11.383988	CAMECARIB	t	f
NOR	Noruega	f	t	TESTUSER	2014-03-03 01:06:30.43547	TESTUSER	2016-05-05 00:41:14.681275	EUROPA	t	f
URU	Uruguay	f	t	TESTUSER	2015-03-14 16:49:57.378678	TESTUSER	2016-05-05 00:41:26.7222	SAMERICA	t	f
GER	Alemania	f	t	TESTUSER	2014-07-28 21:25:46.495951	TESTUSER	2016-05-05 00:41:34.56929	EUROPA	t	f
BRA	Brasil	f	t	TESTUSER	2014-01-15 04:09:48.671663	TESTUSER	2016-05-05 00:41:41.655551	SAMERICA	t	f
\.


--
-- TOC entry 2663 (class 0 OID 37650)
-- Dependencies: 226
-- Data for Name: tb_postas; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY tb_postas (postas_id, postas_descripcion, competencias_pruebas_id, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
17	test2	926	t	carlos	2016-04-04 01:20:25.726763	\N	\N
22	rwewer	926	t	TESTUSER	2016-04-12 00:08:53.761624	\N	\N
23	xxxxx	926	t	TESTUSER	2016-04-12 01:32:40.468786	\N	\N
25	xxxxxx	926	t	TESTUSER	2016-04-12 01:44:25.451416	\N	\N
26	gggggg	926	t	TESTUSER	2016-04-12 01:50:34.184697	\N	\N
27	hhhhhhhhh	926	t	TESTUSER	2016-04-12 02:23:22.40423	\N	\N
28	hghgghgh	926	t	TESTUSER	2016-04-12 13:32:19.084861	\N	\N
29	iuuierytyrt	926	t	TESTUSER	2016-04-12 16:45:35.638383	\N	\N
30	dfgdfgdf	926	t	TESTUSER	2016-04-14 01:34:12.767634	\N	\N
31	ssssdddsd	926	t	TESTUSER	2016-04-14 17:17:40.51896	\N	\N
33	xxxxxxxxx	926	t	TESTUSER	2016-04-16 14:31:29.671162	\N	\N
36	sdfsfsdfdsffd	926	t	TESTUSER	2016-04-16 14:36:32.788852	\N	\N
37	hfghfhfh	926	t	TESTUSER	2016-04-16 14:50:28.834228	\N	\N
39	sdfsdfsdf	926	t	TESTUSER	2016-04-16 15:10:49.551772	\N	\N
41	fffff	926	t	TESTUSER	2016-04-16 15:24:34.685919	\N	\N
43	dfsfsdfsd	926	t	TESTUSER	2016-04-16 15:29:10.509506	\N	\N
45	sdsdsaddsad	926	t	TESTUSER	2016-04-16 15:37:47.385463	\N	\N
47	hgfhfghfh	926	t	TESTUSER	2016-04-18 16:20:17.670947	\N	\N
48	dfgdfgdgdfg	926	t	TESTUSER	2016-04-18 16:23:50.445381	\N	\N
49	erwterterterteert	926	t	TESTUSER	2016-04-18 16:25:38.906648	\N	\N
50	ytryututyu	926	t	TESTUSER	2016-04-18 16:27:00.079734	\N	\N
51	ghjgghjj	926	t	TESTUSER	2016-04-18 16:27:47.771698	\N	\N
52	jtyutyutytyuty	926	t	TESTUSER	2016-04-18 16:30:33.175876	\N	\N
53	test01	932	t	TESTUSER	2016-04-21 00:49:54.493414	\N	\N
55	Colombia	925	t	TESTUSER	2016-04-25 01:53:33.684325	\N	\N
56	peru	925	t	TESTUSER	2016-05-12 01:52:18.401258	\N	\N
57	ertryry	925	t	TESTUSER	2016-05-13 15:16:12.575545	\N	\N
\.


--
-- TOC entry 2665 (class 0 OID 37666)
-- Dependencies: 228
-- Data for Name: tb_postas_detalle; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY tb_postas_detalle (postas_detalle_id, postas_id, atletas_codigo, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
55	17	46658908	t	TESTUSER	2016-04-17 17:08:31.894516	\N	\N
57	51	73501965	t	TESTUSER	2016-04-18 16:52:40.543749	\N	\N
58	53	46134708	t	TESTUSER	2016-04-21 00:50:08.960728	\N	\N
63	55	46134708	t	TESTUSER	2016-04-25 16:41:01.898441	\N	\N
64	55	72661990	t	TESTUSER	2016-05-01 13:11:51.061987	\N	\N
65	56	70830992	t	TESTUSER	2016-05-12 01:52:30.479194	\N	\N
66	56	71336507	t	TESTUSER	2016-05-12 01:52:36.710349	\N	\N
32	30	71835626	t	TESTUSER	2016-04-15 04:26:28.917977	\N	\N
46	30	70690315	t	TESTUSER	2016-04-15 20:13:37.311619	\N	\N
\.


--
-- TOC entry 2706 (class 0 OID 0)
-- Dependencies: 227
-- Name: tb_postas_detalle_postas_detalle_id_seq; Type: SEQUENCE SET; Schema: public; Owner: atluser
--

SELECT pg_catalog.setval('tb_postas_detalle_postas_detalle_id_seq', 66, true);


--
-- TOC entry 2707 (class 0 OID 0)
-- Dependencies: 225
-- Name: tb_postas_postas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: atluser
--

SELECT pg_catalog.setval('tb_postas_postas_id_seq', 57, true);


--
-- TOC entry 2637 (class 0 OID 16667)
-- Dependencies: 200
-- Data for Name: tb_pruebas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY tb_pruebas (pruebas_codigo, pruebas_descripcion, pruebas_generica_codigo, pruebas_sexo, categorias_codigo, pruebas_record_hasta, pruebas_anotaciones, pruebas_protected, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
JABALFMY	Lanzamiento de Jabalina	LJABALINA	F	MAY	MAY		f	t	postgres	2014-03-21 04:40:52.739939	\N	\N
100MPMME	100 Metros Planos	100MP	M	MEN	MAY		f	t	postgres	2014-03-21 04:40:52.739939	\N	\N
100MVFJV	100 Metros Con Vallas	100MV	F	JUV	MAY		f	t	postgres	2014-03-21 04:40:52.739939	\N	\N
100MVFME	100 Metros Con Valla	100MV	F	MEN	MEN		f	t	postgres	2014-03-21 04:40:52.739939	\N	\N
SLALTOFJV	Salto Alto	SALTO	F	JUV	MAY		f	t	postgres	2014-03-21 04:40:52.739939	\N	\N
JABALFJV	Lanzamiento de Jabalina	LJABALINA	F	JUV	JUV		f	t	TESTUSER	2014-04-08 12:45:39.076424	\N	\N
SLALTOFMY	Salto Alto	SALTO	F	MAY	MAY		f	t	postgres	2014-03-21 04:40:52.739939	\N	\N
SLALTOMJV	Salto Alto	SALTO	M	JUV	MAY		f	t	postgres	2014-03-21 04:40:52.739939	\N	\N
SLLARGOFJV	Salto Largo	SLARGO	F	JUV	MAY		f	t	postgres	2014-03-21 04:40:52.739939	\N	\N
SLLARGOFME	Salto Largo	SLARGO	F	MEN	MEN		f	t	postgres	2014-03-21 04:40:52.739939	\N	\N
SLLARGOFMY	Salto Largo	SLARGO	F	MAY	MAY		f	t	postgres	2014-03-21 04:40:52.739939	\N	\N
SLLARGOMME	Salto Largo	SLARGO	M	MEN	MEN		f	t	postgres	2014-03-21 04:40:52.739939	\N	\N
SLLARGOMJV	Salto Largo	SLARGO	M	JUV	MAY		f	t	postgres	2014-03-21 04:40:52.739939	\N	\N
SLLARGOMMY	Salto Largo	SLARGO	M	MAY	MAY		f	t	postgres	2014-03-21 04:40:52.739939	\N	\N
IBALAFME	Impulsion de Bala	LBALA	F	MEN	MEN		f	t	postgres	2014-03-21 04:40:52.739939	\N	\N
IBALAFMY	Impulsion De Bala	LBALA	F	MAY	MAY		f	t	postgres	2014-03-21 04:40:52.739939	\N	\N
IBALAFJV	Impulsion De Bala	LBALA	F	JUV	MAY		f	t	postgres	2014-03-21 04:40:52.739939	\N	\N
SALTOFMYHEP	Salto Alto (Hepta)	SALTO	F	MAY	MAY		f	t	TESTUSER	2014-05-21 17:49:45.377193	TESTUSER	2014-07-18 17:05:34.94539
JABALFME	Lanzamiento de Jabalina	LJABALINA	F	MEN	MEN		f	t	TESTUSER	2014-04-08 14:04:57.836828	\N	\N
800MPFME	800 Metros Planos	800MP	F	MEN	MAY		f	t	TESTUSER	2014-04-08 14:05:42.891061	\N	\N
SLALTOFME	Salto Alto	SALTO	F	MEN	MAY		f	t	postgres	2014-03-21 04:40:52.739939	TESTUSER	2014-03-24 03:12:47.2066
LMARTFME	Lanzamiento de Martillo	LMARTILLO	F	MEN	MEN		f	t	TESTUSER	2014-04-08 14:10:06.211909	\N	\N
LMARTFMY	Lanzamiento de Martillo	LMARTILLO	F	MAY	MAY		f	t	TESTUSER	2014-04-08 14:12:04.11598	\N	\N
100MPFJV	100 Metros Planos	100MP	F	JUV	MAY		f	t	postgres	2014-03-21 04:40:52.739939	TESTUSER	2014-04-08 14:47:39.441225
10000MPMJV	10000 Metros Planos	10000MP	M	JUV	MAY		f	t	TESTUSER	2014-07-26 12:32:14.523083	\N	\N
200MPFMY	200 Metros Planos	200MP	F	MAY	MAY		f	t	postgres	2014-03-21 04:40:52.739939	TESTUSER	2014-04-08 14:24:05.345679
100MPMMY	100 Metros Planos	100MP	M	MAY	MAY		f	t	postgres	2014-03-21 04:40:52.739939	TESTUSER	2014-04-08 14:48:11.049796
100MPMJV	100 MetrosPlanos	100MP	M	JUV	MAY		f	t	postgres	2014-03-21 04:40:52.739939	TESTUSER	2014-04-08 14:48:16.791881
800MPFJV	800 Metros Planos	800MP	F	JUV	MAY		f	t	TESTUSER	2014-04-08 12:47:00.089413	TESTUSER	2014-04-08 14:26:38.11331
300MOBSFJV	3000 Metros Con Obstaculos	3000MOBS	F	JUV	MAY		f	t	TESTUSER	2014-07-26 15:04:01.635483	\N	\N
3000MOBSFMY	3000 Metros Con Obstaculos	3000MOBS	F	MAY	MAY		f	t	TESTUSER	2014-07-26 18:49:54.842357	\N	\N
200MPFME	200 Metros planos	200MP	F	MEN	MAY		f	t	TESTUSER	2014-04-08 14:04:22.407121	TESTUSER	2014-04-08 14:36:20.858617
100MPFMY	100 Metros Planos	100MP	F	MAY	MAY		f	t	postgres	2014-03-21 04:40:52.739939	TESTUSER	2014-04-08 14:36:34.64206
200MPFJV	200 Metros Planos	200MP	F	JUV	MAY		f	t	TESTUSER	2014-04-08 12:43:49.253311	TESTUSER	2014-04-08 14:36:45.299642
800MPFMY	800 Metros Planos	800MP	F	MAY	MAY		f	t	postgres	2014-03-21 04:40:52.739939	TESTUSER	2014-04-08 14:37:28.487936
100MVFMY	100 Metros Con Vallas	100MV	F	MAY	MAY	ss	f	t	postgres	2014-03-21 04:40:52.739939	TESTUSER	2014-04-08 14:38:38.896323
SLALTOMMY	Salto Alto	SALTO	M	MAY	MAY	we	f	t	postgres	2014-03-21 04:40:52.739939	TESTUSER	2014-04-08 14:39:00.465459
SLALTOMME	Salto Alto	SALTO	M	MEN	MAY		f	t	postgres	2014-03-21 04:40:52.739939	TESTUSER	2014-04-08 14:39:11.772991
LMARTFJV	Lanzamiento de Martillo	LMARTILLO	F	JUV	JUV		f	t	TESTUSER	2014-04-08 14:11:26.816898	TESTUSER	2014-04-08 14:40:59.383322
100MVFMYHEP	100 Metros Con Vallas (Hepta)	100MV	F	MAY	MAY		f	t	TESTUSER	2014-05-21 17:48:13.790661	\N	\N
IBALAFMYHEP	Impulsion de Bala (Hepta)	LBALA	F	MAY	MAY		f	t	TESTUSER	2014-05-21 17:50:48.453515	\N	\N
200MPFMYHEP	200 Metros Planos (Hepta)	200MP	F	MAY	MAY		f	t	TESTUSER	2014-05-21 17:51:45.438053	\N	\N
SLARGOFMYHEP	Salto Largo (Hepta)	SLARGO	F	MAY	MAY		f	t	TESTUSER	2014-05-21 17:52:25.869126	\N	\N
JABALFMYHEP	Lanzamiento De Jabalina (Hepta)	LJABALINA	F	MAY	MAY		f	t	TESTUSER	2014-05-21 17:53:38.213756	\N	\N
800MPFMYHEP	800 Metros Planos (Hepta)	800MP	F	MAY	MAY		f	t	TESTUSER	2014-05-21 17:54:15.174039	\N	\N
1500MPFMY	1500 Metros Planos	1500MP	F	MAY	MAY		f	t	TESTUSER	2014-06-11 16:47:46.902173	\N	\N
HEPTAFJV	Heptatlon	HEPTATLON	F	JUV	MAY		f	t	TESTUSER	2014-07-16 16:26:30.305114	\N	\N
100MVFJVHEP	100 Metros Con Vallas (Hepta)	100MV	F	JUV	MAY		f	t	TESTUSER	2014-07-18 16:29:02.687296	\N	\N
200MPFJVHEP	200 Metros Planos (Hepta)	200MP	F	JUV	MAY		f	t	TESTUSER	2014-07-18 16:30:23.107197	\N	\N
800MPFJVHEP	800 Metros Planos (Hepta)	800MP	F	JUV	MAY		f	t	TESTUSER	2014-07-18 16:36:24.711754	\N	\N
IBALAFJVHEP	Impulsion de Bala (Hepta)	LBALA	F	JUV	MAY		f	t	TESTUSER	2014-07-18 16:52:21.849296	\N	\N
JABALFJVHEP	Lanzamiento De Jabalina (Hepta)	LJABALINA	F	JUV	MAY		f	t	TESTUSER	2014-07-18 16:53:50.820785	\N	\N
SLARGOFJVHEP	Salto Largo (Hepta)	SLARGO	F	JUV	MAY		f	t	TESTUSER	2014-07-18 16:55:32.697277	\N	\N
SALTOFJVHEP	Salto Alto (Hepta)	SALTO	F	JUV	MAY		f	t	TESTUSER	2014-07-18 16:54:54.511726	TESTUSER	2014-07-18 17:05:27.790022
10000MARMMJV	10000 Metros - Marcha	10000MMARCHA	M	JUV	MAY		f	t	TESTUSER	2014-07-28 16:28:31.179263	\N	\N
100MPFME	100 Metros Planos	100MP	F	MEN	MAY		f	t	postgres	2014-03-21 04:40:52.739939	TESTUSER	2014-04-08 03:39:04.964128
HEPTAFMY	Heptatlon	HEPTATLON	F	MAY	MAY		f	t	TESTUSER	2014-04-07 17:50:51.02593	TESTUSER	2014-04-08 03:43:19.025594
400MPFMY	400 Mts Planos	400MP	F	MAY	MAY		f	t	TESTUSER	2015-03-14 16:29:25.735608	\N	\N
400MPFS23	400 Mts Planos	400MP	F	SUB23	MAY		f	t	TESTUSER	2015-03-14 16:30:04.494024	\N	\N
400MVFS23	400 Metros Con Vallas	400MV	F	SUB23	MAY		f	t	TESTUSER	2015-03-14 16:54:30.716565	TESTUSER	2015-03-14 18:33:13.94951
400MVFMY	400 Metros Con Vallas	400MV	F	MAY	MAY		f	t	TESTUSER	2015-03-14 16:55:06.332367	TESTUSER	2015-03-14 18:34:26.45164
SGARROCHAMMY	Salto Con Garrocha	SGARROCHA	M	MAY	MAY		f	t	TESTUSER	2015-04-19 20:18:37.595476	\N	\N
200MPMMY	200 Mts Planos	200MP	M	MAY	MAY		f	t	TESTUSER	2015-04-26 12:20:42.144653	\N	\N
SGARROCHAMME	Salto Con Garrocha	SGARROCHA	M	MEN	MAY		f	t	TESTUSER	2015-04-26 17:00:06.858087	\N	\N
4X400MPMMY	Posta 4x400	4X400MP	M	MAY	MAY		f	t	TESTUSER	2016-04-03 23:28:08.792167	TESTUSER	2016-04-03 23:36:36.189643
4X400MPFMY	Posta 4x400	4X400MP	F	MAY	MAY		f	t	TESTUSER	2016-04-04 01:13:46.607545	\N	\N
\.


--
-- TOC entry 2638 (class 0 OID 16673)
-- Dependencies: 201
-- Data for Name: tb_pruebas_clasificacion; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY tb_pruebas_clasificacion (pruebas_clasificacion_codigo, pruebas_clasificacion_descripcion, pruebas_tipo_codigo, unidad_medida_codigo, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
VEL	Velocidad	PIS	SEG	t	TESTUSER	2014-03-21 02:54:21.520442	\N	\N
LANZ	Lanzamientos o Impulsion	CAMP	MTSCM	t	TESTUSER	2014-03-21 02:54:21.520442	\N	\N
SFONDO	Semi Fondo	PIS	MS	t	TESTUSER	2014-03-21 02:54:21.520442	\N	\N
SALTO	Saltos	CAMP	MTSCM	t	TESTUSER	2014-03-21 02:54:21.520442	\N	\N
COMBI	Combinada	PISCAM	PUNT	t	TESTUSER	2014-03-21 02:54:21.520442	\N	\N
FONDO	Fondo	PIS	HMS	t	TESTUSER	2014-03-21 02:54:21.520442	TESTUSER	2016-02-09 00:01:18.305051
\.


--
-- TOC entry 2639 (class 0 OID 16677)
-- Dependencies: 202
-- Data for Name: tb_pruebas_detalle; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY tb_pruebas_detalle (pruebas_detalle_id, pruebas_codigo, pruebas_detalle_prueba_codigo, pruebas_detalle_orden, pruebas_detalle_protected, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
56	HEPTAFMY	100MVFMYHEP	1	f	t	TESTUSER	2014-05-21 17:55:05.921211	\N	\N
58	HEPTAFMY	IBALAFMYHEP	3	f	t	TESTUSER	2014-05-21 17:55:31.919541	\N	\N
59	HEPTAFMY	200MPFMYHEP	4	f	t	TESTUSER	2014-05-21 17:56:09.68915	\N	\N
60	HEPTAFMY	SLARGOFMYHEP	5	f	t	TESTUSER	2014-05-21 17:56:20.854266	\N	\N
61	HEPTAFMY	JABALFMYHEP	6	f	t	TESTUSER	2014-05-21 17:56:33.494573	\N	\N
62	HEPTAFMY	800MPFMYHEP	7	f	t	TESTUSER	2014-05-21 17:56:45.235359	\N	\N
70	HEPTAFJV	100MVFJVHEP	1	f	t	TESTUSER	2014-07-18 16:56:11.54137	\N	\N
71	HEPTAFJV	SALTOFJVHEP	2	f	t	TESTUSER	2014-07-18 16:56:36.253597	\N	\N
72	HEPTAFJV	IBALAFJVHEP	3	f	t	TESTUSER	2014-07-18 16:56:51.505843	\N	\N
73	HEPTAFJV	200MPFJVHEP	4	f	t	TESTUSER	2014-07-18 16:57:08.074885	\N	\N
74	HEPTAFJV	SLARGOFJVHEP	5	f	t	TESTUSER	2014-07-18 16:57:23.715137	\N	\N
75	HEPTAFJV	JABALFJVHEP	6	f	t	TESTUSER	2014-07-18 16:57:35.082359	\N	\N
76	HEPTAFJV	800MPFJVHEP	7	f	t	TESTUSER	2014-07-18 16:57:48.623408	\N	\N
103	HEPTAFMY	SALTOFMYHEP	2	f	t	TESTUSER	2016-02-17 18:53:54.766673	\N	\N
\.


--
-- TOC entry 2708 (class 0 OID 0)
-- Dependencies: 203
-- Name: tb_pruebas_detalle_pruebas_detalle_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('tb_pruebas_detalle_pruebas_detalle_id_seq', 103, true);


--
-- TOC entry 2641 (class 0 OID 16684)
-- Dependencies: 204
-- Data for Name: tb_pruebas_tipo; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY tb_pruebas_tipo (pruebas_tipo_codigo, pruebas_tipo_descripcion, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
PIS	Pista	t	TESTUSER	2014-03-03 17:24:21.960897	\N	\N
CAMP	Campo	t	TESTUSER	2014-03-03 17:24:33.815961	\N	\N
PEDEST	Pedestre	t	TESTUSER	2014-03-03 17:24:59.342096	\N	\N
PISCAM	Pista y Campo	t	TESTUSER	2014-03-09 13:40:35.915179	\N	\N
CROSC	Cross Country	t	TESTUSER	2014-03-03 17:26:07.839675	TESTUSER	2016-02-08 17:23:02.523075
\.


--
-- TOC entry 2642 (class 0 OID 16688)
-- Dependencies: 205
-- Data for Name: tb_records; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY tb_records (records_id, records_tipo_codigo, atletas_resultados_id, categorias_codigo, records_id_origen, records_protected, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
124	NACIONAL	769	JUV	\N	f	t	TESTUSER	2015-01-05 00:41:38.134136	\N	\N
125	NACIONAL	780	JUV	\N	f	t	TESTUSER	2015-01-05 00:41:38.134136	\N	\N
126	NACIONAL	780	MAY	\N	f	t	TESTUSER	2015-01-05 00:41:38.134136	\N	\N
127	NACIONAL	781	JUV	\N	f	t	TESTUSER	2015-01-05 00:41:38.134136	\N	\N
128	NACIONAL	785	JUV	\N	f	t	TESTUSER	2015-01-05 00:41:38.134136	\N	\N
129	NACIONAL	785	MAY	\N	f	t	TESTUSER	2015-01-05 00:41:38.134136	\N	\N
130	NACIONAL	782	MAY	\N	f	t	TESTUSER	2015-01-05 00:41:38.134136	\N	\N
137	NACIONAL	784	MAY	\N	f	t	TESTUSER	2015-01-05 00:41:38.134136	\N	\N
139	NACIONAL	783	MAY	\N	f	t	TESTUSER	2015-01-05 00:41:38.134136	\N	\N
140	NACIONAL	794	MAY	\N	f	t	TESTUSER	2015-01-05 00:41:38.134136	\N	\N
141	NACIONAL	795	MAY	\N	f	t	TESTUSER	2015-01-05 00:41:38.134136	\N	\N
142	NACIONAL	796	MAY	\N	f	t	TESTUSER	2015-01-05 00:41:38.134136	\N	\N
145	NACIONAL	797	MAY	\N	f	t	TESTUSER	2015-01-05 00:41:38.134136	\N	\N
146	NACIONAL	799	MAY	\N	f	t	TESTUSER	2015-01-05 00:41:38.134136	\N	\N
147	NACIONAL	798	MAY	\N	f	t	TESTUSER	2015-01-05 00:41:38.134136	\N	\N
116	NACIONAL	720	MAY	\N	f	t	TESTUSER	2015-01-05 00:41:38.134136	\N	\N
117	NACIONAL	733	MAY	\N	f	t	TESTUSER	2015-01-05 00:41:38.134136	\N	\N
119	REGIONAL	778	JUV	\N	f	t	TESTUSER	2015-01-05 00:41:38.134136	\N	\N
123	NACIONAL	778	MAY	\N	f	t	TESTUSER	2015-01-05 00:41:38.134136	\N	\N
1	NACIONAL	797	JUV	\N	f	t	TESTUSER	2015-02-23 01:45:15.366845	\N	\N
4	NACIONAL	803	MEN	\N	f	t	TESTUSER	2015-03-14 15:44:24.055443	\N	\N
7	NACIONAL	803	JUV	\N	f	t	TESTUSER	2015-03-14 15:45:40.998076	\N	\N
8	NACIONAL	804	MAY	\N	f	t	TESTUSER	2015-03-14 16:33:12.795468	\N	\N
9	NACIONAL	804	SUB23	\N	f	t	TESTUSER	2015-03-14 16:33:33.462333	\N	\N
10	NACIONAL	806	SUB23	\N	f	t	TESTUSER	2015-03-14 17:01:28.564498	\N	\N
11	NACIONAL	806	MAY	\N	f	t	TESTUSER	2015-03-14 17:01:50.611097	\N	\N
12	NACIONAL	808	MAY	\N	f	t	TESTUSER	2015-04-19 19:44:36.588378	\N	\N
13	NACIONAL	816	MAY	\N	f	t	TESTUSER	2015-04-19 20:14:22.515446	\N	\N
14	NACIONAL	817	SUB23	\N	f	t	TESTUSER	2015-04-26 12:24:07.665347	\N	\N
15	NACIONAL	818	MAY	\N	f	t	TESTUSER	2015-04-26 12:41:15.643504	\N	\N
16	NACIONAL	819	MAY	\N	f	t	TESTUSER	2015-04-26 14:54:59.140116	\N	\N
17	NACIONAL	819	SUB23	\N	f	t	TESTUSER	2015-04-26 15:03:24.747802	\N	\N
18	NACIONAL	820	MEN	\N	f	t	TESTUSER	2015-04-26 17:07:19.32938	\N	\N
25	NACIONAL	1239	MAY	\N	f	t	TESTUSER	2016-04-22 12:46:48.992497	\N	\N
32	NACIONAL	1249	MAY	\N	f	t	TESTUSER	2016-05-11 13:24:44.567219	\N	\N
33	NACIONAL	1154	MAY	\N	f	t	TESTUSER	2016-05-12 01:47:43.796852	\N	\N
34	NACIONAL	1257	MAY	\N	f	t	TESTUSER	2016-05-12 01:55:28.098146	\N	\N
36	MUNDIAL	1258	MAY	\N	f	t	TESTUSER	2016-05-22 19:05:03.030167	\N	\N
\.


--
-- TOC entry 2643 (class 0 OID 16693)
-- Dependencies: 206
-- Data for Name: tb_records_pase; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY tb_records_pase (records_id, records_tipo_codigo, atletas_resultados_id, categorias_codigo, records_id_origen, records_protected, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
124	NACIONAL	769	JUV	\N	f	t	TESTUSER	2014-07-26 18:29:33.296338	\N	\N
125	NACIONAL	780	JUV	\N	f	t	TESTUSER	2014-07-27 14:18:09.865995	\N	\N
126	NACIONAL	780	MAY	\N	f	t	TESTUSER	2014-07-27 14:41:19.810798	\N	\N
127	NACIONAL	781	JUV	\N	f	t	TESTUSER	2014-07-27 14:50:04.518135	\N	\N
128	NACIONAL	785	JUV	\N	f	t	TESTUSER	2014-07-28 16:30:40.538022	\N	\N
129	NACIONAL	785	MAY	\N	f	t	TESTUSER	2014-07-28 16:30:59.926065	\N	\N
130	NACIONAL	782	MAY	\N	f	t	TESTUSER	2014-07-28 16:32:08.794845	\N	\N
137	NACIONAL	784	MAY	\N	f	t	TESTUSER	2014-07-28 16:48:43.663356	\N	\N
139	NACIONAL	783	MAY	\N	f	t	TESTUSER	2014-07-28 16:49:18.477364	\N	\N
140	NACIONAL	794	MAY	\N	f	t	TESTUSER	2014-07-28 21:28:57.080271	\N	\N
141	NACIONAL	795	MAY	\N	f	t	TESTUSER	2014-07-28 22:27:51.162898	\N	\N
142	NACIONAL	796	MAY	\N	f	t	TESTUSER	2014-07-28 22:45:42.950379	\N	\N
143	REGIONAL	797	JUV	\N	f	t	TESTUSER	2014-08-01 18:01:15.607185	\N	\N
144	NACIONAL	797	JUV	143	f	t	TESTUSER	2014-08-01 18:01:15.607185	\N	\N
145	NACIONAL	797	MAY	\N	f	t	TESTUSER	2014-08-01 18:01:55.564244	\N	\N
146	NACIONAL	799	MAY	\N	f	t	TESTUSER	2014-08-02 17:54:18.785967	\N	\N
147	NACIONAL	798	MAY	\N	f	t	TESTUSER	2014-08-02 18:00:14.02289	\N	\N
116	NACIONAL	720	MAY	\N	f	t	TESTUSER	2014-07-16 17:11:53.803548	\N	\N
117	NACIONAL	733	MAY	\N	f	t	TESTUSER	2014-07-16 17:12:12.701302	\N	\N
119	REGIONAL	778	JUV	\N	f	t	TESTUSER	2014-07-26 15:06:25.146504	\N	\N
120	NACIONAL	778	JUV	119	f	t	TESTUSER	2014-07-26 15:06:25.146504	\N	\N
123	NACIONAL	778	MAY	\N	f	t	TESTUSER	2014-07-26 18:15:21.793163	\N	\N
\.


--
-- TOC entry 2709 (class 0 OID 0)
-- Dependencies: 207
-- Name: tb_records_records_id_seq; Type: SEQUENCE SET; Schema: public; Owner: atluser
--

SELECT pg_catalog.setval('tb_records_records_id_seq', 38, true);


--
-- TOC entry 2645 (class 0 OID 16698)
-- Dependencies: 208
-- Data for Name: tb_records_tipo; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY tb_records_tipo (records_tipo_codigo, records_tipo_descripcion, records_tipo_abreviatura, records_tipo_tipo, records_tipo_clasificacion, records_tipo_peso, records_tipo_protected, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
MUNDIAL	Record Mundial	RM	A	M	1000	t	t	TESTUSER	2015-01-05 00:40:42.112712	postgres	2014-06-30 17:23:32.105369
OLIMPICO	Record Olimpico	RO	C	O	800	t	t	TESTUSER	2015-01-05 00:40:42.112712	postgres	2014-06-30 17:23:32.105369
PANAMER	Record Panamericano	RP	C	T	600	t	t	TESTUSER	2015-01-05 00:40:42.112712	postgres	2015-01-05 00:44:15.759464
NACIONAL	Record Nacional	RN	A	N	100	t	t	TESTUSER	2015-01-05 00:40:42.112712	TESTUSER	2015-01-05 00:44:18.314749
RCOMPETEN	Record Competencia	RC	C	X	10	t	t	TESTUSER	2015-01-05 00:40:42.112712	TESTUSER	2015-01-05 00:44:19.862441
REGIONAL	Record Regional	RR	A	R	600	t	t	TESTUSER	2015-01-05 00:40:42.112712	postgres	2015-01-05 00:44:24.714696
\.


--
-- TOC entry 2646 (class 0 OID 16708)
-- Dependencies: 209
-- Data for Name: tb_records_tipo_pase; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY tb_records_tipo_pase (records_tipo_codigo, records_tipo_descripcion, records_tipo_abreviatura, records_tipo_tipo, records_tipo_clasificacion, records_tipo_peso, records_tipo_protected, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
MUNDIAL	Record Mundial	RM	A	M	1000	t	t	TESTUSER	2014-06-30 16:54:55.132265	postgres	2014-06-30 17:23:32.105369
OLIMPICO	Record Olimpico	RO	C	O	800	t	t	TESTUSER	2014-06-30 17:01:18.87838	postgres	2014-06-30 17:23:32.105369
PANAMER	Record Panamericano	RP	C	X	600	t	t	TESTUSER	2014-06-30 17:03:00.43558	postgres	2014-06-30 17:23:32.105369
NACIONAL	Record Nacional	RN	A	N	100	f	t	TESTUSER	2014-07-08 18:10:02.338826	TESTUSER	2014-07-08 18:34:14.375073
REGIONAL	Record Regional	RR	A	R	600	f	t	TESTUSER	2014-07-10 18:17:57.821411	\N	\N
RCOMPETEN	Record Competencia	RC	C	X	10	f	t	TESTUSER	2014-07-01 16:51:23.649336	TESTUSER	2015-01-04 23:34:11.56977
\.


--
-- TOC entry 2647 (class 0 OID 16711)
-- Dependencies: 210
-- Data for Name: tb_regiones; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY tb_regiones (regiones_codigo, regiones_descripcion, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
EUROPA	Europa	t	TESTUSER	2014-06-27 16:16:28.302958	\N	\N
CAMECARIB	Norte Centro America y el Caribe	t	TESTUSER	2014-06-27 16:16:13.512191	TESTUSER	2014-07-16 15:32:54.812526
SAMERICA	Sud America	t	TESTUSER	2014-06-27 16:15:35.642623	TESTUSER	2016-02-07 19:17:14.23636
\.


--
-- TOC entry 2648 (class 0 OID 16715)
-- Dependencies: 211
-- Data for Name: tb_sys_menu; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY tb_sys_menu (sys_systemcode, menu_id, menu_codigo, menu_descripcion, menu_accesstype, menu_parent_id, menu_orden, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
ATLETISMO	37	smn_pruebas	Pruebas	A         	34	120	t	ADMIN	2014-03-02 18:03:42.050051	\N	\N
ATLETISMO	4	mn_menu	Menu	A         	\N	0	t	ADMIN	2014-01-14 17:51:30.074514	\N	\N
ATLETISMO	11	mn_generales	Datos Generales	A         	4	10	t	ADMIN	2014-01-14 17:53:10.656624	\N	\N
ATLETISMO	12	smn_entidad	Entidad	A         	11	100	t	ADMIN	2014-01-14 17:54:38.907518	\N	\N
ATLETISMO	13	smn_paises	Paises	A         	11	110	t	ADMIN	2014-01-15 02:22:33.127141	\N	\N
ATLETISMO	14	smn_ciudades	Ciudades	A         	11	120	t	ADMIN	2014-01-15 17:24:14.969116	\N	\N
ATLETISMO	15	smn_unidadmedida	Unidades De Medida	A         	11	130	t	ADMIN	2014-01-15 23:45:38.848008	\N	\N
ATLETISMO	16	smn_categorias	Categorias	A         	11	140	t	ADMIN	2014-01-16 04:57:32.87322	\N	\N
ATLETISMO	24	smn_niveles	Niveles	A         	23	100	t	ADMIN	2014-02-03 15:34:23.237108	\N	\N
ATLETISMO	23	mn_entrenadores	Entrenadores	A         	4	30	t	ADMIN	2014-02-03 15:33:43.952305	\N	\N
ATLETISMO	25	mn_ligas	Ligas	A         	4	20	t	ADMIN	2014-02-03 16:25:10.8917	\N	\N
ATLETISMO	17	smn_clubes	Clubes	A         	25	100	t	ADMIN	2014-01-17 15:35:42.866956	\N	\N
ATLETISMO	21	smn_ligas	Ligas	A         	25	110	t	ADMIN	2014-01-17 15:36:35.894364	\N	\N
ATLETISMO	27	smn_entrenadores	Entrenadores	A         	23	200	t	ADMIN	2014-02-04 02:15:10.439885	\N	\N
ATLETISMO	29	mn_atletas	Atletas	A         	4	40	t	ADMIN	2014-02-07 15:43:45.021177	\N	\N
ATLETISMO	30	smn_atletas	Atletas	A         	29	100	t	ADMIN	2014-02-07 15:44:33.516848	\N	\N
ATLETISMO	31	mn_competencias	Competencias	A         	4	50	t	ADMIN	2014-02-19 03:48:46.072903	\N	\N
ATLETISMO	32	smn_competenciatipo	Tipo De Competencias	A         	31	100	t	ADMIN	2014-02-19 03:49:37.379119	\N	\N
ATLETISMO	33	smn_competencias	Competencias	A         	31	110	t	ADMIN	2014-02-22 03:14:29.294908	\N	\N
ATLETISMO	35	smn_pruebastipo	Tipo De Pruebas	A         	34	100	t	ADMIN	2014-03-01 15:58:50.225123	\N	\N
ATLETISMO	36	smn_pruebasclasificacion	Clasificacion De Pruebas	A         	34	110	t	ADMIN	2014-03-01 19:01:12.167305	\N	\N
ATLETISMO	38	smn_carnets	Carnets	A         	29	110	t	ADMIN	2014-03-12 02:50:06.598382	\N	\N
ATLETISMO	40	smn_pruebasgenericas	Genericas	A         	34	115	t	ADMIN	2014-03-21 14:47:09.718467	\N	\N
ATLETISMO	39	smn_atletasresultados	Resultados	A         	29	120	t	ADMIN	2014-03-17 23:42:27.697067	\N	\N
ATLETISMO	34	mn_pruebas	Pruebas	A         	11	150	t	ADMIN	2014-03-01 15:57:59.690178	\N	\N
ATLETISMO	43	smn_regiones	Regiones	A         	11	105	t	ADMIN	2014-06-27 15:39:30.620084	\N	\N
ATLETISMO	44	smn_recordstipo	Tipo Records	A         	11	107	t	ADMIN	2014-06-30 16:30:55.629948	\N	\N
ATLETISMO	45	mn_records	Records	A         	4	100	t	ADMIN	2014-07-01 21:16:34.57233	\N	\N
ATLETISMO	46	smn_records	Mantenimiento	A         	45	100	t	ADMIN	2014-07-04 14:46:02.881785	\N	\N
ATLETISMO	48	smn_recordsGraph	Records graficos	A         	45	180	t	ADMIN	2014-08-03 20:37:05.575636	\N	\N
ATLETISMO	51	smn_reportes	Reportes	A         	45	200	t	ADMIN	2014-11-23 14:19:07.750109	\N	\N
ATLETISMO	49	smn_recordsHistReport	Historico / Normal	A         	51	190	t	ADMIN	2014-08-17 21:33:37.384173	\N	\N
ATLETISMO	54	smn_reportesAtletasResultados	Reportes	A         	29	400	t	ADMIN	2015-02-08 12:39:37.370479	\N	\N
ATLETISMO	55	smn_atletasResultadosReport	Resultados x Atleta	A         	54	100	t	ADMIN	2015-02-08 12:40:26.784489	\N	\N
ATLETISMO	42	smn_atletasResultadosGraph	Resultados Graficos	A         	54	125	t	ADMIN	2014-06-09 14:24:48.932961	\N	\N
ATLETISMO	57	smn_usuarios	Usuarios	A         	56	100	t	ADMIN	2015-10-04 15:00:26.551082	\N	\N
ATLETISMO	58	smn_perfiles	Perfiles	A         	56	110	t	ADMIN	2015-10-04 15:01:00.279735	\N	\N
ATLETISMO	56	mn_admin	Administrador	A         	4	5	t	ADMIN	2015-10-04 14:59:17.331335	\N	\N
\.


--
-- TOC entry 2710 (class 0 OID 0)
-- Dependencies: 212
-- Name: tb_sys_menu_menu_id_seq; Type: SEQUENCE SET; Schema: public; Owner: atluser
--

SELECT pg_catalog.setval('tb_sys_menu_menu_id_seq', 58, true);


--
-- TOC entry 2650 (class 0 OID 16722)
-- Dependencies: 213
-- Data for Name: tb_sys_perfil; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY tb_sys_perfil (perfil_id, sys_systemcode, perfil_codigo, perfil_descripcion, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
4	ATLETISMO	ADMIN	Perfil Administrador	t	TESTUSER	2015-10-04 21:34:18.153993	\N	\N
5	ATLETISMO	POWERUSER	Power User	t	TESTUSER	2015-10-04 21:41:49.702143	TESTUSER	2016-01-25 16:51:45.415906
18	ATLETISMO	TRRTRT	rtrtrtrgfdfgdfghfgh	t	TESTUSER	2016-02-01 20:33:25.445028	TESTUSER	2016-02-01 20:34:22.33115
\.


--
-- TOC entry 2651 (class 0 OID 16726)
-- Dependencies: 214
-- Data for Name: tb_sys_perfil_detalle; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY tb_sys_perfil_detalle (perfdet_id, perfdet_accessdef, perfdet_accleer, perfdet_accagregar, perfdet_accactualizar, perfdet_acceliminar, perfdet_accimprimir, perfil_id, menu_id, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
571	\N	t	t	t	t	t	18	4	t	TESTUSER	2016-02-01 20:33:25.445028	\N	\N
573	\N	t	t	t	t	t	18	25	t	TESTUSER	2016-02-01 20:33:25.445028	\N	\N
574	\N	t	t	t	t	t	18	23	t	TESTUSER	2016-02-01 20:33:25.445028	\N	\N
575	\N	t	t	t	t	t	18	29	t	TESTUSER	2016-02-01 20:33:25.445028	\N	\N
576	\N	t	t	t	t	t	18	31	t	TESTUSER	2016-02-01 20:33:25.445028	\N	\N
579	\N	t	t	t	t	t	18	24	t	TESTUSER	2016-02-01 20:33:25.445028	\N	\N
580	\N	t	t	t	t	t	18	17	t	TESTUSER	2016-02-01 20:33:25.445028	\N	\N
581	\N	t	t	t	t	t	18	30	t	TESTUSER	2016-02-01 20:33:25.445028	\N	\N
77	\N	t	t	t	t	t	5	4	t	TESTUSER	2015-10-04 21:41:49.702143	TESTUSER	2015-10-04 21:42:02.265457
582	\N	t	t	t	t	t	18	32	t	TESTUSER	2016-02-01 20:33:25.445028	\N	\N
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
583	\N	t	t	t	t	t	18	45	t	TESTUSER	2016-02-01 20:33:25.445028	\N	\N
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
584	\N	t	t	t	t	t	18	46	t	TESTUSER	2016-02-01 20:33:25.445028	\N	\N
94	\N	t	t	t	t	t	5	43	t	TESTUSER	2015-10-04 21:41:49.702143	TESTUSER	2015-10-04 21:42:02.265457
95	\N	t	t	t	t	t	5	44	t	TESTUSER	2015-10-04 21:41:49.702143	TESTUSER	2015-10-04 21:42:02.265457
96	\N	t	t	t	t	t	5	21	t	TESTUSER	2015-10-04 21:41:49.702143	TESTUSER	2015-10-04 21:42:02.265457
97	\N	t	t	t	t	t	5	36	t	TESTUSER	2015-10-04 21:41:49.702143	TESTUSER	2015-10-04 21:42:02.265457
98	\N	t	t	t	t	t	5	38	t	TESTUSER	2015-10-04 21:41:49.702143	TESTUSER	2015-10-04 21:42:02.265457
99	\N	t	t	t	t	t	5	13	t	TESTUSER	2015-10-04 21:41:49.702143	TESTUSER	2015-10-04 21:42:02.265457
100	\N	t	t	t	t	t	5	33	t	TESTUSER	2015-10-04 21:41:49.702143	TESTUSER	2015-10-04 21:42:02.265457
585	\N	t	t	t	t	t	18	55	t	TESTUSER	2016-02-01 20:33:25.445028	\N	\N
102	\N	t	t	t	t	t	5	40	t	TESTUSER	2015-10-04 21:41:49.702143	TESTUSER	2015-10-04 21:42:02.265457
103	\N	t	t	t	t	t	5	14	t	TESTUSER	2015-10-04 21:41:49.702143	TESTUSER	2015-10-04 21:42:02.265457
104	\N	t	t	t	t	t	5	37	t	TESTUSER	2015-10-04 21:41:49.702143	TESTUSER	2015-10-04 21:42:02.265457
588	\N	t	t	t	t	t	18	21	t	TESTUSER	2016-02-01 20:33:25.445028	\N	\N
590	\N	t	t	t	t	t	18	38	t	TESTUSER	2016-02-01 20:33:25.445028	\N	\N
592	\N	t	t	t	t	t	18	33	t	TESTUSER	2016-02-01 20:33:25.445028	\N	\N
596	\N	f	f	f	f	f	18	56	t	TESTUSER	2016-02-01 20:33:25.445028	\N	\N
599	\N	t	t	t	t	t	18	39	t	TESTUSER	2016-02-01 20:33:25.445028	\N	\N
78	\N	f	f	f	f	f	5	56	t	TESTUSER	2015-10-04 21:41:49.702143	TESTUSER	2016-01-25 16:53:28.983914
93	\N	f	f	f	f	f	5	57	t	TESTUSER	2015-10-04 21:41:49.702143	TESTUSER	2016-01-25 16:53:28.983914
101	\N	f	f	f	f	f	5	58	t	TESTUSER	2015-10-04 21:41:49.702143	TESTUSER	2016-01-25 16:53:28.983914
600	\N	t	t	t	t	t	18	42	t	TESTUSER	2016-02-01 20:33:25.445028	\N	\N
604	\N	t	t	t	t	t	18	48	t	TESTUSER	2016-02-01 20:33:25.445028	\N	\N
572	\N	t	t	t	t	t	18	11	t	TESTUSER	2016-02-01 20:33:25.445028	TESTUSER	2016-02-07 20:37:53.892013
605	\N	t	t	t	t	t	18	49	t	TESTUSER	2016-02-01 20:33:25.445028	\N	\N
606	\N	t	t	t	t	t	18	27	t	TESTUSER	2016-02-01 20:33:25.445028	\N	\N
607	\N	t	t	t	t	t	18	51	t	TESTUSER	2016-02-01 20:33:25.445028	\N	\N
608	\N	t	t	t	t	t	18	54	t	TESTUSER	2016-02-01 20:33:25.445028	\N	\N
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
597	\N	t	t	t	f	f	18	57	t	TESTUSER	2016-02-01 20:33:25.445028	TESTUSER	2016-02-07 16:46:46.778248
598	\N	t	f	t	f	f	18	58	t	TESTUSER	2016-02-01 20:33:25.445028	TESTUSER	2016-02-07 16:47:08.64293
577	\N	t	t	t	t	t	18	35	t	TESTUSER	2016-02-01 20:33:25.445028	TESTUSER	2016-02-07 20:37:53.892013
578	\N	t	t	t	t	t	18	12	t	TESTUSER	2016-02-01 20:33:25.445028	TESTUSER	2016-02-07 20:37:53.892013
586	\N	t	t	t	t	t	18	43	t	TESTUSER	2016-02-01 20:33:25.445028	TESTUSER	2016-02-07 20:37:53.892013
587	\N	t	t	t	t	t	18	44	t	TESTUSER	2016-02-01 20:33:25.445028	TESTUSER	2016-02-07 20:37:53.892013
589	\N	t	t	t	t	t	18	36	t	TESTUSER	2016-02-01 20:33:25.445028	TESTUSER	2016-02-07 20:37:53.892013
591	\N	t	t	t	t	t	18	13	t	TESTUSER	2016-02-01 20:33:25.445028	TESTUSER	2016-02-07 20:37:53.892013
593	\N	t	t	t	t	t	18	40	t	TESTUSER	2016-02-01 20:33:25.445028	TESTUSER	2016-02-07 20:37:53.892013
594	\N	t	t	t	t	t	18	14	t	TESTUSER	2016-02-01 20:33:25.445028	TESTUSER	2016-02-07 20:37:53.892013
595	\N	t	t	t	t	t	18	37	t	TESTUSER	2016-02-01 20:33:25.445028	TESTUSER	2016-02-07 20:37:53.892013
601	\N	t	t	t	t	t	18	15	t	TESTUSER	2016-02-01 20:33:25.445028	TESTUSER	2016-02-07 20:37:53.892013
602	\N	t	t	t	t	t	18	16	t	TESTUSER	2016-02-01 20:33:25.445028	TESTUSER	2016-02-07 20:37:53.892013
603	\N	t	t	t	t	t	18	34	t	TESTUSER	2016-02-01 20:33:25.445028	TESTUSER	2016-02-07 20:37:53.892013
\.


--
-- TOC entry 2711 (class 0 OID 0)
-- Dependencies: 215
-- Name: tb_sys_perfil_detalle_perfdet_id_seq; Type: SEQUENCE SET; Schema: public; Owner: atluser
--

SELECT pg_catalog.setval('tb_sys_perfil_detalle_perfdet_id_seq', 608, true);


--
-- TOC entry 2712 (class 0 OID 0)
-- Dependencies: 216
-- Name: tb_sys_perfil_id_seq; Type: SEQUENCE SET; Schema: public; Owner: atluser
--

SELECT pg_catalog.setval('tb_sys_perfil_id_seq', 18, true);


--
-- TOC entry 2654 (class 0 OID 16739)
-- Dependencies: 217
-- Data for Name: tb_sys_sistemas; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY tb_sys_sistemas (sys_systemcode, sistema_descripcion, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
ATLETISMO	Sistema Deportivo de la Federacion Deportiva de Atletismo	t	ADMIN	2014-01-13 00:30:14.078422	postgres	2014-01-14 17:51:23.612927
\.


--
-- TOC entry 2655 (class 0 OID 16743)
-- Dependencies: 218
-- Data for Name: tb_sys_usuario_perfiles; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY tb_sys_usuario_perfiles (usuario_perfil_id, perfil_id, usuarios_id, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
1	4	2	t	TESTUSER	2015-10-05 00:03:41.563698	TESTUSER	2016-01-26 16:22:00.235152
3	4	1	t	TESTUSER	2016-01-26 13:17:46.032845	TESTUSER	2016-02-01 15:09:50.479604
\.


--
-- TOC entry 2713 (class 0 OID 0)
-- Dependencies: 219
-- Name: tb_sys_usuario_perfiles_usuario_perfil_id_seq; Type: SEQUENCE SET; Schema: public; Owner: atluser
--

SELECT pg_catalog.setval('tb_sys_usuario_perfiles_usuario_perfil_id_seq', 6, true);


--
-- TOC entry 2657 (class 0 OID 16749)
-- Dependencies: 220
-- Data for Name: tb_unidad_medida; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY tb_unidad_medida (unidad_medida_codigo, unidad_medida_descripcion, unidad_medida_regex_e, unidad_medida_regex_m, unidad_medida_protected, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion, unidad_medida_tipo) FROM stdin;
PUNT	Puntos	^([0-9]){2,4}	^([0-9]){2,4}	f	t	postgres	2014-03-21 01:55:48.662382	TESTUSER	2014-03-27 02:48:07.680461	P
MS	Minutos,Segundos,Decimas/Centesimas	^([0-5]?[0-9])\\:([0-5][0-9])\\.([0-9][0-9])$	^([0-5]?[0-9])\\:([0-5][0-9])\\.([0-9])$	f	t	postgres	2014-03-21 01:55:48.662382	TESTUSER	2014-04-10 14:58:48.477279	T
SEG	Segundos , Decimas , Centesimas	^((([0-5]?[0-9]|2[0-3]):)?([0-5]?[0-9])).([0-9][0-9])$	^((([0-5]?[0-9]|2[0-3]):)?([0-5]?[0-9])).[0-9]$	f	t	postgres	2014-03-21 01:55:48.662382	TESTUSER	2014-04-20 17:55:20.38246	T
HMS	Horas,Minutos,Segundos	^([0-2]?[0-9])\\:([0-5][0-9])\\:([0-5][0-9])\\.([0-9][0-9])$	^([0-2]?[0-9])\\:([0-5][0-9])\\:([0-5][0-9])\\.([0-9])$	f	t	postgres	2014-03-21 01:55:48.662382	TESTUSER	2014-04-23 05:05:23.882472	T
MTSCM	Metros,Centimetros	^([1-9]?[0-9]{1})\\.([0-9]?[0-9])$	^([1-9]?[0-9]{1})\\.([0-9]?[0-9])$	f	t	postgres	2014-03-21 01:55:48.662382	TESTUSER	2016-02-08 16:34:56.425018	M
\.


--
-- TOC entry 2658 (class 0 OID 16755)
-- Dependencies: 221
-- Data for Name: tb_usuarios; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY tb_usuarios (usuarios_id, usuarios_code, usuarios_password, usuarios_nombre_completo, usuarios_admin, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
1	ADMIN	melivane100	Carlos Arana Reategui	f	t	TESTUSER	2015-10-04 18:18:38.522948	TESTUSER	18:33:24.640328
2	TEST	testx1	Soy el Test User	f	t	TESTUSER	2015-10-04 19:20:13.66406	TESTUSER	01:09:30.537483
\.


--
-- TOC entry 2714 (class 0 OID 0)
-- Dependencies: 222
-- Name: tb_usuarios_usuarios_id_seq; Type: SEQUENCE SET; Schema: public; Owner: atluser
--

SELECT pg_catalog.setval('tb_usuarios_usuarios_id_seq', 14, true);


--
-- TOC entry 2661 (class 0 OID 37545)
-- Dependencies: 224
-- Data for Name: v_count; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY v_count (count) FROM stdin;
1
\.


--
-- TOC entry 2660 (class 0 OID 16762)
-- Dependencies: 223
-- Data for Name: v_peso_desde; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY v_peso_desde (appcat_peso) FROM stdin;
0
10
20
30
40
9
6
\.


--
-- TOC entry 2278 (class 2606 OID 16805)
-- Name: pk_app_categorias; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_app_categorias_values
ADD CONSTRAINT pk_app_categorias PRIMARY KEY (appcat_codigo);


--
-- TOC entry 2281 (class 2606 OID 16807)
-- Name: pk_app_pruebas; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_app_pruebas_values
ADD CONSTRAINT pk_app_pruebas PRIMARY KEY (apppruebas_codigo);


--
-- TOC entry 2285 (class 2606 OID 16809)
-- Name: pk_atletas; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_atletas
ADD CONSTRAINT pk_atletas PRIMARY KEY (atletas_codigo);


--
-- TOC entry 2288 (class 2606 OID 16811)
-- Name: pk_atletas_carnets; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_atletas_carnets
ADD CONSTRAINT pk_atletas_carnets PRIMARY KEY (atletas_carnets_id);


--
-- TOC entry 2296 (class 2606 OID 16813)
-- Name: pk_atletas_resultados; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_atletas_resultados
ADD CONSTRAINT pk_atletas_resultados PRIMARY KEY (atletas_resultados_id);


--
-- TOC entry 2302 (class 2606 OID 16815)
-- Name: pk_atletas_resultados_detalle; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_atletas_resultados_detalle
ADD CONSTRAINT pk_atletas_resultados_detalle PRIMARY KEY (atletas_resultados_detalle_id);


--
-- TOC entry 2309 (class 2606 OID 16817)
-- Name: pk_categorias; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_categorias
ADD CONSTRAINT pk_categorias PRIMARY KEY (categorias_codigo);


--
-- TOC entry 2312 (class 2606 OID 16819)
-- Name: pk_ciudades; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_ciudades
ADD CONSTRAINT pk_ciudades PRIMARY KEY (ciudades_codigo);


--
-- TOC entry 2317 (class 2606 OID 16821)
-- Name: pk_clubes; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_clubes
ADD CONSTRAINT pk_clubes PRIMARY KEY (clubes_codigo);


--
-- TOC entry 2321 (class 2606 OID 16823)
-- Name: pk_clubesatletas; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_clubes_atletas
ADD CONSTRAINT pk_clubesatletas PRIMARY KEY (clubesatletas_id);


--
-- TOC entry 2324 (class 2606 OID 16825)
-- Name: pk_competencia_clasificacion; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_competencia_tipo
ADD CONSTRAINT pk_competencia_clasificacion PRIMARY KEY (competencia_tipo_codigo);


--
-- TOC entry 2330 (class 2606 OID 16827)
-- Name: pk_competencias; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_competencias
ADD CONSTRAINT pk_competencias PRIMARY KEY (competencias_codigo);


--
-- TOC entry 2334 (class 2606 OID 16829)
-- Name: pk_competencias_pruebas; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_competencias_pruebas
ADD CONSTRAINT pk_competencias_pruebas PRIMARY KEY (competencias_pruebas_id);


--
-- TOC entry 2340 (class 2606 OID 16831)
-- Name: pk_entrenadores; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_entrenadores
ADD CONSTRAINT pk_entrenadores PRIMARY KEY (entrenadores_codigo);


--
-- TOC entry 2346 (class 2606 OID 16833)
-- Name: pk_entrenadores_nivel; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_entrenadores_nivel
ADD CONSTRAINT pk_entrenadores_nivel PRIMARY KEY (entrenadores_nivel_codigo);


--
-- TOC entry 2344 (class 2606 OID 16835)
-- Name: pk_entrenadoresatletas; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_entrenadores_atletas
ADD CONSTRAINT pk_entrenadoresatletas PRIMARY KEY (entrenadoresatletas_id);


--
-- TOC entry 2349 (class 2606 OID 16837)
-- Name: pk_ligas; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_ligas
ADD CONSTRAINT pk_ligas PRIMARY KEY (ligas_codigo);


--
-- TOC entry 2351 (class 2606 OID 16839)
-- Name: pk_ligasclubes; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_ligas_clubes
ADD CONSTRAINT pk_ligasclubes PRIMARY KEY (ligasclubes_id);


--
-- TOC entry 2387 (class 2606 OID 16841)
-- Name: pk_menu; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_sys_menu
ADD CONSTRAINT pk_menu PRIMARY KEY (menu_id);


--
-- TOC entry 2353 (class 2606 OID 16843)
-- Name: pk_paises; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_paises
ADD CONSTRAINT pk_paises PRIMARY KEY (paises_codigo);


--
-- TOC entry 2398 (class 2606 OID 16845)
-- Name: pk_perfdet_id; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_sys_perfil_detalle
ADD CONSTRAINT pk_perfdet_id PRIMARY KEY (perfdet_id);


--
-- TOC entry 2365 (class 2606 OID 16847)
-- Name: pk_pruebas_clasificacion; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_pruebas_clasificacion
ADD CONSTRAINT pk_pruebas_clasificacion PRIMARY KEY (pruebas_clasificacion_codigo);


--
-- TOC entry 2369 (class 2606 OID 16849)
-- Name: pk_pruebas_detalle; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY tb_pruebas_detalle
ADD CONSTRAINT pk_pruebas_detalle PRIMARY KEY (pruebas_detalle_id);


--
-- TOC entry 2373 (class 2606 OID 16851)
-- Name: pk_pruebas_tipo; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_pruebas_tipo
ADD CONSTRAINT pk_pruebas_tipo PRIMARY KEY (pruebas_tipo_codigo);


--
-- TOC entry 2376 (class 2606 OID 16853)
-- Name: pk_records; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_records
ADD CONSTRAINT pk_records PRIMARY KEY (records_id);


--
-- TOC entry 2381 (class 2606 OID 16855)
-- Name: pk_records_tipos_codigo; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_records_tipo
ADD CONSTRAINT pk_records_tipos_codigo PRIMARY KEY (records_tipo_codigo);


--
-- TOC entry 2383 (class 2606 OID 16857)
-- Name: pk_regiones; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_regiones
ADD CONSTRAINT pk_regiones PRIMARY KEY (regiones_codigo);


--
-- TOC entry 2400 (class 2606 OID 16859)
-- Name: pk_sistemas; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_sys_sistemas
ADD CONSTRAINT pk_sistemas PRIMARY KEY (sys_systemcode);


--
-- TOC entry 2392 (class 2606 OID 16861)
-- Name: pk_sys_perfil; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_sys_perfil
ADD CONSTRAINT pk_sys_perfil PRIMARY KEY (perfil_id);


--
-- TOC entry 2406 (class 2606 OID 16863)
-- Name: pk_unidad_medida; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_unidad_medida
ADD CONSTRAINT pk_unidad_medida PRIMARY KEY (unidad_medida_codigo);


--
-- TOC entry 2404 (class 2606 OID 16865)
-- Name: pk_usuarioperfiles; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_sys_usuario_perfiles
ADD CONSTRAINT pk_usuarioperfiles PRIMARY KEY (usuario_perfil_id);


--
-- TOC entry 2409 (class 2606 OID 16867)
-- Name: pk_usuarios; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_usuarios
ADD CONSTRAINT pk_usuarios PRIMARY KEY (usuarios_id);


--
-- TOC entry 2416 (class 2606 OID 37672)
-- Name: tb_postas_detalle_pkey; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_postas_detalle
ADD CONSTRAINT tb_postas_detalle_pkey PRIMARY KEY (postas_detalle_id);


--
-- TOC entry 2413 (class 2606 OID 37656)
-- Name: tb_postas_pkey; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_postas
ADD CONSTRAINT tb_postas_pkey PRIMARY KEY (postas_id);


--
-- TOC entry 2359 (class 2606 OID 16869)
-- Name: tb_pruebas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY tb_pruebas
ADD CONSTRAINT tb_pruebas_pkey PRIMARY KEY (pruebas_codigo);


--
-- TOC entry 2290 (class 2606 OID 16871)
-- Name: unq_atletas_carnets; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_atletas_carnets
ADD CONSTRAINT unq_atletas_carnets UNIQUE (atletas_carnets_agno, atletas_codigo);


--
-- TOC entry 2292 (class 2606 OID 16873)
-- Name: unq_atletas_carnets_numero; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_atletas_carnets
ADD CONSTRAINT unq_atletas_carnets_numero UNIQUE (atletas_carnets_agno, atletas_carnets_numero);


--
-- TOC entry 2298 (class 2606 OID 37756)
-- Name: unq_atletas_resultados; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_atletas_resultados
ADD CONSTRAINT unq_atletas_resultados UNIQUE (atletas_codigo, competencias_pruebas_id, postas_id);


--
-- TOC entry 2304 (class 2606 OID 16877)
-- Name: unq_atletas_resultados_detalle_pruebas_detalle; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_atletas_resultados_detalle
ADD CONSTRAINT unq_atletas_resultados_detalle_pruebas_detalle UNIQUE (atletas_resultados_detalle_id, pruebas_codigo);


--
-- TOC entry 2314 (class 2606 OID 16879)
-- Name: unq_ciudades_paises; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_ciudades
ADD CONSTRAINT unq_ciudades_paises UNIQUE (ciudades_codigo, paises_codigo);


--
-- TOC entry 2389 (class 2606 OID 16881)
-- Name: unq_codigomenu; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_sys_menu
ADD CONSTRAINT unq_codigomenu UNIQUE (menu_codigo);


--
-- TOC entry 2336 (class 2606 OID 16883)
-- Name: unq_competencias_pruebas; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_competencias_pruebas
ADD CONSTRAINT unq_competencias_pruebas UNIQUE (competencias_codigo, pruebas_codigo, competencias_pruebas_origen_combinada, competencias_pruebas_tipo_serie, competencias_pruebas_nro_serie);


--
-- TOC entry 2394 (class 2606 OID 16885)
-- Name: unq_perfil_syscode_codigo; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_sys_perfil
ADD CONSTRAINT unq_perfil_syscode_codigo UNIQUE (sys_systemcode, perfil_codigo);


--
-- TOC entry 2396 (class 2606 OID 16887)
-- Name: unq_perfil_syscode_perfil_id; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_sys_perfil
ADD CONSTRAINT unq_perfil_syscode_perfil_id UNIQUE (sys_systemcode, perfil_id);


--
-- TOC entry 2371 (class 2606 OID 16889)
-- Name: unq_pruebas_detalle; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY tb_pruebas_detalle
ADD CONSTRAINT unq_pruebas_detalle UNIQUE (pruebas_codigo, pruebas_detalle_prueba_codigo);


--
-- TOC entry 2715 (class 0 OID 0)
-- Dependencies: 2371
-- Name: CONSTRAINT unq_pruebas_detalle ON tb_pruebas_detalle; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON CONSTRAINT unq_pruebas_detalle ON tb_pruebas_detalle IS 'No puede repetirse la misma prueba en el detalle';


--
-- TOC entry 2361 (class 2606 OID 16891)
-- Name: unq_pruebas_nombre; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY tb_pruebas
ADD CONSTRAINT unq_pruebas_nombre UNIQUE (pruebas_descripcion, categorias_codigo, pruebas_sexo);


--
-- TOC entry 2378 (class 2606 OID 16893)
-- Name: unq_records; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_records
ADD CONSTRAINT unq_records UNIQUE (records_tipo_codigo, atletas_resultados_id, categorias_codigo);


--
-- TOC entry 2299 (class 1259 OID 16894)
-- Name: fk_atletas_resultados_pruebas_codigo; Type: INDEX; Schema: public; Owner: atluser; Tablespace:
--

CREATE INDEX fk_atletas_resultados_pruebas_codigo ON tb_atletas_resultados_detalle USING btree (pruebas_codigo);


--
-- TOC entry 2279 (class 1259 OID 16895)
-- Name: fki_app_pruebas_pruebas_clasificacion; Type: INDEX; Schema: public; Owner: atluser; Tablespace:
--

CREATE INDEX fki_app_pruebas_pruebas_clasificacion ON tb_app_pruebas_values USING btree (pruebas_clasificacion_codigo);


--
-- TOC entry 2282 (class 1259 OID 16896)
-- Name: fki_atletas; Type: INDEX; Schema: public; Owner: atluser; Tablespace:
--

CREATE INDEX fki_atletas ON tb_atletas USING btree (atletas_codigo);


--
-- TOC entry 2286 (class 1259 OID 16897)
-- Name: fki_atletas_carnets_atletas; Type: INDEX; Schema: public; Owner: atluser; Tablespace:
--

CREATE INDEX fki_atletas_carnets_atletas ON tb_atletas_carnets USING btree (atletas_codigo);


--
-- TOC entry 2293 (class 1259 OID 16898)
-- Name: fki_atletas_resultados_atletas_codigo; Type: INDEX; Schema: public; Owner: atluser; Tablespace:
--

CREATE INDEX fki_atletas_resultados_atletas_codigo ON tb_atletas_resultados USING btree (atletas_codigo);


--
-- TOC entry 2294 (class 1259 OID 16899)
-- Name: fki_atletas_resultados_competencias_pruebas; Type: INDEX; Schema: public; Owner: atluser; Tablespace:
--

CREATE INDEX fki_atletas_resultados_competencias_pruebas ON tb_atletas_resultados USING btree (competencias_pruebas_id);


--
-- TOC entry 2300 (class 1259 OID 16900)
-- Name: fki_atletas_resultados_detalle_resultados_id; Type: INDEX; Schema: public; Owner: atluser; Tablespace:
--

CREATE INDEX fki_atletas_resultados_detalle_resultados_id ON tb_atletas_resultados_detalle USING btree (atletas_resultados_id);


--
-- TOC entry 2307 (class 1259 OID 16901)
-- Name: fki_categorias_appcat; Type: INDEX; Schema: public; Owner: atluser; Tablespace:
--

CREATE INDEX fki_categorias_appcat ON tb_categorias USING btree (categorias_validacion);


--
-- TOC entry 2310 (class 1259 OID 16902)
-- Name: fki_ciudad_pais; Type: INDEX; Schema: public; Owner: atluser; Tablespace:
--

CREATE INDEX fki_ciudad_pais ON tb_ciudades USING btree (paises_codigo);


--
-- TOC entry 2318 (class 1259 OID 16903)
-- Name: fki_clubesatletas_atletas; Type: INDEX; Schema: public; Owner: atluser; Tablespace:
--

CREATE INDEX fki_clubesatletas_atletas ON tb_clubes_atletas USING btree (atletas_codigo);


--
-- TOC entry 2319 (class 1259 OID 16904)
-- Name: fki_clubesatletas_clubes; Type: INDEX; Schema: public; Owner: atluser; Tablespace:
--

CREATE INDEX fki_clubesatletas_clubes ON tb_clubes_atletas USING btree (clubes_codigo);


--
-- TOC entry 2325 (class 1259 OID 16905)
-- Name: fki_competencias_categorias_codigo; Type: INDEX; Schema: public; Owner: atluser; Tablespace:
--

CREATE INDEX fki_competencias_categorias_codigo ON tb_competencias USING btree (categorias_codigo);


--
-- TOC entry 2326 (class 1259 OID 16906)
-- Name: fki_competencias_ciudades_codigo; Type: INDEX; Schema: public; Owner: atluser; Tablespace:
--

CREATE INDEX fki_competencias_ciudades_codigo ON tb_competencias USING btree (paises_codigo, ciudades_codigo);


--
-- TOC entry 2327 (class 1259 OID 16907)
-- Name: fki_competencias_competencia_tipo; Type: INDEX; Schema: public; Owner: atluser; Tablespace:
--

CREATE INDEX fki_competencias_competencia_tipo ON tb_competencias USING btree (competencia_tipo_codigo);


--
-- TOC entry 2328 (class 1259 OID 16908)
-- Name: fki_competencias_paises_codigo; Type: INDEX; Schema: public; Owner: atluser; Tablespace:
--

CREATE INDEX fki_competencias_paises_codigo ON tb_competencias USING btree (paises_codigo);


--
-- TOC entry 2337 (class 1259 OID 16909)
-- Name: fki_entrenadores_nivel; Type: INDEX; Schema: public; Owner: atluser; Tablespace:
--

CREATE INDEX fki_entrenadores_nivel ON tb_entrenadores USING btree (entrenadores_nivel_codigo);


--
-- TOC entry 2341 (class 1259 OID 16910)
-- Name: fki_entrenadoresatletas_atletas; Type: INDEX; Schema: public; Owner: atluser; Tablespace:
--

CREATE INDEX fki_entrenadoresatletas_atletas ON tb_entrenadores_atletas USING btree (atletas_codigo);


--
-- TOC entry 2342 (class 1259 OID 16911)
-- Name: fki_entrenadoresatletas_entrenadores; Type: INDEX; Schema: public; Owner: atluser; Tablespace:
--

CREATE INDEX fki_entrenadoresatletas_entrenadores ON tb_entrenadores_atletas USING btree (entrenadores_codigo);


--
-- TOC entry 2384 (class 1259 OID 16912)
-- Name: fki_menu_parent_id; Type: INDEX; Schema: public; Owner: atluser; Tablespace:
--

CREATE INDEX fki_menu_parent_id ON tb_sys_menu USING btree (menu_parent_id);


--
-- TOC entry 2385 (class 1259 OID 16913)
-- Name: fki_menu_sistemas; Type: INDEX; Schema: public; Owner: atluser; Tablespace:
--

CREATE INDEX fki_menu_sistemas ON tb_sys_menu USING btree (sys_systemcode);


--
-- TOC entry 2390 (class 1259 OID 16914)
-- Name: fki_perfil_sistema; Type: INDEX; Schema: public; Owner: atluser; Tablespace:
--

CREATE INDEX fki_perfil_sistema ON tb_sys_perfil USING btree (sys_systemcode);


--
-- TOC entry 2401 (class 1259 OID 16915)
-- Name: fki_perfil_usuario; Type: INDEX; Schema: public; Owner: atluser; Tablespace:
--

CREATE INDEX fki_perfil_usuario ON tb_sys_usuario_perfiles USING btree (perfil_id);


--
-- TOC entry 2354 (class 1259 OID 16916)
-- Name: fki_pruebas_apppruebas; Type: INDEX; Schema: public; Owner: postgres; Tablespace:
--

CREATE INDEX fki_pruebas_apppruebas ON tb_pruebas USING btree (pruebas_generica_codigo);


--
-- TOC entry 2355 (class 1259 OID 16917)
-- Name: fki_pruebas_categoria; Type: INDEX; Schema: public; Owner: postgres; Tablespace:
--

CREATE INDEX fki_pruebas_categoria ON tb_pruebas USING btree (categorias_codigo);


--
-- TOC entry 2356 (class 1259 OID 16918)
-- Name: fki_pruebas_categorias_hasta; Type: INDEX; Schema: public; Owner: postgres; Tablespace:
--

CREATE INDEX fki_pruebas_categorias_hasta ON tb_pruebas USING btree (pruebas_record_hasta);


--
-- TOC entry 2362 (class 1259 OID 16919)
-- Name: fki_pruebas_clasificacion_pruebas_tipo; Type: INDEX; Schema: public; Owner: atluser; Tablespace:
--

CREATE INDEX fki_pruebas_clasificacion_pruebas_tipo ON tb_pruebas_clasificacion USING btree (pruebas_tipo_codigo);


--
-- TOC entry 2363 (class 1259 OID 16920)
-- Name: fki_pruebas_clasificacion_um; Type: INDEX; Schema: public; Owner: atluser; Tablespace:
--

CREATE INDEX fki_pruebas_clasificacion_um ON tb_pruebas_clasificacion USING btree (unidad_medida_codigo);


--
-- TOC entry 2374 (class 1259 OID 16921)
-- Name: fki_record_id_origen; Type: INDEX; Schema: public; Owner: atluser; Tablespace:
--

CREATE INDEX fki_record_id_origen ON tb_records USING btree (records_id_origen);


--
-- TOC entry 2305 (class 1259 OID 16922)
-- Name: fki_tb_atletas_resultados_competencias_codigo; Type: INDEX; Schema: public; Owner: atluser; Tablespace:
--

CREATE INDEX fki_tb_atletas_resultados_competencias_codigo ON tb_atletas_resultados_old USING btree (competencias_codigo);


--
-- TOC entry 2306 (class 1259 OID 16923)
-- Name: fki_tb_atletas_resultados_pruebas_codigo; Type: INDEX; Schema: public; Owner: atluser; Tablespace:
--

CREATE INDEX fki_tb_atletas_resultados_pruebas_codigo ON tb_atletas_resultados_old USING btree (pruebas_codigo);


--
-- TOC entry 2331 (class 1259 OID 16924)
-- Name: fki_tb_competencias_pruebas_competencias_codigo; Type: INDEX; Schema: public; Owner: atluser; Tablespace:
--

CREATE INDEX fki_tb_competencias_pruebas_competencias_codigo ON tb_competencias_pruebas USING btree (competencias_codigo);


--
-- TOC entry 2332 (class 1259 OID 16925)
-- Name: fki_tb_competencias_pruebas_pruebas_codigo; Type: INDEX; Schema: public; Owner: atluser; Tablespace:
--

CREATE INDEX fki_tb_competencias_pruebas_pruebas_codigo ON tb_competencias_pruebas USING btree (pruebas_codigo);


--
-- TOC entry 2366 (class 1259 OID 16926)
-- Name: fki_tb_pruebas_detalle_prueba_detalle_codigo; Type: INDEX; Schema: public; Owner: postgres; Tablespace:
--

CREATE INDEX fki_tb_pruebas_detalle_prueba_detalle_codigo ON tb_pruebas_detalle USING btree (pruebas_detalle_prueba_codigo);


--
-- TOC entry 2367 (class 1259 OID 16927)
-- Name: fki_tb_pruebas_detalle_pruebas; Type: INDEX; Schema: public; Owner: postgres; Tablespace:
--

CREATE INDEX fki_tb_pruebas_detalle_pruebas ON tb_pruebas_detalle USING btree (pruebas_codigo);


--
-- TOC entry 2402 (class 1259 OID 16928)
-- Name: fki_usuarioperfiles; Type: INDEX; Schema: public; Owner: atluser; Tablespace:
--

CREATE INDEX fki_usuarioperfiles ON tb_sys_usuario_perfiles USING btree (usuarios_id);


--
-- TOC entry 2283 (class 1259 OID 16929)
-- Name: idx_atletas_nmcompleto; Type: INDEX; Schema: public; Owner: atluser; Tablespace:
--

CREATE UNIQUE INDEX idx_atletas_nmcompleto ON tb_atletas USING btree (upper((atletas_nombre_completo)::text));


--
-- TOC entry 2322 (class 1259 OID 16930)
-- Name: idx_competencia_tipo_descripcion; Type: INDEX; Schema: public; Owner: atluser; Tablespace:
--

CREATE UNIQUE INDEX idx_competencia_tipo_descripcion ON tb_competencia_tipo USING btree (upper((competencia_tipo_descripcion)::text));


--
-- TOC entry 2338 (class 1259 OID 16931)
-- Name: idx_entrenadores_nmcompleto; Type: INDEX; Schema: public; Owner: atluser; Tablespace:
--

CREATE UNIQUE INDEX idx_entrenadores_nmcompleto ON tb_entrenadores USING btree (upper((entrenadores_nombre_completo)::text));


--
-- TOC entry 2379 (class 1259 OID 16932)
-- Name: idx_records_tipo_descripcion; Type: INDEX; Schema: public; Owner: atluser; Tablespace:
--

CREATE UNIQUE INDEX idx_records_tipo_descripcion ON tb_records_tipo USING btree (upper((records_tipo_descripcion)::text));


--
-- TOC entry 2407 (class 1259 OID 16933)
-- Name: idx_unique_usuarios; Type: INDEX; Schema: public; Owner: atluser; Tablespace:
--

CREATE UNIQUE INDEX idx_unique_usuarios ON tb_usuarios USING btree (upper((usuarios_code)::text));


--
-- TOC entry 2315 (class 1259 OID 16934)
-- Name: idx_unq_descripcion; Type: INDEX; Schema: public; Owner: atluser; Tablespace:
--

CREATE UNIQUE INDEX idx_unq_descripcion ON tb_clubes USING btree (upper((clubes_descripcion)::text));


--
-- TOC entry 2347 (class 1259 OID 16935)
-- Name: idx_unq_ligas_descripcion; Type: INDEX; Schema: public; Owner: atluser; Tablespace:
--

CREATE UNIQUE INDEX idx_unq_ligas_descripcion ON tb_ligas USING btree (upper((ligas_descripcion)::text));


--
-- TOC entry 2410 (class 1259 OID 37693)
-- Name: idx_unq_postas_descripcion_competencia; Type: INDEX; Schema: public; Owner: atluser; Tablespace:
--

CREATE UNIQUE INDEX idx_unq_postas_descripcion_competencia ON tb_postas USING btree (upper((postas_descripcion)::text), competencias_pruebas_id);


--
-- TOC entry 2414 (class 1259 OID 37683)
-- Name: idx_unq_postas_detalle_id; Type: INDEX; Schema: public; Owner: atluser; Tablespace:
--

CREATE UNIQUE INDEX idx_unq_postas_detalle_id ON tb_postas_detalle USING btree (postas_detalle_id);


--
-- TOC entry 2411 (class 1259 OID 37662)
-- Name: idx_unq_postas_id; Type: INDEX; Schema: public; Owner: atluser; Tablespace:
--

CREATE UNIQUE INDEX idx_unq_postas_id ON tb_postas USING btree (postas_id);


--
-- TOC entry 2357 (class 1259 OID 16936)
-- Name: pk_pruebas; Type: INDEX; Schema: public; Owner: postgres; Tablespace:
--

CREATE UNIQUE INDEX pk_pruebas ON tb_pruebas USING btree (pruebas_codigo);


--
-- TOC entry 2497 (class 2620 OID 16937)
-- Name: sptrg_verify_usuario_code_change; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER sptrg_verify_usuario_code_change BEFORE INSERT OR DELETE OR UPDATE ON tb_usuarios FOR EACH ROW EXECUTE PROCEDURE sptrg_verify_usuario_code_change();


--
-- TOC entry 2480 (class 2620 OID 16938)
-- Name: t__entrenadores_nivel; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER t__entrenadores_nivel BEFORE INSERT OR UPDATE ON tb_entrenadores_nivel FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2496 (class 2620 OID 16939)
-- Name: tb_unidad_medida; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tb_unidad_medida BEFORE INSERT OR UPDATE ON tb_unidad_medida FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2463 (class 2620 OID 16940)
-- Name: tr_app_categorias_values; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_app_categorias_values BEFORE INSERT OR UPDATE ON tb_app_categorias_values FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2464 (class 2620 OID 16941)
-- Name: tr_app_pruebas_values; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_app_pruebas_values BEFORE INSERT OR UPDATE ON tb_app_pruebas_values FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2465 (class 2620 OID 16942)
-- Name: tr_atletas; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_atletas BEFORE INSERT OR UPDATE ON tb_atletas FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2466 (class 2620 OID 16943)
-- Name: tr_atletas_carnets; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_atletas_carnets BEFORE INSERT OR UPDATE ON tb_atletas_carnets FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2469 (class 2620 OID 16944)
-- Name: tr_atletas_resultados; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_atletas_resultados BEFORE INSERT OR UPDATE ON tb_atletas_resultados_old FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2467 (class 2620 OID 16945)
-- Name: tr_atletas_resultados; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_atletas_resultados BEFORE INSERT OR UPDATE ON tb_atletas_resultados FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2468 (class 2620 OID 16946)
-- Name: tr_atletas_resultados_detalle; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_atletas_resultados_detalle BEFORE INSERT OR UPDATE ON tb_atletas_resultados_detalle FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2470 (class 2620 OID 16947)
-- Name: tr_categorias; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_categorias BEFORE INSERT OR UPDATE ON tb_categorias FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2471 (class 2620 OID 16948)
-- Name: tr_ciudades; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_ciudades BEFORE INSERT OR UPDATE ON tb_ciudades FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2472 (class 2620 OID 16949)
-- Name: tr_clubes; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_clubes BEFORE INSERT OR UPDATE ON tb_clubes FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2473 (class 2620 OID 16950)
-- Name: tr_clubes_atletas; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_clubes_atletas BEFORE INSERT OR UPDATE ON tb_clubes_atletas FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2474 (class 2620 OID 16951)
-- Name: tr_competencia_clasificacion; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_competencia_clasificacion BEFORE INSERT OR UPDATE ON tb_competencia_tipo FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2475 (class 2620 OID 16952)
-- Name: tr_competencias; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_competencias BEFORE INSERT OR UPDATE ON tb_competencias FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2476 (class 2620 OID 16953)
-- Name: tr_competencias_pruebas; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_competencias_pruebas BEFORE INSERT OR UPDATE ON tb_competencias_pruebas FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2477 (class 2620 OID 16954)
-- Name: tr_entidad; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_entidad BEFORE INSERT OR UPDATE ON tb_entidad FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2478 (class 2620 OID 16955)
-- Name: tr_entrenadores; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_entrenadores BEFORE INSERT OR UPDATE ON tb_entrenadores FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2479 (class 2620 OID 16956)
-- Name: tr_entrenadores_atletas; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_entrenadores_atletas BEFORE INSERT OR UPDATE ON tb_entrenadores_atletas FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2481 (class 2620 OID 16957)
-- Name: tr_ligas; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_ligas BEFORE INSERT OR UPDATE ON tb_ligas FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2482 (class 2620 OID 16958)
-- Name: tr_ligasclubes; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_ligasclubes BEFORE INSERT OR UPDATE ON tb_ligas_clubes FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2483 (class 2620 OID 16959)
-- Name: tr_paises; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_paises BEFORE INSERT OR UPDATE ON tb_paises FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2499 (class 2620 OID 37663)
-- Name: tr_postas; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_postas BEFORE INSERT OR UPDATE ON tb_postas FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2500 (class 2620 OID 37684)
-- Name: tr_postas_detalle; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_postas_detalle BEFORE INSERT OR UPDATE ON tb_postas_detalle FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2484 (class 2620 OID 16960)
-- Name: tr_pruebas; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tr_pruebas BEFORE INSERT OR UPDATE ON tb_pruebas FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2485 (class 2620 OID 16961)
-- Name: tr_pruebas_clasificacion; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_pruebas_clasificacion BEFORE INSERT OR UPDATE ON tb_pruebas_clasificacion FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2486 (class 2620 OID 16962)
-- Name: tr_pruebas_detalle; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tr_pruebas_detalle BEFORE INSERT OR UPDATE ON tb_pruebas_detalle FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2487 (class 2620 OID 16963)
-- Name: tr_pruebas_tipo; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_pruebas_tipo BEFORE INSERT OR UPDATE ON tb_pruebas_tipo FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2488 (class 2620 OID 16964)
-- Name: tr_records; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_records BEFORE INSERT OR UPDATE ON tb_records FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2489 (class 2620 OID 16965)
-- Name: tr_records_save; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_records_save BEFORE INSERT OR UPDATE ON tb_records FOR EACH ROW EXECUTE PROCEDURE sptrg_records_save();


--
-- TOC entry 2490 (class 2620 OID 16966)
-- Name: tr_records_tipo; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_records_tipo BEFORE INSERT OR UPDATE ON tb_records_tipo FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2491 (class 2620 OID 16967)
-- Name: tr_regiones; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_regiones BEFORE INSERT OR UPDATE ON tb_regiones FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2492 (class 2620 OID 16968)
-- Name: tr_sys_perfil; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_sys_perfil BEFORE INSERT OR UPDATE ON tb_sys_perfil FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2493 (class 2620 OID 16969)
-- Name: tr_sys_perfil_detalle; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_sys_perfil_detalle BEFORE INSERT OR UPDATE ON tb_sys_perfil_detalle FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2494 (class 2620 OID 16970)
-- Name: tr_sys_sistemas; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_sys_sistemas BEFORE INSERT OR UPDATE ON tb_sys_sistemas FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2495 (class 2620 OID 16971)
-- Name: tr_sys_usuario_perfiles; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_sys_usuario_perfiles BEFORE INSERT OR UPDATE ON tb_sys_usuario_perfiles FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2498 (class 2620 OID 16972)
-- Name: tr_usuarios; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_usuarios BEFORE INSERT OR UPDATE ON tb_usuarios FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2450 (class 2606 OID 16973)
-- Name: categorias_codigo; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_records
ADD CONSTRAINT categorias_codigo FOREIGN KEY (categorias_codigo) REFERENCES tb_categorias(categorias_codigo);


--
-- TOC entry 2417 (class 2606 OID 16978)
-- Name: fk_app_pruebas_pruebas_clasificacion; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_app_pruebas_values
ADD CONSTRAINT fk_app_pruebas_pruebas_clasificacion FOREIGN KEY (pruebas_clasificacion_codigo) REFERENCES tb_pruebas_clasificacion(pruebas_clasificacion_codigo);


--
-- TOC entry 2419 (class 2606 OID 16983)
-- Name: fk_atletas_carnets_atletas; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_atletas_carnets
ADD CONSTRAINT fk_atletas_carnets_atletas FOREIGN KEY (atletas_codigo) REFERENCES tb_atletas(atletas_codigo);


--
-- TOC entry 2418 (class 2606 OID 16988)
-- Name: fk_atletas_pais; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_atletas
ADD CONSTRAINT fk_atletas_pais FOREIGN KEY (paises_codigo) REFERENCES tb_paises(paises_codigo);


--
-- TOC entry 2420 (class 2606 OID 16993)
-- Name: fk_atletas_resultados_atletas_codigo; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_atletas_resultados
ADD CONSTRAINT fk_atletas_resultados_atletas_codigo FOREIGN KEY (atletas_codigo) REFERENCES tb_atletas(atletas_codigo);


--
-- TOC entry 2421 (class 2606 OID 16998)
-- Name: fk_atletas_resultados_competencias_pruebas; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_atletas_resultados
ADD CONSTRAINT fk_atletas_resultados_competencias_pruebas FOREIGN KEY (competencias_pruebas_id) REFERENCES tb_competencias_pruebas(competencias_pruebas_id);


--
-- TOC entry 2422 (class 2606 OID 37737)
-- Name: fk_atletas_resultados_postas; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_atletas_resultados
ADD CONSTRAINT fk_atletas_resultados_postas FOREIGN KEY (postas_id) REFERENCES tb_postas(postas_id);


--
-- TOC entry 2423 (class 2606 OID 17003)
-- Name: fk_atletas_resultados_pruebas_codigo; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_atletas_resultados_detalle
ADD CONSTRAINT fk_atletas_resultados_pruebas_codigo FOREIGN KEY (pruebas_codigo) REFERENCES tb_pruebas(pruebas_codigo);


--
-- TOC entry 2426 (class 2606 OID 17008)
-- Name: fk_categorias_appcat; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_categorias
ADD CONSTRAINT fk_categorias_appcat FOREIGN KEY (categorias_validacion) REFERENCES tb_app_categorias_values(appcat_codigo);


--
-- TOC entry 2427 (class 2606 OID 17013)
-- Name: fk_ciudad_pais; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_ciudades
ADD CONSTRAINT fk_ciudad_pais FOREIGN KEY (paises_codigo) REFERENCES tb_paises(paises_codigo);


--
-- TOC entry 2428 (class 2606 OID 17018)
-- Name: fk_clubesatletas_atletas; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_clubes_atletas
ADD CONSTRAINT fk_clubesatletas_atletas FOREIGN KEY (atletas_codigo) REFERENCES tb_atletas(atletas_codigo);


--
-- TOC entry 2429 (class 2606 OID 17023)
-- Name: fk_clubesatletas_clubes; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_clubes_atletas
ADD CONSTRAINT fk_clubesatletas_clubes FOREIGN KEY (clubes_codigo) REFERENCES tb_clubes(clubes_codigo);


--
-- TOC entry 2430 (class 2606 OID 17028)
-- Name: fk_competencias_categorias_codigo; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_competencias
ADD CONSTRAINT fk_competencias_categorias_codigo FOREIGN KEY (categorias_codigo) REFERENCES tb_categorias(categorias_codigo);


--
-- TOC entry 2431 (class 2606 OID 17033)
-- Name: fk_competencias_ciudades_codigo; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_competencias
ADD CONSTRAINT fk_competencias_ciudades_codigo FOREIGN KEY (paises_codigo, ciudades_codigo) REFERENCES tb_ciudades(paises_codigo, ciudades_codigo);


--
-- TOC entry 2432 (class 2606 OID 17038)
-- Name: fk_competencias_competencia_tipo; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_competencias
ADD CONSTRAINT fk_competencias_competencia_tipo FOREIGN KEY (competencia_tipo_codigo) REFERENCES tb_competencia_tipo(competencia_tipo_codigo);


--
-- TOC entry 2433 (class 2606 OID 17043)
-- Name: fk_competencias_paises_codigo; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_competencias
ADD CONSTRAINT fk_competencias_paises_codigo FOREIGN KEY (paises_codigo) REFERENCES tb_paises(paises_codigo);


--
-- TOC entry 2460 (class 2606 OID 37657)
-- Name: fk_competencias_pruebas; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_postas
ADD CONSTRAINT fk_competencias_pruebas FOREIGN KEY (competencias_pruebas_id) REFERENCES tb_competencias_pruebas(competencias_pruebas_id);


--
-- TOC entry 2436 (class 2606 OID 17153)
-- Name: fk_competencias_pruebas_competencias_codigo; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_competencias_pruebas
ADD CONSTRAINT fk_competencias_pruebas_competencias_codigo FOREIGN KEY (competencias_codigo) REFERENCES tb_competencias(competencias_codigo);


--
-- TOC entry 2434 (class 2606 OID 17048)
-- Name: fk_competencias_pruebas_origen_id; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_competencias_pruebas
ADD CONSTRAINT fk_competencias_pruebas_origen_id FOREIGN KEY (competencias_pruebas_origen_id) REFERENCES tb_competencias_pruebas(competencias_pruebas_id);


--
-- TOC entry 2435 (class 2606 OID 17158)
-- Name: fk_competencias_pruebas_pruebas_codigo; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_competencias_pruebas
ADD CONSTRAINT fk_competencias_pruebas_pruebas_codigo FOREIGN KEY (pruebas_codigo) REFERENCES tb_pruebas(pruebas_codigo);


--
-- TOC entry 2437 (class 2606 OID 17053)
-- Name: fk_entrenadores_nivel; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_entrenadores
ADD CONSTRAINT fk_entrenadores_nivel FOREIGN KEY (entrenadores_nivel_codigo) REFERENCES tb_entrenadores_nivel(entrenadores_nivel_codigo);


--
-- TOC entry 2438 (class 2606 OID 17058)
-- Name: fk_entrenadoresatletas_atletas; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_entrenadores_atletas
ADD CONSTRAINT fk_entrenadoresatletas_atletas FOREIGN KEY (atletas_codigo) REFERENCES tb_atletas(atletas_codigo);


--
-- TOC entry 2439 (class 2606 OID 17063)
-- Name: fk_entrenadoresatletas_entrenadores; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_entrenadores_atletas
ADD CONSTRAINT fk_entrenadoresatletas_entrenadores FOREIGN KEY (entrenadores_codigo) REFERENCES tb_entrenadores(entrenadores_codigo);


--
-- TOC entry 2440 (class 2606 OID 17068)
-- Name: fk_ligasclubes_clubes; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_ligas_clubes
ADD CONSTRAINT fk_ligasclubes_clubes FOREIGN KEY (clubes_codigo) REFERENCES tb_clubes(clubes_codigo);


--
-- TOC entry 2441 (class 2606 OID 17073)
-- Name: fk_ligasclubes_ligas; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_ligas_clubes
ADD CONSTRAINT fk_ligasclubes_ligas FOREIGN KEY (ligas_codigo) REFERENCES tb_ligas(ligas_codigo);


--
-- TOC entry 2454 (class 2606 OID 17078)
-- Name: fk_menu_parent; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_sys_menu
ADD CONSTRAINT fk_menu_parent FOREIGN KEY (menu_parent_id) REFERENCES tb_sys_menu(menu_id);


--
-- TOC entry 2455 (class 2606 OID 17083)
-- Name: fk_menu_sistemas; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_sys_menu
ADD CONSTRAINT fk_menu_sistemas FOREIGN KEY (sys_systemcode) REFERENCES tb_sys_sistemas(sys_systemcode);


--
-- TOC entry 2442 (class 2606 OID 17088)
-- Name: fk_paises_regiones; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_paises
ADD CONSTRAINT fk_paises_regiones FOREIGN KEY (regiones_codigo) REFERENCES tb_regiones(regiones_codigo);


--
-- TOC entry 2457 (class 2606 OID 17093)
-- Name: fk_perfdet_perfil; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_sys_perfil_detalle
ADD CONSTRAINT fk_perfdet_perfil FOREIGN KEY (perfil_id) REFERENCES tb_sys_perfil(perfil_id);


--
-- TOC entry 2456 (class 2606 OID 17098)
-- Name: fk_perfil_sistema; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_sys_perfil
ADD CONSTRAINT fk_perfil_sistema FOREIGN KEY (sys_systemcode) REFERENCES tb_sys_sistemas(sys_systemcode);


--
-- TOC entry 2461 (class 2606 OID 37673)
-- Name: fk_postas_detalle_atletas; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_postas_detalle
ADD CONSTRAINT fk_postas_detalle_atletas FOREIGN KEY (atletas_codigo) REFERENCES tb_atletas(atletas_codigo);


--
-- TOC entry 2462 (class 2606 OID 37678)
-- Name: fk_postas_detalles_postas; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_postas_detalle
ADD CONSTRAINT fk_postas_detalles_postas FOREIGN KEY (postas_id) REFERENCES tb_postas(postas_id);


--
-- TOC entry 2443 (class 2606 OID 17103)
-- Name: fk_pruebas_apppruebas; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY tb_pruebas
ADD CONSTRAINT fk_pruebas_apppruebas FOREIGN KEY (pruebas_generica_codigo) REFERENCES tb_app_pruebas_values(apppruebas_codigo);


--
-- TOC entry 2446 (class 2606 OID 17108)
-- Name: fk_pruebas_clasificacion_pruebas_tipo; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_pruebas_clasificacion
ADD CONSTRAINT fk_pruebas_clasificacion_pruebas_tipo FOREIGN KEY (pruebas_tipo_codigo) REFERENCES tb_pruebas_tipo(pruebas_tipo_codigo);


--
-- TOC entry 2447 (class 2606 OID 17113)
-- Name: fk_pruebas_clasificacion_um; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_pruebas_clasificacion
ADD CONSTRAINT fk_pruebas_clasificacion_um FOREIGN KEY (unidad_medida_codigo) REFERENCES tb_unidad_medida(unidad_medida_codigo);


--
-- TOC entry 2451 (class 2606 OID 17118)
-- Name: fk_record_id_origen; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_records
ADD CONSTRAINT fk_record_id_origen FOREIGN KEY (records_id_origen) REFERENCES tb_records(records_id);


--
-- TOC entry 2452 (class 2606 OID 17123)
-- Name: fk_records_atletas_resultados; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_records
ADD CONSTRAINT fk_records_atletas_resultados FOREIGN KEY (atletas_resultados_id) REFERENCES tb_atletas_resultados(atletas_resultados_id);


--
-- TOC entry 2453 (class 2606 OID 17128)
-- Name: fk_records_tipo; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_records
ADD CONSTRAINT fk_records_tipo FOREIGN KEY (records_tipo_codigo) REFERENCES tb_records_tipo(records_tipo_codigo);


--
-- TOC entry 2458 (class 2606 OID 17133)
-- Name: fk_usuarioperfiles; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_sys_usuario_perfiles
ADD CONSTRAINT fk_usuarioperfiles FOREIGN KEY (perfil_id) REFERENCES tb_sys_perfil(perfil_id);


--
-- TOC entry 2459 (class 2606 OID 17138)
-- Name: fk_usuarioperfiles_usuario; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_sys_usuario_perfiles
ADD CONSTRAINT fk_usuarioperfiles_usuario FOREIGN KEY (usuarios_id) REFERENCES tb_usuarios(usuarios_id);


--
-- TOC entry 2424 (class 2606 OID 17143)
-- Name: tb_atletas_resultados_competencias_codigo; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_atletas_resultados_old
ADD CONSTRAINT tb_atletas_resultados_competencias_codigo FOREIGN KEY (competencias_codigo) REFERENCES tb_competencias(competencias_codigo);


--
-- TOC entry 2425 (class 2606 OID 17148)
-- Name: tb_atletas_resultados_pruebas_codigo; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_atletas_resultados_old
ADD CONSTRAINT tb_atletas_resultados_pruebas_codigo FOREIGN KEY (pruebas_codigo) REFERENCES tb_pruebas(pruebas_codigo);


--
-- TOC entry 2444 (class 2606 OID 17163)
-- Name: tb_pruebas_categorias_codigo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY tb_pruebas
ADD CONSTRAINT tb_pruebas_categorias_codigo_fkey FOREIGN KEY (categorias_codigo) REFERENCES tb_categorias(categorias_codigo);


--
-- TOC entry 2448 (class 2606 OID 17168)
-- Name: tb_pruebas_detalle_prueba_detalle_codigo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY tb_pruebas_detalle
ADD CONSTRAINT tb_pruebas_detalle_prueba_detalle_codigo FOREIGN KEY (pruebas_detalle_prueba_codigo) REFERENCES tb_pruebas(pruebas_codigo);


--
-- TOC entry 2449 (class 2606 OID 17173)
-- Name: tb_pruebas_detalle_pruebas_codigo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY tb_pruebas_detalle
ADD CONSTRAINT tb_pruebas_detalle_pruebas_codigo_fkey FOREIGN KEY (pruebas_codigo) REFERENCES tb_pruebas(pruebas_codigo);


--
-- TOC entry 2445 (class 2606 OID 17178)
-- Name: tb_pruebas_pruebas_record_hasta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY tb_pruebas
ADD CONSTRAINT tb_pruebas_pruebas_record_hasta_fkey FOREIGN KEY (pruebas_record_hasta) REFERENCES tb_categorias(categorias_codigo);


--
-- TOC entry 2672 (class 0 OID 0)
-- Dependencies: 7
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2016-05-28 03:21:05 PET

--
-- PostgreSQL database dump complete
--

