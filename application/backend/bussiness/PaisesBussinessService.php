<?php

    if (!defined('BASEPATH'))
        exit('No direct script access allowed');

    /**
     * Objeto de Negocios que manipula las acciones directas a los paises
     *  tales como listar , agregar , eliminar , etc.
     *
     * @author  $Author: aranape $
     * @since   17-May-2013
     * @version $Id: PaisesBussinessService.php 279 2014-06-30 02:14:51Z aranape $
     * @history 1.01 , Se agrego soporte para foreign key
     *
     * $Date: 2014-06-29 21:14:51 -0500 (dom, 29 jun 2014) $
     * $Rev: 279 $
     */
    class PaisesBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

        function __construct() {
            //    parent::__construct();
            $this->setup("PaisesDAO", "paises", "msg_paises");
        }

        /**
         *
         * @param \TSLIDataTransferObj $dto
         *
         * @return PaisesModel
         */
        protected function &getModelToAdd(\TSLIDataTransferObj $dto) {
            $model = new PaisesModel();
            // Leo el id enviado en el DTO
            $model->set_paises_codigo($dto->getParameterValue('paises_codigo'));
            $model->set_paises_descripcion($dto->getParameterValue('paises_descripcion'));
            $model->set_paises_entidad($dto->getParameterValue('paises_entidad'));
            $model->set_regiones_codigo($dto->getParameterValue('regiones_codigo'));
            $model->set_paises_use_apm($dto->getParameterValue('paises_use_apm'));
            $model->set_paises_use_docid($dto->getParameterValue('paises_use_docid'));
            if ($dto->getParameterValue('activo') != NULL)
                $model->setActivo($dto->getParameterValue('activo'));
            $model->setUsuario($dto->getSessionUser());

            return $model;
        }

        /**
         *
         * @param \TSLIDataTransferObj $dto
         *
         * @return PaisesModel
         */
        protected function &getModelToUpdate(\TSLIDataTransferObj $dto) {
            $model = new PaisesModel();
            // Leo el id enviado en el DTO
            $model->set_paises_codigo($dto->getParameterValue('paises_codigo'));
            $model->set_paises_descripcion($dto->getParameterValue('paises_descripcion'));
            $model->set_paises_entidad($dto->getParameterValue('paises_entidad'));
            $model->set_regiones_codigo($dto->getParameterValue('regiones_codigo'));
            $model->set_paises_use_apm($dto->getParameterValue('paises_use_apm'));
            $model->set_paises_use_docid($dto->getParameterValue('paises_use_docid'));
            $model->setVersionId($dto->getParameterValue('versionId'));
            if ($dto->getParameterValue('activo') != NULL)
                $model->setActivo($dto->getParameterValue('activo'));
            $model->set_Usuario_mod($dto->getSessionUser());

            return $model;
        }

        /**
         *
         * @return PaisesModel
         */
        protected function &getEmptyModel() {
            $model = new PaisesModel();

            return $model;
        }

        /**
         *
         * @param \TSLIDataTransferObj $dto
         *
         * @return \TSLDataModel
         */
        protected function &getModelToDelete(\TSLIDataTransferObj $dto) {
            $model = new PaisesModel();
            $model->set_paises_codigo($dto->getParameterValue('paises_codigo'));
            $model->setVersionId($dto->getParameterValue('versionId'));
            $model->set_Usuario_mod($dto->getSessionUser());

            return $model;
        }

    }

?>
