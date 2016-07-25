<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo para definir las lineaas de relacion entrenadores y atletas
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: EntrenadoresAtletasModel.php 39 2014-02-16 09:46:39Z aranape $
 * @history ''
 *
 * $Date: 2014-02-16 04:46:39 -0500 (dom, 16 feb 2014) $
 * $Rev: 39 $
 */
class EntrenadoresAtletasModel extends \app\common\model\TSLAppCommonBaseModel {

    protected $entrenadoresatletas_id;
    protected $entrenadores_codigo;
    protected $atletas_codigo;
    protected $entrenadoresatletas_desde;
    protected $entrenadoresatletas_hasta;

    /**
     * Setea el id unico de la relacion entrenadores-atletas
     *
     * @param integer $entrenadoresatletas_id unico de la relacion entrenadores-atletas
     */
    public function set_entrenadoresatletas_id($entrenadoresatletas_id) {
        $this->entrenadoresatletas_id = $entrenadoresatletas_id;
        $this->setId($entrenadoresatletas_id);
    }

    /**
     * @return integer retorna el id unico de la relacion entrenadores-atletas
     */
    public function get_entrenadoresatletas_id() {
        return $this->entrenadoresatletas_id;
    }

    /**
     * Setea el codigo del entrenador a relacionar
     *
     * @param string $entrenadores_codigo codigo del entrenador
     */
    public function set_entrenadores_codigo($entrenadores_codigo) {
        $this->entrenadores_codigo = $entrenadores_codigo;
    }

    /**
     *
     * @return string con el codigo del entrenador
     */
    public function get_entrenadores_codigo() {
        return $this->entrenadores_codigo;
    }

    /**
     *
     * @return string con el codigo del atleta a relacionar con un entrenador
     */
    public function get_atletas_codigo() {
        return $this->atletas_codigo;
    }

    /**
     * Setea el codigo del atleta a relacionar con un entrenador
     *
     * @param string $atletas_codigo
     */
    public function set_atletas_codigo($atletas_codigo) {
        $this->atletas_codigo = $atletas_codigo;
    }

    /**
     *
     * @return string que representa la fecha desde que el atleta
     * se asocia al entrenador. (no es la fecha de ingreso al sistema)
     */
    public function get_entrenadoresatletas_desde() {
        return $this->entrenadoresatletas_desde;
    }

    /**
     * Setea la fecha desde que el atleta se asocia al entrenador.
     * (no es la fecha de ingreso al sistema)
     *
     * @param string $entrenadoresatletas_desde la fecha en string convertible a date.
     */
    public function set_entrenadoresatletas_desde($entrenadoresatletas_desde) {
        $this->entrenadoresatletas_desde = $entrenadoresatletas_desde;
    }

    /**
     *
     * @return string que representa la fecha hasta la cual el atleta
     * estuvo asociado al entrenador.
     */
    public function get_entrenadoresatletas_hasta() {
        return $this->entrenadoresatletas_hasta;
    }

    /**
     * Setea la fecha hasta la cual el atleta
     * estuvo asociado al entrenador.
     *
     * @param string $entrenadoresatletas_hasta la fecha en string convertible a date.
     */
    public function set_entrenadoresatletas_hasta($entrenadoresatletas_hasta) {
        $this->entrenadoresatletas_hasta = $entrenadoresatletas_hasta;
    }

    public function &getPKAsArray() {
        $pk['entrenadoresatletas_id'] = $this->getId();
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