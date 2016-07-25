<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que manipula las acciones directas de los records diversos posibles
 * como nacionales,mundiales,etc.
 *
 * @author $Author: aranape $
 * @since 17-May-2013
 * @version $Id: RecordsBussinessService.php 307 2014-07-16 02:17:13Z aranape $
 * @history 1.01 , Se agrego soporte para foreign key
 *
 * $Date: 2014-07-15 21:17:13 -0500 (mar, 15 jul 2014) $
 * $Rev: 307 $
 */
class RecordsBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

    function __construct() {
        //    parent::__construct();
        $this->setup("RecordsDAO", "records", "msg_records");
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return RecordsModel
     */
    protected function &getModelToAdd(\TSLIDataTransferObj $dto) {
        $model = new RecordsModel();
        // Leo el id enviado en el DTO
        $model->set_records_tipo_codigo($dto->getParameterValue('records_tipo_codigo'));
        $model->set_atletas_resultados_id($dto->getParameterValue('atletas_resultados_id'));
        $model->set_categorias_codigo($dto->getParameterValue('categorias_codigo'));
        $model->set_records_id_origen($dto->getParameterValue('records_id_origen'));
        $model->set_records_protected($dto->getParameterValue('records_protected'));

        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->setUsuario($dto->getSessionUser());

        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return RecordsModel
     */
    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) {
        $model = new RecordsModel();
        // Leo el id enviado en el DTO
        $model->set_records_id($dto->getParameterValue('records_id'));
        $model->set_records_tipo_codigo($dto->getParameterValue('records_tipo_codigo'));
        $model->set_atletas_resultados_id($dto->getParameterValue('atletas_resultados_id'));
        $model->set_categorias_codigo($dto->getParameterValue('categorias_codigo'));
        $model->set_records_id_origen($dto->getParameterValue('records_id_origen'));
        $model->set_records_protected($dto->getParameterValue('records_protected'));

        $model->setVersionId($dto->getParameterValue('versionId'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->set_Usuario_mod($dto->getSessionUser());
        return $model;
    }

    /**
     *
     * @return RecordsModel
     */
    protected function &getEmptyModel() {
        $model = new RecordsModel();
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel
     */
    protected function &getModelToDelete(\TSLIDataTransferObj $dto) {
        $model = new RecordsModel();
        $model->set_records_id($dto->getParameterValue('records_id'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        $model->set_Usuario_mod($dto->getSessionUser());

        return $model;
    }

}

?>
