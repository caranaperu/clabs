--
-- PostgreSQL database dump
--

-- Dumped from database version 9.3.13
-- Dumped by pg_dump version 9.3.13
-- Started on 2016-07-24 23:21:37 PET

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
-- TOC entry 602 (class 1247 OID 58381)
-- Name: sexo_full_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE sexo_full_type AS ENUM (
    'F',
    'M',
    'A'
);


ALTER TYPE public.sexo_full_type OWNER TO postgres;

--
-- TOC entry 605 (class 1247 OID 58388)
-- Name: sexo_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE sexo_type AS ENUM (
    'F',
    'M'
);


ALTER TYPE public.sexo_type OWNER TO postgres;

--
-- TOC entry 205 (class 1255 OID 58393)
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
-- TOC entry 207 (class 1255 OID 58394)
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
-- TOC entry 208 (class 1255 OID 58395)
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
-- TOC entry 209 (class 1255 OID 58396)
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
-- TOC entry 210 (class 1255 OID 58397)
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
-- TOC entry 213 (class 1255 OID 58399)
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
-- TOC entry 214 (class 1255 OID 58400)
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
-- TOC entry 215 (class 1255 OID 58401)
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
-- TOC entry 216 (class 1255 OID 58402)
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
-- TOC entry 217 (class 1255 OID 58405)
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
-- TOC entry 218 (class 1255 OID 58408)
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
-- TOC entry 219 (class 1255 OID 58411)
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
-- TOC entry 220 (class 1255 OID 58414)
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
-- TOC entry 221 (class 1255 OID 58417)
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
-- TOC entry 222 (class 1255 OID 58418)
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
-- TOC entry 223 (class 1255 OID 58419)
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
-- TOC entry 224 (class 1255 OID 58422)
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
-- TOC entry 225 (class 1255 OID 58425)
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
-- TOC entry 226 (class 1255 OID 58428)
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
-- TOC entry 227 (class 1255 OID 58430)
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
-- TOC entry 228 (class 1255 OID 58433)
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
-- TOC entry 229 (class 1255 OID 58434)
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
-- TOC entry 230 (class 1255 OID 58435)
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
-- TOC entry 231 (class 1255 OID 58438)
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
-- TOC entry 232 (class 1255 OID 58441)
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
-- TOC entry 233 (class 1255 OID 58444)
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
-- TOC entry 236 (class 1255 OID 58447)
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
-- TOC entry 237 (class 1255 OID 58448)
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
-- TOC entry 243 (class 1255 OID 58449)
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
-- TOC entry 244 (class 1255 OID 58450)
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
-- TOC entry 245 (class 1255 OID 58453)
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
-- TOC entry 211 (class 1255 OID 58454)
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
-- TOC entry 246 (class 1255 OID 58457)
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
-- TOC entry 247 (class 1255 OID 58458)
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
-- TOC entry 248 (class 1255 OID 58461)
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
-- TOC entry 249 (class 1255 OID 58463)
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
-- TOC entry 250 (class 1255 OID 58466)
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
-- TOC entry 251 (class 1255 OID 58469)
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
-- TOC entry 234 (class 1255 OID 58472)
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
-- TOC entry 235 (class 1255 OID 58473)
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
DECLARE v_atletas_paises_codigo character varying(15);
DECLARE v_paises_codigo character varying(15);


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
		  coalesce(categoria, 0) as is_valid_categoria,
		  paises_codigo
		INTO
		  v_competencias_pruebas_fecha,
		  v_is_valid_categoria,
		  v_atletas_paises_codigo
		FROM
		  (
		    SELECT
		      competencias_pruebas_fecha,
		      (SELECT 1
		       FROM tb_categorias
		       WHERE categorias_codigo = p_categorias_codigo AND
			     (SELECT date_part('year' :: TEXT, competencias_pruebas_fecha :: DATE) -
				     date_part('year' :: TEXT, atletas_fecha_nacimiento :: DATE)) <= categorias_edad_final
		       LIMIT 1) AS categoria,
		       (SELECT paises_codigo FROM tb_atletas atl where atl.atletas_codigo = ar.atletas_codigo) as paises_codigo
		    FROM tb_atletas_resultados ar
		      INNER JOIN tb_competencias_pruebas cp ON cp.competencias_pruebas_id = ar.competencias_pruebas_id
		      INNER JOIN tb_competencias co ON co.competencias_codigo = cp.competencias_codigo
		      INNER JOIN tb_atletas at ON at.atletas_codigo = ar.atletas_codigo
		    WHERE ar.atletas_resultados_id = p_atletas_resultados_id
		  ) res;
	ELSE
		SELECT
		  max(competencias_pruebas_fecha),
		  min(coalesce(categoria, 0)) as is_valid_categoria,
		  -- recordar que si es record todos los integrantes son del mismo pais
		  max(paises_codigo) as paises_codigo
		INTO
		  v_competencias_pruebas_fecha,
		  v_is_valid_categoria,
		  v_atletas_paises_codigo
		FROM
		  (
		    SELECT
		      competencias_pruebas_fecha,
		      (SELECT 1
		       FROM tb_categorias
		       WHERE categorias_codigo = p_categorias_codigo AND
			     (SELECT date_part('year' :: TEXT, competencias_pruebas_fecha :: DATE) -
				     date_part('year' :: TEXT, atletas_fecha_nacimiento :: DATE)) <= categorias_edad_final
		       LIMIT 1) AS categoria,
		       (SELECT paises_codigo FROM tb_atletas atl where atl.atletas_codigo = ar.atletas_codigo) as paises_codigo
		    FROM tb_atletas_resultados ar
		      INNER JOIN tb_postas po ON po.postas_id = ar.postas_id
		      INNER JOIN tb_postas_detalle pd ON pd.postas_id = po.postas_id
		      INNER JOIN tb_competencias_pruebas cp ON cp.competencias_pruebas_id = ar.competencias_pruebas_id
		      INNER JOIN tb_competencias co ON co.competencias_codigo = cp.competencias_codigo
		      INNER JOIN tb_atletas at ON at.atletas_codigo = pd.atletas_codigo
		    WHERE ar.atletas_resultados_id = p_atletas_resultados_id
		  ) res;
	END IF;

	-- Leemos el pais default , cuidado solo un pais puede tener el flag paises_entidad = TRUE
	SELECT paises_codigo
	INTO v_paises_codigo
	FROM tb_paises where paises_entidad = TRUE;

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
		-- pero verificamos que el pais del atleta sea el atleta del pais.
		IF v_records_tipo_tipo = 'A' AND v_paises_codigo = v_atletas_paises_codigo
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
-- TOC entry 252 (class 1255 OID 58476)
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
-- TOC entry 253 (class 1255 OID 58477)
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
-- TOC entry 254 (class 1255 OID 58480)
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
-- TOC entry 255 (class 1255 OID 58483)
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
-- TOC entry 256 (class 1255 OID 58484)
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
-- TOC entry 238 (class 1255 OID 58487)
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
-- TOC entry 239 (class 1255 OID 58490)
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
-- TOC entry 240 (class 1255 OID 58493)
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
-- TOC entry 241 (class 1255 OID 58495)
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
-- TOC entry 242 (class 1255 OID 58498)
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
-- TOC entry 257 (class 1255 OID 58500)
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
-- TOC entry 258 (class 1255 OID 58501)
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
-- TOC entry 259 (class 1255 OID 58504)
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
-- TOC entry 260 (class 1255 OID 58507)
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
-- TOC entry 266 (class 1255 OID 59436)
-- Name: sptrg_insumo_validate_save(); Type: FUNCTION; Schema: public; Owner: clabsuser
--

