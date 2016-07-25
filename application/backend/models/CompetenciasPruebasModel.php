<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo para definir las pruebas que corresponden a una competencia.
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: CompetenciasPruebasModel.php 195 2014-06-23 19:54:42Z aranape $
 * @history ''
 *
 * $Date: 2014-06-23 14:54:42 -0500 (lun, 23 jun 2014) $
 * $Rev: 195 $
 */
class CompetenciasPruebasModel extends \app\common\model\TSLAppCommonBaseModel {

    use CompetenciasPruebasModelTraits;

    protected $competencias_pruebas_protected;
    protected $competencias_pruebas_origen_id;

   /**
     * En el caso de las combinadas cada prueba tiene una prueba principal , por ejempo
     * los 110 metros con vallas son parte de la prueba heptatlon.
     *
     * @return int el id de la prueba origen de esta prueba .     *
     */
    public function get_competencias_pruebas_origen_id() {
        return $this->competencias_pruebas_origen_id;
    }

    /**
     * Se setea el id a la pruena  principal.
     * En el caso de las combinadas cada prueba tiene una prueba principal , por ejempo
     * los 110 metros con vallas son parte de la prueba heptatlon.
     *
     * @param int $competencias_pruebas_origen_id
     */
    public function set_competencias_pruebas_origen_id($competencias_pruebas_origen_id) {
        $this->competencias_pruebas_origen_id = $competencias_pruebas_origen_id;
    }

    /**
     *
     * @return boolean , true si el registro ya no es modificable.
     */
    public function get_competencias_pruebas_protected() {
        if (!isset($this->competencias_pruebas_protected)) {
            return 'false';
        }
        return $this->competencias_pruebas_protected;
    }

    /**
     * setea  true si el registro ya no es modificable, de lo contrario false.
     *
     * @param boolean $competencias_pruebas_protected
     */
    public function set_competencias_pruebas_protected($competencias_pruebas_protected) {
        $this->competencias_pruebas_protected = $competencias_pruebas_protected;
    }

    public function &getPKAsArray() {
        $pk['competencias_pruebas_id'] = $this->getId();
        return $pk;
    }

    /**
     * Indica que su pk o id es una secuencia o campo identity
     *
     * @return boolean true
     */
    public function isPKSequenceOrIdentity() {
        return true;
    }

}

?>