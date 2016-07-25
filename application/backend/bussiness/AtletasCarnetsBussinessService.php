<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que manipula la carnetizacion de los atletas.
 *
 * @author $Author: aranape $
 * @since 17-May-2013
 * @version $Id: AtletasCarnetsBussinessService.php 85 2014-03-25 10:12:35Z aranape $
 * @history 1.01 , Se agrego soporte para foreign key
 *
 * $Date: 2014-03-25 05:12:35 -0500 (mar, 25 mar 2014) $
 * $Rev: 85 $
 */
class AtletasCarnetsBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

    function __construct() {
        //    parent::__construct();
        $this->setup("AtletasCarnetsDAO", "atletascarnets", "msg_atletascarnets");
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return AtletasCarnetsModel
     */
    protected function &getModelToAdd(\TSLIDataTransferObj $dto) {
        $model = new AtletasCarnetsModel();
        // Leo el id enviado en el DTO
        $model->set_atletas_carnets_agno($dto->getParameterValue('atletas_carnets_agno'));
        $model->set_atletas_carnets_numero($dto->getParameterValue('atletas_carnets_numero'));
        $model->set_atletas_carnets_fecha($dto->getParameterValue('atletas_carnets_fecha'));
        $model->set_atletas_codigo($dto->getParameterValue('atletas_codigo'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->setUsuario($dto->getSessionUser());

        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return AtletasCarnetsModel
     */
    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) {
        $model = new AtletasCarnetsModel();
        // Leo el id enviado en el DTO
        $model->set_atletas_carnets_id($dto->getParameterValue('atletas_carnets_id'));
        $model->set_atletas_carnets_agno($dto->getParameterValue('atletas_carnets_agno'));
        $model->set_atletas_carnets_numero($dto->getParameterValue('atletas_carnets_numero'));
        $model->set_atletas_carnets_fecha($dto->getParameterValue('atletas_carnets_fecha'));
        $model->set_atletas_codigo($dto->getParameterValue('atletas_codigo'));

        $model->setVersionId($dto->getParameterValue('versionId'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->set_Usuario_mod($dto->getSessionUser());
        return $model;
    }

    /**
     *
     * @return AtletasCarnetsModel
     */
    protected function &getEmptyModel() {
        $model = new AtletasCarnetsModel();
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel
     */
    protected function &getModelToDelete(\TSLIDataTransferObj $dto) {
        $model = new AtletasCarnetsModel();
        $model->set_atletas_carnets_id($dto->getParameterValue('atletas_carnets_id'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        $model->set_Usuario_mod($dto->getSessionUser());

        return $model;
    }

}

?>
