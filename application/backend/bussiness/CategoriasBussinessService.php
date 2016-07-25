<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que manipula las acciones directas a las categorias
 * atleticas tales como menores,juveniles,mayores.
 *
 * @author $Author: aranape $
 * @since 17-May-2013
 * @version $Id: CategoriasBussinessService.php 56 2014-03-09 10:09:53Z aranape $
 * @history 1.01 , Se agrego soporte para foreign key
 *
 * $Date: 2014-03-09 05:09:53 -0500 (dom, 09 mar 2014) $
 * $Rev: 56 $
 */
class CategoriasBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

    function __construct() {
        //    parent::__construct();
        $this->setup("CategoriasDAO", "categorias", "msg_categorias");
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return CategoriasModel
     */
    protected function &getModelToAdd(\TSLIDataTransferObj $dto) {
        $model = new CategoriasModel();
        // Leo el id enviado en el DTO
        $model->set_categorias_codigo($dto->getParameterValue('categorias_codigo'));
        $model->set_categorias_descripcion($dto->getParameterValue('categorias_descripcion'));
        $model->set_categorias_edad_inicial($dto->getParameterValue('categorias_edad_inicial'));
        $model->set_categorias_edad_final($dto->getParameterValue('categorias_edad_final'));
        $model->set_categorias_valido_desde($dto->getParameterValue('categorias_valido_desde'));
        $model->set_categorias_validacion($dto->getParameterValue('categorias_validacion'));

        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->setUsuario($dto->getSessionUser());

        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return CategoriasModel
     */
    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) {
        $model = new CategoriasModel();
        // Leo el id enviado en el DTO
        $model->set_categorias_codigo($dto->getParameterValue('categorias_codigo'));
        $model->set_categorias_descripcion($dto->getParameterValue('categorias_descripcion'));
        $model->set_categorias_edad_inicial($dto->getParameterValue('categorias_edad_inicial'));
        $model->set_categorias_edad_final($dto->getParameterValue('categorias_edad_final'));
        $model->set_categorias_valido_desde($dto->getParameterValue('categorias_valido_desde'));
        $model->set_categorias_validacion($dto->getParameterValue('categorias_validacion'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->set_Usuario_mod($dto->getSessionUser());
        return $model;
    }

    /**
     *
     * @return CategoriasModel
     */
    protected function &getEmptyModel() {
        $model = new CategoriasModel();
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel
     */
    protected function &getModelToDelete(\TSLIDataTransferObj $dto) {
        $model = new CategoriasModel();
        $model->set_categorias_codigo($dto->getParameterValue('categorias_codigo'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        $model->set_Usuario_mod($dto->getSessionUser());

        return $model;
    }

}

?>
