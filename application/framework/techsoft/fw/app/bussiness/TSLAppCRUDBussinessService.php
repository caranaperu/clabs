<?php

namespace app\common\bussiness;

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que manipula las acciones directas a la entidad
 * tales como listar , agregar , eliminar , etc., este es util para casos
 * simples donde las operaciones CRUD se asocian directamente a un modelo.
 *
 * @since 17-Sep-2011
 * @version 1.01
 * @history 1.01 - Se agrego soporte para foreign keys
 *
 * 18 JUL 2016 Se agrego a las llamadas get que representan la relectura de un record el parametro
 * subOperation de acuerdo a los nuevos requerimientos de los dao,
 *
 * $Author: aranape $
 * $Date: 2014-02-10 22:31:42 -0500 (lun, 10 feb 2014) $
 * $Rev: 4 $
 *
 */
abstract class TSLAppCRUDBussinessService extends \TSLStandardBussinessService {

    /**
     * El Nombre que identifica al DAO
     * @var String
     */
    private $IdDAOName;

    /**
     * El nombre en la definicion de lenguaje para los mensajes de error o informacion,
     * @var String
     */
    private $IdMSGLanguage;

    /**
     * Prefijo a usarse para rescatar los mensajes en el lenguaje adecuado.
     * @var String
     */
    private $msgPrefix;

    /**
     *
     * @param string $IdDAOName Nombre de la clase DAO
     * @param string $IdMSGLanguage Identificador del lenguage para los mensajes,
     * por ejemplo sera usado en $CI->lang->load('tcontribuyente')
     *
     * @param string $msgPrefix prefijo a usar en los identificadores de mensajes
     * por ejemplo "msg_tcontrib" el cual sera prefijado a "_servererror" para la
     * busqueda del mensaje , la segunda parte esta fija en el codigo.
     */
    public function setup($IdDAOName, $IdMSGLanguage, $msgPrefix) {
        $this->IdDAOName = $IdDAOName;
        $this->IdMSGLanguage = $IdMSGLanguage;
        $this->msgPrefix = $msgPrefix;
    }

    /**
     * Despachador estandard para las Operaciones CRUD de un servicio.
     * Se entiende que a traves del DTO o DATA TRANSFER OBJECT se
     * entregara la informacion necesaria para el procesamiento de la operacion.
     *
     * @param type $action , las acciones estandard soportadas son list,read,delete,update,add
     * @param \TSLIDataTransferObj $dto el DATA TRANSFER OBJECT
     * @return Mixed el resultado de la operacion o los registros de dicha operacion, ver casos
     * especificos en cada operacion, los errores o excepciones se retornaran dentro del DTO.
     */
    protected function doService($action, \TSLIDataTransferObj $dto) {
        if ($action == 'fetch' || $action == 'list') {
            return $this->fetch($dto);
        } else if ($action == 'read') {
            return $this->read($dto);
        } else if ($action == 'delete' || $action == 'del') {
            return $this->delete($dto);
        } else if ($action == 'update' || $action == 'upd') {
            return $this->update($dto);
        } else if ($action == 'add') {
            return $this->add($dto);
        }
    }

    /**
     * Retorna una lista con todos los tipos de registros asociados
     * a la operacion listAll del DAO indicado.
     * Esta lista no es paginada
     *
     * @param \TSLIDataTransferObj $dto EL DATA TRANSFER OBJECT este es el repositorio
     * de las respuestas encontradas y/o de los mensajes necesarios ya sean de exito o error.
     *
     * @see \TSLIBasicRecordDAO
     * @see \TSLBasicRecordDAO
     *
     */
    private function fetch(\TSLIDataTransferObj $dto) {
        // Obtengo referencia a los constraints
        $constraints = &$dto->getConstraints();
        // Obtengo la sub operacion si existe
        $subOperation = &$dto->getSubOperation();

        $model = &$this->getEmptyModel();

        // Obtengo la referencia al mensaje de salida.
        $outMessage = &$dto->getOutMessage();
        $tmg = NULL;
        try {
            $tmg = \TSLTrxFactoryManager::instance()->getTrxManager();
            $tmg->init();

            /* @var $dao \TSLIBasicRecordDAO */
            $dao = \TSLDAOLoaderHelper::loadDAO($this->IdDAOName);
            $ret = $dao->fetch($model, $constraints, $subOperation);

            /* @var $outMessage TSLOutMessage */
            $outMessage->setSuccess(true);
            $outMessage->setResultData($ret);
        } catch (Exception $ex) {
            // Coloco la excepcion en el DTO.
            // TODO: Internacionalizar.
            $processError = new \TSLProcessErrorMessage($ex->getCode(), 'Error Interno', $ex);
            $outMessage->addProcessError($processError);
        }

        if ($tmg !== NULL) {
            $tmg->end();
        }
    }

