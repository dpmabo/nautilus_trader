#!/usr/bin/env python3
# -------------------------------------------------------------------------------------------------
# <copyright file="data.pyx" company="Invariance Pte">
#  Copyright (C) 2018-2019 Invariance Pte. All rights reserved.
#  The use of this source code is governed by the license as found in the LICENSE.md file.
#  http://www.invariance.com
# </copyright>
# -------------------------------------------------------------------------------------------------

# cython: language_level=3, boundscheck=False

from typing import List, Dict, Callable

from cpython.datetime cimport datetime

from inv_trader.core.precondition cimport Precondition
from inv_trader.common.data cimport DataClient
from inv_trader.model.objects cimport Symbol, BarType, Instrument
from inv_trader.tools cimport BarBuilder


cdef class BacktestDataClient(DataClient):
    """
    Provides a data client for the BacktestEngine.
    """

    def __init__(self,
                 list instruments,
                 dict data):
        """
        Initializes a new instance of the BacktestDataClient class.

        :param instruments: The instruments needed for the backtest.
        :param data: The historical market data needed for the backtest.
        """
        # Check there is an instrument for each data symbol
        # Check the shape of each data symbol is equal

        # Convert instruments list to dictionary indexed by symbol
        instruments_dict = {}  # type: Dict[Symbol, Instrument]
        for instrument in instruments:
            instruments_dict[instrument.symbol] = instrument
        self._instruments = instruments_dict

        for bar_type, dataframe in data:
            self.bar_builders[bar_type] = BarBuilder(data=dataframe,
                                                     decimal_precision=instrument.tick_decimals) # type: Dict[BarType, BarBuilder]

    cpdef void connect(self):
        # Raise exception if not overridden in implementation.
        raise NotImplementedError()

    cpdef void disconnect(self):
        # Raise exception if not overridden in implementation.
        raise NotImplementedError()

    cpdef void update_all_instruments(self):
        # Raise exception if not overridden in implementation.
        raise NotImplementedError()

    cpdef void update_instrument(self, Symbol symbol):
        # Raise exception if not overridden in implementation.
        raise NotImplementedError()

    cpdef void historical_bars(
            self,
            BarType bar_type,
            int quantity,
            handler: Callable):
        """
        Download the historical bars for the given parameters from the data
        service, then pass them to the callable bar handler.

        :param bar_type: The historical bar type to download.
        :param quantity: The number of historical bars to download (can be None, will download all).
        :param handler: The bar handler to pass the bars to.
        :raises ValueError: If the quantity is not None and not positive (> 0).
        """
        Precondition.true(bar_type in self.bar_builders, 'bar_type in self.bar_builders')

        cdef BarBuilder bar_builder = self.bar_builders[bar_type]
        cdef list bars = []


        self._log.info(f"Historical download of {len(bars)} bars for {bar_type} complete.")

        for bar in bars:
            handler(bar_type, bar)
        self._log.debug(f"Historical bars hydrated to handler {handler}.")

    cpdef void historical_bars_from(
            self,
            BarType bar_type,
            datetime from_datetime,
            handler: Callable):
        """
        Download the historical bars for the given parameters from the data
        service, then pass them to the callable bar handler.

        :param bar_type: The historical bar type to download.
        :param from_datetime: The datetime from which the historical bars should be downloaded.
        :param handler: The handler to pass the bars to.
        :raises ValueError: If the from_datetime is not less than datetime.utcnow().
        """
        # Raise exception if not overridden in implementation.
        raise NotImplementedError("Method must be implemented in the data client.")