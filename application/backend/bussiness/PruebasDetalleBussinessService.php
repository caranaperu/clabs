<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que manipula las acciones directas sobre las pruebas que conforman una
 * principal , tal como el caso de las pruebas del heptatlon.
 *
 * @author $Author: aranape $
 * @since 17-May-2013
 * @version $Id: PruebasDetalleBussinessService.php 74 2014-03-09 10:24:37Z aranape $
 * @history 1.01 , Se agrego soporte para foreign key
 *
 * $Date: 2014-03-09 05:24:37 -0500 (dom, 09 mar 2014) $
 * $Rev: 74 $
 */
class PruebasDetalleBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

    function __construct() {
        //    parent::__construct();
        $this->setup("PruebasDetalleDAO", "pruebasdetalle", "msg_pruebasdetalle");
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return PruebasDetalleModel
     */
    protected function &getModelToAdd(\TSLIDataTransferObj $dto) {
        $model = new PruebasDetalleModel();
        // Leo el id enviado en el DTO
        $model->set_pruebas_codigo($dto->getParameterValue('pruebas_codigo'));
        $model->set_pruebas_detalle_prueba_codigo($dto->getParameterValue('pruebas_detalle_prueba_codigo'));
        $model->set_pruebas_detalle_orden($dto->getParameterValue('pruebas_detalle_orden'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->setUsuario($dto->getSessionUser());

        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return PruebasDetalleModel
     */
    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) {
        $model = new PruebasDetalleModel();
        // Leo el id enviado en el DTO
        $model->set_pruebas_detalle_id($dto->getParameterValue('pruebas_detalle_id'));
        $model->set_pruebas_codigo($dto->getParameterValue('pruebas_codigo'));
        $model->set_pruebas_detalle_prueba_codigo($dto->getParameterValue('pruebas_detalle_prueba_codigo'));
        $model->set_pruebas_detalle_orden($dto->getParameterValue('pruebas_detalle_orden'));

        $model->setVersionId($dto->getParameterValue('versionId'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->set_Usuario_mod($dto->getSessionUser());
        return $model;
    }

    /**
     *
     * @return PruebasDetalleModel
     */
    protected function &getEmptyModel() {
        $model = new PruebasDetalleModel();
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel
     */
    protected function &getModelToDelete(\TSLIDataTransferObj $dto) {
        $model = new PruebasDetalleModel();
        $model->set_pruebas_detalle_id($dto->getParameterValue('pruebas_detalle_id'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        $model->set_Usuario_mod($dto->getSessionUser());

        return $model;
    }

}

?>