    /**
     * Lee un registro de la persistencia.
     *
     * @param \TSLIDataTransferObj $dto EL DATA TRANSFER OBJECT contendra todos los
     * datos requeridos para la busqueda del registro a leer, se espera los siguientes
     * parametros al menos:
     * id: EL identificador unico del registro a leer
     * verifyExist: si es true indicara error si no existe.
     *
     * Ya sea en caso de error o no , la respuesta estara contenida en el DTO.
     *
     * @see \TSLIBasicRecordDAO
     * @see \TSLBasicRecordDAO
     */
    private function read(\TSLIDataTransferObj $dto) {
        $model = &$this->getEmptyModel();

        // Leo el id enviado en el DTO
        $id = $dto->getParameterValue('id');
        $verifyExist = $dto->getParameterValue('verifyExist');

        /* @var $outMessage TSLOutMessage */
        $outMessage = &$dto->getOutMessage();
        // Obtengo la sub operacion si existe
        $subOperation = &$dto->getSubOperation();

        $tmg = NULL;

        try {
            $tmg = \TSLTrxFactoryManager::instance()->getTrxManager();
            $tmg->init();

            /* @var $dao \TSLIBasicRecordDAO */
            $dao = \TSLDAOLoaderHelper::loadDAO($this->IdDAOName);

            /* @var $ret CommonBaseModel */
            $ret = $dao->get($id, $model,$subOperation);

            if ($ret === DB_ERR_ALLOK) {
                $outMessage->setSuccess(true);
                // El resultado es el modelo mismo con los datos adicionales
                $outMessage->setResultData($model);
            } else {
                $CI = & get_instance();
                $CI->lang->load($this->IdMSGLanguage);


                // Si no se verifica si existe el record no enviamos mensaje de error
                if ($verifyExist === 'false') {
                    if ($ret != DB_ERR_RECORDNOTFOUND) {
                        $outMessage->setSuccess(false);
                        // Send the error message
                        if ($ret == DB_ERR_RECORDINACTIVE) {
                            $outMessage->setAnswerMessage($CI->lang->line($this->msgPrefix . '_rec_inactivo'), $ret);
                        } else {
                            $outMessage->setAnswerMessage($CI->lang->line($this->msgPrefix . '_servererror'), $ret);
                        }
                    } else {
                        $outMessage->setSuccess(TRUE);
                        // Ponemos el codigo enviado como lo unico encontrado.
                        $model->setCodigo($id);
                        $outMessage->setResultData($model);
                    }
                } else {
                    $outMessage->setSuccess(false);
                    // Send the error message
                    if ($ret == DB_ERR_RECORDINACTIVE) {
                        $outMessage->setAnswerMessage($CI->lang->line($this->msgPrefix . '_rec_inactivo'), $ret);
                    } else {
                        $outMessage->setAnswerMessage($CI->lang->line($ret == DB_ERR_RECORDNOTFOUND ? $this->msgPrefix . '_notexist' : $this->msgPrefix . '_servererror'), $ret);
                    }
                }
            }
        } catch (\Exception $ex) {
            // Coloco la excepcion en el DTO.
            // TODO: Internacionalizar.
            $processError = new \TSLProcessErrorMessage($ex->getCode(), 'Error Interno', $ex);
            $outMessage->addProcessError($processError);
        }
        if ($tmg !== NULL) {
            $tmg->end();
        }
    }

