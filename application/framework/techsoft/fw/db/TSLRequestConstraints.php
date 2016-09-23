<?php

/**
 * Esta clase define los constraints que pueden usarse
 * para acceder a un query en la base de datos , define
 * al menos los minimos conocidos pudiendo agregarse mas
 * los cuales seran de interpretacion por las clases.
 *
 * Por ahora solo acepta busqueda parcial o exacta, soporta ademas
 * multiples campos con diferentes tipos de busqueda cada una.
 *
 * @author Carlos Arana Reategui
 * @since 19-Sep-2011
 *
 * Cambios : 16-Jul-2016
 *  Soporte  para filtros de mayor , mayor o igual , menor y menor o igual.
 */
class TSLRequestConstraints {

    // Contantes de filtro
    private static $_FILTER_EXACT = 'exact';
    private static $_FILTER_PARTIAL = 'partial';
    private static $_FILTER_GREATERTHAN = 'greaterThan';
    private static $_FILTER_LESSTHAN = 'lessThan';
    private static $_FILTER_GREATEROREQUAL = 'greaterOrEqual';
    private static $_FILTER_LESSOREQUAL = 'lessOrEqual';

    private $currentPage = -1;
    private $recordsPerPage = -1;
    private $startRow = 0;
    private $endRow = 0;
    private $sortFields = null;
    private $listFields = null;
    private $filterFields = null;
    private $otherParams = null; // Especiales o especificos a una determinada operacion.

    /**
     * Retorna el numero actual de pagina a procesar, habitualmente
     * para solicitudes de listas paginadas.
     *
     * @return int con el numero actual de pagina a leer
     */

    public function getCurrentPage() {
        return $this->currentPage;
    }

    /**
     * Setea el numero de pagina a procesar.
     *
     * @param int $currentPage
     */
    public function setCurrentPage($currentPage) {
        $this->currentPage = $currentPage;
    }

    /**
     * Retorna el numero de registros a devolver por pagina,
     * habitualmente para el paginado de listas.
     *
     * @return int el numero de registros x pagina.
     */
    public function getRecordsPerPage() {
        return $this->recordsPerPage;
    }

    /**
     * Setea el numero de registros a devolver por pagina,
     * habitualmente para el paginado de listas.
     *
     * @param int $recordsPerPage
     */
    public function setRecordsPerPage($recordsPerPage) {
        $this->recordsPerPage = $recordsPerPage;
    }

    /**
     * Retorna un arreglo con los campos a usarse en el sort
     * se usara el orden de entrada al arreglo.
     *
     * @return array con la lista de campos a uasrse en el sorteo.
     */
    public function getSortFields() {
        return $this->sortFields;
    }

    /**
     * Se envia un arreglo de los campos a usarse
     * para el sort.
     *
     * @param array $sortFields
     */
    public function setSortFields(array $sortFields) {
        $this->sortFields = $sortFields;
    }

    /**
     * Retorna un arreglo con los campos listarse
     * en el select.
     *
     * @return array con la lista de campos.
     */
    public function getListFields() {
        return $this->listFields;
    }

    /**
     * Se envia un arreglo con la lista de campos a usarse
     * en el select.
     *
     * @param array $listFields
     */
    public function setListFields(array $listFields) {
        $this->listFields = $listFields;
    }

    /*     * *
     * Parametros Opcionales
     */

    /**
     * Agrega un parametro a usarse por el query
     * estos seran interpretados por contexto.
     *
     * @param String $parameterName nombre del parametro
     * @param mixed valor del parametro.
     */
    public function addParameter($parameterName, $value) {
        if ($this->otherParams == null) {
            $this->otherParams = array();
        }
        $this->otherParams[$parameterName] = $value;
    }

    /**
     * Retorna el valor de un parametro , si no esta definido
     * retorna null.
     *
     * @param string $parameterName nombnre del parametor
     * @return mixed valor del parametro o null si no existe.
     */
    public function getParameter($parameterName) {
        if ($this->otherParams == null) {
            return NULL;
        }

        if (!isset($this->otherParams[$parameterName])) {
            return NULL;
        } else {
            return $this->otherParams[$parameterName];
        }
    }

    /**
     * Retorna la primera fila dentro del resulset total
     * que se tomara en cuenta.
     *
     * @return long
     */
    public function getStartRow() {
        return $this->startRow;
    }

