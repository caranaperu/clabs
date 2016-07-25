<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que manipula las acciones directas a los resultados de
 * los atletas inputados en forma directa , por lo que a su vez require que se grabe la
 * prueba de ser necesario.
 *
 * @author $Author: aranape $
 * @since 17-May-2013
 * @version $Id: CompetenciasPruebasBussinessService.php 217 2014-06-23 22:55:14Z aranape $
 * @history 1.01 , Se agrego soporte para foreign key
 *
 * $Date: 2014-06-23 17:55:14 -0500 (lun, 23 jun 2014) $
 * $Rev: 217 $
 */
class CompetenciasPruebasBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

    function __construct() {
        //    parent::__construct();
        $this->setup("CompetenciasPruebasDAO", "competencias_pruebas", "msg_competencias_pruebas");
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return CompetenciasPruebasModel
     */
    protected function &getModelToAdd(\TSLIDataTransferObj $dto) {
        $model = new CompetenciasPruebasModel();

        // Leo el id enviado en el DTO
        $model->set_competencias_codigo($dto->getParameterValue('competencias_codigo'));
        $model->set_pruebas_codigo($dto->getParameterValue('pruebas_codigo'));
        $model->set_competencias_pruebas_fecha($dto->getParameterValue('competencias_pruebas_fecha'));
        $model->set_competencias_pruebas_viento($dto->getParameterValue('competencias_pruebas_viento'));
        $model->set_competencias_pruebas_tipo_serie($dto->getParameterValue('competencias_pruebas_tipo_serie'));
        $model->set_competencias_pruebas_nro_serie($dto->getParameterValue('competencias_pruebas_nro_serie'));
        $model->set_competencias_pruebas_anemometro($dto->getParameterValue('competencias_pruebas_anemometro'));
        $model->set_competencias_pruebas_material_reglamentario($dto->getParameterValue('competencias_pruebas_material_reglamentario'));
        $model->set_competencias_pruebas_manual($dto->getParameterValue('competencias_pruebas_manual'));
        $model->set_competencias_pruebas_observaciones($dto->getParameterValue('competencias_pruebas_observaciones'));
        $model->set_competencias_pruebas_origen_id($dto->getParameterValue('competencias_pruebas_origen_id'));
        $model->set_competencias_pruebas_origen_combinada($dto->getParameterValue('competencias_pruebas_origen_combinada'));

        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->setUsuario($dto->getSessionUser());

        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return CompetenciasPruebasModel
     */
    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) {
        $model = new CompetenciasPruebasModel();
        // Leo el id enviado en el DTO
        $model->set_competencias_pruebas_id($dto->getParameterValue('competencias_pruebas_id'));
        $model->set_competencias_codigo($dto->getParameterValue('competencias_codigo'));
        $model->set_pruebas_codigo($dto->getParameterValue('pruebas_codigo'));
        $model->set_competencias_pruebas_fecha($dto->getParameterValue('competencias_pruebas_fecha'));
        $model->set_competencias_pruebas_viento($dto->getParameterValue('competencias_pruebas_viento'));
        $model->set_competencias_pruebas_tipo_serie($dto->getParameterValue('competencias_pruebas_tipo_serie'));
        $model->set_competencias_pruebas_nro_serie($dto->getParameterValue('competencias_pruebas_nro_serie'));
        $model->set_competencias_pruebas_anemometro($dto->getParameterValue('competencias_pruebas_anemometro'));
        $model->set_competencias_pruebas_material_reglamentario($dto->getParameterValue('competencias_pruebas_material_reglamentario'));
        $model->set_competencias_pruebas_manual($dto->getParameterValue('competencias_pruebas_manual'));
        $model->set_competencias_pruebas_observaciones($dto->getParameterValue('competencias_pruebas_observaciones'));
        $model->set_competencias_pruebas_origen_id($dto->getParameterValue('competencias_pruebas_origen_id'));
        $model->set_competencias_pruebas_origen_combinada($dto->getParameterValue('competencias_pruebas_origen_combinada'));

        $model->setVersionId($dto->getParameterValue('versionId'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->set_Usuario_mod($dto->getSessionUser());

        return $model;
    }

    /**
     *
     * @return CompetenciasPruebasModel
     */
    protected function &getEmptyModel() {
        $model = new CompetenciasPruebasModel();
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel
     */
    protected function &getModelToDelete(\TSLIDataTransferObj $dto) {
        $model = new CompetenciasPruebasModel();
        $model->set_competencias_pruebas_id($dto->getParameterValue('competencias_pruebas_id'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        $model->set_Usuario_mod($dto->getSessionUser());

        return $model;
    }

}

?>