    /**
     * Elimina un registro de la persistencia.
     *
     * @param \TSLIDataTransferObj $dto EL DATA TRANSFER OBJECT contendra todos los
     * datos requeridos del registro a eliminar, se espera los siguientes
     * parametros al menos:
     * id: EL identificador unico del registro a leer.
     * versionid ; Identificador unico de version del registro a eliminar,
     * si este valor se encuentra cambiado se asume que ha sido alterado previo a esta
     * accion de eliminacion.
     * $verifiedDeleted: si es true indicara error en el caso que ya haya sido eliminado.
     *
     * Ya sea en caso de error o no , la respuesta estara contenida en el DTO.
     *
     * @see \TSLIBasicRecordDAO
     * @see \TSLBasicRecordDAO
     */
    private function delete(\TSLIDataTransferObj $dto) {
        $model = &$this->getModelToDelete($dto);

        // Opcional solo si se desea chequear si ya estaba previamente eliminado.
        $verifiedDeleted = $dto->getParameterValue('verifiedDeleted');

        // Si no se indica por default se verificara si realmente fue eliminado.
        if (!isset($verifiedDeleted) || !is_bool($verifiedDeleted)) {
            $verifiedDeleted = true;
        }

        /* @var $outMessage TSLOutMessage */
        $outMessage = &$dto->getOutMessage();

        $tmg = NULL;

        try {
            $tmg = \TSLTrxFactoryManager::instance()->getTrxManager();
            $tmg->init();

            /* @var $dao \TSLIBasicRecordDAO */
            $dao = \TSLDAOLoaderHelper::loadDAO($this->IdDAOName);


            $ret = $dao->remove($model->getId(), $model->getVersionId(), $verifiedDeleted);

            if ($ret === DB_ERR_ALLOK) {
                $outMessage->setSuccess(true);
                // Se indica el codigo o pk del registro eliminado
                $outMessage->setResultData($model->getPKAsArray());
            } else {
                $CI = & get_instance();
                $CI->lang->load($this->IdMSGLanguage);

                $outMessage->setSuccess(false);

                if ($ret == DB_ERR_FOREIGNKEY) {
                    $outMessage->setAnswerMessage($CI->lang->line($this->msgPrefix . '_rec_foreignkey_del'), $ret);
                } else {
                    // Send the error message
                    $outMessage->setAnswerMessage($CI->lang->line($ret == DB_ERR_RECORDNOTFOUND ? $this->msgPrefix . '_delnotexist' : $this->msgPrefix . '_servererror'), $ret);
                }
            }
            $tmg->end();
        } catch (\Exception $ex) {
            // Coloco la excepcion en el DTO.
            // TODO: Internacionalizar.
            $processError = new \TSLProcessErrorMessage($ex->getCode(), 'Error Interno', $ex);
            $outMessage->addProcessError($processError);
        }
        if ($tmg !== NULL) {
            $tmg->end();
        }
    }

    /**
     * Actualiza un registro en la persistencia.
     *
     * @param \TSLIDataTransferObj $dto EL DATA TRANSFER OBJECT contendra todos los
     * datos requeridos del registro a actualizar, se espera como parte de los parametros
     * los datos a usarse para crear el modelo a actualizar.
     *
     * Ya sea en caso de error o no , la respuesta estara contenida en el DTO.
     *
     * @see \TSLIBasicRecordDAO
     * @see \TSLBasicRecordDAO
     */
    private function update(\TSLIDataTransferObj $dto) {

        $model = &$this->getModelToUpdate($dto);

        /* @var $outMessage TSLOutMessage */
        $outMessage = &$dto->getOutMessage();
        // Obtengo la sub operacion si existe
        $subOperation = &$dto->getSubOperation();

        $tmg = NULL;
        try {
            $tmg = \TSLTrxFactoryManager::instance()->getTrxManager();
            $tmg->init();

            /* @var $dao \TSLIBasicRecordDAO */
            $dao = \TSLDAOLoaderHelper::loadDAO($this->IdDAOName);

            /* @var $ret string */
            $ret = $dao->update($model,$subOperation);

            $CI = & get_instance();
            if ($ret === DB_ERR_ALLOK) {
                $outMessage->setSuccess(true);
                // El resultado es el modelo mismo con los datos pero el campo de version modificado.
                $outMessage->setResultData($model);
            } else if ($ret == DB_ERR_RECORD_MODIFIED) {
                $outMessage->setSuccess(false);
                // El resultado es el modelo mismo con los datos del registro modificados
                $outMessage->setResultData($model);
                $CI->lang->load($this->IdMSGLanguage);
                $outMessage->setAnswerMessage($CI->lang->line($this->msgPrefix . '_recmodified'), $ret);
            } else if ($ret == DB_ERR_FOREIGNKEY) {
                $outMessage->setSuccess(false);
                $CI->lang->load($this->IdMSGLanguage);
                $outMessage->setAnswerMessage($CI->lang->line($this->msgPrefix . '_rec_foreignkey_add'), $ret);
            } else if ($ret == DB_ERR_DUPLICATEKEY) {
                $outMessage->setSuccess(false);
                $CI->lang->load($this->IdMSGLanguage);
                $outMessage->setAnswerMessage($CI->lang->line($this->msgPrefix . '_rec_duplicatekey'), $ret);
            } else {
                $CI->lang->load($this->IdMSGLanguage);
                $outMessage->setSuccess(false);
                // Si es iactivo enviamos el mensaje respectivo
                if ($ret == DB_ERR_RECORDINACTIVE) {
                    $outMessage->setAnswerMessage($CI->lang->line($this->msgPrefix . '_rec_inactivo'), $ret);
                } else {
                    $outMessage->setAnswerMessage($CI->lang->line($ret == DB_ERR_RECORDNOTFOUND ? $this->msgPrefix . '_recdeleted' : $this->msgPrefix . '_servererror'), $ret);
                }
            }
        } catch (\Exception $ex) {
            // Coloco la excepcion en el DTO.
            // TODO: Internacionalizar.
            $processError = new \TSLProcessErrorMessage($ex->getCode(), 'Error Interno', $ex);
            $outMessage->addProcessError($processError);
        }
        if ($tmg !== NULL) {
            $tmg->end();
        }
    }

