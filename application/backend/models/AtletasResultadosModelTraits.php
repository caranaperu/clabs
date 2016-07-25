<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Dado que se requiere la parte de los resultados de pruebas en mas de una clase
 * es conveniente implementarlo como trait y luego anexarlo a las clases que lo requieren.
 *
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: AtletasResultadosModelTraits.php 195 2014-06-23 19:54:42Z aranape $
 * @history ''
 *
 * $Date: 2014-06-23 14:54:42 -0500 (lun, 23 jun 2014) $
 * $Rev: 195 $
 */
trait AtletasResultadosModelTraits  {

    protected $atletas_resultados_id;
    protected $atletas_codigo;
    protected $atletas_resultados_resultado;
    protected $atletas_resultados_puntos;
    protected $atletas_resultados_puesto;
    protected $atletas_resultados_viento;
    protected $atletas_resultados_protected;


    /**
     * Setea el id unico de la relacion resultados-atletas
     *
     * @param integer $atletas_resultados_id unico de la relacion resultados-atletas
     */
    public function set_atletas_resultados_id($atletas_resultados_id) {
        $this->atletas_resultados_id = $atletas_resultados_id;
        $this->setId($atletas_resultados_id);
    }

    /**
     * @return integer retorna el id unico de la relacion resultados-atletas
     */
    public function get_atletas_resultados_id() {
        return $this->atletas_resultados_id;
    }

    /**
     *
     * @return string con el codigo del atleta a relacionar con un resultado
     */
    public function get_atletas_codigo() {
        return $this->atletas_codigo;
    }

    /**
     * Setea el codigo del atleta a relacionar con un resultado
     *
     * @param string $atletas_codigo
     */
    public function set_atletas_codigo($atletas_codigo) {
        $this->atletas_codigo = $atletas_codigo;
    }


    /**
     *
     * @return string el resultado de la prueba
     */
    public function get_atletas_resultados_resultado() {
        return $this->atletas_resultados_resultado;
    }

    /**
     * Setea el resultado de la prueba. POr ahora es un string formateado
     * o validado por una expresion regular, esto dado que para diferentes
     * pruebas el formato del resultado es diferente
     *
     * @param string $atletas_resultados_resultado
     */
    public function set_atletas_resultados_resultado($atletas_resultados_resultado) {
        $this->atletas_resultados_resultado = $atletas_resultados_resultado;
    }

    /**
     * Las pruebas multiples o combinadas tienen un puntaje por cada
     * resultado de prueba.
     *
     * @return integer con los puntosotorgados en la prueba
     */
    public function get_atletas_resultados_puntos() {
        return $this->atletas_resultados_puntos;
    }

    /**
     * Setea el puntaje otorgado a la prueba , dado que las pruebas multiples o
     * combinadas tienen un puntaje por cada resultado de prueba.
     *
     * @param integer $atletas_resultados_puntos
     */
    public function set_atletas_resultados_puntos($atletas_resultados_puntos) {
        $this->atletas_resultados_puntos = $atletas_resultados_puntos;
    }

        /**
     *
     * @return int con puesto en que termino la prueba
     */
    public function get_atletas_resultados_puesto() {
        if (!isset($this->atletas_resultados_puesto)) {
            return null;
        }
        return $this->atletas_resultados_puesto;
    }

    /**
     * indica en que puesto termino dentro de la prueba.
     *
     * @param int $atletas_resultados_puesto puesto en que termino la prueba
     */
    public function set_atletas_resultados_puesto($atletas_resultados_puesto) {
        $this->atletas_resultados_puesto = $atletas_resultados_puesto;
    }

    /**
     * Retorna el viento existente en el resultado de la prueba,
     *
     * @return int El viento durante la ejecucion de la prueba,
     */
    public function get_atletas_resultados_viento() {
        return $this->atletas_resultados_viento;
    }

    /**
     * Setea el viento existente en el resultado de la prueba,
     * Hay que aclarar que si bien es cierto la prueba computa un viento
     * para los casos especificos de pruebas como salto largo/triple el viento
     * es individual a cada salto por ende no puede computarse como un global
     * a la prueba sino para cada salto.
     *
     * @param int $atletas_resultados_viento El viento con que se ejectuo, null o cero
     * de no ser necesario (caso que el viento es global a la prueba).
     */
    public function set_atletas_resultados_viento($atletas_resultados_viento) {
        $this->atletas_resultados_viento = $atletas_resultados_viento;
    }

        /**
     *
     * @return boolean , true si el registro ya no es modificable.
     */
    public function get_atletas_resultados_protected() {
        if (!isset($this->atletas_resultados_protected)) {
            return 'false';
        }
        return $this->atletas_resultados_protected;
    }

    /**
     * setea  true si el registro ya no es modificable, de lo contrario false.
     *
     * @param boolean $atletas_resultados_protected
     */
    public function set_atletas_resultados_protected($atletas_resultados_protected) {
        $this->atletas_resultados_protected = $atletas_resultados_protected;
    }

}

?>