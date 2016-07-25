<?php

    if (!defined('BASEPATH'))
        exit('No direct script access allowed');

    /**
     * Objeto de Negocios que manipula las acciones directas a los detalle de  postas asociadas
     * a una determinada competencia-prueba-posta.
     *
     * @author    Carlos Arana Reategui <aranape@gmail.com>
     * @version   0.1
     * @package   SoftAthletics
     * @copyright 2015-2016 Carlos Arana Reategui.
     * @license   GPL
     *
     */
    class PostasDetalleBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

        function __construct() {
            //    parent::__construct();
            $this->setup("PostasDetalleDAO", "postas_detalle", "msg_postas_detalle");
        }

        /**
         *
         * @param \TSLIDataTransferObj $dto
         *
         * @return PostasDetalleModel
         */
        protected function &getModelToAdd(\TSLIDataTransferObj $dto) {
            $model = new PostasDetalleModel();
            // Leo el id enviado en el DTO
            $model->set_postas_id($dto->getParameterValue('postas_id'));
            $model->set_atletas_codigo($dto->getParameterValue('atletas_codigo'));
            if ($dto->getParameterValue('activo') != NULL)
                $model->setActivo($dto->getParameterValue('activo'));
            $model->setUsuario($dto->getSessionUser());

            return $model;
        }

        /**
         *
         * @param \TSLIDataTransferObj $dto
         *
         * @return PostasDetalleModel
         */
        protected function &getModelToUpdate(\TSLIDataTransferObj $dto) {
            $model = new PostasDetalleModel();
            // Leo el id enviado en el DTO
            $model->set_postas_detalle_id($dto->getParameterValue('postas_detalle_id'));
            $model->set_postas_id($dto->getParameterValue('postas_id'));
            $model->set_atletas_codigo($dto->getParameterValue('atletas_codigo'));

            $model->setVersionId($dto->getParameterValue('versionId'));
            if ($dto->getParameterValue('activo') != NULL)
                $model->setActivo($dto->getParameterValue('activo'));
            $model->set_Usuario_mod($dto->getSessionUser());

            return $model;
        }

        /**
         *
         * @return PostasDetalleModel
         */
        protected function &getEmptyModel() {
            $model = new PostasDetalleModel();

            return $model;
        }

        /**
         *
         * @param \TSLIDataTransferObj $dto
         *
         * @return \TSLDataModel
         */
        protected function &getModelToDelete(\TSLIDataTransferObj $dto) {
            $model = new PostasDetalleModel();
            $model->set_postas_detalle_id($dto->getParameterValue('postas_detalle_id'));
            $model->setVersionId($dto->getParameterValue('versionId'));
            $model->set_Usuario_mod($dto->getSessionUser());

            return $model;
        }

    }
