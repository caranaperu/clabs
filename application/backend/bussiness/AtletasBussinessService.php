<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que manipula las acciones directas a los atletas
 *  tales como listar , agregar , eliminar , etc.
 *
 * @author $Author: aranape $
 * @since 17-May-2013
 * @version $Id: AtletasBussinessService.php 82 2014-03-25 10:07:18Z aranape $
 * @history 1.01 , Se agrego soporte para foreign key
 *
 * $Date: 2014-03-25 05:07:18 -0500 (mar, 25 mar 2014) $
 * $Rev: 82 $
 */
class AtletasBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

    function __construct() {
        //    parent::__construct();
        $this->setup("AtletasDAO", "atletas", "msg_atletas");
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return AtletasModel
     */
    protected function &getModelToAdd(\TSLIDataTransferObj $dto) {
        $model = new AtletasModel();
        // Leo el id enviado en el DTO
        $model->set_atletas_codigo($dto->getParameterValue('atletas_codigo'));
        $model->set_atletas_ap_paterno($dto->getParameterValue('atletas_ap_paterno'));
        $model->set_atletas_ap_materno($dto->getParameterValue('atletas_ap_materno'));
        $model->set_atletas_nombres($dto->getParameterValue('atletas_nombres'));
        $model->set_paises_codigo($dto->getParameterValue('paises_codigo'));
        $model->set_atletas_nro_documento($dto->getParameterValue('atletas_nro_documento'));
        $model->set_atletas_nro_pasaporte($dto->getParameterValue('atletas_nro_pasaporte'));
        $model->set_atletas_fecha_nacimiento($dto->getParameterValue('atletas_fecha_nacimiento'));
        $model->set_atletas_direccion($dto->getParameterValue('atletas_direccion'));
        $model->set_atletas_telefono_casa($dto->getParameterValue('atletas_telefono_casa'));
        $model->set_atletas_telefono_celular($dto->getParameterValue('atletas_telefono_celular'));
        $model->set_atletas_email($dto->getParameterValue('atletas_email'));
        $model->set_atletas_sexo($dto->getParameterValue('atletas_sexo'));
        $model->set_atletas_observaciones($dto->getParameterValue('atletas_observaciones'));
        $model->set_atletas_talla_ropa_buzo($dto->getParameterValue('atletas_talla_ropa_buzo'));
        $model->set_atletas_talla_ropa_poloshort($dto->getParameterValue('atletas_talla_ropa_poloshort'));
        $model->set_atletas_talla_zapatillas($dto->getParameterValue('atletas_talla_zapatillas'));
        $model->set_atletas_norma_zapatillas($dto->getParameterValue('atletas_norma_zapatillas'));
        $model->set_atletas_url_foto($dto->getParameterValue('atletas_url_foto'));

        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->setUsuario($dto->getSessionUser());

        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return AtletasModel
     */
    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) {
        $model = new AtletasModel();
        // Leo el id enviado en el DTO
        $model->set_atletas_codigo($dto->getParameterValue('atletas_codigo'));
        $model->set_atletas_ap_paterno($dto->getParameterValue('atletas_ap_paterno'));
        $model->set_atletas_ap_materno($dto->getParameterValue('atletas_ap_materno'));
        $model->set_atletas_nombres($dto->getParameterValue('atletas_nombres'));
        $model->set_paises_codigo($dto->getParameterValue('paises_codigo'));
        $model->set_atletas_nro_documento($dto->getParameterValue('atletas_nro_documento'));
        $model->set_atletas_nro_pasaporte($dto->getParameterValue('atletas_nro_pasaporte'));
        $model->set_atletas_fecha_nacimiento($dto->getParameterValue('atletas_fecha_nacimiento'));
        $model->set_atletas_direccion($dto->getParameterValue('atletas_direccion'));
        $model->set_atletas_telefono_casa($dto->getParameterValue('atletas_telefono_casa'));
        $model->set_atletas_telefono_celular($dto->getParameterValue('atletas_telefono_celular'));
        $model->set_atletas_email($dto->getParameterValue('atletas_email'));
        $model->set_atletas_sexo($dto->getParameterValue('atletas_sexo'));
        $model->set_atletas_observaciones($dto->getParameterValue('atletas_observaciones'));
        $model->set_atletas_talla_ropa_buzo($dto->getParameterValue('atletas_talla_ropa_buzo'));
        $model->set_atletas_talla_ropa_poloshort($dto->getParameterValue('atletas_talla_ropa_poloshort'));
        $model->set_atletas_talla_zapatillas($dto->getParameterValue('atletas_talla_zapatillas'));
        $model->set_atletas_norma_zapatillas($dto->getParameterValue('atletas_norma_zapatillas'));
        $model->set_atletas_url_foto($dto->getParameterValue('atletas_url_foto'));

        $model->setVersionId($dto->getParameterValue('versionId'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->set_Usuario_mod($dto->getSessionUser());
        return $model;
    }

    /**
     *
     * @return AtletasModel
     */
    protected function &getEmptyModel() {
        $model = new AtletasModel();
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel
     */
    protected function &getModelToDelete(\TSLIDataTransferObj $dto) {
        $model = new AtletasModel();
        $model->set_atletas_codigo($dto->getParameterValue('atletas_codigo'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        $model->set_Usuario_mod($dto->getSessionUser());

        return $model;
    }

}

?>
