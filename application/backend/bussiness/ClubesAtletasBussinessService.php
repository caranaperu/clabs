<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que manipula las acciones directas de los atletas y su
 * relacion con sus clubes.
 *
 * @author $Author: aranape $
 * @since 17-May-2013
 * @version $Id: ClubesAtletasBussinessService.php 32 2014-02-15 10:01:11Z aranape $
 * @history 1.01 , Se agrego soporte para foreign key
 *
 * $Date: 2014-02-15 05:01:11 -0500 (sáb, 15 feb 2014) $
 * $Rev: 32 $
 */
class ClubesAtletasBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

    function __construct() {
        //    parent::__construct();
        $this->setup("ClubesAtletasDAO", "clubesatletas", "msg_clubesatletas");
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return ClubesAtletasModel
     */
    protected function &getModelToAdd(\TSLIDataTransferObj $dto) {
        $model = new ClubesAtletasModel();
        // Leo el id enviado en el DTO
        $model->set_clubes_codigo($dto->getParameterValue('clubes_codigo'));
        $model->set_atletas_codigo($dto->getParameterValue('atletas_codigo'));
        $model->set_clubesatletas_desde($dto->getParameterValue('clubesatletas_desde'));
        $model->set_clubesatletas_hasta($dto->getParameterValue('clubesatletas_hasta'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->setUsuario($dto->getSessionUser());

        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return ClubesAtletasModel
     */
    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) {
        $model = new ClubesAtletasModel();
        // Leo el id enviado en el DTO
        $model->set_clubesatletas_id($dto->getParameterValue('clubesatletas_id'));
        $model->set_clubes_codigo($dto->getParameterValue('clubes_codigo'));
        $model->set_atletas_codigo($dto->getParameterValue('atletas_codigo'));
        $model->set_clubesatletas_desde($dto->getParameterValue('clubesatletas_desde'));
        $model->set_clubesatletas_hasta($dto->getParameterValue('clubesatletas_hasta'));

        $model->setVersionId($dto->getParameterValue('versionId'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->set_Usuario_mod($dto->getSessionUser());
        return $model;
    }

    /**
     *
     * @return ClubesAtletasModel
     */
    protected function &getEmptyModel() {
        $model = new ClubesAtletasModel();
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel
     */
    protected function &getModelToDelete(\TSLIDataTransferObj $dto) {
        $model = new ClubesAtletasModel();
        $model->set_clubesatletas_id($dto->getParameterValue('clubesatletas_id'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        $model->set_Usuario_mod($dto->getSessionUser());

        return $model;
    }

}

?>
