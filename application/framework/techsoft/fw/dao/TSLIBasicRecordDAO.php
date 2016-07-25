<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Esta interface define los metodos a implementar del DAO comun para manejar modelos
 * simples que basicamente representen una entidad en la persistencia.
 *
 * @author Carlos Arana Reategui
 * @since 08-AGO-2012
 * @version $Id: TSLIBasicRecordDAO.php 4 2014-02-11 03:31:42Z aranape $
 * @history 1.01 , Se agrego soporte para foreign key
 *
 * 18 JUL 2016 Se agrego a los metodos signature get,add y update el parametro $subOperation por si se requiriera
 * acciones especiales durante una de estas operaciones basado en las operaciones a realizar.
 * Un ejemplo seria que get pueda leer los datos de acuerdo al modelo fisico o haciendo un join
 * para retornar un registro con valores consolidado.

 *
 * $Author: aranape $
 * $Date: 2014-02-10 22:31:42 -0500 (lun, 10 feb 2014) $
 * $Rev: 4 $
 */
interface TSLIBasicRecordDAO {

    /**
     * Busca un basado en su id, util basicamente si no se tiene un codigo
     * unico o en el caso de un update donde ya se conoce el id de existir.
     *
     * @param int $id con el unique id del registro
     * @param \TSLDataModel  $model, repositorio de la respuesta.
     * @param string $subOperation ya que no siempre solo se requerira la lectura del modelo
     * fisico en un get, aqui se puede indicar que sub operacion de lectura deberemos
     * hacer , por ejemplo leer haciendo un join para normalizar datos al cliente.
     *
     * @return string
     * DB_ERR_ALL_OK no hay errores
     * DB_ERR_SERVERNOTFOUND el servidor de base de datos no se ha encontrado.
     * DB_ERR_CANTEXECUTE Error ejecutando el query.
     * DB_ERR_RECORDNOTFOUND - No se encontro el registro
     *
     * @expectedException \TSLDbException si existe un error no recuperable
     */
    public function get($id, \TSLDataModel &$model, $subOperation = NULL);

    /**
     * Busca basado en un codigo para el caso exista codigo
     * unico, esto es util cuando por ejemplo se agrega , no se tiene aun un id
     * unico y se requiere verificar si el registro existe , en ese caso el id no nos es util.
     *
     * @param mixed $code con el unique id del registro
     * @param \TSLDataModel  $model, repositorio de la respuesta.
     * @param string $subOperation ya que no siempre solo se requerira la lectura del modelo
     * fisico en un get, aqui se puede indicar que sub operacion de lectura deberemos
     * hacer , por ejemplo leer haciendo un join para normalizar datos al cliente.
     *
     * @return string
     * DB_ERR_ALL_OK no hay errores
     * DB_ERR_SERVERNOTFOUND el servidor de base de datos no se ha encontrado.
     * DB_ERR_CANTEXECUTE Error ejecutando el query.
     * DB_ERR_RECORDNOTFOUND - No se encontro el registro
     *
     * @expectedException \TSLDbException si existe un error no recuperable
     */
    public function getByCode($code, \TSLDataModel &$model, $subOperation = NULL);

    /**
     * Funcion que lee la lista de todos los registros del modelo
     * que el DAO este manejando, basado en los constraits y los datos
     * del modelo.
     *
     * @param \TSLDataModel  $model, con los datos base para generar la condicion de
     * busqueda.
     * @param \TSLRequestConstraints $constraints conteniendo el numero de registros
     * elementos para el order by , filtro etc de la lista.
     * @param string $subOperation si el caso de fetch de datos tiene sub operaciones
     *  que realizar, es comun en el fetch que existan variantes para una misma entidad
     *
     * @return string con el Codigo de Error , estos pueden ser :
     * DB_ERR_ALL_OK no hay errores
     * DB_ERR_SERVERNOTFOUND el servidor de base de datos no se ha encontrado.
     * DB_ERR_CANTEXECUTE Error ejecutando el query.
     *
     * @expectedException \TSLDbException si existe un error no recuperable
     */
    public function fetch(\TSLDataModel &$record = NULL, \TSLRequestConstraints &$constraints = NULL, $subOperation = NULL);