    /**
     * Agrega un registro a la persistencia.
     *
     * @param \TSLIDataTransferObj $dto EL DATA TRANSFER OBJECT contendra todos los
     * datos requeridos del registro a agregar, se espera como parte de los parametros
     * los datos a usarse para crear el modelo a actualizar.
     *
     * Ya sea en caso de error o no , la respuesta estara contenida en el DTO.
     *
     * @see \TSLIBasicRecordDAO
     * @see \TSLBasicRecordDAO
     */
    private function add(\TSLIDataTransferObj $dto) {
        // Obtengo referencia a los constraints
        $constraints = &$dto->getConstraints();
        // el modelo
        $model = &$this->getModelToAdd($dto);

        /* @var $outMessage TSLOutMessage */
        $outMessage = &$dto->getOutMessage();
        // Obtengo la sub operacion si existe
        $subOperation = &$dto->getSubOperation();

        $tmg = NULL;

        try {
            $tmg = \TSLTrxFactoryManager::instance()->getTrxManager();
            $tmg->init();

            /* @var $dao \TSLIBasicRecordDAO */
            $dao = \TSLDAOLoaderHelper::loadDAO($this->IdDAOName);

            /* @var $ret string */
            $ret = $dao->add($model, $constraints,$subOperation);

            $CI = & get_instance();
            if ($ret === DB_ERR_ALLOK) {
                $outMessage->setSuccess(true);
                // El resultado es el modelo mismo con los datos pero el campo de version modificado.
                $outMessage->setResultData($model);
            } else if ($ret == DB_ERR_RECORDEXIST) {
                $outMessage->setSuccess(false);
                // El resultado es el modelo mismo con los datos del registro modificados
                $outMessage->setResultData($model);
                $CI->lang->load($this->IdMSGLanguage);
                $outMessage->setAnswerMessage($CI->lang->line($this->msgPrefix . '_rec_alreadyexist'), $ret);
            } else if ($ret == DB_ERR_FOREIGNKEY) {
                $outMessage->setSuccess(false);
                $CI->lang->load($this->IdMSGLanguage);
                $outMessage->setAnswerMessage($CI->lang->line($this->msgPrefix . '_rec_foreignkey_add'), $ret);
            } else {
                $CI->lang->load($this->IdMSGLanguage);
                $outMessage->setSuccess(false);

                // Si es iactivo enviamos el mensaje respectivo
                if ($ret == DB_ERR_RECORDINACTIVE) {
                    $outMessage->setAnswerMessage($CI->lang->line($this->msgPrefix . '_rec_inactivo'), $ret);
                } else {
                    $outMessage->setAnswerMessage($CI->lang->line($this->msgPrefix . '_servererror'), $ret);
                }
            }
        } catch (\Exception $ex) {
            // Coloco la excepcion en el DTO.
            // TODO: Internacionalizar.
            $processError = new \TSLProcessErrorMessage($ex->getCode(), 'Error Interno', $ex);
            $outMessage->addProcessError($processError);
        }
        if ($tmg !== NULL) {
            $tmg->end();
        }
    }

    /**
     * Metodo a ser implementado por las clases especificas que basicamente debera
     * extraer del DTO los valores del modelo  para crearlo y retornarlo para
     * su posterior proceso en un update.
     *
     * @param \TSLIDataTransferObj $dto EL DATA TRANSFER OBJECT conteniendo
     * los datos para crear el modelo dentro de su lista de parametros.
     *
     * @return \TSLDataModel Some especific model to work with it.
     */
    abstract protected function &getModelToUpdate(\TSLIDataTransferObj $dto);

    /**
     * Metodo a ser implementado por las clases especificas que basicamente debera
     * extraer del DTO los valores del modelo  para crearlo y retornarlo para
     * su posterior proceso en una operacion de agregar.
     *
     * @param \TSLIDataTransferObj $dto EL DATA TRANSFER OBJECT conteniendo
     * los datos para crear el modelo dentro de su lista de parametros.
     *
     * @return \TSLDataModel Some especific model to work with it.
     */
    abstract protected function &getModelToAdd(\TSLIDataTransferObj $dto);

    /**
     * return an instance of the model to work.
     *
     * @return \TSLDataModel Some especific model to work with it.
     */
    abstract protected function &getEmptyModel();

    /**
     * Retorna una instancia del modelo para eliminar.
     *
     * @param \TSLIDataTransferObj $dto EL DATA TRANSFER OBJECT conteniendo
     * los datos para crear el modelo dentro de su lista de parametros.
     *
     * @return \TSLDataModel el modelo especifico a usar.
     */
    abstract protected function &getModelToDelete(\TSLIDataTransferObj $dto);
}

?>
