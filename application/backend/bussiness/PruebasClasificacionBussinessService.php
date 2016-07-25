<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que manipula las acciones directas a la clasificacion de las pruebas.
 *  tales como listar , agregar , eliminar , etc.
 *
 * @author $Author: aranape $
 * @since 17-May-2013
 * @version $Id: PruebasClasificacionBussinessService.php 73 2014-03-09 10:23:39Z aranape $
 * @history 1.01 , Se agrego soporte para foreign key
 *
 * $Date: 2014-03-09 05:23:39 -0500 (dom, 09 mar 2014) $
 * $Rev: 73 $
 */
class PruebasClasificacionBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

    function __construct() {
        //    parent::__construct();
        $this->setup("PruebasClasificacionDAO", "pruebasclasificacion", "msg_pruebasclasificacion");
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return PruebasClasificacionModel
     */
    protected function &getModelToAdd(\TSLIDataTransferObj $dto) {
        $model = new PruebasClasificacionModel();
        // Leo el id enviado en el DTO
        $model->set_pruebas_clasificacion_codigo($dto->getParameterValue('pruebas_clasificacion_codigo'));
        $model->set_pruebas_clasificacion_descripcion($dto->getParameterValue('pruebas_clasificacion_descripcion'));
        $model->set_pruebas_tipo_codigo($dto->getParameterValue('pruebas_tipo_codigo'));
        $model->set_unidad_medida_codigo($dto->getParameterValue('unidad_medida_codigo'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->setUsuario($dto->getSessionUser());

        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return PruebasClasificacionModel
     */
    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) {
        $model = new PruebasClasificacionModel();
        // Leo el id enviado en el DTO
        $model->set_pruebas_clasificacion_codigo($dto->getParameterValue('pruebas_clasificacion_codigo'));
        $model->set_pruebas_clasificacion_descripcion($dto->getParameterValue('pruebas_clasificacion_descripcion'));
        $model->set_pruebas_tipo_codigo($dto->getParameterValue('pruebas_tipo_codigo'));
        $model->set_unidad_medida_codigo($dto->getParameterValue('unidad_medida_codigo'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->set_Usuario_mod($dto->getSessionUser());
        return $model;
    }

    /**
     *
     * @return PruebasClasificacionModel
     */
    protected function &getEmptyModel() {
        $model = new PruebasClasificacionModel();
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel
     */
    protected function &getModelToDelete(\TSLIDataTransferObj $dto) {
        $model = new PruebasClasificacionModel();
        $model->set_pruebas_clasificacion_codigo($dto->getParameterValue('pruebas_clasificacion_codigo'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        $model->set_Usuario_mod($dto->getSessionUser());

        return $model;
    }

}

?>
