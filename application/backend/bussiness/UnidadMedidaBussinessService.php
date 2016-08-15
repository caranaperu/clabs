<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que manipula las acciones directas a las unidades de medidas
 *  tales como listar , agregar , eliminar , etc.
 *
 * @author $Author: aranape $
 * @since 17-May-2013
 * @version $Id: UnidadMedidaBussinessService.php 136 2014-04-07 00:31:52Z aranape $
 * @history 1.01 , Se agrego soporte para foreign key
 *
 * $Date: 2014-04-06 19:31:52 -0500 (dom, 06 abr 2014) $
 * $Rev: 136 $
 */
class UnidadMedidaBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

    function __construct() {
        //    parent::__construct();
        $this->setup("UnidadMedidaDAO", "unidadmedida", "msg_unidadmedida");
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return UnidadMedidaModel
     */
    protected function &getModelToAdd(\TSLIDataTransferObj $dto) {
        $model = new UnidadMedidaModel();
        // Leo el id enviado en el DTO
        $model->set_unidad_medida_codigo($dto->getParameterValue('unidad_medida_codigo'));
        $model->set_unidad_medida_descripcion($dto->getParameterValue('unidad_medida_descripcion'));
        $model->set_unidad_medida_siglas($dto->getParameterValue('unidad_medida_siglas'));
        $model->set_unidad_medida_tipo($dto->getParameterValue('unidad_medida_tipo'));
        $model->set_unidad_medida_protected($dto->getParameterValue('unidad_medida_protected'));

        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->setUsuario($dto->getSessionUser());
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return UnidadMedidaModel
     */
    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) {
        $model = new UnidadMedidaModel();
        // Leo el id enviado en el DTO
        $model->set_unidad_medida_codigo($dto->getParameterValue('unidad_medida_codigo'));
        $model->set_unidad_medida_descripcion($dto->getParameterValue('unidad_medida_descripcion'));
        $model->set_unidad_medida_siglas($dto->getParameterValue('unidad_medida_siglas'));
        $model->set_unidad_medida_tipo($dto->getParameterValue('unidad_medida_tipo'));
        $model->set_unidad_medida_protected($dto->getParameterValue('unidad_medida_protected'));

        $model->setVersionId($dto->getParameterValue('versionId'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->set_Usuario_mod($dto->getSessionUser());
        return $model;
    }

    /**
     *
     * @return UnidadMedidaModel
     */
    protected function &getEmptyModel() {
        $model = new UnidadMedidaModel();
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel
     */
    protected function &getModelToDelete(\TSLIDataTransferObj $dto) {
        $model = new UnidadMedidaModel();
        $model->set_unidad_medida_codigo($dto->getParameterValue('unidad_medida_codigo'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        $model->set_Usuario_mod($dto->getSessionUser());

        return $model;
    }

}

?>
