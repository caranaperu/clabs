<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que manipula las acciones directas a los entrenadores
 *  tales como listar , agregar , eliminar , etc.
 *
 * @author $Author: aranape $
 * @since 17-May-2013
 * @version $Id: EntrenadoresBussinessService.php 7 2014-02-11 23:55:54Z aranape $
 * @history 1.01 , Se agrego soporte para foreign key
 *
 * $Date: 2014-02-11 18:55:54 -0500 (mar, 11 feb 2014) $
 * $Rev: 7 $
 */
class EntrenadoresBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

    function __construct() {
        //    parent::__construct();
        $this->setup("EntrenadoresDAO", "entrenadores", "msg_entrenadores");
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return EntrenadoresModel
     */
    protected function &getModelToAdd(\TSLIDataTransferObj $dto) {
        $model = new EntrenadoresModel();
        // Leo el id enviado en el DTO
        $model->set_entrenadores_codigo($dto->getParameterValue('entrenadores_codigo'));
        $model->set_entrenadores_ap_paterno($dto->getParameterValue('entrenadores_ap_paterno'));
        $model->set_entrenadores_ap_materno($dto->getParameterValue('entrenadores_ap_materno'));
        $model->set_entrenadores_nombres($dto->getParameterValue('entrenadores_nombres'));
        $model->set_entrenadores_nivel_codigo($dto->getParameterValue('entrenadores_nivel_codigo'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->setUsuario($dto->getSessionUser());

        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return EntrenadoresModel
     */
    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) {
        $model = new EntrenadoresModel();
        // Leo el id enviado en el DTO
        $model->set_entrenadores_codigo($dto->getParameterValue('entrenadores_codigo'));
        $model->set_entrenadores_ap_paterno($dto->getParameterValue('entrenadores_ap_paterno'));
        $model->set_entrenadores_ap_materno($dto->getParameterValue('entrenadores_ap_materno'));
        $model->set_entrenadores_nombres($dto->getParameterValue('entrenadores_nombres'));
        $model->set_entrenadores_nivel_codigo($dto->getParameterValue('entrenadores_nivel_codigo'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->set_Usuario_mod($dto->getSessionUser());
        return $model;
    }

    /**
     *
     * @return EntrenadoresModel
     */
    protected function &getEmptyModel() {
        $model = new EntrenadoresModel();
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel
     */
    protected function &getModelToDelete(\TSLIDataTransferObj $dto) {
        $model = new EntrenadoresModel();
        $model->set_entrenadores_codigo($dto->getParameterValue('entrenadores_codigo'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        $model->set_Usuario_mod($dto->getSessionUser());

        return $model;
    }

}

?>
