<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo  para definir los tipos de  las competencias
 * LAs competencias se clasifican como mundiales,olimpiadas ,nacionales,otros.
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: CompetenciaTipoModel.php 70 2014-03-09 10:20:51Z aranape $
 * @history ''
 *
 * $Date: 2014-03-09 05:20:51 -0500 (dom, 09 mar 2014) $
 * $Rev: 70 $
 */
class CompetenciaTipoModel extends \app\common\model\TSLAppCommonBaseModel {

    protected $competencia_tipo_codigo;
    protected $competencia_tipo_descripcion;

    /**
     * Setea el codigo unico de los tipos de la competencia
     *
     * @param string $competencia_tipo_codigo codigo  unico del pais
     */
    public function set_competencia_tipo_codigo($competencia_tipo_codigo) {
        $this->competencia_tipo_codigo = $competencia_tipo_codigo;
        $this->setId($competencia_tipo_codigo);
    }

    /**
     * @return string retorna el codigo unico de los tipos de la competencia
     */
    public function get_competencia_tipo_codigo() {
        return $this->competencia_tipo_codigo;
    }

    /**
     * Setea el nombre de los tipos de la competencia
     *
     * @param string $competencia_tipo_descripcion describe el tipo de la competencia
     */
    public function set_competencia_tipo_descripcion($competencia_tipo_descripcion) {
        $this->competencia_tipo_descripcion = $competencia_tipo_descripcion;
    }

    /**
     *
     * @return string con el tipo de la competencia
     */
    public function get_competencia_tipo_descripcion() {
        return $this->competencia_tipo_descripcion;
    }


    public function &getPKAsArray() {
        $pk['competencia_tipo_codigo'] = $this->getId();
        return $pk;
    }

}

?>