CREATE FUNCTION sptrg_insumo_validate_save() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE v_insumo_codigo character varying(15);

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
		-- Verificamos si alguno con el mismo nombre existe e indicamos el error.
		SELECT insumo_codigo INTO v_insumo_codigo FROM tb_insumo
		  where UPPER(LTRIM(RTRIM(insumo_descripcion))) = UPPER(LTRIM(RTRIM(NEW.insumo_descripcion)));

		IF NEW.insumo_codigo != v_insumo_codigo
		THEN
			-- Excepcion de region con ese nombre existe
			RAISE 'Ya existe una insumo con ese nombre en el insumo [%]',v_insumo_codigo USING ERRCODE = 'restrict_violation';
		END IF;
	END IF;
	RETURN NEW;
END;
$$;


ALTER FUNCTION public.sptrg_insumo_validate_save() OWNER TO clabsuser;

--
-- TOC entry 265 (class 1255 OID 59408)
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
-- TOC entry 261 (class 1255 OID 58510)
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
-- TOC entry 267 (class 1255 OID 59493)
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
-- TOC entry 206 (class 1255 OID 59257)
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
-- TOC entry 268 (class 1255 OID 59481)
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
-- TOC entry 212 (class 1255 OID 59370)
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
-- TOC entry 264 (class 1255 OID 59400)
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
-- TOC entry 262 (class 1255 OID 58511)
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
-- TOC entry 263 (class 1255 OID 58512)
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
-- TOC entry 192 (class 1259 OID 59504)
-- Name: tb_insumo; Type: TABLE; Schema: public; Owner: clabsuser; Tablespace:
--

CREATE TABLE tb_insumo (
    insumo_codigo character varying(15) NOT NULL,
    insumo_descripcion character varying(60) NOT NULL,
    tinsumo_codigo character varying(15) NOT NULL,
    tcostos_codigo character varying(5) NOT NULL,
    unidad_medida_codigo character varying(8) NOT NULL,
    insumo_merma numeric(10,4) DEFAULT 0.00 NOT NULL,
    activo boolean,
    usuario character varying(15),
    fecha_creacion timestamp without time zone,
    usuario_mod character varying(15),
    fecha_modificacion timestamp without time zone,
    CONSTRAINT chk_insumo_field_len CHECK (((length(rtrim((insumo_codigo)::text)) > 0) AND (length(rtrim((insumo_descripcion)::text)) > 0))),
    CONSTRAINT chk_insumo_merma CHECK ((insumo_merma > 0.00))
);


ALTER TABLE public.tb_insumo OWNER TO clabsuser;

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
-- TOC entry 2293 (class 0 OID 0)
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
-- TOC entry 2294 (class 0 OID 0)
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
-- TOC entry 2295 (class 0 OID 0)
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
-- TOC entry 2296 (class 0 OID 0)
-- Dependencies: 181
-- Name: tb_sys_usuario_perfiles_usuario_perfil_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: atluser
--

ALTER SEQUENCE tb_sys_usuario_perfiles_usuario_perfil_id_seq OWNED BY tb_sys_usuario_perfiles.usuario_perfil_id;


--
-- TOC entry 191 (class 1259 OID 59495)
-- Name: tb_tcostos; Type: TABLE; Schema: public; Owner: clabsuser; Tablespace:
--