    /**
     * Funcion que elimina un registro de la persistencia.
     *
     * @param mixed $id , representa el valor unico del registro dentro de la base de datos.
     * @param long  $versionid el cual representa la version del registro en la persistencia,
     * debemos recordar que toda base de datos al menos es capaz de mantener un codigo
     * de version de un registro el cual cambia en cada update.
     * @param  boolean $verifiedDeletedCheck , si es true verficara si no pudo eliminar por ya estar
     * eliminado el registro. Es usualmente util para el caso de bases de datos que no soporten
     * versionamiento.
     *
     * @return string
     * DB_ERR_ALL_OK no hay errores
     * DB_ERR_SERVERNOTFOUND el servidor de base de datos no se ha encontrado.
     * DB_ERR_CANTEXECUTE Error ejecutando el query.
     * DB_ERR_RECORDNOTFOUND - No se encontro el registro   ya estaba eliminado
     *
     * @expectedException \TSLDbException si existe un error no recuperable
     *
     */
    public function remove($id, $versionId, $verifiedDeletedCheck);

    /**
     * Funcion que actualiza un registro en la persistencia.
     * Debe verificar si el registro ha sido modificado o ya no existe, si estuviera modificado
     * el parametro model debe retornar el registro modificado.
     *
     * @param \TSLDataModel  $model, datos a actualizar , en el caso haya
     * sido modificado previo a grabar contendra el registro modificado.
     * @param string $subOperation esto puede usarse para indicar que clase de relectura
     * de registro luego del update debe hacerse (llamada a get()).
     *     *
     * @return string
     * DB_ERR_ALL_OK no hay errores
     * DB_ERR_SERVERNOTFOUND el servidor de base de datos no se ha encontrado.
     * DB_ERR_CANTEXECUTE Error ejecutando el query.
     * DB_ERR_RECORDNOTFOUND - No se encontro el registro   ya estaba eliminado
     * DB_ERR_RECORD_MODIFIED - El registro esta modificado.
     *
     * @expectedException \TSLDbException si existe un error no recuperable
     *
     */
    public function update(\TSLDataModel &$record, $subOperation = NULL);

    /**
     * Funcion que agrega un registro a  la persistencia.
     * Debe verificar que el registro no haya sido modificado externamente.
     * De estar modificado , el parametro model debera contener el registro encontrado.
     *
     * @param \TSLDataModel  $model, datos a agregar , en el caso ya
     * se encuentre el registro contendra el registro agregado externamente.
     * @param \TSLRequestConstraints $constraints que para este caso podria ser
     * por ejemplo un valor que puedamodificar la forma de agregar o cualquier otro uso.
     * @param string $subOperation esto puede usarse para indicar que clase de relectura
     * de registro luego del add debe hacerse (llamada a get()).
     *
     * @return string
     * DB_ERR_ALL_OK no hay errores
     * DB_ERR_SERVERNOTFOUND el servidor de base de datos no se ha encontrado.
     * DB_ERR_CANTEXECUTE Error ejecutando el query.
     * DB_ERR_RECORDEXIST - El registro ya existe previamente.
     *
     * @expectedException  \TSLDbException si existe un error no recuperable
     *
     */
    public function add(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL, $subOperation = NULL);

    /**
     * Dado que no existe una manera comun entre las bases de datos para
     * determinar el error por llave duplicada , algunos dan un codigo
     * de error y otros solo un mensaje , este metodo debe ser implementado
     * para cada caso , de ser necesario.
     *
     * @param int $errorCode , El error retornado al ejecutar el query
     * @param string $errorMsg , el mensaje de error
     * @return boolean TRUE si es llave diuplicada, FALSE de lo contrario
     */
    public function isDuplicateKeyError($errorCode, $errorMsg);

    /**
     * Dado que no existe una manera comun entre las bases de datos para
     * determinar el error por lforeign key , algunos dan un codigo
     * de error y otros solo un mensaje , este metodo debe ser implementado
     * para cada caso , de ser necesario.
     *
     * @param int $errorCode , El error retornado al ejecutar el query
     * @param string $errorMsg , el mensaje de error
     * @return boolean TRUE si es error de foreign key, FALSE de lo contrario
     */
    public function isForeignKeyError($errorCode, $errorMsg);

    /**
     * Dado que no existe una manera comun entre las bases de datos para
     * determinar el error por registro modficado por otra estacion ,
     * Se deja a la implementacion del driver final que indique si un registro
     * ha sido modificado. Posiblemente la implementacion default lo haga por comparacion
     * pero esto no es posible si se hace un stored procedure.
     *
     * @param int $errorCode , El error retornado al ejecutar el query
     * @param string $errorMsg , el mensaje de error
     * @return boolean TRUE si es error de registro modificado, FALSE de lo contrario
     */
    public function isRecordModifiedError($errorCode, $errorMsg);
}

?>