    /**
     * Setea la primera fila dentro del resulset total
     * que se tomara en cuenta.
     *
     * @param long $startRow el numero de fila
     */
    public function setStartRow($startRow) {
        $this->startRow = $startRow;
    }

    /**
     * Retorna la ultima fila dentro del resulset total
     * que se tomara en cuenta.
     *
     * @return long
     */
    public function getEndRow() {
        return $this->endRow;
    }

    /**
     * Setea la ultima fila dentro del resulset total
     * que se tomara en cuenta.
     *
     * @param long $endRow el numero de fila
     */
    public function setEndRow($endRow) {
        $this->endRow = $endRow;
    }

    /**
     * Retorna un arreglo con los campos a usarse en filtro
     * para el where.
     *
     * @return array con la lista de campos a uasrse en el filtro.
     */
    public function getFilterFields() {
        return $this->filterFields;
    }

    /**
     * Se envia un arreglo de los campos a usarse
     * para filtro del where.
     *
     * @param array $sortFields
     */
    public function setFilterFields(array $filterFields) {
        $this->filterFields = $filterFields;
    }

    /**
     * Retorna un camo de filtro basado en su nombre,
     * de no existir retorna NULL.
     * Esta funcion es util cuando se necesitan los campos para ser
     * usados fuera del filtro.
     *
     * @return mixed con el valor del campo de filtro.
     */
    public function getFilterField($fieldName) {
        if ($this->filterFields == null || !isset($this->filterFields[$fieldName])) {
            return NULL;
        }
        return $this->filterFields[$fieldName];
    }

    /**
     * Elimina un campo de filtro , esto es util cuando el campo
     * es usado no en el filtro , por lo que se captura y elimina para
     * que posteriormente el filtro no lo use.
     *
     * @param string $fieldName con el nombre del campo
     */
    public function removeFilterField($fieldName) {
        if ($this->filterFields != null) {
            if (isset($this->filterFields[$fieldName])) {
                unset($this->filterFields[$fieldName]);
            }
        }
    }

    /*     * *
     * HELPERS
     */

    /**
     * Agrega un campo de sort a la lista a usarse
     * @param String $sortField nomnbre del campo
     * @param String $direction ASC o DESC , si no esta definido sera ASC
     */
    public function addSortField($sortField, $direction) {
        if ($this->sortFields == null) {
            $this->sortFields = array();
        }
        if (isset($sortField)) {
            // Si no se define la direccion del sor se pone ASC como default
            if (strcasecmp($direction, 'asc') != 0 && strcasecmp($direction, 'desc') != 0) {
                $this->sortFields[$sortField] = 'ASC';
            } else {
                $this->sortFields[$sortField] = $direction;
            }
        }
    }

    /**
     * Agrega un campo a la lista de campos que conforma el select
     *
     * @param String $listField momnbre del campo a agregar
     */
    public function addListField($listField) {
        if ($this->listFields == null) {
            $this->listFields = array();
        }
        $this->listFields[] = $listField;
    }

    /**
     * Devuelve una lista de los campos de sorteo separada por comas incluyendo la direccion
     * del sort.
     */
    public function getSortFieldsAsString() {
        if (is_array($this->sortFields) && count($this->sortFields) > 0) {
            $str = '';
            foreach ($this->sortFields as $field => $direction) {
                $str .= $field . ' ' . $direction . ',';
            }
            if (strlen($str) > 0) {
                $str = rtrim($str, ',');
            }
            return $str;
        } else {
            return NULL;
        }
    }

    /**
     * Devuelve una lista de los campos a recoger en el select deparados por comas
     */
    public function getListFieldsAsString() {
        if (is_array($this->listFields) && count($this->listFields) > 0) {
            $str = '';
            foreach ($this->listFields as $value) {
                $str .= $value . ",";
            }
            if (strlen($str) > 0) {
                $str = rtrim($str, ',');
            }
            return $str;
        } else
            return '*';
    }

