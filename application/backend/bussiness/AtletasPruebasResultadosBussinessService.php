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
 * @version $Id: AtletasPruebasResultadosBussinessService.php 220 2014-06-23 23:00:30Z aranape $
 * @history 1.01 , Se agrego soporte para foreign key
 *
 * $Date: 2014-06-23 18:00:30 -0500 (lun, 23 jun 2014) $
 * $Rev: 220 $
 */
class AtletasPruebasResultadosBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

    function __construct() {
        //    parent::__construct();
        $this->setup("AtletasPruebasResultadosDAO", "atletaspruebas_resultados", "msg_atletaspruebas_resultados");
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return AtletasPruebasResultadosModel
     */
    protected function &getModelToAdd(\TSLIDataTransferObj $dto) {
        $model = new AtletasPruebasResultadosModel();

        // Leo el id enviado en el DTO
        $model->set_atletas_codigo($dto->getParameterValue('atletas_codigo'));
        $model->set_competencias_codigo($dto->getParameterValue('competencias_codigo'));
        $model->set_pruebas_codigo($dto->getParameterValue('pruebas_codigo'));
        $model->set_competencias_pruebas_origen_combinada($dto->getParameterValue('competencias_pruebas_origen_combinada'));
        $model->set_competencias_pruebas_fecha($dto->getParameterValue('competencias_pruebas_fecha'));
        $model->set_competencias_pruebas_viento($dto->getParameterValue('competencias_pruebas_viento'));
        $model->set_competencias_pruebas_tipo_serie($dto->getParameterValue('competencias_pruebas_tipo_serie'));
        $model->set_competencias_pruebas_nro_serie($dto->getParameterValue('competencias_pruebas_nro_serie'));
        $model->set_competencias_pruebas_anemometro($dto->getParameterValue('competencias_pruebas_anemometro'));
        $model->set_competencias_pruebas_material_reglamentario($dto->getParameterValue('competencias_pruebas_material_reglamentario'));
        $model->set_competencias_pruebas_manual($dto->getParameterValue('competencias_pruebas_manual'));
        $model->set_competencias_pruebas_observaciones($dto->getParameterValue('competencias_pruebas_observaciones'));
        $model->set_atletas_resultados_resultado($dto->getParameterValue('atletas_resultados_resultado'));
        $model->set_atletas_resultados_puntos($dto->getParameterValue('atletas_resultados_puntos'));
        $model->set_atletas_resultados_puesto($dto->getParameterValue('atletas_resultados_puesto'));

        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->setUsuario($dto->getSessionUser());

        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return AtletasPruebasResultadosModel
     */
    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) {
        $model = new AtletasPruebasResultadosModel();
        // Leo el id enviado en el DTO
        $model->set_atletas_resultados_id($dto->getParameterValue('atletas_resultados_id'));
        $model->set_atletas_codigo($dto->getParameterValue('atletas_codigo'));
        $model->set_competencias_codigo($dto->getParameterValue('competencias_codigo'));
        $model->set_pruebas_codigo($dto->getParameterValue('pruebas_codigo'));
        $model->set_competencias_pruebas_origen_combinada($dto->getParameterValue('competencias_pruebas_origen_combinada'));
        $model->set_competencias_pruebas_fecha($dto->getParameterValue('competencias_pruebas_fecha'));
        $model->set_competencias_pruebas_viento($dto->getParameterValue('competencias_pruebas_viento'));
        $model->set_competencias_pruebas_tipo_serie($dto->getParameterValue('competencias_pruebas_tipo_serie'));
        $model->set_competencias_pruebas_nro_serie($dto->getParameterValue('competencias_pruebas_nro_serie'));
        $model->set_competencias_pruebas_anemometro($dto->getParameterValue('competencias_pruebas_anemometro'));
        $model->set_competencias_pruebas_material_reglamentario($dto->getParameterValue('competencias_pruebas_material_reglamentario'));
        $model->set_competencias_pruebas_manual($dto->getParameterValue('competencias_pruebas_manual'));
        $model->set_competencias_pruebas_observaciones($dto->getParameterValue('competencias_pruebas_observaciones'));
        $model->set_atletas_resultados_resultado($dto->getParameterValue('atletas_resultados_resultado'));
        $model->set_atletas_resultados_puntos($dto->getParameterValue('atletas_resultados_puntos'));
        $model->set_atletas_resultados_puesto($dto->getParameterValue('atletas_resultados_puesto'));

        $model->setVersionId($dto->getParameterValue('versionId'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->set_Usuario_mod($dto->getSessionUser());
        return $model;
    }

    /**
     *
     * @return AtletasPruebasResultadosModel
     */
    protected function &getEmptyModel() {
        $model = new AtletasPruebasResultadosModel();
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel
     */
    protected function &getModelToDelete(\TSLIDataTransferObj $dto) {
        $model = new AtletasPruebasResultadosModel();
        $model->set_atletas_resultados_id($dto->getParameterValue('atletas_resultados_id'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        $model->set_Usuario_mod($dto->getSessionUser());

        return $model;
    }

}

?>
