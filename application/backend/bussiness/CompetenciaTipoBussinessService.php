<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que manipula las acciones directas de los tipos de competencia
 *  tales como listar , agregar , eliminar , etc.
 *
 * @author $Author: aranape $
 * @since 17-May-2013
 * @version $Id: CompetenciaTipoBussinessService.php 70 2014-03-09 10:20:51Z aranape $
 * @history 1.01 , Se agrego soporte para foreign key
 *
 * $Date: 2014-03-09 05:20:51 -0500 (dom, 09 mar 2014) $
 * $Rev: 70 $
 */
class CompetenciaTipoBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

    function __construct() {
        //    parent::__construct();
        $this->setup("CompetenciaTipoDAO", "competencia_tipo", "msg_competencia_tipo");
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return CompetenciaTipoModel
     */
    protected function &getModelToAdd(\TSLIDataTransferObj $dto) {
        $model = new CompetenciaTipoModel();
        // Leo el id enviado en el DTO
        $model->set_competencia_tipo_codigo($dto->getParameterValue('competencia_tipo_codigo'));
        $model->set_competencia_tipo_descripcion($dto->getParameterValue('competencia_tipo_descripcion'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->setUsuario($dto->getSessionUser());

        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return CompetenciaTipoModel
     */
    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) {
        $model = new CompetenciaTipoModel();
        // Leo el id enviado en el DTO
        $model->set_competencia_tipo_codigo($dto->getParameterValue('competencia_tipo_codigo'));
        $model->set_competencia_tipo_descripcion($dto->getParameterValue('competencia_tipo_descripcion'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->set_Usuario_mod($dto->getSessionUser());
        return $model;
    }

    /**
     *
     * @return CompetenciaTipoModel
     */
    protected function &getEmptyModel() {
        $model = new CompetenciaTipoModel();
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel
     */
    protected function &getModelToDelete(\TSLIDataTransferObj $dto) {
        $model = new CompetenciaTipoModel();
        $model->set_competencia_tipo_codigo($dto->getParameterValue('competencia_tipo_codigo'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        $model->set_Usuario_mod($dto->getSessionUser());

        return $model;
    }

}

?>