    /**
     * Devuelve un string adecuado para el where basado en los constraints
     * y si el filtro es exacto o parcial enn cuyo caso se usara like.
     * Esta funcion en esta primera version solo soporta el operador "and"
     * de ser necesario se implementara otros casos
     */
    public function getFilterFieldsAsString() {
        if (is_array($this->filterFields) && count($this->filterFields) > 0) {
            $str = '';
            foreach ($this->filterFields as $field => $value) {
                // Se retiran los que no son camopos reales , tienen Type  la pabra virt_
                // que son campos virtuales.
                if (substr($field, -4) === 'Type' or substr($field, 0, 5) === 'virt_') {
                    continue;
                }
                // Para un query las bases de datos entienden mejor de esta manera.
                if (is_bool($value)) {
                    if ($value == TRUE) {
                        $value = 'T';
                    } else {
                        $value = 'F';
                    }
                }

                if ($this->filterFields[$field . 'Type'] == TSLRequestConstraints::$_FILTER_EXACT) {
                    if ($str === '') {
                        $str .= ' "' . $field . '" =\'' . $value . '\'';
                    } else {
                        $str .= ' and "' . $field . '" =\'' . $value . '\' ';
                    }
                } else if ($this->filterFields[$field . 'Type'] == TSLRequestConstraints::$_FILTER_GREATERTHAN) {
                    if ($str === '') {
                        $str .= ' "' . $field . '" >\'' . $value . '\'';
                    } else {
                        $str .= ' and "' . $field . '" >\'' . $value . '\' ';
                    }
                } else if ($this->filterFields[$field . 'Type'] == TSLRequestConstraints::$_FILTER_LESSTHAN) {
                    if ($str === '') {
                        $str .= ' "' . $field . '" <\'' . $value . '\'';
                    } else {
                        $str .= ' and "' . $field . '" <\'' . $value . '\' ';
                    }
                } else if ($this->filterFields[$field . 'Type'] == TSLRequestConstraints::$_FILTER_GREATEROREQUAL) {
                    if ($str === '') {
                        $str .= ' "' . $field . '" >=\'' . $value . '\'';
                    } else {
                        $str .= ' and "' . $field . '" >=\'' . $value . '\' ';
                    }
                } else if ($this->filterFields[$field . 'Type'] == TSLRequestConstraints::$_FILTER_LESSOREQUAL) {
                    if ($str === '') {
                        $str .= ' "' . $field . '" <=\'' . $value . '\'';
                    } else {
                        $str .= ' and "' . $field . '" <=\'' . $value . '\' ';
                    }
                } else {
                    if ($str === '') {
                        $str .= ' "' . $field . '" like \'%' . $value . '%\'';
                    } else {
                        $str .= ' and "' . $field . '" like \'%' . $value . '%\' ';
                    }
                }
            }
            if (strlen($str) > 0) {
                $str = rtrim($str, ',');
            }
            return $str;
        } else
            return '';
    }

    /**
     * Agrega un campo de filtro a la lista a usarse
     * @param String $filterField nomnbre del campo
     * @param Mixed $filterValue valor del campo
     * @param String $typeFilter exact - exacto o substring - parcial
     * estos valores son para el SmartClient otras librerias pudieran
     * usar otros casos para lo mismo.
     */
    public function addFilterField($filterField, $filterValue, $typeFilter='exact') {
        if ($this->filterFields == null) {
            $this->filterFields = array();
        }
        if (isset($filterField)) {
            $this->filterFields[$filterField] = $filterValue;
            // Por ahora se soporta exact y parcial
            if (strcasecmp($typeFilter, 'exact') == 0 || strcasecmp($typeFilter, 'equals') == 0) {
                $this->filterFields[$filterField . 'Type'] = TSLRequestConstraints::$_FILTER_EXACT;
            } else if (strcasecmp($typeFilter, 'greaterThan') == 0 ) {
                $this->filterFields[$filterField . 'Type'] = TSLRequestConstraints::$_FILTER_GREATERTHAN;
            } else if (strcasecmp($typeFilter, 'lessThan') == 0 ) {
                $this->filterFields[$filterField . 'Type'] = TSLRequestConstraints::$_FILTER_LESSTHAN;
            } else if (strcasecmp($typeFilter, 'greaterOrEqual') == 0 ) {
                $this->filterFields[$filterField . 'Type'] = TSLRequestConstraints::$_FILTER_GREATEROREQUAL;
            } else if (strcasecmp($typeFilter, 'lessOrEqual') == 0 ) {
                $this->filterFields[$filterField . 'Type'] = TSLRequestConstraints::$_FILTER_LESSOREQUAL;
            } else {
                $this->filterFields[$filterField . 'Type'] = TSLRequestConstraints::$_FILTER_PARTIAL;
            }
        }
    }

}

?>
