<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que manipula las acciones directas a los tipos de records
 *  tales como listar , agregar , eliminar , etc.
 *
 * @author $Author: aranape $
 * @since 17-May-2013
 * @version $Id: RecordsTipoBussinessService.php 295 2014-06-30 22:29:53Z aranape $
 * @history 1.01 , Se agrego soporte para foreign key
 *
 * $Date: 2014-06-30 17:29:53 -0500 (lun, 30 jun 2014) $
 * $Rev: 295 $
 */
class RecordsTipoBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

    function __construct() {
        //    parent::__construct();
        $this->setup("RecordsTipoDAO", "recordstipo", "msg_recordstipo");
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return RecordsTipoModel
     */
    protected function &getModelToAdd(\TSLIDataTransferObj $dto) {
        $model = new RecordsTipoModel();
        // Leo el id enviado en el DTO
        $model->set_records_tipo_codigo($dto->getParameterValue('records_tipo_codigo'));
        $model->set_records_tipo_descripcion($dto->getParameterValue('records_tipo_descripcion'));
        $model->set_records_tipo_abreviatura($dto->getParameterValue('records_tipo_abreviatura'));
        $model->set_records_tipo_tipo($dto->getParameterValue('records_tipo_tipo'));
        $model->set_records_tipo_clasificacion($dto->getParameterValue('records_tipo_clasificacion'));
        $model->set_records_tipo_peso($dto->getParameterValue('records_tipo_peso'));
        $model->set_records_tipo_protected('records_tipo_protected');
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->setUsuario($dto->getSessionUser());

        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return RecordsTipoModel
     */
    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) {
        $model = new RecordsTipoModel();
        // Leo el id enviado en el DTO
        $model->set_records_tipo_codigo($dto->getParameterValue('records_tipo_codigo'));
        $model->set_records_tipo_descripcion($dto->getParameterValue('records_tipo_descripcion'));
        $model->set_records_tipo_abreviatura($dto->getParameterValue('records_tipo_abreviatura'));
        $model->set_records_tipo_tipo($dto->getParameterValue('records_tipo_tipo'));
        $model->set_records_tipo_clasificacion($dto->getParameterValue('records_tipo_clasificacion'));
        $model->set_records_tipo_peso($dto->getParameterValue('records_tipo_peso'));
        $model->set_records_tipo_protected('records_tipo_protected');
        $model->setVersionId($dto->getParameterValue('versionId'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->set_Usuario_mod($dto->getSessionUser());
        return $model;
    }

    /**
     *
     * @return RecordsTipoModel
     */
    protected function &getEmptyModel() {
        $model = new RecordsTipoModel();
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel
     */
    protected function &getModelToDelete(\TSLIDataTransferObj $dto) {
        $model = new RecordsTipoModel();
        $model->set_records_tipo_codigo($dto->getParameterValue('records_tipo_codigo'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        $model->set_Usuario_mod($dto->getSessionUser());

        return $model;
    }

}

?>
