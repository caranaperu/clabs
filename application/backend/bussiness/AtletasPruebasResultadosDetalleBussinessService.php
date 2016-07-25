<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que manipula las acciones directas a los resultados de
 * los atletas inputados en forma directa , por lo que a su vez require que se grabe la
 * prueba de ser necesario. En este caso es solo para las pruebas que componen una prueba combinada
 * no para las pruebas normales.
 *
 * @author $Author: aranape $
 * @since 17-May-2013
 * @version $Id: AtletasPruebasResultadosDetalleBussinessService.php 221 2014-06-23 23:00:56Z aranape $
 * @history 1.01 , Se agrego soporte para foreign key
 *
 * $Date: 2014-06-23 18:00:56 -0500 (lun, 23 jun 2014) $
 * $Rev: 221 $
 */
class AtletasPruebasResultadosDetalleBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

    function __construct() {
        //    parent::__construct();
        $this->setup("AtletasPruebasResultadosDetalleDAO", "atletaspruebas_resultados_detalle", "msg_atletaspruebas_resultados_detalle");
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return AtletasPruebasResultadosDetalleModel
     */
    protected function &getModelToAdd(\TSLIDataTransferObj $dto) {
        $model = new AtletasPruebasResultadosDetalleModel();
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return AtletasPruebasResultadosDetalleModel
     */
    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) {
        $model = new AtletasPruebasResultadosDetalleModel();
        // Leo el id enviado en el DTO
        $model->set_competencias_pruebas_id($dto->getParameterValue('competencias_pruebas_id'));
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
     * @return AtletasPruebasResultadosDetalleModel
     */
    protected function &getEmptyModel() {
        $model = new AtletasPruebasResultadosDetalleModel();
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel
     */
    protected function &getModelToDelete(\TSLIDataTransferObj $dto) {
        $model = new AtletasPruebasResultadosDetalleModel();
        $model->set_atletas_resultados_id($dto->getParameterValue('atletas_resultados_id'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        $model->set_Usuario_mod($dto->getSessionUser());

        return $model;
    }

}

?>
