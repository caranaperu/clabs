<?php

namespace app\common\model\impl;

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo para los sistemas que componen una aplicacion.
 *
 * @author $Author: aranape $
 * @version $Id: TSLAppSistemasModel.php 4 2014-02-11 03:31:42Z aranape $
 * @history , ''
 *
 * $Rev: 4 $
 * $Date: 2014-02-10 22:31:42 -0500 (lun, 10 feb 2014) $
 */
class TSLAppSistemasModel extends \app\common\model\TSLAppCommonBaseModel {

    protected $sys_systemcode;
    protected $sys_sistema_descripcion;

    /**
     *
     * @return string con el identificador unico de la aplicacion
     */
    public function get_sys_systemcode() {
        return $this->sys_systemcode;
    }

    /**
     * Setea el identificador unico del sistema.
     *
     * @param string $sys_systemcode
     */
    public function set_sys_systemcode($sys_systemcode) {
        $this->sys_systemcode = $sys_systemcode;
    }


    public function get_sys_sistema_descripcion() {
        return $this->sys_sistema_descripcion;
    }


    public function set_sys_sistema_descripcion($sys_sistema_descripcion) {
        $this->sys_sistema_descripcion = $sys_sistema_descripcion;
    }


    public function &getPKAsArray() {
        $pk['sys_systemcode'] = $this->getId();
        return $pk;
    }

}

?>