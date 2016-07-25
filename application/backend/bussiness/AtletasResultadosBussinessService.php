<?php

    if (!defined('BASEPATH'))
        exit('No direct script access allowed');

    /**
     * Objeto de Negocios que manipula las acciones directas a los resultados de
     * los atletas inputados en forma directa o por consolidacion de resultados de una
     * competencia..
     *
     * @author  $Author: aranape $
     * @since   17-May-2013
     * @version $Id: AtletasResultadosBussinessService.php 219 2014-06-23 22:59:39Z aranape $
     * @history 1.01 , Se agrego soporte para foreign key
     *
     * $Date: 2014-06-23 17:59:39 -0500 (lun, 23 jun 2014) $
     * $Rev: 219 $
     */
    class AtletasResultadosBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

        function __construct() {
            //    parent::__construct();
            $this->setup("AtletasResultadosDAO", "atletasresultados", "msg_atletasresultados");
        }

        /**
         *
         * @param \TSLIDataTransferObj $dto
         *
         * @return AtletasResultadosModel
         */
        protected function &getModelToAdd(\TSLIDataTransferObj $dto) {
            $model = new AtletasResultadosModel();
            // Leo el id enviado en el DTO
            $model->set_atletas_codigo($dto->getParameterValue('atletas_codigo'));
            $model->set_competencias_pruebas_id($dto->getParameterValue('competencias_pruebas_id'));
            $model->set_postas_id($dto->getParameterValue('postas_id'));
            $model->set_atletas_resultados_resultado($dto->getParameterValue('atletas_resultados_resultado'));
            $model->set_atletas_resultados_puesto($dto->getParameterValue('atletas_resultados_puesto'));
            $model->set_atletas_resultados_puntos($dto->getParameterValue('atletas_resultados_puntos'));
            $model->set_atletas_resultados_viento($dto->getParameterValue('atletas_resultados_viento'));
            if ($dto->getParameterValue('activo') != NULL)
                $model->setActivo($dto->getParameterValue('activo'));
            $model->setUsuario($dto->getSessionUser());

            return $model;
        }

        /**
         *
         * @param \TSLIDataTransferObj $dto
         *
         * @return EntrenadoresAtletasModel
         */
        protected function &getModelToUpdate(\TSLIDataTransferObj $dto) {
            $model = new AtletasResultadosModel();
            // Leo el id enviado en el DTO
            $model->set_atletas_resultados_id($dto->getParameterValue('atletas_resultados_id'));
            $model->set_atletas_codigo($dto->getParameterValue('atletas_codigo'));
            $model->set_competencias_pruebas_id($dto->getParameterValue('competencias_pruebas_id'));
            $model->set_postas_id($dto->getParameterValue('postas_id'));
            $model->set_atletas_resultados_resultado($dto->getParameterValue('atletas_resultados_resultado'));
            $model->set_atletas_resultados_puesto($dto->getParameterValue('atletas_resultados_puesto'));
            $model->set_atletas_resultados_puntos($dto->getParameterValue('atletas_resultados_puntos'));
            $model->set_atletas_resultados_viento($dto->getParameterValue('atletas_resultados_viento'));

            $model->setVersionId($dto->getParameterValue('versionId'));
            if ($dto->getParameterValue('activo') != NULL)
                $model->setActivo($dto->getParameterValue('activo'));
            $model->set_Usuario_mod($dto->getSessionUser());

            return $model;
        }

        /**
         *
         * @return AtletasResultadosModel
         */
        protected function &getEmptyModel() {
            $model = new AtletasResultadosModel();

            return $model;
        }

        /**
         *
         * @param \TSLIDataTransferObj $dto
         *
         * @return \TSLDataModel
         */
        protected function &getModelToDelete(\TSLIDataTransferObj $dto) {
            $model = new AtletasResultadosModel();
            $model->set_atletas_resultados_id($dto->getParameterValue('atletas_resultados_id'));
            $model->setVersionId($dto->getParameterValue('versionId'));
            $model->set_Usuario_mod($dto->getSessionUser());

            return $model;
        }

    }

?>
