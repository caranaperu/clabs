<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que manipula las acciones directas a las unidades de medidas
 *  tales como listar , agregar , eliminar , etc.
 *
 * @author $Author: aranape $
 * @since 17-May-2013
 * @version $Id: PruebasBussinessService.php 88 2014-03-25 15:14:07Z aranape $
 * @history 1.01 , Se agrego soporte para foreign key
 *
 * $Date: 2014-03-25 10:14:07 -0500 (mar, 25 mar 2014) $
 * $Rev: 88 $
 */
class PruebasBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

    function __construct() {
        //    parent::__construct();
        $this->setup("PruebasDAO", "pruebas", "msg_pruebas");
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return PruebasModel
     */
    protected function &getModelToAdd(\TSLIDataTransferObj $dto) {
        $model = new PruebasModel();
        // Leo el id enviado en el DTO
        $model->set_pruebas_codigo($dto->getParameterValue('pruebas_codigo'));
        $model->set_pruebas_descripcion($dto->getParameterValue('pruebas_descripcion'));
        $model->set_pruebas_generica_codigo($dto->getParameterValue('pruebas_generica_codigo'));
        $model->set_categorias_codigo($dto->getParameterValue('categorias_codigo'));
        $model->set_pruebas_sexo($dto->getParameterValue('pruebas_sexo'));
        $model->set_pruebas_record_hasta($dto->getParameterValue('pruebas_record_hasta'));
        $model->set_pruebas_anotaciones($dto->getParameterValue('pruebas_anotaciones'));

        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->setUsuario($dto->getSessionUser());

        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return PruebasModel
     */
    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) {
        $model = new PruebasModel();
        // Leo el id enviado en el DTO
        $model->set_pruebas_codigo($dto->getParameterValue('pruebas_codigo'));
        $model->set_pruebas_descripcion($dto->getParameterValue('pruebas_descripcion'));
        $model->set_pruebas_generica_codigo($dto->getParameterValue('pruebas_generica_codigo'));
        $model->set_categorias_codigo($dto->getParameterValue('categorias_codigo'));
        $model->set_pruebas_sexo($dto->getParameterValue('pruebas_sexo'));
        $model->set_pruebas_record_hasta($dto->getParameterValue('pruebas_record_hasta'));
        $model->set_pruebas_anotaciones($dto->getParameterValue('pruebas_anotaciones'));

        $model->setVersionId($dto->getParameterValue('versionId'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->set_Usuario_mod($dto->getSessionUser());
        return $model;
    }

    /**
     *
     * @return PruebasModel
     */
    protected function &getEmptyModel() {
        $model = new PruebasModel();
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel
     */
    protected function &getModelToDelete(\TSLIDataTransferObj $dto) {
        $model = new PruebasModel();
        $model->set_pruebas_codigo($dto->getParameterValue('pruebas_codigo'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        $model->set_Usuario_mod($dto->getSessionUser());

        return $model;
    }

}

?>
