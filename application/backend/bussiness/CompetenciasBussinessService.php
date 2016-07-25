<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que manipula las acciones directas de las competencas
 *  tales como listar , agregar , eliminar , etc.
 *
 * @author $Author: aranape $
 * @since 17-May-2013
 * @version $Id: CompetenciasBussinessService.php 298 2014-06-30 23:59:00Z aranape $
 * @history 1.01 , Se agrego soporte para foreign key
 *
 * $Date: 2014-06-30 18:59:00 -0500 (lun, 30 jun 2014) $
 * $Rev: 298 $
 */
class CompetenciasBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

    function __construct() {
        //    parent::__construct();
        $this->setup("CompetenciasDAO", "competencias", "msg_competencias");
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return CompetenciasModel
     */
    protected function &getModelToAdd(\TSLIDataTransferObj $dto) {
        $model = new CompetenciasModel();
        // Leo el id enviado en el DTO
        $model->set_competencias_codigo($dto->getParameterValue('competencias_codigo'));
        $model->set_competencias_descripcion($dto->getParameterValue('competencias_descripcion'));
        $model->set_competencia_tipo_codigo($dto->getParameterValue('competencia_tipo_codigo'));
        $model->set_categorias_codigo($dto->getParameterValue('categorias_codigo'));
        $model->set_paises_codigo($dto->getParameterValue('paises_codigo'));
        $model->set_ciudades_codigo($dto->getParameterValue('ciudades_codigo'));
        $model->set_competencias_fecha_inicio($dto->getParameterValue('competencias_fecha_inicio'));
        $model->set_competencias_fecha_final($dto->getParameterValue('competencias_fecha_final'));
        $model->set_competencias_clasificacion($dto->getParameterValue('competencias_clasificacion'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->setUsuario($dto->getSessionUser());

        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return CompetenciasModel
     */
    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) {
        $model = new CompetenciasModel();
        // Leo el id enviado en el DTO
        $model->set_competencias_codigo($dto->getParameterValue('competencias_codigo'));
        $model->set_competencias_descripcion($dto->getParameterValue('competencias_descripcion'));
        $model->set_competencia_tipo_codigo($dto->getParameterValue('competencia_tipo_codigo'));
        $model->set_categorias_codigo($dto->getParameterValue('categorias_codigo'));
        $model->set_paises_codigo($dto->getParameterValue('paises_codigo'));
        $model->set_ciudades_codigo($dto->getParameterValue('ciudades_codigo'));
        $model->set_competencias_fecha_inicio($dto->getParameterValue('competencias_fecha_inicio'));
        $model->set_competencias_fecha_final($dto->getParameterValue('competencias_fecha_final'));
        $model->set_competencias_clasificacion($dto->getParameterValue('competencias_clasificacion'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->set_Usuario_mod($dto->getSessionUser());
        return $model;
    }

    /**
     *
     * @return CompetenciasModel
     */
    protected function &getEmptyModel() {
        $model = new CompetenciasModel();
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel
     */
    protected function &getModelToDelete(\TSLIDataTransferObj $dto) {
        $model = new CompetenciasModel();
        $model->set_competencias_codigo($dto->getParameterValue('competencias_codigo'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        $model->set_Usuario_mod($dto->getSessionUser());

        return $model;
    }

}

?>
