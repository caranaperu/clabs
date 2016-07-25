<?php

namespace app\common\model\impl;

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo para los perfiles de los sistemas , este modelo representa
 * en realidad el header del perfil.
 *
 * @author $Author: aranape $
 * @version $Id: TSLAppPerfilModel.php 4 2014-02-11 03:31:42Z aranape $
 * @history , ''
 *
 * $Rev: 4 $
 * $Date: 2014-02-10 22:31:42 -0500 (lun, 10 feb 2014) $
 */
class TSLAppPerfilModel extends \app\common\model\TSLAppCommonBaseModel {

    protected $sys_systemcode;
    protected $perfil_codigo;
    protected $perfil_descripcion;
    protected $perfil_id;

    public function get_perfil_id() {
        return $this->perfil_id;
    }

    public function set_perfil_id($perfil_id) {
        $this->perfil_id = $perfil_id;
        $this->setId($perfil_id);
    }

    /**
     * Para soportar una sola tabla para muultiples sistemas , cada entrada
     * de perfil (header) debe infdicar a que sistema pertene.
     *
     * @param string $sys_systemcode con el identificador unico del sistema
     */
    public function set_sys_systemcode($sys_systemcode) {
        $this->sys_systemcode = $sys_systemcode;
    }

    /**
     *
     * @return string con el identificador de sistema
     */
    public function get_sys_systemcode() {
        return $this->sys_systemcode;
    }

    /**
     * Retorna el codigo que identifica a perfil
     *
     * @return String con el codigo.
     */
    public function get_perfil_codigo() {
        return $this->perfil_codigo;
    }

    /**
     * Setea el codigo que identifica el perfil
     * en este caso es tambien el unique key o id.
     * @param String $perfil_codigo con el codigo del perfil.
     */
    public function set_perfil_codigo($perfil_codigo) {
        // El codigo es tratado como id.
        $this->perfil_codigo = $perfil_codigo;
    }

    public function get_perfil_descripcion() {
        return $this->perfil_descripcion;
    }

    public function set_perfil_descripcion($perfil_descripcion) {
        $this->perfil_descripcion = $perfil_descripcion;
    }

    public function &getPKAsArray() {
        $pk['perfil_id'] = $this->getId();
        return $pk;
    }

    public function isPKSequenceOrIdentity() {
        return true;
    }

}

?>