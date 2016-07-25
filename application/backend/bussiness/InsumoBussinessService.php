<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que manipula las acciones directas a los insumos
 *  tales como listar , agregar , eliminar , etc.
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.1
 * @package CLABS
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license GPL
 *
 */
class InsumoBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

    function __construct() {
        //    parent::__construct();
        $this->setup("InsumoDAO", "insumo", "msg_insumo");
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return InsumoModel
     */
    protected function &getModelToAdd(\TSLIDataTransferObj $dto) {
        $model = new InsumoModel();
        // Leo el id enviado en el DTO
        $model->set_insumo_codigo($dto->getParameterValue('insumo_codigo'));
        $model->set_insumo_descripcion($dto->getParameterValue('insumo_descripcion'));
        $model->set_tcostos_codigo($dto->getParameterValue('tcostos_codigo'));
        $model->set_tinsumo_codigo($dto->getParameterValue('tinsumo_codigo'));
        $model->set_unidad_medida_codigo($dto->getParameterValue('unidad_medida_codigo'));
        $model->set_insumo_merma($dto->getParameterValue('insumo_merma'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->setUsuario($dto->getSessionUser());

        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return InsumoModel
     */
    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) {
        $model = new InsumoModel();
        // Leo el id enviado en el DTO
        $model->set_insumo_codigo($dto->getParameterValue('insumo_codigo'));
        $model->set_insumo_descripcion($dto->getParameterValue('insumo_descripcion'));
        $model->set_tcostos_codigo($dto->getParameterValue('tcostos_codigo'));
        $model->set_tinsumo_codigo($dto->getParameterValue('tinsumo_codigo'));
        $model->set_unidad_medida_codigo($dto->getParameterValue('unidad_medida_codigo'));
        $model->set_insumo_merma($dto->getParameterValue('insumo_merma'));

        $model->setVersionId($dto->getParameterValue('versionId'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->set_Usuario_mod($dto->getSessionUser());
        return $model;
    }

    /**
     *
     * @return InsumoModel
     */
    protected function &getEmptyModel() {
        $model = new InsumoModel();
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel
     */
    protected function &getModelToDelete(\TSLIDataTransferObj $dto) {
        $model = new InsumoModel();
        $model->set_insumo_codigo($dto->getParameterValue('insumo_codigo'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        $model->set_Usuario_mod($dto->getSessionUser());

        return $model;
    }

}

?>
