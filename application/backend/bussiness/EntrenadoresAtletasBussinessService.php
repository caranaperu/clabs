<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que manipula las acciones directas de los atletas y su
 * relacion con sus entrenadores.
 *
 * @author $Author: aranape $
 * @since 17-May-2013
 * @version $Id: EntrenadoresAtletasBussinessService.php 7 2014-02-11 23:55:54Z aranape $
 * @history 1.01 , Se agrego soporte para foreign key
 *
 * $Date: 2014-02-11 18:55:54 -0500 (mar, 11 feb 2014) $
 * $Rev: 7 $
 */
class EntrenadoresAtletasBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

    function __construct() {
        //    parent::__construct();
        $this->setup("EntrenadoresAtletasDAO", "entrenadoresatletas", "msg_entrenadoresatletas");
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return EntrenadoresAtletasModel
     */
    protected function &getModelToAdd(\TSLIDataTransferObj $dto) {
        $model = new EntrenadoresAtletasModel();
        // Leo el id enviado en el DTO
        $model->set_entrenadores_codigo($dto->getParameterValue('entrenadores_codigo'));
        $model->set_atletas_codigo($dto->getParameterValue('atletas_codigo'));
        $model->set_entrenadoresatletas_desde($dto->getParameterValue('entrenadoresatletas_desde'));
        $model->set_entrenadoresatletas_hasta($dto->getParameterValue('entrenadoresatletas_hasta'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->setUsuario($dto->getSessionUser());

        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return EntrenadoresAtletasModel
     */
    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) {
        $model = new EntrenadoresAtletasModel();
        // Leo el id enviado en el DTO
        $model->set_entrenadoresatletas_id($dto->getParameterValue('entrenadoresatletas_id'));
        $model->set_entrenadores_codigo($dto->getParameterValue('entrenadores_codigo'));
        $model->set_atletas_codigo($dto->getParameterValue('atletas_codigo'));
        $model->set_entrenadoresatletas_desde($dto->getParameterValue('entrenadoresatletas_desde'));
        $model->set_entrenadoresatletas_hasta($dto->getParameterValue('entrenadoresatletas_hasta'));

        $model->setVersionId($dto->getParameterValue('versionId'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->set_Usuario_mod($dto->getSessionUser());
        return $model;
    }

    /**
     *
     * @return EntrenadoresAtletasModel
     */
    protected function &getEmptyModel() {
        $model = new EntrenadoresAtletasModel();
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel
     */
    protected function &getModelToDelete(\TSLIDataTransferObj $dto) {
        $model = new EntrenadoresAtletasModel();
        $model->set_entrenadoresatletas_id($dto->getParameterValue('entrenadoresatletas_id'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        $model->set_Usuario_mod($dto->getSessionUser());

        return $model;
    }

}

?>