CREATE TABLE tb_tcostos (
    tcostos_codigo character varying(5) NOT NULL,
    tcostos_descripcion character varying(60) NOT NULL,
    activo boolean DEFAULT true NOT NULL,
    usuario character varying(15) NOT NULL,
    fecha_creacion timestamp without time zone NOT NULL,
    usuario_mod character varying(15),
    fecha_modificacion timestamp without time zone,
    CONSTRAINT chk_tcostos_field_len CHECK (((length(rtrim((tcostos_codigo)::text)) > 0) AND (length(rtrim((tcostos_descripcion)::text)) > 0)))
);


ALTER TABLE public.tb_tcostos OWNER TO clabsuser;

--
-- TOC entry 186 (class 1259 OID 59250)
-- Name: tb_tinsumo; Type: TABLE; Schema: public; Owner: clabsuser; Tablespace:
--

CREATE TABLE tb_tinsumo (
    tinsumo_codigo character varying(15) NOT NULL,
    tinsumo_descripcion character varying(60) NOT NULL,
    activo boolean DEFAULT true NOT NULL,
    usuario character varying(15) NOT NULL,
    fecha_creacion timestamp without time zone NOT NULL,
    usuario_mod character varying(15),
    fecha_modificacion timestamp without time zone,
    CONSTRAINT chk_tinsumo_field_len CHECK (((length(rtrim((tinsumo_codigo)::text)) > 0) AND (length(rtrim((tinsumo_descripcion)::text)) > 0)))
);


ALTER TABLE public.tb_tinsumo OWNER TO clabsuser;

--
-- TOC entry 190 (class 1259 OID 59462)
-- Name: tb_tipo_cambio; Type: TABLE; Schema: public; Owner: clabsuser; Tablespace:
--

CREATE TABLE tb_tipo_cambio (
    tipo_cambio_id integer NOT NULL,
    moneda_codigo_origen character varying(8) NOT NULL,
    moneda_codigo_destino character varying(8) NOT NULL,
    tipo_cambio_fecha_desde date NOT NULL,
    tipo_cambio_fecha_hasta date NOT NULL,
    tipo_cambio_tasa numeric(8,4) NOT NULL,
    activo boolean DEFAULT true NOT NULL,
    usuario character varying(15) NOT NULL,
    fecha_creacion timestamp without time zone NOT NULL,
    usuario_mod character varying(15),
    fecha_modificacion timestamp without time zone,
    CONSTRAINT ckk_tipo_cambio_tasa CHECK ((tipo_cambio_tasa > 0.00))
);


ALTER TABLE public.tb_tipo_cambio OWNER TO clabsuser;

--
-- TOC entry 189 (class 1259 OID 59460)
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
-- TOC entry 2297 (class 0 OID 0)
-- Dependencies: 189
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
-- TOC entry 188 (class 1259 OID 59377)
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
-- TOC entry 187 (class 1259 OID 59375)
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
-- TOC entry 2298 (class 0 OID 0)
-- Dependencies: 187
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
-- TOC entry 2299 (class 0 OID 0)
-- Dependencies: 183
-- Name: tb_usuarios_usuarios_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: atluser
--

ALTER SEQUENCE tb_usuarios_usuarios_id_seq OWNED BY tb_usuarios.usuarios_id;


--
-- TOC entry 2039 (class 2604 OID 58792)
-- Name: entidad_id; Type: DEFAULT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_entidad ALTER COLUMN entidad_id SET DEFAULT nextval('tb_entidad_entidad_id_seq'::regclass);


--
-- TOC entry 2042 (class 2604 OID 58799)
-- Name: menu_id; Type: DEFAULT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_sys_menu ALTER COLUMN menu_id SET DEFAULT nextval('tb_sys_menu_menu_id_seq'::regclass);


--
-- TOC entry 2044 (class 2604 OID 58800)
-- Name: perfil_id; Type: DEFAULT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_sys_perfil ALTER COLUMN perfil_id SET DEFAULT nextval('tb_sys_perfil_id_seq'::regclass);


--
-- TOC entry 2051 (class 2604 OID 58801)
-- Name: perfdet_id; Type: DEFAULT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_sys_perfil_detalle ALTER COLUMN perfdet_id SET DEFAULT nextval('tb_sys_perfil_detalle_perfdet_id_seq'::regclass);


--
-- TOC entry 2054 (class 2604 OID 58802)
-- Name: usuario_perfil_id; Type: DEFAULT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_sys_usuario_perfiles ALTER COLUMN usuario_perfil_id SET DEFAULT nextval('tb_sys_usuario_perfiles_usuario_perfil_id_seq'::regclass);


--
-- TOC entry 2070 (class 2604 OID 59465)
-- Name: tipo_cambio_id; Type: DEFAULT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY tb_tipo_cambio ALTER COLUMN tipo_cambio_id SET DEFAULT nextval('tb_tipo_cambio_tipo_cambio_id_seq'::regclass);


--
-- TOC entry 2067 (class 2604 OID 59380)
-- Name: unidad_medida_conversion_id; Type: DEFAULT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY tb_unidad_medida_conversion ALTER COLUMN unidad_medida_conversion_id SET DEFAULT nextval('tb_unidad_medida_conversion_unidad_medida_conversion_id_seq'::regclass);


--
-- TOC entry 2057 (class 2604 OID 58803)
-- Name: usuarios_id; Type: DEFAULT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_usuarios ALTER COLUMN usuarios_id SET DEFAULT nextval('tb_usuarios_usuarios_id_seq'::regclass);


