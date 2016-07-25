<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que manipula las acciones directas a las ciudades
 *  tales como listar , agregar , eliminar , etc.
 *
 * @author $Author: aranape $
 * @since 17-May-2013
 * @version $Id: CiudadesBussinessService.php 218 2014-06-23 22:58:34Z aranape $
 * @history 1.01 , Se agrego soporte para foreign key
 *
 * $Date: 2014-06-23 17:58:34 -0500 (lun, 23 jun 2014) $
 * $Rev: 218 $
 */
class CiudadesBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

    function __construct() {
        //    parent::__construct();
        $this->setup("CiudadesDAO", "ciudades", "msg_ciudades");
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return CiudadesModel
     */
    protected function &getModelToAdd(\TSLIDataTransferObj $dto) {
        $model = new CiudadesModel();
        // Leo el id enviado en el DTO
        $model->set_ciudades_codigo($dto->getParameterValue('ciudades_codigo'));
        $model->set_ciudades_descripcion($dto->getParameterValue('ciudades_descripcion'));
        $model->set_paises_codigo($dto->getParameterValue('paises_codigo'));
        $model->set_ciudades_altura($dto->getParameterValue('ciudades_altura'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->setUsuario($dto->getSessionUser());

        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return CiudadesModel
     */
    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) {
        $model = new CiudadesModel();
        // Leo el id enviado en el DTO
        $model->set_ciudades_codigo($dto->getParameterValue('ciudades_codigo'));
        $model->set_ciudades_descripcion($dto->getParameterValue('ciudades_descripcion'));
        $model->set_paises_codigo($dto->getParameterValue('paises_codigo'));
        $model->set_ciudades_altura($dto->getParameterValue('ciudades_altura'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->set_Usuario_mod($dto->getSessionUser());
        return $model;
    }

    /**
     *
     * @return CiudadesModel
     */
    protected function &getEmptyModel() {
        $model = new CiudadesModel();
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel
     */
    protected function &getModelToDelete(\TSLIDataTransferObj $dto) {
        $model = new CiudadesModel();
        $model->set_ciudades_codigo($dto->getParameterValue('ciudades_codigo'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        $model->set_Usuario_mod($dto->getSessionUser());

        return $model;
    }

}

?>
