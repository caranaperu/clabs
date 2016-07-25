<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que manipula las acciones directas a las regiones atleticas
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
class RegionesBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

    function __construct() {
        //    parent::__construct();
        $this->setup("RegionesDAO", "regiones", "msg_regiones");
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return RegionesModel
     */
    protected function &getModelToAdd(\TSLIDataTransferObj $dto) {
        $model = new RegionesModel();
        // Leo el id enviado en el DTO
        $model->set_regiones_codigo($dto->getParameterValue('regiones_codigo'));
        $model->set_regiones_descripcion($dto->getParameterValue('regiones_descripcion'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->setUsuario($dto->getSessionUser());

        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return RegionesModel
     */
    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) {
        $model = new RegionesModel();
        // Leo el id enviado en el DTO
        $model->set_regiones_codigo($dto->getParameterValue('regiones_codigo'));
        $model->set_regiones_descripcion($dto->getParameterValue('regiones_descripcion'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->set_Usuario_mod($dto->getSessionUser());
        return $model;
    }

    /**
     *
     * @return RegionesModel
     */
    protected function &getEmptyModel() {
        $model = new RegionesModel();
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel
     */
    protected function &getModelToDelete(\TSLIDataTransferObj $dto) {
        $model = new RegionesModel();
        $model->set_regiones_codigo($dto->getParameterValue('regiones_codigo'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        $model->set_Usuario_mod($dto->getSessionUser());

        return $model;
    }

}

?>
