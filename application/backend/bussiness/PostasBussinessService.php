<?php

    if (!defined('BASEPATH'))
        exit('No direct script access allowed');

    /**
     * Objeto de Negocios que manipula las acciones directas a las postas asociadas
     * a una determinada competencia-prueba.
     *
     * @author    Carlos Arana Reategui <aranape@gmail.com>
     * @version   0.1
     * @package   SoftAthletics
     * @copyright 2015-2016 Carlos Arana Reategui.
     * @license   GPL
     *
     */
    class PostasBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

        function __construct() {
            //    parent::__construct();
            $this->setup("PostasDAO", "postas", "msg_postas");
        }

        /**
         *
         * @param \TSLIDataTransferObj $dto
         *
         * @return PostasModel
         */
        protected function &getModelToAdd(\TSLIDataTransferObj $dto) {
            $model = new PostasModel();
            // Leo el id enviado en el DTO
            $model->set_postas_descripcion($dto->getParameterValue('postas_descripcion'));
            $model->set_competencias_pruebas_id($dto->getParameterValue('competencias_pruebas_id'));
            if ($dto->getParameterValue('activo') != NULL)
                $model->setActivo($dto->getParameterValue('activo'));
            $model->setUsuario($dto->getSessionUser());

            return $model;
        }

        /**
         *
         * @param \TSLIDataTransferObj $dto
         *
         * @return PostasModel
         */
        protected function &getModelToUpdate(\TSLIDataTransferObj $dto) {
            $model = new PostasModel();
            // Leo el id enviado en el DTO
            $model->set_postas_id($dto->getParameterValue('postas_id'));
            $model->set_postas_descripcion($dto->getParameterValue('postas_descripcion'));
            $model->set_competencias_pruebas_id($dto->getParameterValue('competencias_pruebas_id'));
            $model->setVersionId($dto->getParameterValue('versionId'));
            if ($dto->getParameterValue('activo') != NULL)
                $model->setActivo($dto->getParameterValue('activo'));
            $model->set_Usuario_mod($dto->getSessionUser());

            return $model;
        }

        /**
         *
         * @return PostasModel
         */
        protected function &getEmptyModel() {
            $model = new PostasModel();

            return $model;
        }

        /**
         *
         * @param \TSLIDataTransferObj $dto
         *
         * @return \TSLDataModel
         */
        protected function &getModelToDelete(\TSLIDataTransferObj $dto) {
            $model = new PostasModel();
            $model->set_postas_id($dto->getParameterValue('postas_id'));
            $model->setVersionId($dto->getParameterValue('versionId'));
            $model->set_Usuario_mod($dto->getSessionUser());

            return $model;
        }

    }
