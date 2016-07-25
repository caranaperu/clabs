<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que manipula las acciones directas a las genericas de pruebas
 *  tales como listar , agregar , eliminar , etc.
 *
 * @author $Author: aranape $
 * @since 17-May-2013
 * @version $Id: AppPruebasBussinessService.php 186 2014-06-04 07:50:12Z aranape $
 * @history 1.01 , Se agrego soporte para foreign key
 *
 * $Date: 2014-06-04 02:50:12 -0500 (mié, 04 jun 2014) $
 * $Rev: 186 $
 */
class AppPruebasBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

    function __construct() {
        //    parent::__construct();
        $this->setup("AppPruebasDAO", "apppruebas", "msg_apppruebas");
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return AppPruebasModel
     */
    protected function &getModelToAdd(\TSLIDataTransferObj $dto) {
        $model = new AppPruebasModel();

        $model->set_apppruebas_codigo($dto->getParameterValue('apppruebas_codigo'));
        $model->set_apppruebas_descripcion($dto->getParameterValue('apppruebas_descripcion'));
        $model->set_pruebas_clasificacion_codigo($dto->getParameterValue('pruebas_clasificacion_codigo'));
        $model->set_apppruebas_multiple($dto->getParameterValue('apppruebas_multiple'));
        $model->set_apppruebas_marca_menor($dto->getParameterValue('apppruebas_marca_menor'));
        $model->set_apppruebas_marca_mayor($dto->getParameterValue('apppruebas_marca_mayor'));
        $model->set_apppruebas_verifica_viento($dto->getParameterValue('apppruebas_verifica_viento'));
        $model->set_apppruebas_viento_individual($dto->getParameterValue('apppruebas_viento_individual'));
        $model->set_apppruebas_viento_limite_normal($dto->getParameterValue('apppruebas_viento_limite_normal'));
        $model->set_apppruebas_viento_limite_multiple($dto->getParameterValue('apppruebas_viento_limite_multiple'));
        $model->set_apppruebas_nro_atletas($dto->getParameterValue('apppruebas_nro_atletas'));
        $model->set_apppruebas_factor_manual($dto->getParameterValue('apppruebas_factor_manual'));

        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->setUsuario($dto->getSessionUser());

        return $model;
    }

    /**
     * NO USADA
     * @param \TSLIDataTransferObj $dto
     * @return AppPruebasModel
     */
    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) {
        $model = new AppPruebasModel();

        $model->set_apppruebas_codigo($dto->getParameterValue('apppruebas_codigo'));
        $model->set_apppruebas_descripcion($dto->getParameterValue('apppruebas_descripcion'));
        $model->set_pruebas_clasificacion_codigo($dto->getParameterValue('pruebas_clasificacion_codigo'));
        $model->set_apppruebas_multiple($dto->getParameterValue('apppruebas_multiple'));
        $model->set_apppruebas_marca_menor($dto->getParameterValue('apppruebas_marca_menor'));
        $model->set_apppruebas_marca_mayor($dto->getParameterValue('apppruebas_marca_mayor'));
        $model->set_apppruebas_verifica_viento($dto->getParameterValue('apppruebas_verifica_viento'));
        $model->set_apppruebas_viento_individual($dto->getParameterValue('apppruebas_viento_individual'));
        $model->set_apppruebas_viento_limite_normal($dto->getParameterValue('apppruebas_viento_limite_normal'));
        $model->set_apppruebas_viento_limite_multiple($dto->getParameterValue('apppruebas_viento_limite_multiple'));
        $model->set_apppruebas_nro_atletas($dto->getParameterValue('apppruebas_nro_atletas'));
        $model->set_apppruebas_factor_manual($dto->getParameterValue('apppruebas_factor_manual'));

        $model->setVersionId($dto->getParameterValue('versionId'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->set_Usuario_mod($dto->getSessionUser());

        return $model;
    }

    /**
     *
     * @return AppPruebasModel
     */
    protected function &getEmptyModel() {
        $model = new AppPruebasModel();
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel
     */
    protected function &getModelToDelete(\TSLIDataTransferObj $dto) {
        $model = new AppPruebasModel();

        $model->set_apppruebas_codigo($dto->getParameterValue('apppruebas_codigo'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        $model->set_Usuario_mod($dto->getSessionUser());

        return $model;
    }

}

?>
