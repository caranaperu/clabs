<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que manipula las acciones directas los niveles de los entrenadores
 *  tales como listar , agregar , eliminar , etc.
 *
 * @author $Author: aranape $
 * @since 17-May-2013
 * @version $Id: EntrenadoresNivelBussinessService.php 7 2014-02-11 23:55:54Z aranape $
 * @history 1.01 , Se agrego soporte para foreign key
 *
 * $Date: 2014-02-11 18:55:54 -0500 (mar, 11 feb 2014) $
 * $Rev: 7 $
 */
class EntrenadoresNivelBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

    function __construct() {
        //    parent::__construct();
        $this->setup("EntrenadoresNivelDAO", "entrenadores_nivel", "msg_entrenadores_nivel");
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return EntrenadoresNivelModel
     */
    protected function &getModelToAdd(\TSLIDataTransferObj $dto) {
        $model = new EntrenadoresNivelModel();
        // Leo el id enviado en el DTO
        $model->set_entrenadores_nivel_codigo($dto->getParameterValue('entrenadores_nivel_codigo'));
        $model->set_entrenadores_nivel_descripcion($dto->getParameterValue('entrenadores_nivel_descripcion'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->setUsuario($dto->getSessionUser());

        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return EntrenadoresNivelModel
     */
    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) {
        $model = new EntrenadoresNivelModel();
        // Leo el id enviado en el DTO
        $model->set_entrenadores_nivel_codigo($dto->getParameterValue('entrenadores_nivel_codigo'));
        $model->set_entrenadores_nivel_descripcion($dto->getParameterValue('entrenadores_nivel_descripcion'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->set_Usuario_mod($dto->getSessionUser());
        return $model;
    }

    /**
     *
     * @return EntrenadoresNivelModel
     */
    protected function &getEmptyModel() {
        $model = new EntrenadoresNivelModel();
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel
     */
    protected function &getModelToDelete(\TSLIDataTransferObj $dto) {
        $model = new EntrenadoresNivelModel();
        $model->set_entrenadores_nivel_codigo($dto->getParameterValue('entrenadores_nivel_codigo'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        $model->set_Usuario_mod($dto->getSessionUser());

        return $model;
    }

}

?>