--
-- TOC entry 2261 (class 0 OID 58623)
-- Dependencies: 171
-- Data for Name: tb_entidad; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY tb_entidad (entidad_id, entidad_razon_social, entidad_ruc, entidad_direccion, entidad_telefonos, entidad_fax, entidad_correo, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
3	Laboratoris Martin Hernandez	10088090867	La casa de MARTIN - Miraflores	993786532,993786533		mhernandez@hotmai.com	t	TESTUSER	2016-07-09 00:08:18.69851	TESTUSER	2016-07-09 14:39:22.946464
\.


--
-- TOC entry 2300 (class 0 OID 0)
-- Dependencies: 172
-- Name: tb_entidad_entidad_id_seq; Type: SEQUENCE SET; Schema: public; Owner: atluser
--

SELECT pg_catalog.setval('tb_entidad_entidad_id_seq', 3, true);


--
-- TOC entry 2282 (class 0 OID 59504)
-- Dependencies: 192
-- Data for Name: tb_insumo; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY tb_insumo (insumo_codigo, insumo_descripcion, tinsumo_codigo, tcostos_codigo, unidad_medida_codigo, insumo_merma, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
SFSF	sfsf	HH	DIR	DDD	4.0000	t	TESTUSER	2016-07-19 14:44:46.761123	TESTUSER	2016-07-19 15:49:21.700255
FDGDG	dgfdg	HH	IND	KILOS	5.0000	t	TESTUSER	2016-07-19 15:50:24.397549	\N	\N
\.


--
-- TOC entry 2275 (class 0 OID 59242)
-- Dependencies: 185
-- Data for Name: tb_moneda; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY tb_moneda (moneda_codigo, moneda_simbolo, moneda_descripcion, moneda_protected, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
PEN	S/.	Nuevos Soles	f	t	TESTUSER	2016-07-10 18:16:12.815048	\N	\N
USD	$	Dolares	f	t	TESTUSER	2016-07-10 18:20:47.857316	TESTUSER	2016-07-10 18:22:59.862666
JPY	Yen	Yen Japones	f	t	TESTUSER	2016-07-14 00:40:58.095941	\N	\N
\.


--
-- TOC entry 2263 (class 0 OID 58731)
-- Dependencies: 173
-- Data for Name: tb_sys_menu; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY tb_sys_menu (sys_systemcode, menu_id, menu_codigo, menu_descripcion, menu_accesstype, menu_parent_id, menu_orden, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
labcostos	60	smn_tipocambio	Tipo De Cambio	A         	11	165	t	ADMIN	2016-07-15 03:24:37.087685	\N	\N
labcostos	61	smn_tcostos	Tipo De Costos	A         	11	155	t	ADMIN	2016-07-19 03:17:27.948919	\N	\N
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
-- TOC entry 2301 (class 0 OID 0)
-- Dependencies: 174
-- Name: tb_sys_menu_menu_id_seq; Type: SEQUENCE SET; Schema: public; Owner: atluser
--

SELECT pg_catalog.setval('tb_sys_menu_menu_id_seq', 61, true);


--
-- TOC entry 2265 (class 0 OID 58738)
-- Dependencies: 175
-- Data for Name: tb_sys_perfil; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY tb_sys_perfil (perfil_id, sys_systemcode, perfil_codigo, perfil_descripcion, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
4	labcostos	ADMIN	Perfil Administrador	t	TESTUSER	2015-10-04 21:34:18.153993	postgres	2016-07-08 23:54:58.365768
5	labcostos	POWERUSER	Power User	t	TESTUSER	2015-10-04 21:41:49.702143	TESTUSER	2016-07-08 23:55:02.519651
\.


--
-- TOC entry 2266 (class 0 OID 58742)
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
-- TOC entry 2302 (class 0 OID 0)
-- Dependencies: 177
-- Name: tb_sys_perfil_detalle_perfdet_id_seq; Type: SEQUENCE SET; Schema: public; Owner: atluser
--

SELECT pg_catalog.setval('tb_sys_perfil_detalle_perfdet_id_seq', 646, true);


--
-- TOC entry 2303 (class 0 OID 0)
-- Dependencies: 178
-- Name: tb_sys_perfil_id_seq; Type: SEQUENCE SET; Schema: public; Owner: atluser
--

SELECT pg_catalog.setval('tb_sys_perfil_id_seq', 19, true);


--
-- TOC entry 2269 (class 0 OID 58755)
-- Dependencies: 179
-- Data for Name: tb_sys_sistemas; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY tb_sys_sistemas (sys_systemcode, sistema_descripcion, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
labcostos	Sistema De Costos Laboratorios	t	ADMIN	2016-07-08 23:47:11.960862	\N	\N
\.


--
-- TOC entry 2270 (class 0 OID 58759)
-- Dependencies: 180
-- Data for Name: tb_sys_usuario_perfiles; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY tb_sys_usuario_perfiles (usuario_perfil_id, perfil_id, usuarios_id, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
1	4	2	t	TESTUSER	2015-10-05 00:03:41.563698	TESTUSER	2016-01-26 16:22:00.235152
3	4	1	t	TESTUSER	2016-01-26 13:17:46.032845	TESTUSER	2016-02-01 15:09:50.479604
\.


--
-- TOC entry 2304 (class 0 OID 0)
-- Dependencies: 181
-- Name: tb_sys_usuario_perfiles_usuario_perfil_id_seq; Type: SEQUENCE SET; Schema: public; Owner: atluser
--

SELECT pg_catalog.setval('tb_sys_usuario_perfiles_usuario_perfil_id_seq', 6, true);


--
-- TOC entry 2281 (class 0 OID 59495)
-- Dependencies: 191
-- Data for Name: tb_tcostos; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY tb_tcostos (tcostos_codigo, tcostos_descripcion, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
DIR	Directos	t	TESTUSER	2016-07-19 03:28:27.346506	TESTUSER	2016-07-19 03:29:09.423302
IND	Indirectos	t	TESTUSER	2016-07-19 03:29:00.152144	TESTUSER	2016-07-19 13:38:10.736724
\.


--
-- TOC entry 2276 (class 0 OID 59250)
-- Dependencies: 186
-- Data for Name: tb_tinsumo; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY tb_tinsumo (tinsumo_codigo, tinsumo_descripcion, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
HH	gfhfhgfhgfhgfhgfh	t	TESTUSER	2016-07-12 14:04:47.422093	TESTUSER	2016-07-18 13:24:34.744389
\.


--
-- TOC entry 2280 (class 0 OID 59462)
-- Dependencies: 190
-- Data for Name: tb_tipo_cambio; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY tb_tipo_cambio (tipo_cambio_id, moneda_codigo_origen, moneda_codigo_destino, tipo_cambio_fecha_desde, tipo_cambio_fecha_hasta, tipo_cambio_tasa, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
10	USD	PEN	2016-01-03	2016-01-28	2.0000	t	admin	2016-07-14 00:37:44.845476	\N	\N
14	USD	JPY	2016-10-03	2016-10-03	2.0000	t	admin	2016-07-14 00:41:23.095109	\N	\N
25	USD	PEN	2016-12-15	2016-12-16	2.0000	t	TESTUSER	2016-07-15 17:38:07.56489	\N	\N
27	JPY	USD	2016-10-12	2016-10-20	2.1445	t	TESTUSER	2016-07-16 02:36:19.485968	\N	\N
26	USD	JPY	2016-10-12	2016-10-14	4.0000	t	TESTUSER	2016-07-16 02:34:35.161308	TESTUSER	2016-07-16 02:48:22.970996
12	USD	PEN	2016-07-16	2016-09-05	3.0088	t	admin	2016-07-14 00:38:10.800262	TESTUSER	2016-07-16 04:14:27.959737
4	USD	PEN	2016-02-01	2016-02-28	2.0000	t	admin	2016-07-14 00:36:16.378024	TESTUSER	2016-07-18 17:32:52.78635
28	PEN	JPY	2015-07-01	2016-07-20	2.0000	t	TESTUSER	2016-07-18 17:54:57.865136	TESTUSER	2016-07-19 00:42:32.569406
\.


--
-- TOC entry 2305 (class 0 OID 0)
-- Dependencies: 189
-- Name: tb_tipo_cambio_tipo_cambio_id_seq; Type: SEQUENCE SET; Schema: public; Owner: clabsuser
--

SELECT pg_catalog.setval('tb_tipo_cambio_tipo_cambio_id_seq', 28, true);


--
-- TOC entry 2274 (class 0 OID 59224)
-- Dependencies: 184
-- Data for Name: tb_unidad_medida; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY tb_unidad_medida (unidad_medida_codigo, unidad_medida_siglas, unidad_medida_descripcion, unidad_medida_tipo, unidad_medida_protected, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
LITROS	Ltrs.	Litros	V	f	t	TESTUSER	2016-07-09 14:13:29.603714	TESTUSER	2016-07-11 02:25:05.884116
KILOS	Kgs.	Kilogramos	P	f	t	TESTUSER	2016-07-09 14:30:43.815942	TESTUSER	2016-07-12 01:24:15.740215
TONELAD	Ton.	Toneladas	P	f	t	TESTUSER	2016-07-11 17:17:40.095483	TESTUSER	2016-07-12 03:24:58.438822
GALON	Gls.	Galones	V	f	t	TESTUSER	2016-07-17 15:07:47.744565	TESTUSER	2016-07-18 04:56:08.667067
DDD	dddd	ddd	V	f	t	TESTUSER	2016-07-18 17:57:21.050869	\N	\N
\.


--
-- TOC entry 2278 (class 0 OID 59377)
-- Dependencies: 188
-- Data for Name: tb_unidad_medida_conversion; Type: TABLE DATA; Schema: public; Owner: clabsuser
--

COPY tb_unidad_medida_conversion (unidad_medida_conversion_id, unidad_medida_origen, unidad_medida_destino, unidad_medida_conversion_factor, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
10	TONELAD	KILOS	1000.00000	t	TESTUSER	2016-07-11 17:18:02.132735	\N	\N
60	GALON	LITROS	3.00000	t	TESTUSER	2016-07-18 04:44:20.861417	TESTUSER	2016-07-18 17:36:29.364226
61	DDD	GALON	2.00000	t	TESTUSER	2016-07-18 17:57:36.453535	TESTUSER	2016-07-18 17:58:34.603747
24	KILOS	TONELAD	0.00100	t	TESTUSER	2016-07-12 15:58:35.930938	TESTUSER	2016-07-16 04:13:48.158402
\.


--
-- TOC entry 2306 (class 0 OID 0)
-- Dependencies: 187
-- Name: tb_unidad_medida_conversion_unidad_medida_conversion_id_seq; Type: SEQUENCE SET; Schema: public; Owner: clabsuser
--

SELECT pg_catalog.setval('tb_unidad_medida_conversion_unidad_medida_conversion_id_seq', 61, true);


--
-- TOC entry 2272 (class 0 OID 58771)
-- Dependencies: 182
-- Data for Name: tb_usuarios; Type: TABLE DATA; Schema: public; Owner: atluser
--

COPY tb_usuarios (usuarios_id, usuarios_code, usuarios_password, usuarios_nombre_completo, usuarios_admin, activo, usuario, fecha_creacion, usuario_mod, fecha_modificacion) FROM stdin;
1	ADMIN	melivane100	Carlos Arana Reategui	f	t	TESTUSER	2015-10-04 18:18:38.522948	TESTUSER	18:33:24.640328
2	TEST	testx1	Soy el Test User	f	t	TESTUSER	2015-10-04 19:20:13.66406	TESTUSER	01:09:30.537483
\.


--
-- TOC entry 2307 (class 0 OID 0)
-- Dependencies: 183
-- Name: tb_usuarios_usuarios_id_seq; Type: SEQUENCE SET; Schema: public; Owner: atluser
--

SELECT pg_catalog.setval('tb_usuarios_usuarios_id_seq', 14, true);


--
-- TOC entry 2079 (class 2606 OID 59214)
-- Name: pk_entidad; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_entidad
    ADD CONSTRAINT pk_entidad PRIMARY KEY (entidad_id);


--
-- TOC entry 2119 (class 2606 OID 59511)
-- Name: pk_insumo; Type: CONSTRAINT; Schema: public; Owner: clabsuser; Tablespace:
--

ALTER TABLE ONLY tb_insumo
    ADD CONSTRAINT pk_insumo PRIMARY KEY (insumo_codigo);


--
-- TOC entry 2083 (class 2606 OID 58841)
-- Name: pk_menu; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_sys_menu
    ADD CONSTRAINT pk_menu PRIMARY KEY (menu_id);


--
-- TOC entry 2107 (class 2606 OID 59248)
-- Name: pk_moneda; Type: CONSTRAINT; Schema: public; Owner: clabsuser; Tablespace:
--

ALTER TABLE ONLY tb_moneda
    ADD CONSTRAINT pk_moneda PRIMARY KEY (moneda_codigo);


--
-- TOC entry 2094 (class 2606 OID 58845)
-- Name: pk_perfdet_id; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_sys_perfil_detalle
    ADD CONSTRAINT pk_perfdet_id PRIMARY KEY (perfdet_id);


--
-- TOC entry 2096 (class 2606 OID 58859)
-- Name: pk_sistemas; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_sys_sistemas
    ADD CONSTRAINT pk_sistemas PRIMARY KEY (sys_systemcode);


--
-- TOC entry 2088 (class 2606 OID 58861)
-- Name: pk_sys_perfil; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_sys_perfil
    ADD CONSTRAINT pk_sys_perfil PRIMARY KEY (perfil_id);


--
-- TOC entry 2117 (class 2606 OID 59501)
-- Name: pk_tcostos; Type: CONSTRAINT; Schema: public; Owner: clabsuser; Tablespace:
--

ALTER TABLE ONLY tb_tcostos
    ADD CONSTRAINT pk_tcostos PRIMARY KEY (tcostos_codigo);


--
-- TOC entry 2109 (class 2606 OID 59255)
-- Name: pk_tinsumo; Type: CONSTRAINT; Schema: public; Owner: clabsuser; Tablespace:
--

ALTER TABLE ONLY tb_tinsumo
    ADD CONSTRAINT pk_tinsumo PRIMARY KEY (tinsumo_codigo);


--
-- TOC entry 2115 (class 2606 OID 59469)
-- Name: pk_tipo_cambio; Type: CONSTRAINT; Schema: public; Owner: clabsuser; Tablespace:
--

ALTER TABLE ONLY tb_tipo_cambio
    ADD CONSTRAINT pk_tipo_cambio PRIMARY KEY (tipo_cambio_id);


--
-- TOC entry 2111 (class 2606 OID 59384)
-- Name: pk_unidad_conversion; Type: CONSTRAINT; Schema: public; Owner: clabsuser; Tablespace:
--

ALTER TABLE ONLY tb_unidad_medida_conversion
    ADD CONSTRAINT pk_unidad_conversion PRIMARY KEY (unidad_medida_conversion_id);


--
-- TOC entry 2105 (class 2606 OID 59231)
-- Name: pk_unidad_medida; Type: CONSTRAINT; Schema: public; Owner: clabsuser; Tablespace:
--

ALTER TABLE ONLY tb_unidad_medida
    ADD CONSTRAINT pk_unidad_medida PRIMARY KEY (unidad_medida_codigo);


--
-- TOC entry 2100 (class 2606 OID 58865)
-- Name: pk_usuarioperfiles; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_sys_usuario_perfiles
    ADD CONSTRAINT pk_usuarioperfiles PRIMARY KEY (usuario_perfil_id);


--
-- TOC entry 2103 (class 2606 OID 58867)
-- Name: pk_usuarios; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_usuarios
    ADD CONSTRAINT pk_usuarios PRIMARY KEY (usuarios_id);


--
-- TOC entry 2085 (class 2606 OID 58885)
-- Name: unq_codigomenu; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_sys_menu
    ADD CONSTRAINT unq_codigomenu UNIQUE (menu_codigo);


--
-- TOC entry 2090 (class 2606 OID 58889)
-- Name: unq_perfil_syscode_codigo; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_sys_perfil
    ADD CONSTRAINT unq_perfil_syscode_codigo UNIQUE (sys_systemcode, perfil_codigo);


--
-- TOC entry 2092 (class 2606 OID 58891)
-- Name: unq_perfil_syscode_perfil_id; Type: CONSTRAINT; Schema: public; Owner: atluser; Tablespace:
--

ALTER TABLE ONLY tb_sys_perfil
    ADD CONSTRAINT unq_perfil_syscode_perfil_id UNIQUE (sys_systemcode, perfil_id);


--
-- TOC entry 2113 (class 2606 OID 59386)
-- Name: uq_unidad_conversion; Type: CONSTRAINT; Schema: public; Owner: clabsuser; Tablespace:
--

ALTER TABLE ONLY tb_unidad_medida_conversion
    ADD CONSTRAINT uq_unidad_conversion UNIQUE (unidad_medida_origen, unidad_medida_destino);


--
-- TOC entry 2080 (class 1259 OID 58916)
-- Name: fki_menu_parent_id; Type: INDEX; Schema: public; Owner: atluser; Tablespace:
--

CREATE INDEX fki_menu_parent_id ON tb_sys_menu USING btree (menu_parent_id);


--
-- TOC entry 2081 (class 1259 OID 58917)
-- Name: fki_menu_sistemas; Type: INDEX; Schema: public; Owner: atluser; Tablespace:
--

CREATE INDEX fki_menu_sistemas ON tb_sys_menu USING btree (sys_systemcode);


--
-- TOC entry 2086 (class 1259 OID 58918)
-- Name: fki_perfil_sistema; Type: INDEX; Schema: public; Owner: atluser; Tablespace:
--

CREATE INDEX fki_perfil_sistema ON tb_sys_perfil USING btree (sys_systemcode);


--
-- TOC entry 2097 (class 1259 OID 58919)
-- Name: fki_perfil_usuario; Type: INDEX; Schema: public; Owner: atluser; Tablespace:
--

CREATE INDEX fki_perfil_usuario ON tb_sys_usuario_perfiles USING btree (perfil_id);


--
-- TOC entry 2098 (class 1259 OID 58932)
-- Name: fki_usuarioperfiles; Type: INDEX; Schema: public; Owner: atluser; Tablespace:
--

CREATE INDEX fki_usuarioperfiles ON tb_sys_usuario_perfiles USING btree (usuarios_id);


--
-- TOC entry 2101 (class 1259 OID 58937)
-- Name: idx_unique_usuarios; Type: INDEX; Schema: public; Owner: atluser; Tablespace:
--

CREATE UNIQUE INDEX idx_unique_usuarios ON tb_usuarios USING btree (upper((usuarios_code)::text));


--
-- TOC entry 2138 (class 2620 OID 58944)
-- Name: sptrg_verify_usuario_code_change; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER sptrg_verify_usuario_code_change BEFORE INSERT OR DELETE OR UPDATE ON tb_usuarios FOR EACH ROW EXECUTE PROCEDURE sptrg_verify_usuario_code_change();


--
-- TOC entry 2133 (class 2620 OID 58961)
-- Name: tr_entidad; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_entidad BEFORE INSERT OR UPDATE ON tb_entidad FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2152 (class 2620 OID 59527)
-- Name: tr_insumo_validate_save; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_insumo_validate_save BEFORE INSERT OR UPDATE ON tb_insumo FOR EACH ROW EXECUTE PROCEDURE sptrg_insumo_validate_save();


--
-- TOC entry 2142 (class 2620 OID 59409)
-- Name: tr_moneda_validate_save; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_moneda_validate_save BEFORE INSERT OR UPDATE ON tb_moneda FOR EACH ROW EXECUTE PROCEDURE sptrg_moneda_validate_save();


--
-- TOC entry 2134 (class 2620 OID 58977)
-- Name: tr_sys_perfil; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_sys_perfil BEFORE INSERT OR UPDATE ON tb_sys_perfil FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2135 (class 2620 OID 58978)
-- Name: tr_sys_perfil_detalle; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_sys_perfil_detalle BEFORE INSERT OR UPDATE ON tb_sys_perfil_detalle FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2136 (class 2620 OID 58979)
-- Name: tr_sys_sistemas; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_sys_sistemas BEFORE INSERT OR UPDATE ON tb_sys_sistemas FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2137 (class 2620 OID 58980)
-- Name: tr_sys_usuario_perfiles; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_sys_usuario_perfiles BEFORE INSERT OR UPDATE ON tb_sys_usuario_perfiles FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2150 (class 2620 OID 59502)
-- Name: tr_tcostos_validate_save; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_tcostos_validate_save BEFORE INSERT OR UPDATE ON tb_tcostos FOR EACH ROW EXECUTE PROCEDURE sptrg_tcostos_validate_save();


--
-- TOC entry 2144 (class 2620 OID 59258)
-- Name: tr_tinsumo_validate_save; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_tinsumo_validate_save BEFORE INSERT OR UPDATE ON tb_tinsumo FOR EACH ROW EXECUTE PROCEDURE sptrg_tinsumo_validate_save();


--
-- TOC entry 2148 (class 2620 OID 59480)
-- Name: tr_tipo_cambio; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_tipo_cambio BEFORE INSERT OR UPDATE ON tb_tipo_cambio FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2149 (class 2620 OID 59482)
-- Name: tr_tipo_cambio_validate_save; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_tipo_cambio_validate_save BEFORE INSERT OR UPDATE ON tb_tipo_cambio FOR EACH ROW EXECUTE PROCEDURE sptrg_tipo_cambio_validate_save();


--
-- TOC entry 2146 (class 2620 OID 59398)
-- Name: tr_unidad_medida_conversion_validate_save; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_unidad_medida_conversion_validate_save BEFORE INSERT OR UPDATE ON tb_unidad_medida_conversion FOR EACH ROW EXECUTE PROCEDURE sptrg_unidad_medida_conversion_validate_save();


--
-- TOC entry 2140 (class 2620 OID 59401)
-- Name: tr_unidad_medida_validate_save; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_unidad_medida_validate_save BEFORE INSERT OR UPDATE ON tb_unidad_medida FOR EACH ROW EXECUTE PROCEDURE sptrg_unidad_medida_validate_save();


--
-- TOC entry 2141 (class 2620 OID 59233)
-- Name: tr_update_log_fields; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_update_log_fields BEFORE INSERT OR UPDATE ON tb_unidad_medida FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2143 (class 2620 OID 59249)
-- Name: tr_update_log_fields; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_update_log_fields BEFORE INSERT OR UPDATE ON tb_moneda FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2145 (class 2620 OID 59256)
-- Name: tr_update_log_fields; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_update_log_fields BEFORE INSERT OR UPDATE ON tb_tinsumo FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2147 (class 2620 OID 59397)
-- Name: tr_update_log_fields; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_update_log_fields BEFORE INSERT OR UPDATE ON tb_unidad_medida_conversion FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2151 (class 2620 OID 59503)
-- Name: tr_update_log_fields; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_update_log_fields BEFORE INSERT OR UPDATE ON tb_tcostos FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2153 (class 2620 OID 59528)
-- Name: tr_update_log_fields; Type: TRIGGER; Schema: public; Owner: clabsuser
--

CREATE TRIGGER tr_update_log_fields BEFORE INSERT OR UPDATE ON tb_insumo FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2139 (class 2620 OID 58981)
-- Name: tr_usuarios; Type: TRIGGER; Schema: public; Owner: atluser
--

CREATE TRIGGER tr_usuarios BEFORE INSERT OR UPDATE ON tb_usuarios FOR EACH ROW EXECUTE PROCEDURE sptrg_update_log_fields();


--
-- TOC entry 2132 (class 2606 OID 59522)
-- Name: fk_insumo_tcostos; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY tb_insumo
    ADD CONSTRAINT fk_insumo_tcostos FOREIGN KEY (tcostos_codigo) REFERENCES tb_tcostos(tcostos_codigo);


--
-- TOC entry 2130 (class 2606 OID 59512)
-- Name: fk_insumo_tinsumo; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY tb_insumo
    ADD CONSTRAINT fk_insumo_tinsumo FOREIGN KEY (tinsumo_codigo) REFERENCES tb_tinsumo(tinsumo_codigo);


--
-- TOC entry 2131 (class 2606 OID 59517)
-- Name: fk_insumo_unidad_media; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY tb_insumo
    ADD CONSTRAINT fk_insumo_unidad_media FOREIGN KEY (unidad_medida_codigo) REFERENCES tb_unidad_medida(unidad_medida_codigo);


--
-- TOC entry 2120 (class 2606 OID 59107)
-- Name: fk_menu_parent; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_sys_menu
    ADD CONSTRAINT fk_menu_parent FOREIGN KEY (menu_parent_id) REFERENCES tb_sys_menu(menu_id);


--
-- TOC entry 2121 (class 2606 OID 59112)
-- Name: fk_menu_sistemas; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_sys_menu
    ADD CONSTRAINT fk_menu_sistemas FOREIGN KEY (sys_systemcode) REFERENCES tb_sys_sistemas(sys_systemcode);


--
-- TOC entry 2128 (class 2606 OID 59475)
-- Name: fk_moneda_destino; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY tb_tipo_cambio
    ADD CONSTRAINT fk_moneda_destino FOREIGN KEY (moneda_codigo_destino) REFERENCES tb_moneda(moneda_codigo);


--
-- TOC entry 2129 (class 2606 OID 59470)
-- Name: fk_moneda_origen; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY tb_tipo_cambio
    ADD CONSTRAINT fk_moneda_origen FOREIGN KEY (moneda_codigo_origen) REFERENCES tb_moneda(moneda_codigo);


--
-- TOC entry 2123 (class 2606 OID 59122)
-- Name: fk_perfdet_perfil; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_sys_perfil_detalle
    ADD CONSTRAINT fk_perfdet_perfil FOREIGN KEY (perfil_id) REFERENCES tb_sys_perfil(perfil_id);


--
-- TOC entry 2122 (class 2606 OID 59127)
-- Name: fk_perfil_sistema; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_sys_perfil
    ADD CONSTRAINT fk_perfil_sistema FOREIGN KEY (sys_systemcode) REFERENCES tb_sys_sistemas(sys_systemcode);


--
-- TOC entry 2126 (class 2606 OID 59387)
-- Name: fk_unidad_conversion_medida_destino; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY tb_unidad_medida_conversion
    ADD CONSTRAINT fk_unidad_conversion_medida_destino FOREIGN KEY (unidad_medida_destino) REFERENCES tb_unidad_medida(unidad_medida_codigo);


--
-- TOC entry 2127 (class 2606 OID 59392)
-- Name: fk_unidad_conversion_medida_origen; Type: FK CONSTRAINT; Schema: public; Owner: clabsuser
--

ALTER TABLE ONLY tb_unidad_medida_conversion
    ADD CONSTRAINT fk_unidad_conversion_medida_origen FOREIGN KEY (unidad_medida_origen) REFERENCES tb_unidad_medida(unidad_medida_codigo);


--
-- TOC entry 2124 (class 2606 OID 59172)
-- Name: fk_usuarioperfiles; Type: FK CONSTRAINT; Schema: public; Owner: atluser
--

ALTER TABLE ONLY tb_sys_usuario_perfiles
    ADD CONSTRAINT fk_usuarioperfiles FOREIGN KEY (perfil_id) REFERENCES tb_sys_perfil(perfil_id);


--
-- TOC entry 2125 (class 2606 OID 59177)
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


-- Completed on 2016-07-24 23:21:38 PET

--
-- PostgreSQL database dump complete
--

