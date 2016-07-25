<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo para las postas.
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.1
 * @package SoftAthletics
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license GPL
 *
 */
class PostasModel extends \app\common\model\TSLAppCommonBaseModel {

    protected $postas_id;
    protected $postas_descripcion;
    protected $competencias_pruebas_id;

    /**
     * Setea el codigo unico de la posta..
     *
     * @param int $postas_id unique id de la posta
     */
    public function set_postas_id($postas_id) {
        $this->postas_id = $postas_id;
        $this->setId($postas_id);
    }

    /**
     * @return int retorna el unique id de la posta
     */
    public function get_postas_id() {
        return $this->postas_id;
    }

    /**
     * Setea el nombre identificatoria de la posta.
     *
     * @param string $postas_descripcion nombre de la ciudad
     */
    public function set_postas_descripcion($postas_descripcion) {
        $this->postas_descripcion = $postas_descripcion;
    }

    /**
     *
     * @return string con el nombre identificatoria de la posta.
     */
    public function get_postas_descripcion() {
        return $this->postas_descripcion;
    }

    /**
     * Retorna el id a la relacion competencia-Prueba
     *
     * @return int con el id de la competencia-prueba
     */
    public function get_competencias_pruebas_id() {
        return $this->competencias_pruebas_id;
    }

    /**
     * Setea el el id a la relacion competencia-Prueba
     *
     * @param int $competencias_pruebas_id  el id de la competencia-prueba
     */
    public function set_competencias_pruebas_id($competencias_pruebas_id) {
        $this->competencias_pruebas_id = $competencias_pruebas_id;
    }


    /**
     * @{inheritdoc}
     */
    public function &getPKAsArray() {
        $pk['postas_id'] = $this->getId();
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