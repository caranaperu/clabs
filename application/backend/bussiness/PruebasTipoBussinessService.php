<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que manipula las acciones directas de los tipos de pruebas
 *  tales como listar , agregar , eliminar , etc.
 *
 * @author $Author: aranape $
 * @since 17-May-2013
 * @version $Id: PruebasTipoBussinessService.php 75 2014-03-09 10:25:12Z aranape $
 * @history 1.01 , Se agrego soporte para foreign key
 *
 * $Date: 2014-03-09 05:25:12 -0500 (dom, 09 mar 2014) $
 * $Rev: 75 $
 */
class PruebasTipoBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

    function __construct() {
        //    parent::__construct();
        $this->setup("PruebasTipoDAO", "pruebastipo", "msg_pruebastipo");
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return PruebasTipoModel
     */
    protected function &getModelToAdd(\TSLIDataTransferObj $dto) {
        $model = new PruebasTipoModel();
        // Leo el id enviado en el DTO
        $model->set_pruebas_tipo_codigo($dto->getParameterValue('pruebas_tipo_codigo'));
        $model->set_pruebas_tipo_descripcion($dto->getParameterValue('pruebas_tipo_descripcion'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->setUsuario($dto->getSessionUser());

        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return PruebasTipoModel
     */
    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) {
        $model = new PruebasTipoModel();
        // Leo el id enviado en el DTO
        $model->set_pruebas_tipo_codigo($dto->getParameterValue('pruebas_tipo_codigo'));
        $model->set_pruebas_tipo_descripcion($dto->getParameterValue('pruebas_tipo_descripcion'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->set_Usuario_mod($dto->getSessionUser());
        return $model;
    }

    /**
     *
     * @return PruebasTipoModel
     */
    protected function &getEmptyModel() {
        $model = new PruebasTipoModel();
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel
     */
    protected function &getModelToDelete(\TSLIDataTransferObj $dto) {
        $model = new PruebasTipoModel();
        $model->set_pruebas_tipo_codigo($dto->getParameterValue('pruebas_tipo_codigo'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        $model->set_Usuario_mod($dto->getSessionUser());

        return $model;
    }

}

?>
