<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que manipula las acciones directas a los tipos de costos
 *  tales como listar , agregar , eliminar , etc.
 *
 * @author $Author: aranape $
 * @since 17-May-2013
 * @version $Id: RegionesBussinessService.php 271 2014-06-27 20:22:18Z aranape $
 * @history 1.01 , Se agrego soporte para foreign key
 *
 * $Date: 2014-06-27 15:22:18 -0500 (vie, 27 jun 2014) $
 * $Rev: 271 $
 */
class TipoCostosBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

    function __construct() {
        //    parent::__construct();
        $this->setup("TipoCostosDAO", "tipocostos", "msg_tipocostos");
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return TipoCostosModel
     */
    protected function &getModelToAdd(\TSLIDataTransferObj $dto) {
        $model = new TipoCostosModel();
        // Leo el id enviado en el DTO
        $model->set_tcostos_codigo($dto->getParameterValue('tcostos_codigo'));
        $model->set_tcostos_descripcion($dto->getParameterValue('tcostos_descripcion'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->setUsuario($dto->getSessionUser());

        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return TipoCostosModel
     */
    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) {
        $model = new TipoCostosModel();
        // Leo el id enviado en el DTO
        $model->set_tcostos_codigo($dto->getParameterValue('tcostos_codigo'));
        $model->set_tcostos_descripcion($dto->getParameterValue('tcostos_descripcion'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->set_Usuario_mod($dto->getSessionUser());
        return $model;
    }

    /**
     *
     * @return TipoCostosModel
     */
    protected function &getEmptyModel() {
        $model = new TipoCostosModel();
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel
     */
    protected function &getModelToDelete(\TSLIDataTransferObj $dto) {
        $model = new TipoCostosModel();
        $model->set_tcostos_codigo($dto->getParameterValue('tcostos_codigo'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        $model->set_Usuario_mod($dto->getSessionUser());

        return $model;
    }

}

?>
